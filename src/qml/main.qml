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
    Timer{
        id:timer;
        interval:15;//15ms启动一次
        running:false;
        repeat:true;
        onTriggered: {
            pidTuneShow.updateMode();//设置是否为PID调节模式
            shootPowerCurveTuneShow.updateMode();//设置是否为射门力度曲线调节模式
            crazyShow.updateCommand();//调用serial.updateCommandParams()
            serial.sendCommand();//把数据发出去
            if(crazyShow.shoot){
                crazyShow.shoot = !crazyShow.shoot;
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
            id:radioRectangle;
            //最上面一条Box
            GroupBox{
                id : crazyListRectangle;
                width: parent.width - 15;
                anchors.horizontalCenter: parent.horizontalCenter;
                anchors.top: parent.top;
                anchors.margins: 10;
                title :qsTr("Sender Setting") + translator.emptyString;
                Grid{
                    height:parent.height;
                    id : crazyListView;
                    verticalItemAlignment: Grid.AlignVCenter;
                    horizontalItemAlignment: Grid.AlignLeft;
                    anchors.horizontalCenter: parent.horizontalCenter;
                    columnSpacing: 40;
                    rowSpacing: 5;
                    columns:4;
                    //enabled: !crazyConnect.ifConnected;
                    property int itemWidth : 90;
                    //端口相关
                    Text
                        text: qsTr("Ports")+ translator.emptyString;
                        width:parent.itemWidth;
                        color : tcolor
                    }
                    ComboBox{
                        id : crazyPort;
                        model:serial.getCrazySetting(0);
                        currentIndex : serial.getDefaultIndex(0);
                        onActivated: serial.sendCrazySetting(0,index);
                        width:parent.itemWidth;
                    }
                    //频率相关
                    Text{
                        text: qsTr("Frequency")+ translator.emptyString;
                        width:parent.itemWidth;
                        color: tcolor
                    }
                    ComboBox{
                        model:serial.getCrazySetting(1);
                        currentIndex : serial.getDefaultIndex(1);
                        onActivated: serial.sendCrazySetting(1,index);
                        width:parent.itemWidth;
                    }
                }
            }
            //连接按钮
            Button{
                id : crazyConnect;
                state : "unconnected"
                property bool ifConnected:false;
                states:[
                    State{
                        name: "connected"
                        PropertyChanges{target:crazyConnect ; text:qsTr("Disconnect") + translator.emptyString}
                        PropertyChanges{target:crazyConnect ; ifConnected:true}
                        PropertyChanges{target:crazyStart ; enabled:true}
                        PropertyChanges{target:crazyListView ; enabled:false}
                    },
                    State{
                        name: "unconnected"
                        PropertyChanges{target:crazyConnect ; text:qsTr("Connect") + translator.emptyString}
                        PropertyChanges{target:crazyConnect ; ifConnected:false}
                        PropertyChanges{target:crazyStart ; enabled:false}
                        PropertyChanges{target:crazyListView ; enabled:true}
                    }
                ]
                //text : (ifConnected ? qsTr("Disconnect") : qsTr("Connect")) + translator.emptyString;
                anchors.top: crazyListRectangle.bottom;
                anchors.right: parent.right;
                anchors.rightMargin: 20;
                anchors.topMargin: 5;
                onClicked: clickEvent();
                function clickEvent(){
                    if(ifConnected){
                        timer.stop();
                        if(crazyStart.ifStarted) crazyStart.handleClickEvent();
                        serial.closeSerialPort();
                        crazyConnect.state = "unconnect"
                    }else{
                        if(crazyPort.currentText != ""){
                            serial.openSerialPort();
                            serial.sendStartPacket();
                            crazyConnect.state = "connected";
                        }
                    }
                }
            }
            //下面大的Box
            GroupBox{
                title : qsTr("Manual Control") + translator.emptyString;
                width:parent.width - 15;
                anchors.top:crazyConnect.bottom;
                anchors.horizontalCenter: parent.horizontalCenter;
                id : groupBox2;
                Grid{
                    id : crazyShow;
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
                    SpinBox{ minimumValue:1; maximumValue:12; value:parent.robotID; width:parent.itemWidth
                        onEditingFinished:{parent.robotID = value}}
                    Text{ text:"Stop"; color: tcolor }
                    Button{ text:qsTr("[Space]") + translator.emptyString;width:parent.itemWidth}

                    Text{ text:" " }

                    Text{ text:" " }

                    Text{ text:qsTr("Vx [W/S]") + translator.emptyString; color: tcolor }
                    SpinBox{ minimumValue:-crazyShow.m_VEL; maximumValue:crazyShow.m_VEL; value:parent.velX;width:parent.itemWidth
                        onEditingFinished:{parent.velX = value;}}

                    Text{ text:qsTr("MaxVel") + translator.emptyString; color: tcolor }
                    SpinBox{ minimumValue:1; maximumValue:crazyShow.velocityMax; value:parent.m_VEL;width:parent.itemWidth
                        onEditingFinished:{parent.m_VEL = value;}}

                    Text{ text:qsTr("KickMode [Up]")  + translator.emptyString; color: tcolor}
                    Button{ text:(parent.kickmode?qsTr("chip"):qsTr("flat")) + translator.emptyString;width:parent.itemWidth
                        onClicked: {
                            parent.kickmode = !parent.kickmode
                        }
                    }

                    Text{ text:qsTr("Vr [Left/Right]")  + translator.emptyString; color: tcolor}
                    SpinBox{ minimumValue:-crazyShow.m_VELR; maximumValue:crazyShow.m_VELR; value:parent.velR;width:parent.itemWidth
                        onEditingFinished:{parent.velR = value;}}

                    Text{ text:qsTr("MaxVelR") + translator.emptyString; color: tcolor }
                    SpinBox{ minimumValue:1; maximumValue:crazyShow.velocityRMax; value:parent.m_VELR;width:parent.itemWidth
                        onEditingFinished:{parent.m_VELR = value;}}

                    Text{ text:qsTr("Shoot [E]") + translator.emptyString; color: tcolor}
                    Button{ text:(parent.shoot? qsTr("true") : qsTr("false")) + translator.emptyString;width:parent.itemWidth
                        onClicked: {
                            parent.shoot = !parent.shoot;
                        }
                    }

                    Text{ text:qsTr("Vy [A/D]") + translator.emptyString; color: tcolor}
                    SpinBox{ minimumValue:-crazyShow.m_VEL; maximumValue:crazyShow.m_VEL; value:parent.velY;width:parent.itemWidth
                        onEditingFinished:{parent.velY = value;}}

                    Text{ text:qsTr("KickPower") + translator.emptyString; color: tcolor }
                    SpinBox{ minimumValue:0; maximumValue:parent.kickPowerMax; value:parent.power;width:parent.itemWidth
                        onEditingFinished:{parent.power = value;}}

                    Text{ text:qsTr("Dribb [Q]") + translator.emptyString; color: tcolor }
                    Button{ text:(parent.dribble ? qsTr("true") : qsTr("false")) +translator.emptyString;width:parent.itemWidth
                        onClicked: {
                            parent.dribble = !parent.dribble;
                        }
                    }

                    Text{ text:qsTr("DribLevel")  + translator.emptyString; color: tcolor}
                    SpinBox{ minimumValue:0; maximumValue:crazyShow.dribbleMaxLevel; value:parent.dribbleLevel;width:parent.itemWidth
                        onEditingFinished:{parent.dribbleLevel = value;}}

                    Text{ text:" " }

                    Text{ text:" " }

                    Rectangle{
                        width:parent.itemWidth; height:20; color:parent.dribble ? "blue" : "lightgrey";
                    }

                    Rectangle{
                        width:parent.itemWidth; height:20; color:parent.shoot ? "red" : "lightgrey";
                    }



                    //键盘响应实现
                    Keys.onPressed:getFocus(event);
                    function getFocus(event){
                        switch(event.key){
                        case Qt.Key_Enter:
                        case Qt.Key_Return:
                        case Qt.Key_Escape:
                            crazyShow.focus = true;
                            break;
                        default:
                            event.accepted = false;
                            return false;
                        }
                        event.accepted = true;
                    }
                    function updateStop(){
                        crazyShow.velX = 0;
                        crazyShow.velY = 0;
                        crazyShow.velR = 0;
                        crazyShow.shoot = false;
                        crazyShow.dribble = false;
                        crazyShow.rush = false;
                    }
                    function handleKeyboardEvent(e){
                        switch(e){
                        case 'U':{crazyShow.kickmode = !crazyShow.kickmode;break;}
                        case 'a':{crazyShow.velY = crazyShow.limitVel(crazyShow.velY-crazyShow.velYStep,-crazyShow.m_VEL,crazyShow.m_VEL);
                            break;}
                        case 'd':{crazyShow.velY = crazyShow.limitVel(crazyShow.velY+crazyShow.velYStep,-crazyShow.m_VEL,crazyShow.m_VEL);
                            break;}
                        case 'w':{crazyShow.velX = crazyShow.limitVel(crazyShow.velX+crazyShow.velXStep,-crazyShow.m_VEL,crazyShow.m_VEL);
                            break;}
                        case 's':{crazyShow.velX = crazyShow.limitVel(crazyShow.velX-crazyShow.velXStep,-crazyShow.m_VEL,crazyShow.m_VEL);
                            break;}
                        case 'q':{crazyShow.dribble = !crazyShow.dribble;
                            break;}
                        case 'e':{crazyShow.shoot = !crazyShow.shoot;
                            break;}
                        case 'L':{crazyShow.velR = crazyShow.limitVel(crazyShow.velR-crazyShow.velRStep,-crazyShow.m_VELR,crazyShow.m_VELR);
                            break;}
                        case 'R':{crazyShow.velR = crazyShow.limitVel(crazyShow.velR+crazyShow.velRStep,-crazyShow.m_VELR,crazyShow.m_VELR);
                            break;}
                        case 'S':{crazyShow.updateStop();
                            break;}
                        default:
                            return false;
                        }
                        updateCommand();
                    }
                    //serial.updateCommandParams在C++中实现
                    function updateCommand(){
                        serial.updateCommandParams(crazyShow.robotID,crazyShow.velX,crazyShow.velY,crazyShow.velR,crazyShow.dribble,crazyShow.dribbleLevel,crazyShow.kickmode,crazyShow.shoot,crazyShow.power);
                    }
                    function limitVel(vel,minValue,maxValue){
                        if(vel>maxValue) return maxValue;
                        if(vel<minValue) return minValue;
                        return vel;
                    }
                    Shortcut{
                        sequence:"A";
                        onActivated:crazyShow.handleKeyboardEvent('a');
                    }
                    Shortcut{
                        sequence:"Up";
                        onActivated:crazyShow.handleKeyboardEvent('U');
                    }
                    Shortcut{
                        sequence:"D"
                        onActivated:crazyShow.handleKeyboardEvent('d');
                    }
                    Shortcut{
                        sequence:"W"
                        onActivated:crazyShow.handleKeyboardEvent('w');
                    }
                    Shortcut{
                        sequence:"S"
                        onActivated:crazyShow.handleKeyboardEvent('s');
                    }
                    Shortcut{
                        sequence:"Q"
                        onActivated:crazyShow.handleKeyboardEvent('q');
                    }
                    Shortcut{
                        sequence:"E"
                        onActivated:crazyShow.handleKeyboardEvent('e');
                    }
                    Shortcut{
                        sequence:"Left"
                        onActivated:crazyShow.handleKeyboardEvent('L');
                    }
                    Shortcut{
                        sequence:"Right"
                        onActivated:crazyShow.handleKeyboardEvent('R');
                    }
                    Shortcut{
                        sequence:"Space"
                        onActivated:crazyShow.handleKeyboardEvent('S');
                    }
                }
            }
            //PID方框
            GroupBox{
                title: qsTr("PID Tune Mode (Switch robot MODE to 5 first)") + translator.emptyString;
                width: parent.width - 15;
                anchors.top: groupBox2.bottom;
                anchors.horizontalCenter: parent.horizontalCenter;
                id: groupBox3;
                Grid{
                    id: pidTuneShow;
                    anchors.top: pidTuneModeText.bottom;
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
                    Text { id: pidTuneModeText; text: qsTr("PID Tune Mode"); color: tcolor }
                    CheckBox {
                        onClicked: {
                            pidTuneShow.mode = !pidTuneShow.mode;
                        }
                    }
                    Text {id: kpText; text: qsTr("Kp")  + translator.emptyString; color: tcolor }
                    TextField{ validator: DoubleValidator{decimals: 5; bottom: pidTuneShow.min_p; top: pidTuneShow.max_p;} focus: false;
                        text: "0.0025"; onEditingFinished: pidTuneShow.p = text; width: 100;}
                    Text { text: qsTr("Ki")  + translator.emptyString; color: tcolor }
                    TextField{ validator: DoubleValidator{decimals: 5; bottom: pidTuneShow.min_i; top: pidTuneShow.max_i;} focus: true;
                        text: "0.0075"; onEditingFinished: pidTuneShow.i = text; width: 100;}
                    Text { text: qsTr("Kd")  + translator.emptyString; color: tcolor }
                    TextField{ validator: DoubleValidator{decimals: 5; bottom: pidTuneShow.min_d; top: pidTuneShow.max_d;} focus: true;
                        text: "0.0000"; onEditingFinished: pidTuneShow.d = text; width: 100;}
                    function updateMode(){
                        if(pidTuneShow.mode) {
                            serial.updatePidParams(pidTuneShow.p, pidTuneShow.i, pidTuneShow.d);
                            serial.updatePidTuneMode(2);
                        }
                        else serial.updatePidTuneMode(1);
                    }
                    Keys.onPressed:getFocus(event);
                    function getFocus(event){
                        switch(event.key){
                        case Qt.Key_Enter:
                        case Qt.Key_Return:
                        case Qt.Key_Escape:
                            pidTuneShow.focus = true;
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
                anchors.top: groupBox3.bottom;
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
                //enabled : crazyConnect.ifConnected;//如果连接成功按钮才有效
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


