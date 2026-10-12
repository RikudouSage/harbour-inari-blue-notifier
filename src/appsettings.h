#ifndef APPSETTINGS_H
#define APPSETTINGS_H

#include <QObject>
#include <QSettings>
#include <QStandardPaths>
#include <QJsonObject>
#include <QJsonArray>

class AppSettings : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QJsonArray storedPatterns READ storedPatterns WRITE setStoredPatterns NOTIFY storedPatternsChanged)
    Q_PROPERTY(QJsonObject callPattern READ callPattern WRITE setCallPattern NOTIFY callPatternChanged)
    Q_PROPERTY(QJsonObject favoriteCallPattern READ favoriteCallPattern WRITE setFavoriteCallPattern NOTIFY favoriteCallPatternChanged)
    Q_PROPERTY(QJsonObject notificationsPattern READ notificationsPattern WRITE setNotificationsPattern NOTIFY notificationsPatternChanged)

    Q_PROPERTY(bool callsEnabled READ callsEnabled WRITE setCallsEnabled NOTIFY callsEnabledChanged)
    Q_PROPERTY(bool favoriteCallsEnabled READ favoriteCallsEnabled WRITE setFavoriteCallsEnabled NOTIFY favoriteCallsEnabledChanged)
    Q_PROPERTY(bool notificationsEnabled READ notificationsEnabled WRITE setNotificationsEnabled NOTIFY notificationsEnabledChanged)

public:
    explicit AppSettings(QObject *parent = nullptr);
    ~AppSettings();

    QJsonArray storedPatterns();
    QJsonObject callPattern();
    QJsonObject favoriteCallPattern();
    QJsonObject notificationsPattern();
    bool callsEnabled();
    bool favoriteCallsEnabled();
    bool notificationsEnabled();

    void setStoredPatterns(const QJsonArray &value);
    void setCallPattern(const QJsonObject &value);
    void setFavoriteCallPattern(const QJsonObject &value);
    void setNotificationsPattern(const QJsonObject &value);
    void setCallsEnabled(bool value);
    void setFavoriteCallsEnabled(bool value);
    void setNotificationsEnabled(bool value);

    Q_INVOKABLE QJsonObject patternByName(const QString &name);
    Q_INVOKABLE void updatePattern(const QJsonObject &value, const QString &oldName = "");

signals:
    void storedPatternsChanged();
    void callPatternChanged();
    void favoriteCallPatternChanged();
    void notificationsPatternChanged();
    void callsEnabledChanged();
    void favoriteCallsEnabledChanged();
    void notificationsEnabledChanged();

private:
    QSettings settings = QSettings(
        QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation) + "/config_v3.ini",
        QSettings::Format::IniFormat
    );
};

#endif // APPSETTINGS_H
