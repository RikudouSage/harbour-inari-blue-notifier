#include "applicationactivation.h"

ApplicationActivation::ApplicationActivation(QQuickView *view, QObject *parent) : QObject(parent), view(view)
{

}

void ApplicationActivation::open()
{
    if (view) {
        view->show();
        view->raise();
        view->requestActivate();
    }
}
