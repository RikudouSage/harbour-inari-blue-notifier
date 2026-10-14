#ifndef APPMANAGER_H
#define APPMANAGER_H

#include <QObject>
#include <QJsonArray>
#include <QList>

class AppManager : public QObject
{
    Q_OBJECT
public:
    explicit AppManager(QObject *parent = nullptr);

    Q_INVOKABLE void fetchAndroidApps();
    Q_INVOKABLE void fetchNativeApps();

signals:
    void androidAppsFetched(const QJsonArray &apps);
    void nativeAppsFetched(const QJsonArray &apps);

private:
    enum AppType {
        Native,
        Android,
    };
    struct App {
        QString name;
        QString iconPath;
        QString packageId;
        AppType type;
    };

    QList<App> fetchApps();
    QString findIcon(const QString &name);

private:
    QList<App> apps;
};

#endif // APPMANAGER_H
