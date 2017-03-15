import QtQuick 2.5
import "../../../base"
import "../../../../utils"

Column {

    id: root
    state: HeistManager.deviceIsPaired? "link" : "pair"
    property var code: []    
    spacing: Resolution.applyScale(45)

    //icon
    Image {
        anchors.horizontalCenter: parent.horizontalCenter
        source: Style.pair
        width: Resolution.applyScale(180); height: Resolution.applyScale(180)
    }

    //instructions
    OmekaText {
        width: parent.width
        center: true
        text: "enter the code you see on the table"
        _font: Style.pairingInstructions
    }

    //code slots
    ListView {
        id: slots
        interactive: false
        width: childrenRect.width
        height: contentItem.children[0].height
        anchors.horizontalCenter: parent.horizontalCenter
        orientation: ListView.Horizontal
        spacing: Resolution.applyScale(21)
        model: 4
        delegate: delegate
    }

    //slot
    Component {
        id: delegate
        Item {
            width: Resolution.applyScale(109)
            height: Resolution.applyScale(155)
            property alias digit: text.text

            //text field
            OmekaText {
                id: text
                center: true
                anchors.fill: parent
                _font: Style.keypadFont
            }

            //border
            Rectangle {
                anchors.fill: parent
                color: Style.transparent
                border.width: Resolution.applyScale(6)
                border.color: Style.color1
                radius: Resolution.applyScale(15)
            }
        }
    }

    //data receiver
    HeistReceiver {
        id: receiver
        onRecordChanged: if(record) HeistManager.deviceIsPaired = true;
        onErrorChanged: {
            if(error) {
                register = false;
            }
        }
    }

    //entry states
    states: [
        State { name: "pair" },
        State { name: "link" }
    ]

    //manage code input
    function submitEntry(value) {
        if(value === "back" && code.length > 0) {
            code.pop();
            slots.contentItem.children[code.length].digit = "";
        } else if(value !== "back" && code.length < 4) {
            slots.contentItem.children[code.length].digit = value;
            code.push(value);
        }
        receiver.code = code.join("");
    }

    //restore initial state
    function reset() {

        //unregister receiver
        receiver.code = null;

        //change paired state
        HeistManager.deviceIsPaired = false;

        //clear code
        for(var i=0; i<4; i++) {
            slots.contentItem.children[i].digit = "";
        }
        code.length = 0;
    }
}
