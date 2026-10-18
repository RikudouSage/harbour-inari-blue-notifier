import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"
import "../js/duration.js" as Duration

Page {
    property bool initialized: false
    property string errorText

    id: page

    function updateKnock(propName, value) {
        if (!initialized) {
            return;
        }

        const knock = appSettings.knock;
        knock[propName] = value;
        appSettings.knock = knock;
        app.serviceNeedsRestart = true;
    }

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            spacing: Theme.paddingLarge
            width: page.width

            PageHeader {
                //% "Knock"
                title: qsTrId("knock.title")
            }

            ServiceRestartNotice {
                visible: app.serviceNeedsRestart
            }

            StandardLabel {
                //% "Knock makes it possible to listen on a port of your choosing over either tcp, udp or both and play a pattern whenever any connection to that port is made."
                text: qsTrId("knock.description")
            }

            SectionHeader {
                //% "Settings"
                text: qsTrId("knock.settings")
            }

            StandardLabel {
                text: errorText
                visible: errorText.length > 0
                color: Theme.errorColor
            }

            TextSwitch {
                //% "Enabled"
                text: qsTrId("knock.enabled")
                checked: appSettings.knock.enabled
                automaticCheck: false
                onClicked: updateKnock('enabled', !checked)
            }

            PatternButton {
                //% "Pattern"
                label: qsTrId("knock.pattern")
                pattern: appSettings.knock.pattern
                onError: errorText = error
                onPatternResolved: updateKnock('pattern', pattern)
            }

            DurationInput {
                //% "Timeout (ms)"
                label: qsTrId("knock.timeout")
                text: Duration.convertToLocale(Duration.convertToMs(appSettings.knock.timeout))
                maxValue: 600000
                onValidValueChanged: updateKnock('timeout', value)
            }

            TextField {
                //% "Port"
                label: qsTrId("knock.port")
                text: appSettings.knock.port
                onActiveFocusChanged: {
                    if (!activeFocus && acceptableInput) {
                        updateKnock('port', Number(text))
                    }
                }
                inputMethodHints: Qt.ImhDigitsOnly
                validator: IntValidator {
                    bottom: 0
                    top: 65535
                }
            }

            ExpandingSectionGroup {
                currentIndex: -1

                ExpandingSection {
                    //% "Advanced options"
                    title: qsTrId("knock.advanced")

                    content.sourceComponent: Column {
                        width: parent.width
                        spacing: Theme.paddingLarge

                        SectionHeader {
                            //% "Protocols"
                            text: qsTrId("knock.protocols")
                        }

                        Repeater {
                            model: ["udp", "tcp"]

                            TextSwitch {
                                property string value: modelData

                                text: value === "udp"
                                          //% "UDP"
                                          ? qsTrId("knock.protocol.udp")
                                          //% "TCP"
                                          : qsTrId("knock.protocol.tcp")
                                checked: appSettings.knock.protocol.indexOf(value) > -1
                                automaticCheck: false
                                onClicked: {
                                    const targetChecked = !checked;
                                    const protocols = appSettings.knock.protocol;
                                    if (targetChecked && protocols.indexOf(value) === -1) {
                                        protocols.push(value);
                                    } else if (!targetChecked && protocols.indexOf(value) !== -1) {
                                        protocols = protocols.filter(function(item) {
                                            return item !== value;
                                        });
                                    }

                                    updateKnock('protocol', protocols);
                                }
                            }
                        }

                        SectionHeader {
                            //% "Bind addresses"
                            text: qsTrId("knock.addresses")
                        }

                        StandardLabel {
                            //% "This configures which addresses does your phone listen on. If you don't know what this means, keep all enabled."
                            text: qsTrId("knock.addresses.description")
                            font.pixelSize: Theme.fontSizeExtraSmall
                            color: Theme.secondaryColor
                        }

                        TextSwitch {
                            //% "All addresses"
                            text: qsTrId("knock.addresses.all")
                            checked: appSettings.knock.addresses.length === 0
                            automaticCheck: false
                            onClicked: {
                                const targetChecked = !checked;
                                if (targetChecked) {
                                    updateKnock('addresses', []);
                                } else {
                                    updateKnock('addresses', ['0.0.0.0', '::']);
                                }
                            }
                        }

                        Repeater {
                            model: appSettings.knock.addresses

                            ListItem {
                                width: parent.width
                                height: row.height

                                Row {
                                    id: row
                                    width: parent.width
                                    spacing: Theme.paddingLarge

                                    TextField {
                                        //% "Bind address"
                                        label: qsTrId("knock.addresses.address")
                                        width: parent.width * 0.8
                                        text: modelData
                                        description: text === '0.0.0.0' || text === '::'
                                            //: %1 will be substituted with either 0.0.0.0 or :: and %2 with either IPv4 or IPv6
                                            //% "%1 means all addresses (%2)"
                                            ? qsTrId("knock.addresses.hint_all_addresses").arg(text).arg(text === '::' ? 'IPv6' : 'IPv4')
                                            : ''

                                        onActiveFocusChanged: {
                                            if (!activeFocus) {
                                                const addresses = appSettings.knock.addresses;
                                                addresses[index] = text;
                                                updateKnock('addresses', addresses);
                                            }
                                        }
                                    }

                                    IconButton {
                                        icon.source: "image://theme/icon-splus-delete"
                                        onClicked: {
                                            remorseDelete(function() {
                                                updateKnock('addresses', appSettings.knock.addresses.filter(function(item) {
                                                    return item !== modelData;
                                                }));
                                            });
                                        }
                                    }
                                }
                            }
                        }

                        Button {
                            //% "Add bind address"
                            text: qsTrId("knock.addresses.add")
                            anchors.horizontalCenter: parent.horizontalCenter
                            onClicked: {
                                const addresses = appSettings.knock.addresses;
                                addresses.push('127.0.0.1');
                                updateKnock('addresses', addresses);
                            }
                        }
                    }
                    content.active: true
                }
            }
        }
    }

    Component.onCompleted: {
        initialized = true;
    }
}
