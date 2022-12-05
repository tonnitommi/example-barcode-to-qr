*** Settings ***
Library             RPA.Browser.Selenium
Library             converter
Library             RPA.PDF
Library             String
Library             RPA.Tables
Library             Collections

*** Variables ***
${WEBSITE}                      https://www.upcitemdb.com/upc/041244600533
${LOCATOR_TABLE_ROWS}           //*[@id="info"]/table/tbody/tr
${LOCATOR_BARCODE}              //tr[td[text()='EAN-13:']]/td[2]

*** Tasks ***
Extract site data
    # Selenium version is needed later for find operations.
    ${sversion}=    Evaluate    selenium.__version__.split(".")[0]    modules=selenium
    Set Task Variable    ${SELENIUM_VERSION}    ${sversion}
    Log To Console    \nRunning on Selenium ${SELENIUM_VERSION}\n

    Open Available Browser    ${WEBSITE}

    # Action: open site and convert barcode to QR and store locally.
    Barcodes to QR

    # Action: extract table data
    ${all_rows}=    Get table data from a webpage
    ${table}=    Create Table    ${all_rows}
    Log    ${all_rows}

*** Keywords ***
Barcodes to QR
    [Documentation]    Reads the EAN-13 code from a fixed locator location defined by the
    ...                variable LOCATOR_BARCODE and converts it to a QR code using qrcode
    ...                library wrapped a in Python method. The QR code is then stored locally.
    ...                Proposed improvements: read the entire data table first and find the row
    ...                with EAN-13 anywhere from the table.
    ${EAN13}=  Get Text  ${LOCATOR_BARCODE}
    Create Qrcode    output/qr.png      ${EAN13}

Get table data from a webpage
    [Documentation]    Reads the table data from a fixed locator location defined by the
    ...                variable LOCATOR_TABLE_ROWS and returns a list of lists.
    ${table_rows}=    Get WebElements    ${LOCATOR_TABLE_ROWS}
    ${rows}=    Create List
    FOR    ${row}    IN    @{table_rows}
        ${cells}=    Find by tag name    ${row}    td
        ${cell_contents}=    Create List

        FOR    ${cell}    IN    @{cells}
            ${cell_text}=    Evaluate    $cell.text.strip()
            Append To List    ${cell_contents}    ${cell_text}
        END
        Append To List    ${rows}    ${cell_contents}
    END
    RETURN    ${rows}

Find by tag name
    [Arguments]    ${element}    ${tagname}
    IF    "${SELENIUM_VERSION}" == "3"
        ${links}=    Evaluate    $element.find_elements_by_tag_name("${tagname}")
    ELSE
        ${links}=    Evaluate    $element.find_elements("tag name", "${tagname}")
    END
    RETURN    ${links}