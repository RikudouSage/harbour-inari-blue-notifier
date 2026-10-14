#include "appsettings.h"
#include "defer.h"

#include <QDebug>
#include <QJsonDocument>
#include <QByteArray>

constexpr auto activePatternsSection = "activePatterns";
constexpr auto storedPatternsSection = "storedPatterns";
constexpr auto eventsSection = "events";
constexpr auto constraintsSection = "constraints";

constexpr auto callPatternKey = "call";
constexpr auto favoriteCallPatternKey = "favoriteCall";
constexpr auto notificationsPatternKey = "notification";
constexpr auto smsPatternKey = "sms";
constexpr auto emailPatternKey = "email";
constexpr auto signalPatternKey = "signal";
constexpr auto matrixPatternKey = "matrix";

constexpr auto constraintStartTime = "startTime";
constexpr auto constraintEndTime = "endTime";

AppSettings::AppSettings(QObject *parent) : QObject(parent)
{
}

implementPattern(callPattern, false)
implementPattern(favoriteCallPattern, true)
implementPattern(notificationsPattern, false)
implementPattern(smsPattern, true)
implementPattern(emailPattern, true)
implementPattern(signalPattern, true)
implementPattern(matrixPattern, true)

implementEnabled(callsEnabled, callPatternKey, true)
implementEnabled(favoriteCallsEnabled, favoriteCallPatternKey, false)
implementEnabled(notificationsEnabled, notificationsPatternKey, false)
implementEnabled(smsEnabled, smsPatternKey, false)
implementEnabled(emailEnabled, emailPatternKey, false)
implementEnabled(signalEnabled, signalPatternKey, false)
implementEnabled(matrixEnabled, matrixPatternKey, false)

#undef implementEnabled
#undef implementPattern

AppSettings::~AppSettings()
{
    settings.sync();
}

QJsonArray AppSettings::storedPatterns()
{
    settings.beginGroup(storedPatternsSection);
    defer({
        settings.endGroup();
    });

    QJsonArray result;
    for (const auto &key : settings.childKeys()) {
        const auto encoded = settings.value(key).toByteArray();
        const auto rawJson = QByteArray::fromBase64(encoded, QByteArray::Base64Option::Base64Encoding);

        QJsonParseError error;
        const auto document = QJsonDocument::fromJson(rawJson, &error);
        if (error.error != QJsonParseError::NoError) {
            qWarning() << "Error parsing JSON: " << error.errorString();
            continue;
        }

        result.append(document.object());
    }

    return result;
}

QTime AppSettings::startTime()
{
    settings.sync();
    settings.beginGroup(constraintsSection);
    defer({
        settings.endGroup();
    });

    const auto value = settings.value(constraintStartTime, "00:00:00").toString();

    return QTime::fromString(value, "hh:mm:ss");
}

QTime AppSettings::endTime()
{
    settings.sync();
    settings.beginGroup(constraintsSection);
    defer({
        settings.endGroup();
    });

    const auto value = settings.value(constraintEndTime, "00:00:00").toString();

    return QTime::fromString(value, "hh:mm:ss");
}

void AppSettings::setStoredPatterns(const QJsonArray &value)
{
    const auto current = storedPatterns();
    if (value == current) {
        return;
    }

    {
        settings.beginGroup(storedPatternsSection);
        defer({
            settings.endGroup();
        });
        settings.remove("");

        for (const auto &item : value) {
            const auto name = item.toObject()["name"].toString();
            if (name.isNull() || name.isEmpty()) {
                continue;
            }

            const auto document = QJsonDocument(item.toObject());
            const auto rawJson = document.toJson(QJsonDocument::JsonFormat::Compact);
            const auto encoded = rawJson.toBase64(QByteArray::Base64Option::Base64Encoding | QByteArray::Base64Option::OmitTrailingEquals);
            settings.setValue(name, QString::fromLatin1(encoded));
        }

        settings.sync();
    }

    emit storedPatternsChanged();
}

void AppSettings::setStartTime(const QTime &value)
{
    const auto current = startTime();
    if (value == current) {
        return;
    }

    {
        settings.beginGroup(constraintsSection);
        defer({
            settings.endGroup();
        });

        settings.setValue(constraintStartTime, value.toString("hh:mm:ss"));
        settings.sync();
    }

    emit startTimeChanged();
}

void AppSettings::setEndTime(const QTime &value)
{
    const auto current = endTime();
    if (value == current) {
        return;
    }

    {
        settings.beginGroup(constraintsSection);
        defer({
            settings.endGroup();
        });

        settings.setValue(constraintEndTime, value.toString("hh:mm:ss"));
        settings.sync();
    }

    emit endTimeChanged();
}

QJsonObject AppSettings::patternByName(const QString &name)
{
    for (const auto &pattern : storedPatterns()) {
        if (pattern.toObject()["name"].toString() == name) {
            return pattern.toObject();
        }
    }

    return QJsonObject();
}

void AppSettings::updatePattern(const QJsonObject &value, const QString &oldName)
{
    auto patterns = storedPatterns();
    if (oldName != "" && value["name"].toString() != oldName) {
        for (auto i = 0; i < patterns.size(); ++i) {
            const auto pattern = patterns.at(i);
            if (pattern.toObject()["name"].toString() == oldName) {
                patterns.removeAt(i);
                break;
            }
        }
    }

    auto existing = false;
    for (auto i = 0; i < patterns.size(); ++i) {
        const auto stored = patterns.at(i);
        if (stored.toObject()["name"].toString() != value["name"].toString()) {
            continue;
        }
        if (stored.toObject() == value) {
            return;
        }

        existing = true;
        patterns.replace(i, value);
        break;
    }

    if (!existing) {
        patterns.append(value);
    }

    setStoredPatterns(patterns);
}

QJsonObject AppSettings::getPattern(const QString &key, bool nullAllowed)
{
    settings.sync();
    settings.beginGroup(activePatternsSection);
    defer({
        settings.endGroup();
    });

    const auto encoded = settings.value(key).toByteArray();
    if (nullAllowed && encoded.length() == 0) {
        return QJsonObject();
    }

    const auto rawJson = QByteArray::fromBase64(encoded, QByteArray::Base64Option::Base64Encoding);
    QJsonParseError error;
    const auto document = QJsonDocument::fromJson(rawJson, &error);
    if (error.error != QJsonParseError::NoError) {
        qWarning() << "Error parsing JSON: " << error.errorString();
        return QJsonObject();
    }

    return document.object();
}

void AppSettings::setPattern(
    const QString &key,
    const QJsonObject &value,
    QJsonObject (AppSettings::*currentValue)(),
    void (AppSettings::*notify)(),
    bool nullAllowed
) {
    const auto current = (this->*currentValue)();
    if (value == current) {
        return;
    }

    {
        settings.beginGroup(activePatternsSection);
        defer({
            settings.endGroup();
        });

        if (value.isEmpty() && nullAllowed) {
            settings.remove(key);
            emit (this->*notify)();
            return;
        }

        const auto name = value["name"].toString();
        if (name.isNull() || name.isEmpty()) {
            return;
        }

        const auto document = QJsonDocument(value);
        const auto rawJson = document.toJson(QJsonDocument::JsonFormat::Compact);
        const auto encoded = rawJson.toBase64(QByteArray::Base64Option::Base64Encoding | QByteArray::Base64Option::OmitTrailingEquals);
        settings.setValue(key, QString::fromLatin1(encoded));

        settings.sync();
    }

    emit (this->*notify)();
}

bool AppSettings::eventEnabled(const QString &key, bool defaultValue)
{
    settings.sync();
    settings.beginGroup(eventsSection);
    defer({
        settings.endGroup();
    });

    return settings.value(key, defaultValue).toBool();
}

void AppSettings::setEventEnabled(
    const QString &key,
    bool value,
    bool (AppSettings::*currentValue)(),
    void (AppSettings::*notify)()
) {
    const auto current = (this->*currentValue)();
    if (value == current) {
        return;
    }

    {
        settings.beginGroup(eventsSection);
        defer({
            settings.endGroup();
        });

        settings.setValue(key, value);
        settings.sync();
    }

    emit (this->*notify)();;
}
