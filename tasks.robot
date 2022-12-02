*** Settings ***
Documentation       Template robot main suite.
Library             RPA.Browser
Library             converter

*** Tasks ***
Barcodes to QR
    Open Available Browser    https://www.upcitemdb.com/upc/041244600533
    ${EAN13}=  Get Text  //tr[td[text()='EAN-13:']]/td[2]

    create_qr_code    output/qr.png      ${EAN13}

