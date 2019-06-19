#include "packet.h"

packet::packet()
{
    //默认正常模式
    commandMode = 0;
    //默认频率
    transmitterFrequency = 25;
    //默认发射机模式
    transmitterMode = 0;
    //默认发射机带宽
    transmitterBandwidth = 0;
}

packet::~packet()
{

}

bool packet::getConfigPacket(quint8 *configPacket)
{
    //获取发射机设置包（不到小车）
    configPacket[0] = 0xff;
    configPacket[1] = transmitterFrequency;
    configPacket[2] = transmitterBandwidth;
    configPacket[3] = transmitterMode;
    configPacket[4] = checkSum(configPacket, 5);
/*    for(quint8 i = 0; i < configPacketWidth-1; i++){
        configPacket[4] = configPacket[4] + configPacket[i];
    }
*/

    return true;
}

bool packet::getCommandPacket(quint8 *commandPacket)
{
    //获取控制包（到小车）
    //commandPacket = (quint8*)malloc(commandPacketWidth*sizeof(quint8));
    switch(commandMode)
    {
    case 0:
        //TODO
        //正常模式
        //encodeMoveParamsPacket();
        getMoveParamsPacket(commandPacket);
        break;
    case 1:
        //PID 调节模式
        getPIDParamsPacket(commandPacket);
        break;
    case 2:
        //射门力度曲线
        getCommandPacket(commandPacket);
        break;
    default:
        getMoveParamsPacket(commandPacket);
        break;
    }
    return true;
}

void packet::updateConfigParams(quint8 freq, quint8 mode, quint8 bandwidth)
{
    //配置设置包内容
    transmitterFrequency = freq;
    transmitterMode = mode;
    transmitterBandwidth = bandwidth;
}

void packet::updateMoveParams(int ID, int vX, int vY, int vR,bool dri,int driLevel,bool sMode,bool s,int sPower)
{
    //配置小车运动参数
    shoot = s;
    dribble = dri;
    shootMode = sMode;
    robotID = quint8(ID - 1);
    velX = quint8(vX);
    velY = quint8(vY);
    velR = quint8(vR);
    dribblePowerLevel = quint8(driLevel);
    shootPowerLevel = quint8(sPower);
}

void packet::updatePIDParams(float p, float i, float d)
{
    //配置小车PID参数
    kp = p;
    ki = i;
    kd = d;
}

void packet::updateShootPowerCurveParams()
{
    //射门力度曲线
}

//设置控制包的类型
//@parameter 1: mode，控制包类型: 0, 正常模式; 1, PID; 2, 射门力度调节
//return: none
void packet::updateCommandMode(quint8 mode)
{
    //设置控制包模式
    commandMode = mode;
}

//设置发射机模式
//@parameter 1: mode，发射机模式: 0, 发送模式; 1, 接收模式
//return: none
void packet::updateTransmitterMode(quint8 mode)
{
    transmitterMode = mode;
}

//设置发射机频率
//@parameter 1: freq，发射机频率编号，暂定为0~15
//return: none
void packet::updateTransmitterFrequency(quint8 freq)
{
    transmitterFrequency = freq;
}

//设置发射机发送带宽
//@parameter 1: bandwidth，发射机带宽编号，暂定为0，1,2，分别对应发射机芯片可设置的三个带宽
//return: none
void packet::updateTransmitterBandwidth(quint8 bandwidth)
{
    transmitterBandwidth = bandwidth;
}

void packet::getPIDParamsPacket(quint8 *packet)
{
    packet[0] = 0xff;
    //RobotID, set bit
    if(robotID > 7){
        packet[1] = quint8((1 << (robotID - 8)) | 0x00);
        packet[2] = 0x00;
        }
    else{
        packet[1] = 0x00;
        packet[2] = quint8(1 << (robotID));
    }
    //挑射或平射
    packet[3] = quint8(shootMode << 6 );
    //吸球力度
    packet[3] = quint8(packet[3] | (dribble ? (dribblePowerLevel << 4):0));
    //低7位速度;
    packet[4] = ((velX >= 0)?0:0x80) | (abs(velX) & 0x7f);
    packet[5] = ((velY >= 0)?0:0x80) | (abs(velY) & 0x7f);
    packet[6] = ((velR >= 0)?0:0x80) | (abs(velR) & 0x7f);
    if(packet[4] == 0xff) packet[4] = 0xfe;
    if(packet[5] == 0xff) packet[5] = 0xfe;
    if(packet[6] == 0xff) packet[6] = 0xfe;
    //高位速度
    packet[7] = ((abs(velX) & 0x180) >> 1) | ((abs(velY) & 0x180) >> 3) | ((abs(velR) & 0x180) >> 5);
    //踢球力度
    packet[8] = (shoot ? shootPowerLevel:0) & 0x7f;
    //pid参数
    //把32位浮点数转换为长度为4的char数组
    char temp[4];
    memcpy(temp, &kp, sizeof(kp));
    for(int i = 0; i < 4; i++)packet[9 + i] = quint8(temp[i]);
    memcpy(temp, &ki, sizeof(ki));
    for(int i = 0; i < 4; i++)packet[13 + i] = quint8(temp[i]);
    memcpy(temp, &kd, sizeof(kd));
    for(int i = 0; i < 4; i++)packet[17 + i] = quint8(temp[i]);
    //clear Bytes
    packet[21] = packet[22] = packet[23] = packet[24] = 0;

    packet[24] = checkSum(packet, 25);
}

void packet::getMoveParamsPacket(quint8 *packet)
{
    packet[0] = 0xff;
    //RobotID, set bit
    if(robotID > 7){
    packet[1] = quint8((1 << (robotID - 8)) | 0x00);
    packet[2] = 0x00;
    }
    else{
        packet[1] = 0x00;
        packet[2] = quint8(1 << (robotID));
    }
    //Robot1 Config
    //shoot or chip
    packet[3] = quint8(shootMode << 6 );
    //power level
    packet[3] = quint8(packet[3] | (dribble ? (dribblePowerLevel << 4):0));

    //need to fix ,complement mode for vel;
    packet[4] = ((velX >= 0)?0:0x80) | (abs(velX) & 0x7f);
    packet[5] = ((velY >= 0)?0:0x80) | (abs(velY) & 0x7f);
    packet[6] = ((velR >= 0)?0:0x80) | (abs(velR) & 0x7f);
    //Don't understand !
    if(packet[4] == 0xff) packet[4] = 0xfe;
    if(packet[5] == 0xff) packet[5] = 0xfe;
    if(packet[6] == 0xff) packet[6] = 0xfe;
    //high 2 bit Speed
    //clear Bytes
    packet[7] = packet[8] = packet[9] = packet[10] = packet[11]
            = packet[12] = packet[13] = packet[14] = packet[15]
            = packet[16] = packet[17] = packet[18] = packet[19]
            = packet[20] = packet[21] = packet[22] = packet[23]
            = packet[24] = 0;

//
    packet[15] = ((abs(velX) & 0x180) >> 1) | ((abs(velY) & 0x180) >> 3) | ((abs(velR) & 0x180) >> 5);
    packet[18] = (shoot ? shootPowerLevel:0) & 0x7f;
    packet[24] = checkSum(packet, 25);
}

void packet::getShootPowerCurveParamsPacket(quint8 *packet)
{
    packet[0] = 0xff;
    //RobotID, set bit
    if(robotID > 7){
        packet[1] = quint8((1 << (robotID - 8)) | 0x00);
        packet[2] = 0x00;
        }
    else{
        packet[1] = 0x00;
        packet[2] = quint8(1 << (robotID));
    }
    //挑射或平射
    packet[3] = quint8((shootMode << 6 ));
    //吸球力度
    packet[3] = quint8(packet[3] | (dribble ? (dribblePowerLevel << 4):0));
    //低7位速度;
    packet[4] = ((velX >= 0)?0:0x80) | (abs(velX) & 0x7f);
    packet[5] = ((velY >= 0)?0:0x80) | (abs(velY) & 0x7f);
    packet[6] = ((velR >= 0)?0:0x80) | (abs(velR) & 0x7f);
    if(packet[4] == 0xff) packet[4] = 0xfe;
    if(packet[5] == 0xff) packet[5] = 0xfe;
    if(packet[6] == 0xff) packet[6] = 0xfe;
    //高位速度
    packet[7] = ((abs(velX) & 0x180) >> 1) | ((abs(velY) & 0x180) >> 3) | ((abs(velR) & 0x180) >> 5);
    //踢球力度
    packet[8] = (shoot ? shootPowerLevel:0) & 0x7f;
    //射门力度曲线参数,
    packet[9] = a & 0x7f;
    qDebug() << "a" << (a & 0x7f) <<endl;
    packet[10] = b & 0x7f;
    qDebug() << "b" << (b & 0x7f) <<endl;
    //吸球电机转速增益
    //把32位浮点数转换为长度为4的char数组
    char temp[4];
    memcpy(temp, &dribbler_amp, sizeof(dribbler_amp));
    for(int i = 0; i < 4; i++)packet[11 + i] = quint8(temp[i]);
    //Clear bytes
    packet[15] = packet[16] = packet[17] = packet[18] = packet[19]
               = packet[20] = packet[21] = packet[22] = packet[23]
               = packet[24] = 0;
    packet[24] = checkSum(packet, 25);
}

quint8 packet::checkSum(quint8 *packet, quint8 len)
{
    quint8 checkSum = 0;
    for(int i = 0; i < len - 1; i++)
    {
        checkSum = checkSum + packet[i];
    }
    return checkSum;
}

//通过UDP发送packet
//@parameter 1: type, packet类型： 0，发送小车控制包；1，发送发射机设置包
//return: none
void packet::sendUdpPacket(quint8 type)
{
    quint8 *packet;
    QByteArray q;
    quint8 width = 0;
    if(type == 0)
    {
        width = commandPacketWidth;
        packet = (quint8*)malloc(width*sizeof(quint8));
        getCommandPacket(packet);
    }else if(type == 1){
        width = configPacketWidth;
        packet = (quint8*)malloc(width*sizeof(quint8));
        getConfigPacket(packet);
    }else{
        width = commandPacketWidth;
        packet = (quint8*)malloc(width*sizeof(quint8));
        getCommandPacket(packet);
    }
    for (int i = 0;i < width; i++) {
        q[i] =  char(packet[i]);
    }
    qDebug() << "   udp send command (length: "<<width<<")" << q.toHex();
    udpSender.updatePacket(&q);
    udpSender.sendPacket();
}

//设置远程IP地址
//return: none
void packet::configUdpRemoteIP(QString rIP, QString rPort, QString rMask, QString rGate)
{
    udpSender.configRemoteIP(rIP, quint16(rPort.toInt()), rMask, rGate);
}

//设置本地IP地址
//return: none
void packet::configUdpLocalIP(QString lIP, QString lPort, QString lMask, QString lGate)
{
    udpSender.configLocalIP(lIP, quint16(lPort.toInt()), lMask, lGate);
}

//设置为动态ip
void packet::configDHCP()
{
    udpSender.configDHCP();
}
