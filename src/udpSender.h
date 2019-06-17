#ifndef UDPSENDER_H
#define UDPSENDER_H

#include <QObject>
#include <QtNetwork>
#include <QtDebug>
#include <QProcess>

class udpSender : public QObject
{
    Q_OBJECT
public:
    udpSender();
    ~udpSender();
    void Init();
    void sendPacket();
    void configRemoteIP(QString rIP, quint16 rPort, QString rMask, QString rGate);
    void configLocalIP(QString lIP, quint16 lPort, QString lMask, QString lGate);
    void configDHCP();
    void updatePacket(QByteArray *p);
private:
    QUdpSocket socket;
    QString remoteAddress;
    QString remoteMask;
    QString remoteGate;
    quint16 remotePort;
    QByteArray packet;
    QString localAddress;
    QString localMask;
    QString localGate;
    quint16 localPort;
};


#endif // UDPSENDER_H
