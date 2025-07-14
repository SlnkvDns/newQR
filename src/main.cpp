#include <auroraapp.h>
#include <QtQuick>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "QZXing.h"
#include "hasher.h"
#include "variantdistributor.h"
#include "variantdb.h"

int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> application(Aurora::Application::application(argc, argv));
    application->setOrganizationName(QStringLiteral("ru.template"));
    application->setApplicationName(QStringLiteral("QRLearning"));

    QZXing::registerQMLTypes();
    qmlRegisterType<Hasher>("Utils", 1, 0, "Hasher");

    qmlRegisterType<VariantDistributor>("ru.auroraos.QrCodeReader", 1, 0, "VariantDistributor");
    qmlRegisterType<VariantDB>("ru.auroraos.QrCodeReader", 1, 0, "VariantDB"); // Регистрация VariantDB

    // Создание динамического объекта supabase
    VariantDB *supabase = new VariantDB(application.data());
    QScopedPointer<QQuickView> view(Aurora::Application::createView());
    view->rootContext()->setContextProperty("supabase", supabase);
    view->setSource(Aurora::Application::pathTo(QStringLiteral("qml/QRLearning.qml")));
    view->show();

    int result = application->exec();

    // Очистка объекта supabase при завершении приложения
    delete supabase;

    return result;
}
