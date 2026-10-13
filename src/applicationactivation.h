#ifndef APPLICATIONACTIVATION_H
#define APPLICATIONACTIVATION_H

#include <QObject>
#include <QQuickView>

class ApplicationActivation : public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "dev.rikudou.InariBlueNotifier")

public:
    explicit ApplicationActivation(QQuickView *view, QObject *parent = nullptr);

public slots:
    void open();

private:
    QQuickView *view;

};

#endif // APPLICATIONACTIVATION_H
