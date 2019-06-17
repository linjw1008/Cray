#include "udpSender.h"

udpSender::udpSender()
{
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
    //如果只发送数据不需要bind？？？？
    socket.bind(QHostAddress(remoteAddress), remotePort);
}

udpSender::~udpSender()
{
    configDHCP();
}

void udpSender::sendPacket()
{
    socket.writeDatagram(packet, QHostAddress(remoteAddress), remotePort);
    qDebug() << "send udp packet......";
}

void udpSender::updatePacket(QByteArray *p)
{
    packet = *p;
}

void udpSender::configLocalIP(QString lIP, quint16 lPort, QString lMask, QString lGate)
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
    qDebug() << "Config local ip: " << localAddress << " port: " << localPort
             << " mask: " << localMask << " gate: " << localGate;
}

void udpSender::configRemoteIP(QString rIP, quint16 rPort, QString rMask, QString rGate)
{
    remoteAddress = rIP;
    remotePort = rPort;
    remoteMask = rMask;
    remoteGate = rGate;
    qDebug() << "Config remote ip: " << remoteAddress << " port: " << remotePort
             << " mask: " << remoteMask << " gate: " << remoteGate;
}

void udpSender::configDHCP()
{
    QProcess cmd;
    QString command = "netsh interface ip set address \"以太网\" dhcp";
    cmd.start(command);
    cmd.waitForFinished();
    qDebug() << "Config local ip to DHCP";
}
