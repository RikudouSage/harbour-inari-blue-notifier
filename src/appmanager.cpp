#include "appmanager.h"

#include <QStandardPaths>
#include <QDirIterator>
#include <QSettings>
#include <QFileInfo>
#include <QtConcurrent>
#include <QJsonObject>

#include "defer.h"

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

            if (hidden || name.isEmpty() || icon.isEmpty()) {
                continue;
            }

            const auto androidPackageName = desktopFile.value("X-apkd-packageName").toString();
            desktopFile.endGroup();

            desktopFile.beginGroup("X-Sailjail");
            const auto sailjailApplicationName = desktopFile.value("ApplicationName").toString();
            desktopFile.endGroup();

            if (sailjailApplicationName.isEmpty() && androidPackageName.isEmpty()) {
                continue;
            }

            App app = {
                .name = name,
                .iconPath = icon,
                .packageId = !sailjailApplicationName.isEmpty() ? sailjailApplicationName : androidPackageName,
                .type = !sailjailApplicationName.isEmpty() ? AppType::Native : AppType::Android,
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
