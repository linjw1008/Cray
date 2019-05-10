#ifndef SERIALOBJECT_H
#define SERIALOBJECT_H

#include <QObject>
#include <QString>
#include <QtDebug>
#include <QSerialPort>
#include "radiopacket.h"

class SerialObject : public QObject
{
    Q_OBJECT
public:
    SerialObject(QObject *parent = 0);
    Q_INVOKABLE QString getName(int itemIndex) const;
    Q_INVOKABLE QStringList getCrazySetting(int itemIndex) const;
    Q_INVOKABLE void sendCrazySetting(int itemIndex,int index);
    Q_INVOKABLE int getDefaultIndex(int itemIndex) const;
    Q_INVOKABLE void openSerialPort();
    Q_INVOKABLE void closeSerialPort();
    Q_INVOKABLE void sendStartPacket();
    Q_INVOKABLE void sendCommand(){radioPacket.sendCommand();}
    Q_INVOKABLE void updateCommandParams(int robotID,int velX,int velY,int velR,bool dribble,int dribbleLevel,bool mode,bool shoot,int power){
        radioPacket.updateCommandParams(robotID,velX,velY,velR,dribble,dribbleLevel,mode,shoot,power);
    }
    Q_INVOKABLE void updatePidParams(float p, float i, float d){
        radioPacket.updatePidParams(p, i, d);
    }
    Q_INVOKABLE void updatePidTuneMode(quint8 mode){
        radioPacket.updatePidTuneMode(mode);
    }
    Q_INVOKABLE void updateShootPowerCurveParams(quint8 a, quint8 b, float dirbbler_amp){
        radioPacket.updateShootPowerCurveParams(a, b, dirbbler_amp);
    }
    Q_INVOKABLE void updateShootPowerCurveTuneMode(quint8 mode){
        radioPacket.updateShootPowerCurveTuneMode(mode);
    }
private:
    QStringList ports;
    QStringList settingsName;
    QList<qint32> baudRate;
    QStringList stringBaudRate;
    QList<QSerialPort::DataBits> dataBits;
    QStringList stringDataBits;
    QList<QSerialPort::Parity> parity;
    QStringList stringParity;
    QList<QSerialPort::StopBits> stopBits;
    QStringList stringStopBits;
    QList<quint8> frequency;
    QStringList stringFrequency;
    QByteArray currentIndex;
    QByteArray defaultIndex;
    QSerialPort serial;
    RadioPacket radioPacket;
};

#endif // SERIALOBJECT_H
