import QtQuick 2.0
import Sailfish.Silica 1.0

ValueButton {
    property var appOverride
    property string defaultKind
    property var pattern

    signal error(string error)
    signal patternResolved(var pattern)
    signal defaultSelected()

    //% "Default pattern"
    value: typeof pattern.name !== 'undefined' ? pattern.name : (defaultKind ? qsTrId("patterns.active.default") : '')

    onClicked: {
        const dialog = pageStack.push("../pages/PatternSelectorPage.qml", {
            patterns: appSettings.storedPatterns,
            withDefaults: defaultKind !== '',
            defaultKind: defaultKind,
        });
        dialog.itemSelected.connect(function(name) {
            const found = appSettings.patternByName(name);
            if (!found.name) {
                //% "A pattern with the name '%1' was not found.
                const errorText = qsTrId("patterns.not_found").arg(name)
                error(errorText);
                return;
            }

            patternResolved(found);
            appOverride.serviceNeedsRestart = true;
        });

        dialog.defaultSelected.connect(function() {
            defaultSelected()
            appOverride.serviceNeedsRestart = true;
        });
    }

    Component.onCompleted: {
        if (!appOverride) {
            appOverride = app;
        }
    }
}
