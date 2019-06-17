#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlEngine>
#include <QtDebug>
#include <QFont>
#include <iostream>
#include "serialobject.h"
#include "translation.hpp"
#include "udpSender.h"
#include "packet.h"
using namespace std;


void qmlRegister(){
    qmlRegisterType<SerialObject>("Client.Component", 1, 0, "Serial");
    qmlRegisterType<TranslationTest>("Client.Component", 1, 0, "Translator");
    qmlRegisterType<udpSender>("Client.Component", 1, 0, "UdpSender");
    qmlRegisterType<packet>("Client.Component", 1, 0, "Packet");
}
int main(int argc, char *argv[]) {
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

#if defined(Q_OS_WIN32)
    //app.setFont(QFont("Microsoft YaHei",9));
    app.setFont(QFont("宋体",9));
#elif defined(Q_OS_MAC)
    app.setFont(QFont("Helvetica",14));
#endif
    qmlRegister();
    QQmlApplicationEngine engine;
    engine.load(QUrl(QLatin1String("qrc:/src/qml/main.qml")));
    return app.exec();
}
