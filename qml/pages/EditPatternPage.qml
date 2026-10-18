import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"
import "../js/colors.js" as Colors
import "../js/duration.js" as Duration

Dialog {
    readonly property var existingNames: appSettings.storedPatterns.map(function(pattern) {
        return pattern.name;
    }).filter(function(name) {
        return name !== originalName;
    });
    property string originalName
    property var pattern: ({name: '', rise: 0, hold: 0, decay: 0, off: 0, delay: 0, repeat: 0, brightness: 255, channels: []})
    property bool lightOnOnlyMode: pattern.hold === -1

    id: page

    function enableLightOnOnlyMode() {
        const newPattern = {
            name: pattern.name,
            rise: 0,
            hold: -1,
            decay: 0,
            off: 0,
            delay: 0,
            repeat: 0,
            brightness: pattern.brightness,
            channels: pattern.channels,
        };
        pattern = newPattern;
    }

    function disableLightOnOnlyMode() {
        const newPattern = pattern;
        newPattern.hold = 0;
        pattern = newPattern;
    }

    canAccept: nameField.text !== ''
                && riseField.acceptableInput
                && holdField.acceptableInput
                && decayField.acceptableInput
                && offField.acceptableInput
                && delayField.acceptableInput

    onRejected: daemon.stopPlaying();
    onAccepted: daemon.stopPlaying();

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            spacing: Theme.paddingLarge
            width: page.width

            DialogHeader {
                //% "Save"
                acceptText: qsTrId("app.save")
            }

            TextField {
                id: nameField
                //% "Name"
                label: qsTrId("edit_pattern.name") + "*"
                text: pattern.name
                onTextChanged: pattern.name = text
            }
            StandardLabel {
                visible: existingNames.indexOf(nameField.text) > -1
                //% "Warning: A pattern with that name already exists, if you save it you will overwrite the existing pattern."
                text: qsTrId("edit_pattern.warning_name")
                color: Theme.errorColor
            }

            TextSwitch {
                //% "Light only"
                text: qsTrId("edit_pattern.light_only_mode")
                //% "Instead of playing a pattern, the LED will stay on indefinitely."
                description: qsTrId("edit_pattern.light_only_mode.description")
                checked: lightOnOnlyMode
                automaticCheck: false

                onClicked: {
                    const targetChecked = !checked;
                    if (targetChecked) {
                        enableLightOnOnlyMode();
                    } else {
                        disableLightOnOnlyMode();
                    }
                }
            }

            DurationInput {
                id: riseField
                //% "Fade-in duration (ms)"
                label: qsTrId("edit_pattern.rise")
                text: Duration.convertToLocale(Duration.convertToMs(pattern.rise))
                onValidValueChanged: pattern.rise = value
                enabled: !lightOnOnlyMode
            }

            DurationInput {
                id: holdField
                //% "On duration (ms)"
                label: qsTrId("edit_pattern.hold")
                text: Duration.convertToLocale(Duration.convertToMs(pattern.hold))
                minValue: -0.000001
                onValidValueChanged: pattern.hold = value
                enabled: !lightOnOnlyMode
            }

            DurationInput {
                id: decayField
                //% "Fade-out duration (ms)"
                label: qsTrId("edit_pattern.decay")
                text: Duration.convertToLocale(Duration.convertToMs(pattern.decay))
                onValidValueChanged: pattern.decay = value
                enabled: !lightOnOnlyMode
            }

            DurationInput {
                id: offField
                //% "Off duration (ms)"
                label: qsTrId("edit_pattern.off")
                text: Duration.convertToLocale(Duration.convertToMs(pattern.off))
                onValidValueChanged: pattern.off = value
                enabled: !lightOnOnlyMode
            }

            DurationInput {
                id: delayField
                //% "Start delay (ms)"
                label: qsTrId("edit_pattern.delay")
                text: Duration.convertToLocale(Duration.convertToMs(pattern.delay))
                onValidValueChanged: pattern.delay = value
                enabled: !lightOnOnlyMode
            }

            Slider {
                id: repeatField
                //% "Repeat count"
                label: qsTrId("edit_pattern.repeat")
                width: parent.width
                minimumValue: 0
                maximumValue: 15
                stepSize: 1
                value: pattern.repeat
                valueText: value === 0 ? '∞' : value + "×"
                onValueChanged: pattern.repeat = value
                enabled: !lightOnOnlyMode
            }

            Slider {
                id: brightnessField
                //% "Brightness"
                label: qsTrId("edit_pattern.brightness")
                width: parent.width
                minimumValue: 0
                maximumValue: 100
                stepSize: 1
                value: Math.round((pattern.brightness / 255) * 100);
                valueText: value + "%"
                onValueChanged: pattern.brightness = Math.round(Math.max(0, Math.min(100, value)) / 100 * 255);
            }

            SectionHeader {
                //: The LED channels that will be used in the pattern
                //% "Channels"
                text: qsTrId("edit_pattern.channels")
            }

            TextSwitch {
                id: allChannelsSwitch
                //% "All channels"
                text: qsTrId("edit_pattern.all_channels")

                onCheckedChanged: {
                    if (checked) {
                        pattern.channels = [];
                    } else {
                        pattern.channels = [0, 1, 2];
                    }

                    // do not remove, this needs to be here
                    pattern = pattern
                }
            }

            Repeater {
                model: [0, 1, 2]

                TextSwitch {
                    //: The index of the channel
                    //% "Channel #%1"
                    text: qsTrId("edit_pattern.channel").arg(modelData)
                    enabled: !allChannelsSwitch.checked
                    checked: pattern.channels ? pattern.channels.indexOf(modelData) > -1 : false
                    onCheckedChanged: {
                        if (checked) {
                            if (pattern.channels.indexOf(modelData) === -1) {
                                pattern.channels.push(modelData);
                            }
                        } else {
                            pattern.channels = pattern.channels.filter(function(channelNo) {
                                return channelNo !== modelData;
                            });
                        }

                        // do not remove, this needs to be here
                        pattern = pattern
                    }
                }
            }

            ListItem {
                id: previewItem
                width: parent.width
                contentHeight: Theme.itemSizeMedium
                property bool playing: false

                function togglePlayback() {
                    playing = !playing

                    if (playing) {
                        daemon.playPattern(pattern)
                    } else {
                        daemon.stopPlaying()
                    }
                }

                Row {
                    anchors.centerIn: parent
                    spacing: Theme.paddingMedium

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        //% "Preview"
                        text: qsTrId("edit_pattern.preview")
                        font.pixelSize: Theme.fontSizeLarge
                    }

                    IconButton {
                        id: previewButton
                        icon.source: previewItem.playing
                                     ? "image://theme/icon-m-stop"
                                     : "image://theme/icon-m-play"
                        onClicked: previewItem.togglePlayback()
                    }
                }

                onClicked: togglePlayback()
            }
        }
    }

    Component.onCompleted: {
        if (pattern.name) {
            originalName = pattern.name;
        }
        if (typeof pattern.channels === 'undefined') {
            pattern.channels = [];
        }
        // needs to be here to prevent parameter binding
        if (pattern.channels.length === 0) {
            allChannelsSwitch.checked = true;
        }
    }
}
