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
constexpr auto notificationPatternKey = "notification";

constexpr auto constraintStartTime = "startTime";
constexpr auto constraintEndTime = "endTime";

AppSettings::AppSettings(QObject *parent) : QObject(parent)
{
}

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

QJsonObject AppSettings::callPattern()
{
    settings.sync();
    settings.beginGroup(activePatternsSection);
    defer({
        settings.endGroup();
    });

    const auto encoded = settings.value(callPatternKey).toByteArray();
    const auto rawJson = QByteArray::fromBase64(encoded, QByteArray::Base64Option::Base64Encoding);
    QJsonParseError error;
    const auto document = QJsonDocument::fromJson(rawJson, &error);
    if (error.error != QJsonParseError::NoError) {
        qWarning() << "Error parsing JSON: " << error.errorString();
        return QJsonObject();
    }

    return document.object();
}

QJsonObject AppSettings::favoriteCallPattern()
{
    settings.sync();
    settings.beginGroup(activePatternsSection);
    defer({
        settings.endGroup();
    });

    const auto encoded = settings.value(favoriteCallPatternKey).toByteArray();
    const auto rawJson = QByteArray::fromBase64(encoded, QByteArray::Base64Option::Base64Encoding);
    QJsonParseError error;
    const auto document = QJsonDocument::fromJson(rawJson, &error);
    if (error.error != QJsonParseError::NoError) {
        qWarning() << "Error parsing JSON: " << error.errorString();
        return QJsonObject();
    }

    return document.object();
}

QJsonObject AppSettings::notificationsPattern()
{
    settings.sync();
    settings.beginGroup(activePatternsSection);
    defer({
        settings.endGroup();
    });

    const auto encoded = settings.value(notificationPatternKey).toByteArray();
    const auto rawJson = QByteArray::fromBase64(encoded, QByteArray::Base64Option::Base64Encoding);
    QJsonParseError error;
    const auto document = QJsonDocument::fromJson(rawJson, &error);
    if (error.error != QJsonParseError::NoError) {
        qWarning() << "Error parsing JSON: " << error.errorString();
        return QJsonObject();
    }

    return document.object();
}

bool AppSettings::callsEnabled()
{
    settings.sync();
    settings.beginGroup(eventsSection);
    defer({
        settings.endGroup();
    });

    return settings.value(callPatternKey, true).toBool();
}

bool AppSettings::favoriteCallsEnabled()
{
    settings.sync();
    settings.beginGroup(eventsSection);
    defer({
        settings.endGroup();
    });

    return settings.value(favoriteCallPatternKey, true).toBool();
}

bool AppSettings::notificationsEnabled()
{
    settings.sync();
    settings.beginGroup(eventsSection);
    defer({
        settings.endGroup();
    });

    return settings.value(notificationPatternKey, false).toBool();
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

void AppSettings::setCallPattern(const QJsonObject &value)
{
    const auto current = callPattern();
    if (value == current) {
        return;
    }

    {
        settings.beginGroup(activePatternsSection);
        defer({
            settings.endGroup();
        });

        const auto name = value["name"].toString();
        if (name.isNull() || name.isEmpty()) {
            return;
        }

        const auto document = QJsonDocument(value);
        const auto rawJson = document.toJson(QJsonDocument::JsonFormat::Compact);
        const auto encoded = rawJson.toBase64(QByteArray::Base64Option::Base64Encoding | QByteArray::Base64Option::OmitTrailingEquals);
        settings.setValue(callPatternKey, QString::fromLatin1(encoded));

        settings.sync();
    }

    emit callPatternChanged();
}

void AppSettings::setFavoriteCallPattern(const QJsonObject &value)
{
    const auto current = favoriteCallPattern();
    if (value == current) {
        return;
    }

    {
        settings.beginGroup(activePatternsSection);
        defer({
            settings.endGroup();
        });

        const auto name = value["name"].toString();
        if (name.isNull() || name.isEmpty()) {
            return;
        }

        const auto document = QJsonDocument(value);
        const auto rawJson = document.toJson(QJsonDocument::JsonFormat::Compact);
        const auto encoded = rawJson.toBase64(QByteArray::Base64Option::Base64Encoding | QByteArray::Base64Option::OmitTrailingEquals);
        settings.setValue(favoriteCallPatternKey, QString::fromLatin1(encoded));

        settings.sync();
    }

    emit favoriteCallPatternChanged();
}

void AppSettings::setNotificationsPattern(const QJsonObject &value)
{
    const auto current = notificationsPattern();
    if (value == current) {
        return;
    }

    {
        settings.beginGroup(activePatternsSection);
        defer({
            settings.endGroup();
        });

        const auto name = value["name"].toString();
        if (name.isNull() || name.isEmpty()) {
            return;
        }

        const auto document = QJsonDocument(value);
        const auto rawJson = document.toJson(QJsonDocument::JsonFormat::Compact);
        const auto encoded = rawJson.toBase64(QByteArray::Base64Option::Base64Encoding | QByteArray::Base64Option::OmitTrailingEquals);
        settings.setValue(notificationPatternKey, QString::fromLatin1(encoded));

        settings.sync();
    }

    emit notificationsPatternChanged();
}

void AppSettings::setCallsEnabled(bool value)
{
    const auto current = callsEnabled();
    if (value == current) {
        return;
    }

    {
        settings.beginGroup(eventsSection);
        defer({
            settings.endGroup();
        });

        settings.setValue(callPatternKey, value);
        settings.sync();
    }

    emit callsEnabledChanged();
}

void AppSettings::setFavoriteCallsEnabled(bool value)
{
    const auto current = favoriteCallsEnabled();
    if (value == current) {
        return;
    }

    {
        settings.beginGroup(eventsSection);
        defer({
            settings.endGroup();
        });

        settings.setValue(favoriteCallPatternKey, value);
        settings.sync();
    }

    emit favoriteCallsEnabledChanged();
}

void AppSettings::setNotificationsEnabled(bool value)
{
    const auto current = notificationsEnabled();
    if (value == current) {
        return;
    }

    {
        settings.beginGroup(eventsSection);
        defer({
            settings.endGroup();
        });

        settings.setValue(notificationPatternKey, value);
        settings.sync();
    }

    emit notificationsEnabledChanged();
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
