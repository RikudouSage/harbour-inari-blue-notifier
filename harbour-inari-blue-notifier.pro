# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-inari-blue-notifier
QT += dbus

CONFIG += sailfishapp

SOURCES += src/harbour-inari-blue-notifier.cpp \
    src/appsettings.cpp \
    src/daemoncontroller.cpp

DISTFILES += qml/harbour-inari-blue-notifier.qml \
    qml/components/DurationInput.qml \
    qml/components/ServiceRestartNotice.qml \
    qml/components/StandardLabel.qml \
    qml/cover/CoverPage.qml \
    qml/js/colors.js \
    qml/pages/EditPatternPage.qml \
    qml/pages/EnableContactsPage.qml \
    qml/pages/MainPage.qml \
    qml/pages/PatternSelectorPage.qml \
    qml/pages/PatternsPage.qml \
    qml/pages/SettingsPage.qml \
    rpm/InariBlueNotifier.permission \
    rpm/harbour-inari-blue-notifier.changes.in \
    rpm/harbour-inari-blue-notifier.changes.run.in \
    rpm/harbour-inari-blue-notifier.spec \
    translations/*.ts \
    harbour-inari-blue-notifier.desktop

sailjail_permission.path = /etc/sailjail/permissions
sailjail_permission.files = rpm/InariBlueNotifier.permission
INSTALLS += sailjail_permission

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n sailfishapp_i18n_idbased

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-inari-blue-notifier-en.ts \
                translations/harbour-inari-blue-notifier-cs.ts \
                translations/harbour-inari-blue-notifier-no.ts \
                translations/harbour-inari-blue-notifier-sv.ts

HEADERS += \
    src/appsettings.h \
    src/daemoncontroller.h \
    src/defer.h
