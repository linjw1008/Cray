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
    void updatePidParams(float p, float i, float d){
        this->p = p;
        this->i = i;
        this->d = d;
    }
    void updateShootPowerCurveParams(quint8 a, quint8 b, float dribbler_amp){
        this->a = a;
        this->b = b;
        this->dribbler_amp = dribbler_amp;
    }
    //设置pid调节packet模式
    //mode = 1 正常模式
    //mode = 2 pid调节模式
    void updatePidTuneMode(quint8 mode){
        this->pidTuneMode = mode;
        qDebug()<<pidTuneMode<<endl;
    }
    //设置射门力度曲线调节packet模式
    //mode = 1 正常模式
    //mode = 2 调节模式
    void updateShootPowerCurveTuneMode(quint8 mode){
        this->shootPowerCurveTuneMode = mode;
        qDebug()<<shootPowerCurveTuneMode<<endl;
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
    quint8 pidTuneMode = 1;
    quint8 shootPowerCurveTuneMode = 1;
    float p;
    float i;
    float d;
    quint8 a;
    quint8 b;
    float dribbler_amp;
};

#endif // RADIOPACKET_H
