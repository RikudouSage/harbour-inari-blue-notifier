import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"

Dialog {
    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            spacing: Theme.paddingLarge
            width: page.width

            DialogHeader {
                //% "Accept"
                acceptText: qsTrId("app.accept")
            }

            StandardLabel {
                //% "By accepting this dialog, you will give this app access to your contacts which is needed to check whether an incoming call is from a favourite contact. Note that if this is the first time you're enabling this, a system dialog will be shown asking you to grant the permission."
                text: qsTrId("enable_contacts.description")
            }
        }
    }
}
