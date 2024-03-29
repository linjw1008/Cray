#include "radiopacket.h"
#include "lib/crc/crc.h"
#include <QSerialPort>
#include <QElapsedTimer>
#include <cstdio>
RadioPacket::RadioPacket(QSerialPort* serialPtr)
    : startPacket1(TRANSMIT_PACKET_SIZE,0)//25 Bytes
    , startPacket2(TRANSMIT_PACKET_SIZE,0)//25 Bytes
    , transmitPacket(TRANSMIT_PACKET_SIZE,0)//25 Bytes
    , serialPtr(serialPtr)
    , shoot(false), ctrl(false), shootMode(false), robotID(0)
    , velX(0), velY(0), velR(0)
    , ctrlPowerLevel(2), shootPowerLevel(0){

    startPacket1[0] = 0xff;
    startPacket1[1] = 0xb0;
    startPacket1[2] = 0x01;
    startPacket1[3] = 0x02;
    startPacket1[4] = 0x03;
    startPacket1[TRANSMIT_PACKET_SIZE - 1] = 0x31;

    startPacket2[0] = 0xff;
    startPacket2[1] = 0xb0;
    startPacket2[2] = 0x04;
    startPacket2[3] = 0x05;
    startPacket2[4] = 0x06;
    encode();
}

bool RadioPacket::sendStartPacket(){
    if(serialPtr != NULL){
        //send startPacket1，第一次握手
        serialPtr->write((startPacket1.data()),TRANSMIT_PACKET_SIZE);
        serialPtr->flush();
        if (serialPtr->waitForBytesWritten(2000)) {
            if (serialPtr->waitForReadyRead(2000)) {
                //收到包，第二次握手
                QByteArray responseData = serialPtr->readAll();
                while (serialPtr->waitForReadyRead(10))
                    responseData += serialPtr->readAll();
            }
        } else {
            qDebug() << "Start packet write timeout!";
        }
        //send startPacket2，第三次握手
        serialPtr->write((startPacket2.data()),TRANSMIT_PACKET_SIZE);
        serialPtr->flush();
        return true;
    }
    return false;
}
void RadioPacket::updateFrequency(int frequency){
    startPacket2[5] = 0x10 + frequency;
    startPacket2[TRANSMIT_PACKET_SIZE - 1] = CCrc8::calc((unsigned char*)(startPacket2.data()), TRANSMIT_PACKET_SIZE - 1);
}
//发送指令
bool RadioPacket::sendCommand(){
    static int times = 0;
    static QElapsedTimer timer;
    if(times == 0) timer.start();
    if(serialPtr != NULL){
        encode();
        //qDebug() << transmitPacket.toHex();
        //transmitPacket是包含命令的包
        serialPtr->write((transmitPacket.data()),TRANSMIT_PACKET_SIZE);
        serialPtr->flush();
        return true;
    }
    return false;
}
//编码
bool RadioPacket::encode(){
    //head, always 0xff
    transmitPacket[0] = 0xff;
    //RobotID, set bit
    if(robotID > 7){
        transmitPacket[1] = (1 << (robotID - 8)) | 0x00;
        transmitPacket[2] = 0x00;
    }
    else{
        transmitPacket[1] = 0x00;
        transmitPacket[2] = 1 << (robotID);
    }
    //Robot1 Config
    //shoot or chip
    transmitPacket[3] = (shootMode << 6 );
    //power level
    transmitPacket[3] = transmitPacket[3] | (ctrl ? (ctrlPowerLevel << 4):0);

    //need to fix ,complement mode for vel;
    transmitPacket[4] = ((velX >= 0)?0:0x80) | (abs(velX) & 0x7f);
    transmitPacket[5] = ((velY >= 0)?0:0x80) | (abs(velY) & 0x7f);
    transmitPacket[6] = ((velR >= 0)?0:0x80) | (abs(velR) & 0x7f);
    //Don't understand !
    if(transmitPacket[4] == char(0xff)) transmitPacket[4] = 0xfe;
    if(transmitPacket[5] == char(0xff)) transmitPacket[5] = 0xfe;
    if(transmitPacket[6] == char(0xff)) transmitPacket[6] = 0xfe;
    //high 2 bit Speed
    //clear Byte[15-24]
    transmitPacket[15] = transmitPacket[16] = transmitPacket[17] = transmitPacket[18] = transmitPacket[19] = transmitPacket[20] = transmitPacket[21] = transmitPacket[22] = transmitPacket[23] = transmitPacket[24] = 0;
    //
    transmitPacket[15] = ((abs(velX) & 0x180) >> 1) | ((abs(velY) & 0x180) >> 3) | ((abs(velR) & 0x180) >> 5);
    transmitPacket[18] = (shoot ? shootPowerLevel:0) & 0x7f;
    return true;
}
