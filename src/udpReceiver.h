#ifndef UDPRECEIVER_H
#define UDPRECEIVER_H

#include <QObject>
#include <QtNetwork>
#include <QtDebug>
#include <QProcess>

class udpReceiver : public QObject
{
    Q_OBJECT
public:
    udpReceiver();
    ~udpReceiver();
    void Init();
    void receivePacket();
    void configRemoteIP(QString rIP, quint16 rPort, QString rMask, QString rGate);
    void configLocalIP(QString lIP, quint16 lPort, QString lMask, QString lGate);
    void configDHCP();
    void getPacket(QByteArray *p);
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


#endif // UDPRECEIVER_H
