#ifndef PACKET_H
#define PACKET_H

#include <QObject>
#include <QtDebug>
#include "udpSender.h"

class packet : public QObject
{
    Q_OBJECT
public:
    packet();
    ~packet();

    bool getConfigPacket(quint8 *configPacket);
    bool getCommandPacket(quint8 *commandPacket);
    Q_INVOKABLE void updateConfigParams(quint8 freq, quint8 mode, quint8 bandwidth);
    Q_INVOKABLE void updateMoveParams(int ID, int vX, int vY, int vR,bool dri,int driLevel,bool sMode,bool s,int sPower);
    Q_INVOKABLE void updatePIDParams(float p, float i, float d);
    Q_INVOKABLE void updateShootPowerCurveParams();
    Q_INVOKABLE void updateCommandMode(quint8 mode);
    Q_INVOKABLE void updateTransmitterMode(quint8 mode);
    Q_INVOKABLE void updateTransmitterFrequency(quint8 freq);
    Q_INVOKABLE void updateTransmitterBandwidth(quint8 bandwidth);

    //网络发包相关
    Q_INVOKABLE void sendUdpPacket(quint8 type);
    Q_INVOKABLE void configUdpRemoteIP(QString rIP, QString rPort, QString rMask, QString rGate);
    Q_INVOKABLE void configUdpLocalIP(QString lIP, QString lPort, QString lMask, QString lGate);
    Q_INVOKABLE void configDHCP();

private:
    bool shoot;
    bool dribble;
    bool shootMode;//false is "flat shoot" and true is "lift shoot".
    quint8 robotID;
    qint16 velX;
    qint16 velY;
    qint16 velR;
    quint16 dribblePowerLevel;
    quint16 shootPowerLevel;
    quint8 commandMode;
    float kp;
    float ki;
    float kd;
    quint8 a;
    quint8 b;
    float dribbler_amp;

    quint8 transmitterFrequency;
    quint8 transmitterMode;
    quint8 transmitterBandwidth;

    udpSender udpSender;

    quint8 commandPacketWidth = 25;
    quint8 configPacketWidth = 25;

    void getPIDParamsPacket(quint8 *packet);
    //void encodeMoveParamsPacket();
    void getMoveParamsPacket(quint8 *packet);
    void getShootPowerCurveParamsPacket(quint8 *packet);
};

#endif // PACKET_H
