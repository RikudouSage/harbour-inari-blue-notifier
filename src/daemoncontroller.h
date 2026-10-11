#ifndef DAEMONCONTROLLER_H
#define DAEMONCONTROLLER_H

#include <QObject>
#include <QJsonObject>

class QDBusArgument;
class QDBusPendingCallWatcher;

class DaemonController : public QObject
{
    Q_OBJECT
public:
    explicit DaemonController(QObject *parent = nullptr);

    Q_INVOKABLE void playPattern(const QJsonObject &pattern);
    Q_INVOKABLE void stopPlaying();

private:
    static void logCallError(QDBusPendingCallWatcher *watcher);
    static QDBusArgument marshalPattern(const QJsonObject &pattern);
};

#endif // DAEMONCONTROLLER_H
