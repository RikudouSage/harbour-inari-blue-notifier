import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"

Page {
    id: page

    function needsRestart() {
        app.serviceNeedsRestart = true;
    }

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu {
            MenuItem {
                //% "Create a filter"
                text: qsTrId("filters.add")
                onClicked: {
                    const dialog = pageStack.push("EditFilterPage.qml");
                    dialog.accepted.connect(function() {
                        appSettings.updateFilter(dialog.filter);
                        page.needsRestart();
                    });
                }
            }
        }

        Column {
            id: column
            spacing: Theme.paddingLarge
            width: page.width

            PageHeader {
                //% "Notification filters"
                title: qsTrId("filters.title")
            }

            ServiceRestartNotice {
                visible: app.serviceNeedsRestart
            }

            StandardLabel {
                //% "There are no custom notification filters created yet. Use the pull down menu to create one."
                text: qsTrId("filters.none_available")
                visible: appSettings.notificationFilters.length === 0
            }

            Repeater {
                model: appSettings.notificationFilters

                ListItem {
                    contentHeight: Theme.itemSizeSmall
                    menu: ContextMenu {
                        MenuItem {
                            //% "Remove"
                            text: qsTrId("filters.remove")
                            onClicked: {
                                var pageRef = page;
                                remorseDelete(function() {
                                    var filters = appSettings.notificationFilters;
                                    filters = filters.filter(function(filter) {
                                        return filter.name !== modelData.name;
                                    });
                                    appSettings.notificationFilters = filters;
                                    pageRef.needsRestart();
                                });
                            }
                        }
                    }
                    onClicked: {
                        const dialog = pageStack.push("EditFilterPage.qml", {
                            filter: modelData,
                        });
                        dialog.accepted.connect(function() {
                            appSettings.updateFilter(dialog.filter, modelData.name);
                            page.needsRestart();
                        });
                    }

                    StandardLabel {
                        text: modelData.name
                    }
                }
            }
        }
    }
}
