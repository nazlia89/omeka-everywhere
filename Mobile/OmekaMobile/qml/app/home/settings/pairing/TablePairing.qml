import QtQuick 2.5
import "../../../base"
import "../../../../utils"

Item {

    id: root
    state: "unpaired"

    /*
     Unique device id for pairing with heist table user
    */
    property var deviceId: HeistManager.uid;


    ///////////////////////////////////////////////////////////
    //          UI
    ///////////////////////////////////////////////////////////

    /*!Pairing header and back button*/
    OmekaToolBar {
        id: bar
        backgroundColor: Style.color3
        z: 1

        OmekaText {
            anchors.centerIn: parent
            text: "pairing"
            _font: Style.titleFont
        }

        OmekaButton {
            id: back
            icon: Style.back
            iconScale: .7
            onClicked: if(homeStack) homeStack.pop()
        }
    }

    /*!Code display*/
    CodeEntry {
        id: entry
        width: Resolution.applyScale(546)
        anchors.top: parent.top
        anchors.topMargin: Resolution.applyScale(438)
        anchors.horizontalCenter: parent.horizontalCenter
        onCodeStringChanged: receiver.code = codeString
    }

    /*!Keypad for code entry*/
    Keypad {
        id: keypad
        anchors.bottom: parent.bottom
        onKeyPressed: entry.submitEntry(key)
    }

    /*!Control to terminate pairing session*/
    Unpair {
        id: unpair_view
        anchors.top: parent.top
        anchors.topMargin: Resolution.applyScale(438)
        width: parent.width
        height: Resolution.applyScale(816)
        onUnpair: root.unpair()
    }

    //pairing states
    states: [
        State {
            name: "unpaired"
            AnchorChanges { target: keypad; anchors.bottom: parent.bottom; anchors.top: undefined }
            PropertyChanges { target: keypad; opacity: 1 }
            AnchorChanges { target: entry; anchors.top: parent.top; anchors.bottom: undefined }
            PropertyChanges { target: entry; opacity: 1 }
            AnchorChanges { target: unpair_view; anchors.left: parent.right }
            PropertyChanges { target: unpair_view; opacity: 0 }
        },
        State {
            name: "paired"
            AnchorChanges { target: keypad; anchors.bottom: undefined; anchors.top: parent.bottom }
            PropertyChanges { target: keypad; opacity: 0 }
            AnchorChanges { target: entry; anchors.top: undefined; anchors.bottom: parent.top }
            PropertyChanges { target: entry; opacity: 0 }
            AnchorChanges { target: unpair_view; anchors.left: parent.left }
            PropertyChanges { target: unpair_view; opacity: 1 }
        }
    ]

    //state animations
    transitions: Transition {
        AnchorAnimation { duration: 400; easing.type: Easing.OutQuad }
        PropertyAnimation { targets: [keypad, entry, unpair_view]; duration: 200; property: "opacity"; easing.type: Easing.OutQuad }
    }

    ///////////////////////////////////////////////////////////
    //          DEVICE PAIRING
    ///////////////////////////////////////////////////////////

    //listens for iterative heist data updates
    HeistReceiver {
        id: receiver
        onSessionChanged: validateSession();
        onErrorChanged: pairingError();
        onAddItem: addHeistItem(item);
    }

    /*
      Once a valid session is determined, established pairing. Once a session
      becomes invalid, terminate the pairing. A valid session is one that has
      an heist entry corresponding with the pairing code and does not have an
      assigned device.
    */
    function validateSession() {
        //valid session
        if(receiver.session) {
            if(receiver.device) {
                //code is already in use - terminate session on table
            } else {
                pair();
            }
        }
        //session terminated on table
        else {
            unpair();
        }
    }

    /*
      Create the pairing in the manager and update the ui state
    */
    function pair() {
        if(state === "unpaired") {
            HeistManager.setPairing(entry.codeString, deviceId);
            state = "paired";
        }
    }

    /*
      Destroy the pairing in the manager and update the ui state
    */
    function unpair() {
        if(state === "paired") {
            HeistManager.releasePairing(entry.codeString, deviceId);
            entry.resetCode();
            state = "unpaired";
        }
    }

    /*
      Handles errors during pairing
    */
    function pairingError() {
        if(receiver.error) {
            HeistManager.removeSession(entry.codeString);
            receiver.register = false;
        }
    }

    /*
      Trigger likes registration process of heist item
    */
    function addHeistItem(item_id) {
        console.log("added: "+item_id)
    }

}
