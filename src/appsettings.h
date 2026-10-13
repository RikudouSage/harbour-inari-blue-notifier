#ifndef APPSETTINGS_H
#define APPSETTINGS_H

#include "appsettings_macros.h"

#include <functional>

#include <QObject>
#include <QSettings>
#include <QStandardPaths>
#include <QJsonObject>
#include <QJsonArray>
#include <QTime>

class AppSettings : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QJsonArray storedPatterns READ storedPatterns WRITE setStoredPatterns NOTIFY storedPatternsChanged)

    Q_PROPERTY(QTime startTime READ startTime WRITE setStartTime NOTIFY startTimeChanged)
    Q_PROPERTY(QTime endTime READ endTime WRITE setEndTime NOTIFY endTimeChanged)

    declarePattern(callPattern)
    declarePattern(favoriteCallPattern)
    declarePattern(notificationsPattern)
    declarePattern(smsPattern)
    declarePattern(emailPattern)
    declarePattern(signalPattern)

    declareEnabled(callsEnabled)
    declareEnabled(favoriteCallsEnabled)
    declareEnabled(notificationsEnabled)
    declareEnabled(smsEnabled)
    declareEnabled(emailEnabled)
    declareEnabled(signalEnabled)

public:
    explicit AppSettings(QObject *parent = nullptr);
    ~AppSettings();

    QJsonArray storedPatterns();

    QTime startTime();
    QTime endTime();

    void setStoredPatterns(const QJsonArray &value);

    void setStartTime(const QTime &value);
    void setEndTime(const QTime &value);

    Q_INVOKABLE QJsonObject patternByName(const QString &name);
    Q_INVOKABLE void updatePattern(const QJsonObject &value, const QString &oldName = "");

signals:
    void storedPatternsChanged();
    void callPatternChanged();
    void favoriteCallPatternChanged();
    void notificationsPatternChanged();
    void smsPatternChanged();
    void emailPatternChanged();
    void signalPatternChanged();

    void callsEnabledChanged();
    void favoriteCallsEnabledChanged();
    void notificationsEnabledChanged();
    void smsEnabledChanged();
    void emailEnabledChanged();
    void signalEnabledChanged();

    void startTimeChanged();
    void endTimeChanged();

private:
    QJsonObject getPattern(const QString &key, bool nullAllowed);
    void setPattern(
        const QString &key,
        const QJsonObject &value,
        QJsonObject (AppSettings::*currentValue)(),
        void (AppSettings::*notify)(),
        bool nullAllowed
    );
    bool eventEnabled(const QString &key, bool defaultValue);
    void setEventEnabled(
        const QString &key,
        bool value,
        bool (AppSettings::*currentValue)(),
        void (AppSettings::*notify)()
    );

private:
    QSettings settings = QSettings(
        QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation) + "/config_v3.ini",
        QSettings::Format::IniFormat
    );
};

#undef declarePattern
#undef declareEnabled

#endif // APPSETTINGS_H
