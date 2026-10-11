#include "daemoncontroller.h"

#include <QDBusArgument>
#include <QDBusConnection>
#include <QDBusError>
#include <QDBusInterface>
#include <QDBusPendingCallWatcher>
#include <QDebug>
#include <QVariant>
#include <QJsonArray>

constexpr auto daemonService = "dev.rikudou.InariBlueNotifier";
constexpr auto daemonObject = "/dev/rikudou/InariBlueNotifier";
constexpr auto daemonInterface = "dev.rikudou.InariBlueNotifier";

DaemonController::DaemonController(QObject *parent) : QObject(parent)
{
}

void DaemonController::logCallError(QDBusPendingCallWatcher *watcher)
{
    QObject::connect(watcher, &QDBusPendingCallWatcher::finished, watcher, [](QDBusPendingCallWatcher *finishedWatcher) {
        if (finishedWatcher->isError()) {
            qWarning() << "Daemon D-Bus call failed:" << finishedWatcher->error().message();
        }
        finishedWatcher->deleteLater();
    });
}

QDBusArgument DaemonController::marshalPattern(const QJsonObject &pattern)
{
    auto channels = pattern["channels"].toArray(QJsonArray());

    QByteArray channelBytes;
    for (const auto &channel : channels) {
        channelBytes.append(static_cast<char>(channel.toInt()));
    }

    QDBusArgument argument;
    argument.beginStructure();
    argument << pattern.value("name").toString()
             << static_cast<qlonglong>(pattern.value("rise").toDouble())
             << static_cast<qlonglong>(pattern.value("hold").toDouble())
             << static_cast<qlonglong>(pattern.value("decay").toDouble())
             << static_cast<qlonglong>(pattern.value("off").toDouble())
             << static_cast<qlonglong>(pattern.value("delay").toDouble())
             << static_cast<uchar>(pattern.value("repeat").toInt())
             << static_cast<uchar>(pattern.value("brightness").toInt())
             << channelBytes
    ;
    argument.endStructure();
    return argument;
}

void DaemonController::playPattern(const QJsonObject &pattern)
{
    QDBusInterface interface(daemonService, daemonObject, daemonInterface, QDBusConnection::sessionBus());
    auto *watcher = new QDBusPendingCallWatcher(
        interface.asyncCall("PlayPattern", QVariant::fromValue(marshalPattern(pattern))),
        this
    );
    logCallError(watcher);
}

void DaemonController::stopPlaying()
{
    QDBusInterface interface(daemonService, daemonObject, daemonInterface, QDBusConnection::sessionBus());
    auto *watcher = new QDBusPendingCallWatcher(interface.asyncCall("Stop"), this);
    logCallError(watcher);
}
