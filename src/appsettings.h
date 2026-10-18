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
    Q_PROPERTY(QJsonArray notificationFilters READ notificationFilters WRITE setNotificationFilters NOTIFY notificationFiltersChanged)
    Q_PROPERTY(QJsonArray customPatterns READ customPatterns WRITE setCustomPatterns NOTIFY customPatternsChanged)
    Q_PROPERTY(QJsonObject knock READ knock WRITE setKnock NOTIFY knockChanged)

    Q_PROPERTY(QTime startTime READ startTime WRITE setStartTime NOTIFY startTimeChanged)
    Q_PROPERTY(QTime endTime READ endTime WRITE setEndTime NOTIFY endTimeChanged)

    declarePattern(callPattern)
    declarePattern(favoriteCallPattern)
    declarePattern(notificationsPattern)
    declarePattern(smsPattern)
    declarePattern(emailPattern)
    declarePattern(signalPattern)
    declarePattern(matrixPattern)
    declarePattern(offPattern)

    declareEnabled(callsEnabled)
    declareEnabled(favoriteCallsEnabled)
    declareEnabled(notificationsEnabled)
    declareEnabled(smsEnabled)
    declareEnabled(emailEnabled)
    declareEnabled(signalEnabled)
    declareEnabled(matrixEnabled)

public:
    explicit AppSettings(QObject *parent = nullptr);
    ~AppSettings();

    QJsonArray storedPatterns();
    QJsonArray notificationFilters();
    QJsonArray customPatterns();
    QJsonObject knock();

    QTime startTime();
    QTime endTime();

    void setStoredPatterns(const QJsonArray &value);
    void setNotificationFilters(const QJsonArray &value);
    void setCustomPatterns(const QJsonArray &value);
    void setKnock(const QJsonObject &value);

    void setStartTime(const QTime &value);
    void setEndTime(const QTime &value);

    Q_INVOKABLE QJsonObject patternByName(const QString &name);
    Q_INVOKABLE void updatePattern(const QJsonObject &value, const QString &oldName = "");
    Q_INVOKABLE void updateFilter(const QJsonObject &value, const QString &oldName = "");
    Q_INVOKABLE void updateCustomPattern(const QJsonObject &value);

signals:
    void storedPatternsChanged();
    void notificationFiltersChanged();
    void customPatternsChanged();
    void knockChanged();

    void callPatternChanged();
    void favoriteCallPatternChanged();
    void notificationsPatternChanged();
    void smsPatternChanged();
    void emailPatternChanged();
    void signalPatternChanged();
    void matrixPatternChanged();
    void offPatternChanged();

    void callsEnabledChanged();
    void favoriteCallsEnabledChanged();
    void notificationsEnabledChanged();
    void smsEnabledChanged();
    void emailEnabledChanged();
    void signalEnabledChanged();
    void matrixEnabledChanged();

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
    QJsonObject parsePattern(const QString &raw) const;
    QString encodePattern(const QJsonObject &pattern) const;

private:
    QSettings settings = QSettings(
        QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation) + "/config_v3.ini",
        QSettings::Format::IniFormat
    );
};

#undef declarePattern
#undef declareEnabled

#endif // APPSETTINGS_H
