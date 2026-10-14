import QtQuick 2.0
import Sailfish.Silica 1.0

import dev.rikudou 1.0

import "../components"

Dialog {
    id: page

    readonly property int flagAndroid: 1 << 0
    readonly property int flagNative: 1 << 1
    property int fetchStatus: 0

    property var allAndroidPackages: []
    property var allNativePackages: []

    property bool packagesReady: (fetchStatus & (flagAndroid | flagNative)) === (flagAndroid | flagNative)
    property bool initialized: false
    property var androidPackageNames: []
    property var nemoOwners: []
    property var filter: ({name: '', androidPackageNames: [], nemoOwners: [], enabled: true})

    function triggerFilterChange() {
        filter = filter;
    }

    canAccept: filter.name !== '' && (filter.androidPackageNames.length > 0 || filter.nemoOwners.length > 0)

    onAndroidPackageNamesChanged: {
        if (!initialized) {
            return;
        }

        filter.androidPackageNames = androidPackageNames;
        triggerFilterChange();
    }
    onNemoOwnersChanged: {
        if (!initialized) {
            return;
        }

        filter.nemoOwners = nemoOwners;
        triggerFilterChange();
    }

    AppManager {
        id: appManager

        onAndroidAppsFetched: {
            allAndroidPackages = apps;
            fetchStatus |= flagAndroid;
        }

        onNativeAppsFetched: {
            allNativePackages = apps;
            fetchStatus |= flagNative;
        }
    }

    BusyLabel {
        id: loader
        visible: !packagesReady
        //% "Loading..."
        text: qsTrId("app.loading")
    }

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: column.height
        visible: !loader.visible

        Column {
            id: column
            spacing: Theme.paddingLarge
            width: page.width

            DialogHeader {
                //% "Save"
                acceptText: qsTrId("app.save")
            }

            StandardLabel {
                //% "This filter will match if any of the apps selected below sends a notification."
                text: qsTrId("edit_filter.info")
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
            }

            TextField {
                //: A notification filter name
                //% "Name"
                label: qsTrId("edit_filter.name")
                text: filter.name
                onTextChanged: {
                    filter.name = text;
                    triggerFilterChange();
                }
            }

            TextSwitch {
                //% "Enabled"
                text: qsTrId("app.enabled")
                checked: filter.enabled
                onCheckedChanged: filter.enabled = checked
            }

            SectionHeader {
                //% "Native apps"
                text: qsTrId("filter.native_packages")
            }

            StandardLabel {
                //% "No native apps currently selected."
                text: qsTrId("create_filter.no_native_apps")
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                visible: nemoOwners.length === 0
            }

            Repeater {
                model: nemoOwners

                ListItem {
                    width: parent.width

                    Row {
                        width: parent.width

                        TextField {
                            id: textField
                            text: modelData
                            width: parent.width * 0.8
                            rightItem: IconButton {
                                icon.source: "image://theme/icon-m-file-rpm"
                                icon.height: Theme.iconSizeMedium * 0.8
                                icon.width: icon.height
                                onClicked: {
                                    const dialog = pageStack.push("SelectAppPage.qml", {
                                        packages: allNativePackages,
                                    });
                                    dialog.packageSelected.connect(function(pkg) {
                                        textField.text = pkg;
                                    });
                                }
                            }
                            onTextChanged: {
                                nemoOwners[index] = text;
                            }
                        }

                        IconButton {
                            icon.source: "image://theme/icon-splus-delete"
                            onClicked: {
                                remorseDelete(function() {
                                    const newModel = nemoOwners.filter(function(item, itemIndex) {
                                        return itemIndex !== index;
                                    });
                                    nemoOwners = newModel;
                                });
                            }
                        }
                    }
                }
            }

            IconButton {
                anchors.horizontalCenter: parent.horizontalCenter
                icon.source: "image://theme/icon-l-add"
                onClicked: {
                    nemoOwners.push('');
                    nemoOwners = nemoOwners;
                }
            }

            SectionHeader {
                //% "Android apps"
                text: qsTrId("filter.android_packages")
            }

            StandardLabel {
                //% "No Android apps currently selected."
                text: qsTrId("create_filter.no_android_apps")
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                visible: androidPackageNames.length === 0
            }

            Repeater {
                model: androidPackageNames

                ListItem {
                    width: parent.width

                    Row {
                        width: parent.width

                        TextField {
                            id: textField
                            text: modelData
                            width: parent.width * 0.8
                            rightItem: IconButton {
                                icon.source: "image://theme/icon-m-file-apk"
                                icon.height: Theme.iconSizeMedium * 0.8
                                icon.width: icon.height
                                onClicked: {
                                    const dialog = pageStack.push("SelectAppPage.qml", {
                                        packages: allAndroidPackages,
                                    });
                                    dialog.packageSelected.connect(function(pkg) {
                                        textField.text = pkg;
                                    });
                                }
                            }
                            onTextChanged: {
                                androidPackageNames[index] = text;
                            }
                        }

                        IconButton {
                            icon.source: "image://theme/icon-splus-delete"
                            onClicked: {
                                remorseDelete(function() {
                                    const newModel = androidPackageNames.filter(function(item, itemIndex) {
                                        return itemIndex !== index;
                                    });
                                    androidPackageNames = newModel;
                                });
                            }
                        }
                    }
                }
            }

            IconButton {
                anchors.horizontalCenter: parent.horizontalCenter
                icon.source: "image://theme/icon-l-add"
                onClicked: {
                    androidPackageNames.push('');
                    androidPackageNames = androidPackageNames;
                }
            }
        }
    }

    Component.onCompleted: {
        if (filter.name) {
            androidPackageNames = typeof filter.androidPackageNames !== 'undefined' ? filter.androidPackageNames : [];
            nemoOwners = typeof filter.nemoOwners !== 'undefined' ? filter.nemoOwners : [];
        }

        appManager.fetchAndroidApps();
        appManager.fetchNativeApps();

        initialized = true;
    }
}
