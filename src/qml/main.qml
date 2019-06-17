import QtQuick 2.6
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.2
import Client.Component 1.0 as Client
ApplicationWindow{
    visible:true;
    width: 630;
    height: 460;
    /*
    //固定窗口大小
    minimumHeight: height;
    minimumWidth: width;
    maximumHeight: height;
    maximumWidth: width;
    */
    color:"lightgrey";
    id:root;
    property color wcolor : "lightgrey"
    property color tcolor : "black"
    Client.Serial { id : serial; }
    Client.Translator{ id : translator; }
    Client.UdpSender {id : udpsender; }
    Client.Packet {id : packet; }
    Timer{
        id:timer;
        interval:100;//15ms启动一次
        running:false;
        repeat:true;
        onTriggered: {
            pidTuneShow.updateMode();//设置是否为PID调节模式
            shootPowerCurveTuneShow.updateMode();//设置是否为射门力度曲线调节模式
            moveParametersList.updateCommand();//调用serial.updateCommandParams()
            serial.sendCommand();//把数据发出去
            //发送网络包
            //packet.getCommandPacket(p);
            //udpsender.updatePacket(p);
            packet.sendUdpPacket(0);

            if(moveParametersList.shoot){
                moveParametersList.shoot = !moveParametersList.shoot;
            }
        }
    }
    Rectangle{
        id : radio;
        anchors.fill: parent;
        Rectangle{
            radius: 5;
            width:parent.width;
            anchors.top: parent.top;
            anchors.bottom: parent.bottom;
            color: wcolor
            id:transmitterConfig;
            //最上面一条Box
            GroupBox{
                id : configParameters;
                width: parent.width - 15;
                anchors.horizontalCenter: parent.horizontalCenter;
                anchors.top: parent.top;
                anchors.margins: 10;
                title :qsTr("Transmitter Setting") + translator.emptyString;

                //设置参数
                property string remoteIP: remoteIP.text;
                property string remoteGate: remoteGate.text;
                property string remoteMask: remoteMask.text;
                property string remotePort: remotePort.text;
                property int frequency: frequency.currentIndex;

                Grid{
                    height:parent.height;
                    id : configParametersList;
                    verticalItemAlignment: Grid.AlignVCenter;
                    horizontalItemAlignment: Grid.AlignLeft;
                    anchors.horizontalCenter: parent.horizontalCenter;
                    columnSpacing: 10;
                    rowSpacing: 5;
                    columns: 8;
                    rows: 2;
                    //enabled: !transmitterConnect.ifConnected;
                    property int textWidth : 30;
                    property int inputWidth : 90;


                    //ip设置相关
                    Text {
                        text: qsTr("remote IP:");
                        width: parent.textWidth*2;
                        color: tcolor;
                    }
                    TextField{
                        id: remoteIP;
                        focus: true;
                        text: "192.168.0.100";
                        onEditingFinished: /*TODO*/console.debug(configParameters.remoteIP);
                        width: parent.inputWidth;
                    }
                    Text {
                        text: qsTr("Gate:");
                        width: parent.textWidth;
                        color: tcolor;
                    }
                    TextField{
                        id: remoteGate;
                        focus: true;
                        text: "192.168.0.1";
                        onEditingFinished: /*TODO*/console.debug(configParameters.remoteGate);
                        width: parent.inputWidth;
                    }
                    Text {
                        text: qsTr("Mask:");
                        width: parent.textWidth;
                        color: tcolor;
                    }
                    TextField{
                        id: remoteMask;
                        focus: true;
                        text: "255.255.255.0";
                        onEditingFinished: /*TODO*/console.debug(configParameters.remoteMask);
                        width: parent.inputWidth;
                    }
                    Text {
                        text: qsTr("Port:");
                        width: parent.textWidth;
                        color: tcolor;
                    }
                    TextField{
                        id: remotePort;
                        focus: true;
                        text: "10007";
                        onEditingFinished: /*TODO*/console.debug(configParameters.remotePort);
                        width: parent.inputWidth/2;
                    }
                    //频率相关
                    Text{
                        text: qsTr("Frequency")+ translator.emptyString;
                        width:parent.textWidth;
                        color: tcolor
                    }
                    ComboBox{
                        id: frequency;
                        model: ListModel{
                            id: frequencyList
                            ListElement { text: "0"}
                            ListElement { text: "1"}
                            ListElement { text: "2"}
                            ListElement { text: "3"}
                            ListElement { text: "4"}
                            ListElement { text: "5"}
                            ListElement { text: "6"}
                            ListElement { text: "7"}
                            ListElement { text: "8"}
                            ListElement { text: "9"}
                        }
                        currentIndex : 0;
                        onActivated:/*TODO*/console.debug(configParameters.frequency);
                        width:parent.inputWidth;
                    }
                }
            }
            //连接按钮
            Button{
                id : transmitterConnect;
                width: 90;
                state : "unconnected"
                property bool isConnected:false;
                states:[
                    State{
                        name: "connected"
                        PropertyChanges{target:transmitterConnect ; text:qsTr("Disconnect")}
                        PropertyChanges{target:transmitterConnect ; isConnected:true}
                        PropertyChanges{target:crazyStart ; enabled:true}
                        PropertyChanges{target:configParametersList ; enabled:false}
                    },
                    State{
                        name: "unconnected"
                        PropertyChanges{target:transmitterConnect ; text:qsTr("Connect")}
                        PropertyChanges{target:transmitterConnect ; isConnected:false}
                        PropertyChanges{target:crazyStart ; enabled:false}
                        PropertyChanges{target:configParametersList ; enabled:true}
                    }
                ]
                anchors.top: configParameters.bottom;
                anchors.right: parent.right;
                anchors.rightMargin: 20;
                anchors.topMargin: 5;
                onClicked: clickEvent();
                function clickEvent(){
                    if(isConnected){
                        timer.stop();
                        transmitterConnect.state = "unconnected";
                        packet.configDHCP();
                    }else{
                        transmitterConnect.state = "connected";
                        packet.configUdpRemoteIP(configParameters.remoteIP, configParameters.remotePort, configParameters.remoteMask, configParameters.remoteGate);
                        console.debug("config remote ip");
                        packet.updateTransmitterFrequency(configParameters.frequency);
                        packet.sendUdpPacket(1);
                        console.debug("config frequency: " + configParameters.frequency);

                    }
                }
            }
            //下面大的Box
            GroupBox{
                title : qsTr("Manual Control") + translator.emptyString;
                width:parent.width - 15;
                anchors.top:transmitterConnect.bottom;
                anchors.horizontalCenter: parent.horizontalCenter;
                id : moveParameters;
                Grid{
                    id : moveParametersList;
                    columns: 6;//6列
                    rows: 5
                    verticalItemAlignment: Grid.AlignVCenter;
                    horizontalItemAlignment: Grid.AlignLeft;
                    anchors.horizontalCenter: parent.horizontalCenter;
                    columnSpacing: 10;
                    rowSpacing: 7;
                    property int robotID : 1;//Robot
                    property int velX : 0;//Vx
                    property int velY : 0;//Vy
                    property int velR : 0;//Vr
                    property bool shoot : false;//Shoot
                    property bool dribble : false;//Dribb

                    property int velXStep : 15;//VxStep
                    property int velYStep : 15;//VyStep
                    property int velRStep : 15;//VrStep
                    property bool kickmode : false;//KickMode
                    property int dribbleLevel : 2;//DribLevel

                    property int m_VEL : 255//MaxVel
                    property int velocityRMax : 511;//MaxVelR
                    property int power : 20;//KickPower

                    property int m_VELR : 255
                    property int velocityMax : 511;//最大速度
                    property int dribbleMaxLevel : 3;//吸球最大等级
                    property int kickPowerMax: 127;//最大踢球力量
                    property int itemWidth : 70;

                    Text{ text:qsTr("Robot") + translator.emptyString; color: tcolor;}
                    //最多12辆车
                    SpinBox{ minimumValue:1; maximumValue:12; value:moveParametersList.robotID; width:moveParametersList.itemWidth
                        onEditingFinished:{moveParametersList.robotID = value}}
                    Text{ text:"Stop"; color: tcolor }
                    Button{ text:qsTr("[Space]") + translator.emptyString;width:moveParametersList.itemWidth}

                    Text{ text:" " }

                    Text{ text:" " }

                    Text{ text:qsTr("Vx [W/S]") + translator.emptyString; color: tcolor }
                    SpinBox{ minimumValue:-moveParametersList.m_VEL; maximumValue:moveParametersList.m_VEL; value:moveParametersList.velX;width:moveParametersList.itemWidth
                        onEditingFinished:{moveParametersList.velX = value;}}

                    Text{ text:qsTr("MaxVel") + translator.emptyString; color: tcolor }
                    SpinBox{ minimumValue:1; maximumValue:moveParametersList.velocityMax; value:moveParametersList.m_VEL;width:moveParametersList.itemWidth
                        onEditingFinished:{moveParametersList.m_VEL = value;}}

                    Text{ text:qsTr("KickMode [Up]")  + translator.emptyString; color: tcolor}
                    Button{ text:(moveParametersList.kickmode?qsTr("chip"):qsTr("flat")) + translator.emptyString;width:moveParametersList.itemWidth
                        onClicked: {
                            moveParametersList.kickmode = !moveParametersList.kickmode
                        }
                    }

                    Text{ text:qsTr("Vr [Left/Right]")  + translator.emptyString; color: tcolor}
                    SpinBox{ minimumValue:-moveParametersList.m_VELR; maximumValue:moveParametersList.m_VELR; value:moveParametersList.velR;width:moveParametersList.itemWidth
                        onEditingFinished:{moveParametersList.velR = value;}}

                    Text{ text:qsTr("MaxVelR") + translator.emptyString; color: tcolor }
                    SpinBox{ minimumValue:1; maximumValue:moveParametersList.velocityRMax; value:moveParametersList.m_VELR;width:moveParametersList.itemWidth
                        onEditingFinished:{moveParametersList.m_VELR = value;}}

                    Text{ text:qsTr("Shoot [E]") + translator.emptyString; color: tcolor}
                    Button{ text:(moveParametersList.shoot? qsTr("true") : qsTr("false")) + translator.emptyString;width:moveParametersList.itemWidth
                        onClicked: {
                            moveParametersList.shoot = !moveParametersList.shoot;
                        }
                    }

                    Text{ text:qsTr("Vy [A/D]") + translator.emptyString; color: tcolor}
                    SpinBox{ minimumValue:-moveParametersList.m_VEL; maximumValue:moveParametersList.m_VEL; value:moveParametersList.velY;width:moveParametersList.itemWidth
                        onEditingFinished:{moveParametersList.velY = value;}}

                    Text{ text:qsTr("KickPower") + translator.emptyString; color: tcolor }
                    SpinBox{ minimumValue:0; maximumValue:moveParametersList.kickPowerMax; value:moveParametersList.power;width:moveParametersList.itemWidth
                        onEditingFinished:{moveParametersList.power = value;}}

                    Text{ text:qsTr("Dribb [Q]") + translator.emptyString; color: tcolor }
                    Button{ text:(moveParametersList.dribble ? qsTr("true") : qsTr("false")) +translator.emptyString;width:moveParametersList.itemWidth
                        onClicked: {
                            moveParametersList.dribble = !moveParametersList.dribble;
                        }
                    }

                    Text{ text:qsTr("DribLevel")  + translator.emptyString; color: tcolor}
                    SpinBox{ minimumValue:0; maximumValue:moveParametersList.dribbleMaxLevel; value:moveParametersList.dribbleLevel;width:moveParametersList.itemWidth
                        onEditingFinished:{moveParametersList.dribbleLevel = value;}}

                    Text{ text:" " }

                    Text{ text:" " }

                    Rectangle{
                        width:moveParametersList.itemWidth; height:20; color:moveParametersList.dribble ? "blue" : "lightgrey";
                    }

                    Rectangle{
                        width:moveParametersList.itemWidth; height:20; color:moveParametersList.shoot ? "red" : "lightgrey";
                    }



                    //键盘响应实现
                    Keys.onPressed:getFocus(event);
                    function getFocus(event){
                        switch(event.key){
                        case Qt.Key_Enter:
                        case Qt.Key_Return:
                        case Qt.Key_Escape:
                            moveParametersList.focus = true;
                            break;
                        default:
                            event.accepted = false;
                            return false;
                        }
                        event.accepted = true;
                    }
                    function updateStop(){
                        moveParametersList.velX = 0;
                        moveParametersList.velY = 0;
                        moveParametersList.velR = 0;
                        moveParametersList.shoot = false;
                        moveParametersList.dribble = false;
                        moveParametersList.rush = false;
                    }
                    function handleKeyboardEvent(e){
                        switch(e){
                        case 'U':{moveParametersList.kickmode = !moveParametersList.kickmode;break;}
                        case 'a':{moveParametersList.velY = moveParametersList.limitVel(moveParametersList.velY-moveParametersList.velYStep,-moveParametersList.m_VEL,moveParametersList.m_VEL);
                            break;}
                        case 'd':{moveParametersList.velY = moveParametersList.limitVel(moveParametersList.velY+moveParametersList.velYStep,-moveParametersList.m_VEL,moveParametersList.m_VEL);
                            break;}
                        case 'w':{moveParametersList.velX = moveParametersList.limitVel(moveParametersList.velX+moveParametersList.velXStep,-moveParametersList.m_VEL,moveParametersList.m_VEL);
                            break;}
                        case 's':{moveParametersList.velX = moveParametersList.limitVel(moveParametersList.velX-moveParametersList.velXStep,-moveParametersList.m_VEL,moveParametersList.m_VEL);
                            break;}
                        case 'q':{moveParametersList.dribble = !moveParametersList.dribble;
                            break;}
                        case 'e':{moveParametersList.shoot = !moveParametersList.shoot;
                            break;}
                        case 'L':{moveParametersList.velR = moveParametersList.limitVel(moveParametersList.velR-moveParametersList.velRStep,-moveParametersList.m_VELR,moveParametersList.m_VELR);
                            break;}
                        case 'R':{moveParametersList.velR = moveParametersList.limitVel(moveParametersList.velR+moveParametersList.velRStep,-moveParametersList.m_VELR,moveParametersList.m_VELR);
                            break;}
                        case 'S':{moveParametersList.updateStop();
                            break;}
                        default:
                            return false;
                        }
                        updateCommand();
                    }
                    //serial.updateCommandParams在C++中实现
                    function updateCommand(){
                        packet.updateMoveParams(moveParametersList.robotID, moveParametersList.velX,
                                                moveParametersList.velY, moveParametersList.velR,
                                                moveParametersList.dribble, moveParametersList.dribbleLevel,
                                                moveParametersList.kickmode, moveParametersList.shoot,
                                                moveParametersList.power);
                    }
                    function limitVel(vel,minValue,maxValue){
                        if(vel>maxValue) return maxValue;
                        if(vel<minValue) return minValue;
                        return vel;
                    }
                    //键盘快捷键定义
                    Shortcut{
                        sequence:"A";
                        onActivated:moveParametersList.handleKeyboardEvent('a');
                    }
                    Shortcut{
                        sequence:"Up";
                        onActivated:moveParametersList.handleKeyboardEvent('U');
                    }
                    Shortcut{
                        sequence:"D"
                        onActivated:moveParametersList.handleKeyboardEvent('d');
                    }
                    Shortcut{
                        sequence:"W"
                        onActivated:moveParametersList.handleKeyboardEvent('w');
                    }
                    Shortcut{
                        sequence:"S"
                        onActivated:moveParametersList.handleKeyboardEvent('s');
                    }
                    Shortcut{
                        sequence:"Q"
                        onActivated:moveParametersList.handleKeyboardEvent('q');
                    }
                    Shortcut{
                        sequence:"E"
                        onActivated:moveParametersList.handleKeyboardEvent('e');
                    }
                    Shortcut{
                        sequence:"Left"
                        onActivated:moveParametersList.handleKeyboardEvent('L');
                    }
                    Shortcut{
                        sequence:"Right"
                        onActivated:moveParametersList.handleKeyboardEvent('R');
                    }
                    Shortcut{
                        sequence:"Space"
                        onActivated:moveParametersList.handleKeyboardEvent('S');
                    }
                }
            }
            //PID方框
            GroupBox{
                title: qsTr("PID Tune Mode (Switch robot MODE to 5 first)") + translator.emptyString;
                width: parent.width - 15;
                anchors.top: moveParameters.bottom;
                anchors.horizontalCenter: parent.horizontalCenter;
                id: pidParameters;
                Grid{
                    id: pidParametersList;
                    anchors.top: pidTuneMode.bottom;
                    columns: 8;
                    verticalItemAlignment: Grid.AlignVCenter;
                    horizontalItemAlignment: Grid.AlignLeft;
                    anchors.horizontalCenter: parent.horizontalCenter;
                    columnSpacing: 10;
                    rowSpacing: 5;
                    property real p: 0.0025;//P
                    property real i: 0.0075;//I
                    property real d: 0.00;//D
                    property real min_p: 0.0;
                    property real max_p: 10.0;
                    property real min_i: 0.0;
                    property real max_i: 10.0;
                    property real min_d: 0.0;
                    property real max_d: 10.0;
                    property bool mode: false;
                    Text { id: pidTuneMode; text: qsTr("PID Tune Mode"); color: tcolor }
                    CheckBox {
                        id: pidCheckBox;
                        enabled: ture;
                        onClicked: {
                            pidParametersList.mode = !pidParametersList.mode;
                            if(pidParametersList.mode)
                            {
                                packet.updateCommandMode(1);
                                shootPowerCurveCheckbox.enabled = false;
                            }else{
                                packet.updateCommandMode(0);
                                shootPowerCurveCheckbox.enabled = true;
                            }
                        }
                    }
                    Text {text: qsTr("Kp")  + translator.emptyString; color: tcolor }
                    TextField{
                        validator: DoubleValidator{decimals: 5; bottom: pidParametersList.min_p; top: pidParametersList.max_p;}
                        focus: true;
                        text: "0.0025";
                        onEditingFinished: {
                            pidParametersList.p = text;
                            updatePidParameters();
                        }
                        width: 100;
                    }
                    Text { text: qsTr("Ki")  + translator.emptyString; color: tcolor }
                    TextField{
                        validator: DoubleValidator{decimals: 5; bottom: pidParametersList.min_i; top: pidParametersList.max_i;}
                        focus: true;
                        text: "0.0075";
                        onEditingFinished: {
                            pidParametersList.i = text;
                            updatePidParameters();
                        }
                        width: 100;
                    }
                    Text { text: qsTr("Kd")  + translator.emptyString; color: tcolor }
                    TextField{
                        validator: DoubleValidator{decimals: 5; bottom: pidParametersList.min_d; top: pidParametersList.max_d;}
                        focus: true;
                        text: "0.0000";
                        onEditingFinished: {
                            pidParametersList.d = text;
                            updatePidParameters();
                        }
                        width: 100;
                    }
                    //更新参数
                    function updatePidParameters(){
                        if(pidParametersList.mode)
                        {
                            packet.updatePidParams(pidParametersList.p, pidParametersList.i, pidParametersList.d);
                        }
                    }
                    Keys.onPressed:getFocus(event);
                    function getFocus(event){
                        switch(event.key){
                        case Qt.Key_Enter:
                        case Qt.Key_Return:
                        case Qt.Key_Escape:
                            pidParametersList.focus = true;
                            break;
                        default:
                            event.accepted = false;
                            return false;
                        }
                        event.accepted = true;
                    }
                }

            }
            //射门力度曲线方框
            GroupBox{
                title: qsTr("Shoot Power Curve Tune Mode (Switch robot MODE to 6 first)") + translator.emptyString;
                width: parent.width - 15;
                anchors.top: pidParameters.bottom;
                anchors.horizontalCenter: parent.horizontalCenter;
                id: groupBox4;
                Grid{
                    id: shootPowerCurveTuneShow;
                    anchors.top: shootPowerCurveTuneModeText.bottom;
                    columns: 8;
                    verticalItemAlignment: Grid.AlignVCenter;
                    horizontalItemAlignment: Grid.AlignLeft;
                    anchors.horizontalCenter: parent.horizontalCenter;
                    columnSpacing: 10;
                    rowSpacing: 5;
                    property int a: 0;//a
                    property int b: 127;//b
                    property real dribbler_amp: 1.0;
                    property int min_a: 0;
                    property int max_a: 127;
                    property int min_b: 0;
                    property int max_b: 127;
                    property real min_dribbler_amp: 1.0;
                    property real max_dribbler_amp: 1.8;
                    property bool mode: false;
                    Text { id: shootPowerCurveTuneModeText; text: qsTr("Shoot Power Curve Tune Mode"); color: tcolor }
                    CheckBox {
                        id: shootPowerCurveCheckbox;
                        enabled: true;
                        onClicked: {
                            shootPowerCurveTuneShow.mode = !shootPowerCurveTuneShow.mode;
                        }
                    }
                    Text {id: aText; text: qsTr("a")  + translator.emptyString; color: tcolor }
                    SpinBox{ minimumValue:shootPowerCurveTuneShow.min_a; maximumValue:shootPowerCurveTuneShow.max_a; value:parent.a; width:parent.itemWidth
                        onEditingFinished:{shootPowerCurveTuneShow.a = value}}
                    Text { text: qsTr("b")  + translator.emptyString; color: tcolor }
                    SpinBox{ minimumValue:shootPowerCurveTuneShow.min_b; maximumValue:shootPowerCurveTuneShow.max_b; value:parent.b; width:parent.itemWidth
                        onEditingFinished:{shootPowerCurveTuneShow.b = value}}
                    Text { text: qsTr("dribbler_amp") + translator.emptyString; color: tcolor }
                    TextField{ validator: DoubleValidator{decimals: 1; bottom: shootPowerCurveTuneShow.min_dribbler_amp; top: shootPowerCurveTuneShow.max_dribbler_amp;} focus: true;
                        text: "1.0"; onEditingFinished: shootPowerCurveTuneShow.dribbler_amp = text; width: 40;}
                    function updateMode(){
                        if(shootPowerCurveTuneShow.mode) {
                            serial.updateShootPowerCurveParams(shootPowerCurveTuneShow.a, shootPowerCurveTuneShow.b, shootPowerCurveTuneShow.dribbler_amp);
                            serial.updateShootPowerCurveTuneMode(2);
                        }
                        else serial.updateShootPowerCurveTuneMode(1);
                    }
                    Keys.onPressed:getFocus(event);
                    function getFocus(event){
                        switch(event.key){
                        case Qt.Key_Enter:
                        case Qt.Key_Return:
                        case Qt.Key_Escape:
                            shootPowerCurveTuneShow.focus = true;
                            break;
                        default:
                            event.accepted = false;
                            return false;
                        }
                        event.accepted = true;
                    }
                }

            }
            //最下面的Start按钮
            Button{
                id:crazyStart;
                //text:qsTr("Start") + translator.emptyString;
                property bool ifStarted:false;
                width: 100
                state : "stop"
                states:[
                    State{
                        name : "start"
                        PropertyChanges{target:crazyStart ; text:qsTr("stop") + translator.emptyString}
                        PropertyChanges{target:crazyStart ; ifStarted : true}
                    },
                    State{
                        name : "stop"
                        PropertyChanges{target:crazyStart ; text:qsTr("start") + translator.emptyString}
                        PropertyChanges{target:crazyStart ; ifStarted : false}
                    }
                ]
                anchors.right:parent.right;
                anchors.rightMargin: 20;
                anchors.top:groupBox4.bottom;
                anchors.topMargin: 10;
                //enabled : transmitterConnect.ifConnected;//如果连接成功按钮才有效
                onClicked:{
                    handleClickEvent();
                }
                function handleClickEvent(){
                    if(ifStarted){//若开始，定时器关闭
                        timer.stop();
                        crazyStart.state = "stop";
                    }else{//若未开始，定时器打开
                        timer.start();
                        crazyStart.state = "start"
                    }
                }
            }
        }
    }
    Component.onCompleted:{
        //translator.selectLanguage("zh");
    }
}


