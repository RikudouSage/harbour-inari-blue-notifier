#ifndef APPSETTINGS_MACROS_H
#define APPSETTINGS_MACROS_H

#define declarePattern(name) \
    Q_PROPERTY(QJsonObject name READ name WRITE set_ ## name NOTIFY name##Changed) \
public: \
    QJsonObject name(); \
    void set_ ## name(const QJsonObject &value);

#define implementPattern(name, nullAllowed) \
    QJsonObject AppSettings::name() \
    { \
        return getPattern(name##Key, nullAllowed); \
    } \
    void AppSettings::set_##name(const QJsonObject &value) \
    { \
        setPattern(name##Key, value, &AppSettings::name, &AppSettings::name##Changed, nullAllowed); \
    }

#define declareEnabled(name) \
    Q_PROPERTY(bool name READ name WRITE set_ ## name NOTIFY name##Changed) \
public: \
    bool name(); \
    void set_ ## name(bool value);

#define implementEnabled(name, key, defaultValue) \
    bool AppSettings::name() \
    { \
        return eventEnabled(key, defaultValue); \
    } \
    void AppSettings::set_##name(bool value) \
    { \
        setEventEnabled(key, value, &AppSettings::name, &AppSettings::name##Changed); \
    }

#endif // APPSETTINGS_MACROS_H
