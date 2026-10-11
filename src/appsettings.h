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
public:
    explicit AppSettings(QObject *parent = nullptr);
    ~AppSettings();

    QJsonArray storedPatterns();
    QJsonObject callPattern();

    void setStoredPatterns(const QJsonArray &value);
    void setCallPattern(const QJsonObject &value);

    Q_INVOKABLE QJsonObject patternByName(const QString &name);
    Q_INVOKABLE void updatePattern(const QJsonObject &value, const QString &oldName = "");

signals:
    void storedPatternsChanged();
    void callPatternChanged();

private:
    QSettings settings = QSettings(
        QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation) + "/config_v3.ini",
        QSettings::Format::IniFormat
    );
};

#endif // APPSETTINGS_H
