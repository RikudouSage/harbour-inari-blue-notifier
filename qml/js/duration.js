function convertToMs(value) {
    return value / 1000000;
}

function convertToLocale(value) {
    return String(value).replace(".", Qt.locale().decimalPoint);
}
