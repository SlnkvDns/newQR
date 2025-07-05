#include <auroraapp.h>
#include <QtQuick>
#include "QZXing.h"

int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> application(Aurora::Application::application(argc, argv));
    application->setOrganizationName(QStringLiteral("ru.template"));
    application->setApplicationName(QStringLiteral("QRLearning"));

    QZXing::registerQMLTypes();

    QScopedPointer<QQuickView> view(Aurora::Application::createView());
    view->setSource(Aurora::Application::pathTo(QStringLiteral("qml/QRLearning.qml")));
    view->show();

    return application->exec();
}
