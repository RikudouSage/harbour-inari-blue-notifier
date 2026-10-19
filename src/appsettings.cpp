#include "appsettings.h"
#include "defer.h"

#include <QDebug>
#include <QJsonDocument>
#include <QByteArray>
#include <QSet>
#include <QStringList>
#include <QRegExp>

constexpr auto activePatternsSection = "activePatterns";
constexpr auto storedPatternsSection = "storedPatterns";
constexpr auto eventsSection = "events";
constexpr auto constraintsSection = "constraints";
constexpr auto sectionNotificationFilters = "notificationFilters";
constexpr auto sectionKnock = "knock";

constexpr auto callPatternKey = "call";
constexpr auto favoriteCallPatternKey = "favoriteCall";
constexpr auto notificationsPatternKey = "notification";
constexpr auto smsPatternKey = "sms";
constexpr auto emailPatternKey = "email";
constexpr auto signalPatternKey = "signal";
constexpr auto matrixPatternKey = "matrix";
constexpr auto offPatternKey = "off";

constexpr auto constraintStartTime = "startTime";
constexpr auto constraintEndTime = "endTime";

constexpr auto knockKeyEnabled = "enabled";
constexpr auto knockKeyPattern = "pattern";
constexpr auto knockKeyTimeout = "timeout";
constexpr auto knockKeyProtocol = "protocol";
constexpr auto knockKeyPort = "port";
constexpr auto knockKeyAddresses = "addresses";
constexpr auto knockKeyStopOnUnlock = "stopOnUnlock";

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
implementPattern(offPattern, false)

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

QJsonArray AppSettings::notificationFilters()
{
    settings.beginGroup(sectionNotificationFilters);
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

QJsonArray AppSettings::customPatterns()
{
    QJsonArray result;
    for (const auto &item : notificationFilters()) {
        const auto filterName = item.toObject()["name"].toString();
        if (filterName.isEmpty()) {
            continue;
        }

        QJsonObject customPattern;
        customPattern["name"] = filterName;
        customPattern["pattern"] = getPattern(filterName, true);
        result.append(customPattern);
    }

    return result;
}

QJsonObject AppSettings::knock()
{
    QJsonObject result;

    settings.beginGroup(sectionKnock);
    defer({
        settings.endGroup();
    });
    result[knockKeyEnabled] = settings.value(knockKeyEnabled).toBool();
    result[knockKeyPattern] = parsePattern(settings.value(knockKeyPattern).toString());
    result[knockKeyTimeout] = settings.value(knockKeyTimeout).toLongLong();
    result[knockKeyPort] = settings.value(knockKeyPort).toInt();
    result[knockKeyProtocol] = QJsonArray::fromStringList(settings.value(knockKeyProtocol).toStringList());
    result[knockKeyAddresses] = QJsonArray::fromStringList(settings.value(knockKeyAddresses).toStringList().filter(QRegExp("^.+$")));
    result[knockKeyStopOnUnlock] = settings.value(knockKeyStopOnUnlock).toBool();

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

void AppSettings::setNotificationFilters(const QJsonArray &value)
{
    const auto current = notificationFilters();
    if (value == current) {
        return;
    }

    {
        settings.beginGroup(sectionNotificationFilters);
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

    QSet<QString> filterNames;
    for (const auto &item : value) {
        filterNames.insert(item.toObject()["name"].toString());
    }

    {
        settings.beginGroup(activePatternsSection);
        defer({
            settings.endGroup();
        });
        for (const auto &item : current) {
            const auto name = item.toObject()["name"].toString();
            if (!name.isEmpty() && !filterNames.contains(name)) {
                settings.remove(name);
            }
        }
        settings.sync();
    }

    emit notificationFiltersChanged();
    emit customPatternsChanged();
}

void AppSettings::setCustomPatterns(const QJsonArray &value)
{
    const auto current = customPatterns();
    if (value == current) {
        return;
    }

    QSet<QString> filterNames;
    for (const auto &item : notificationFilters()) {
        filterNames.insert(item.toObject()["name"].toString());
    }

    {
        settings.beginGroup(activePatternsSection);
        defer({
            settings.endGroup();
        });

        for (const auto &filterName : filterNames) {
            settings.remove(filterName);
        }

        for (const auto &item : value) {
            const auto customPattern = item.toObject();
            const auto filterName = customPattern["name"].toString();
            const auto pattern = customPattern["pattern"].toObject();
            if (!filterNames.contains(filterName) || pattern["name"].toString().isEmpty()) {
                continue;
            }

            const auto document = QJsonDocument(pattern);
            const auto rawJson = document.toJson(QJsonDocument::JsonFormat::Compact);
            const auto encoded = rawJson.toBase64(QByteArray::Base64Option::Base64Encoding | QByteArray::Base64Option::OmitTrailingEquals);
            settings.setValue(filterName, QString::fromLatin1(encoded));
        }
        settings.sync();
    }

    emit customPatternsChanged();
}

void AppSettings::setKnock(const QJsonObject &value)
{
    const auto currentValue = knock();
    if (value == currentValue) {
        return;
    }

    {
        settings.beginGroup(sectionKnock);
        defer({
            settings.endGroup();
        });

        const auto convertArrayToStringList = [&](const QJsonArray &value) -> QVariant {
            QStringList list;
            for (const auto &val : value) {
                const auto str = val.toString();
                if (str.isEmpty()) {
                    continue;
                }
                list.append(str);
            }

            if (list.isEmpty()) {
                return "";
            }

            return list;
        };

        settings.setValue(knockKeyEnabled, value[knockKeyEnabled].toBool());
        settings.setValue(knockKeyPattern, encodePattern(value[knockKeyPattern].toObject()));
        settings.setValue(knockKeyPort, value[knockKeyPort].toInt());
        settings.setValue(knockKeyTimeout, static_cast<qint64>(value[knockKeyTimeout].toDouble()));
        settings.setValue(knockKeyProtocol, convertArrayToStringList(value[knockKeyProtocol].toArray()));
        settings.setValue(knockKeyAddresses, convertArrayToStringList(value[knockKeyAddresses].toArray()));
        settings.setValue(knockKeyStopOnUnlock, value[knockKeyStopOnUnlock].toBool());
    }

    emit knockChanged();
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

void AppSettings::updateFilter(const QJsonObject &value, const QString &oldName)
{
    QJsonObject previousCustomPattern;
    if (!oldName.isEmpty() && value["name"].toString() != oldName) {
        for (const auto &item : customPatterns()) {
            const auto customPattern = item.toObject();
            if (customPattern["name"].toString() == oldName) {
                previousCustomPattern = customPattern["pattern"].toObject();
                break;
            }
        }
    }

    auto filters = notificationFilters();
    if (oldName != "" && value["name"].toString() != oldName) {
        for (auto i = 0; i < filters.size(); ++i) {
            const auto filter = filters.at(i);
            if (filter.toObject()["name"].toString() == oldName) {
                filters.removeAt(i);
                break;
            }
        }
    }

    auto existing = false;
    for (auto i = 0; i < filters.size(); ++i) {
        const auto stored = filters.at(i);
        if (stored.toObject()["name"].toString() != value["name"].toString()) {
            continue;
        }
        if (stored.toObject() == value) {
            return;
        }

        existing = true;
        filters.replace(i, value);
        break;
    }

    if (!existing) {
        filters.append(value);
    }

    setNotificationFilters(filters);

    if (!previousCustomPattern.isEmpty()) {
        auto patterns = customPatterns();
        for (auto i = 0; i < patterns.size(); ++i) {
            auto pattern = patterns[i].toObject();
            if (pattern["name"].toString() == value["name"].toString()) {
                pattern["pattern"] = previousCustomPattern;
                patterns.replace(i, pattern);
                setCustomPatterns(patterns);
                break;
            }
        }
    }
}

void AppSettings::updateCustomPattern(const QJsonObject &value)
{
    auto patterns = customPatterns();
    for (auto i = 0; i < patterns.size(); ++i) {
        if (patterns[i].toObject()["name"].toString() != value["name"].toString()) {
            continue;
        }

        patterns.replace(i, value);
        setCustomPatterns(patterns);
        return;
    }
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
            settings.sync();
        } else {
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

QJsonObject AppSettings::parsePattern(const QString &raw) const
{
    const auto rawJson = QByteArray::fromBase64(raw.toUtf8(), QByteArray::Base64Option::Base64Encoding);
    QJsonParseError error;
    const auto document = QJsonDocument::fromJson(rawJson, &error);
    if (error.error != QJsonParseError::NoError) {
        qWarning() << "Error parsing JSON: " << error.errorString();
        return QJsonObject();
    }

    return document.object();
}

QString AppSettings::encodePattern(const QJsonObject &pattern) const
{
    const auto document = QJsonDocument(pattern);
    const auto rawJson = document.toJson(QJsonDocument::JsonFormat::Compact);
    const auto encoded = rawJson.toBase64(QByteArray::Base64Option::Base64Encoding | QByteArray::Base64Option::OmitTrailingEquals);

    return encoded;
}
