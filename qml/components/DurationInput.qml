import QtQuick 2.0
import Sailfish.Silica 1.0

TextField {
    readonly property real maxValue: 7031250000 / 1000000;
    signal validValueChanged(real value);

    function convertToNs(value) {
        return value * 1000000;
    }

    onTextChanged: {
        if (acceptableInput) {
            validValueChanged(convertToNs(Number(text.replace(/,/g, "."))));
        }
    }
    inputMethodHints: Qt.ImhFormattedNumbersOnly
    validator: DoubleValidator {
        bottom: 0
        top: maxValue
        decimals: 6
        notation: DoubleValidator.StandardNotation
    }
}
