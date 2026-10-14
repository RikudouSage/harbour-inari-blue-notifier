#include "appmanager.h"

#include <QStandardPaths>
#include <QDirIterator>
#include <QSettings>
#include <QFileInfo>
#include <QtConcurrent>
#include <QJsonObject>

#include "defer.h"

namespace {

QString processNameFromExec(const QString &exec)
{
    QString command;
    bool quoted = false;
    bool escaped = false;

    for (const QChar character : exec) {
        if (escaped) {
            command.append(character);
            escaped = false;
        } else if (character == QLatin1Char('\\')) {
            escaped = true;
        } else if (character == QLatin1Char('"')) {
            quoted = !quoted;
        } else if (character.isSpace() && !quoted) {
            if (!command.isEmpty()) {
                break;
            }
        } else {
            command.append(character);
        }
    }

    if (escaped) {
        command.append(QLatin1Char('\\'));
    }

    return QFileInfo(command).fileName();
}

}

AppManager::AppManager(QObject *parent) : QObject(parent)
{

}

void AppManager::fetchAndroidApps()
{
    QtConcurrent::run([&] {
        QJsonArray result;
        for (const auto &app : fetchApps()) {
            if (app.type != AppType::Android) {
                continue;
            }

            QJsonObject appJson;
            appJson["name"] = app.name;
            appJson["iconPath"] = app.iconPath;
            appJson["packageId"] = app.packageId;

            result.append(appJson);
        }

        emit androidAppsFetched(result);
    });
}

void AppManager::fetchNativeApps()
{
    QtConcurrent::run([&] {
        QJsonArray result;
        for (const auto &app : fetchApps()) {
            if (app.type != AppType::Native) {
                continue;
            }

            QJsonObject appJson;
            appJson["name"] = app.name;
            appJson["iconPath"] = app.iconPath;
            appJson["packageId"] = app.packageId;

            result.append(appJson);
        }

        emit nativeAppsFetched(result);
    });
}

QList<AppManager::App> AppManager::fetchApps()
{
    if (!apps.isEmpty()) {
        return apps;
    }

    QList<App> result;
    const auto paths = QStandardPaths::standardLocations(QStandardPaths::StandardLocation::ApplicationsLocation);
    for (const auto &path : paths) {
        QDirIterator iterator(path, {"*.desktop"}, QDir::Files | QDir::Readable, QDirIterator::Subdirectories);

        while (iterator.hasNext()) {
            const auto desktopFilePath = iterator.next();

            QSettings desktopFile(desktopFilePath, QSettings::IniFormat);
            desktopFile.setIniCodec("UTF-8");

            desktopFile.beginGroup("Desktop Entry");
            const auto hidden = desktopFile.value("Hidden", false).toBool() || desktopFile.value("NoDisplay", false).toBool();
            const auto name = desktopFile.value("Name").toString();
            const auto icon = findIcon(desktopFile.value("Icon").toString());
            const auto notificationOwner = desktopFile.value("X-Nemo-Owner").toString();
            const auto processName = processNameFromExec(desktopFile.value("Exec").toString());

            if (hidden || name.isEmpty() || icon.isEmpty()) {
                continue;
            }

            const auto androidPackageName = desktopFile.value("X-apkd-packageName").toString();
            desktopFile.endGroup();

            desktopFile.beginGroup("X-Sailjail");
            const auto sailjailApplicationName = desktopFile.value("ApplicationName").toString();
            const auto sandboxingDisabled = desktopFile.value("Sandboxing").toString().compare(
                "Disabled", Qt::CaseInsensitive
            ) == 0;
            desktopFile.endGroup();

            if (androidPackageName.isEmpty() && notificationOwner.isEmpty() && (sandboxingDisabled || sailjailApplicationName.isEmpty()) && processName.isEmpty()) {
                continue;
            }

            QString nativeNotificationOwner;
            if (!notificationOwner.isEmpty()) {
                nativeNotificationOwner = notificationOwner;
            } else if (!sandboxingDisabled && !sailjailApplicationName.isEmpty()) {
                nativeNotificationOwner = sailjailApplicationName;
            } else {
                nativeNotificationOwner = processName;
            }
            App app = {
                .name = name,
                .iconPath = icon,
                .packageId = !androidPackageName.isEmpty() ? androidPackageName : nativeNotificationOwner,
                .type = !androidPackageName.isEmpty() ? AppType::Android : AppType::Native,
            };
            result.append(app);
        }
    }

    apps = result;
    return result;
}

QString AppManager::findIcon(const QString &name)
{
    if (name == "") {
        return {};
    }

    if (QFileInfo(name).isAbsolute()) {
        return name;
    }

    for (int size : {172, 128, 108, 86}) {
        const auto path = QString(
            "/usr/share/icons/hicolor/%1x%1/apps/%2.png"
        ).arg(size).arg(name);

        if (QFile::exists(path)) {
            return path;
        }
    }

    return {};
}
