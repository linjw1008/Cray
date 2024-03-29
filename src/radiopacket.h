#ifndef RADIOPACKET_H
#define RADIOPACKET_H

#include <QSerialPort>
#include <QtDebug>
class RadioPacket
{
public:
    explicit RadioPacket(QSerialPort* serialPtr);
    bool sendStartPacket();
    bool sendCommand();
    void updateCommandParams(int robotID,int velX,int velY,int velR,bool ctrl,int ctrlLevel,bool mode,bool shoot,int power){
        this->robotID = robotID - 1;
        this->velX = velX; this->velY = velY; this->velR = velR;
        this->ctrl = ctrl;
        this->shootMode = mode;this->shoot = shoot; this->shootPowerLevel = power;
        this->ctrlPowerLevel = ctrlLevel;
    }
    void updateFrequency(int);
private:
    static const int TRANSMIT_PACKET_SIZE = 25;
    static const int TRANS_FEEDBACK_SIZE = 20;
    QByteArray startPacket1;
    QByteArray startPacket2;
    QByteArray transmitPacket;
    QSerialPort* serialPtr;
    bool encode();
private:
    bool shoot;
    bool ctrl;
    bool shootMode;//false is "flat shoot" and true is "lift shoot".
    quint8 robotID;
    qint16 velX;
    qint16 velY;
    qint16 velR;
    quint16 ctrlPowerLevel;
    quint16 shootPowerLevel;
};

#endif // RADIOPACKET_H
