#include "udpReceiver.h"

udpReceiver::udpReceiver()
{
    /*
     *
     * TODO
     *
     * 需要对应修改*/
    localAddress = "192.168.0.101";
    localPort = 10007;
    localMask = "255.255.255.0";
    localGate = "192.168.0.1";
    remoteAddress = "192.168.0.100";
    remotePort = 10007;
    remoteMask = "255.255.255.0";
    remoteGate = "192.168.0.1";
    packet = "test";
    configLocalIP(localAddress, localPort, localMask, localGate);
    //???????
    socket.bind(QHostAddress(remoteAddress), remotePort);
}

udpReceiver::~udpReceiver()
{
    //configDHCP();
}

void udpReceiver::receivePacket()
{
    /*TODO
    有待测试
    */
    char *receivedPacket;
    socket.readDatagram(receivedPacket, 25);
    packet = QByteArray(receivedPacket);
}

void udpReceiver::getPacket(QByteArray *p)
{
    /*TODO
    有待测试
    */
    p = &packet;
}

void udpReceiver::configLocalIP(QString lIP, quint16 lPort, QString lMask, QString lGate)
{
    localAddress = lIP;
    localPort = lPort;
    localMask = lMask;
    localGate = lGate;

    QProcess cmd;
    QString command = "netsh interface ip set address \"以太网\" static "
             + localAddress + " " + localMask + " " + localGate;
    cmd.start(command);
    cmd.waitForFinished();
    qDebug() << "From udpReceiver: Config local ip: " << localAddress << " port: " << localPort
             << " mask: " << localMask << " gate: " << localGate;
}

void udpReceiver::configRemoteIP(QString rIP, quint16 rPort, QString rMask, QString rGate)
{
    remoteAddress = rIP;
    remotePort = rPort;
    remoteMask = rMask;
    remoteGate = rGate;
    qDebug() << "From udpReceiver: Config remote ip: " << remoteAddress << " port: " << remotePort
             << " mask: " << remoteMask << " gate: " << remoteGate;
}

void udpReceiver::configDHCP()
{
    QProcess cmd;
    QString command = "netsh interface ip set address \"以太网\" dhcp";
    cmd.start(command);
    cmd.waitForFinished();
    qDebug() << "From udpReceiver: Config local ip to DHCP";
}
