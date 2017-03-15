pragma Singleton
import QtQuick 2.0
import "../utils"

Item {

    //request types
    readonly property var get: "GET";
    readonly property var post: "POST";
    readonly property var put: "PUT";
    readonly property var del: "DELETE";

    /*Url to heist plugin*/
    readonly property var baseUrl: Omeka.rest+"heist/"

    /*Map session codes to heist record id*/
    readonly property var sessions: ({});

    /*Map session codes to item lists*/
    readonly property var items: ({});

    /*Indicates the device is paired with the table for content sharing*/
    property var deviceIsPaired: false

    /*List of registered receivers of iterative polling results*/
    property var receivers: [];

    //iteratively polls heist for data updates
    Timer {
        id: timer
        interval: 1000
        repeat: true
        triggeredOnStart: true
        onTriggered: pollData()
    }

    /*
      Register receiver for iterative heist updates of a specified pairing code
    */
    function registerReceiver(receiver) {
        if(!registered(receiver)) {
            receivers.push(receiver);
        } if(!timer.running && receivers.length) {
            timer.start();
        }
    }

    /*
      Unregister receiver from iterative heist updates of a specified pairing code
    */
    function unregisterReceiver(receiver) {
        if(registered(receiver)) {
            receivers.splice(receivers.indexOf(receiver), 1);
        } if(timer.running && !receivers.length) {
            timer.stop();
        }
    }

    /*
      Returns the registered state of the receiver
    */
    function registered(receiver) {
        return receivers.indexOf(receiver) !== -1;
    }

    /*! \internal
      Submits poll requests for heist updates
    */
    function pollData() {
        for(var i=0; i<receivers.length; i++) {
            getData(baseUrl+"?pairing_id="+receivers[i].code, receivers[i]);
        }
    }

    /*! \internal
      Sends http request and links response handler
      \a url - heist request
      \a type - request type (GET, POST, PUT, or DELETE)
      \a data - request body
      \a context - calling object instance
    */
    function submitRequest(url, type, body, context) {
        var request = new XMLHttpRequest();
        request.type = type;
        request.context = context;
        request.onreadystatechange = onResponse(request);
        request.open(type, url);
        request.setRequestHeader('Content-type','application/json');
        request.send(body);
    }

    /*! \internal
      Evaluate validity of heist response
      \a request - http request
    */
    function onResponse(request) {
        return function(){
            if(request.readyState === XMLHttpRequest.DONE){
                switch(request.type) {
                    case get:
                        var result = JSON.parse(request.responseText);
                        request.context.data = result;
                        break;
                    case post:
                        var result = JSON.parse(request.responseText);
                        sessions[result.pairing_id] = result.id;
                        if(request.status === 201) {
                            console.log("ENTRY ADDED");
                        }
                        break;
                    case put:
                        console.log(request.status);
                        break;
                    case del:
                        console.log("ENTRY REMOVED");
                        break;
                }
            }
        }
    }

    /*! \internal
      Process results from GET requests
      \a result - request result
    */
    function processResult(result) {
        if(result.errors !== undefined) {

        } else {

        }
    }

    /*! \internal
      Add data entry to heist table
      \a data - record data
      \a context - calling object
    */
    function addData(data, context) {
        var json = JSON.stringify(data);
        submitRequest(baseUrl, post, json, context);
    }

    /*! \internal
      Remove entry by id
      \a id - record id
      \a context - calling object
    */
    function removeData(id, context) {
        var url = baseUrl+id;
        submitRequest(url, del, null, context);
    }

    /*! \internal
      Update data field in heist record
      \a url - url to specific record
      \a data - data values
      \a context - calling object
    */
    function updateData(url, data, context) {
        var json = JSON.stringify(data);
        submitRequest(url, put, json, context);
    }

    /*! \internal
     Get heist record data
     \a url - url to specific record
     \a context - calling object
    */
    function getData(url, context) {
        submitRequest(url, get, "", context);
    }

    /**********TABLE REQUESTS**********/

    /*Clears all heist records generated by this instance*/
    function clearAllSessions() {
        for(var code in sessions) {
            removeData(sessions[code]);
        }
    }

    /*Start session by adding a new entry with provided code
      /a code - pairing code
    */
    function startPairingSession(code) {
        var data = {pairing_id: code};
        addData(data, "");
    }

    /*End session by removing entry with specified code
      /a code - pairing code
    */
    function endPairingSession(code) {
        if(code in sessions) {
            removeData(sessions[code]);
        }
    }

    /*Add item to item list
      /a code - pairing code
      /a item - item url to add
      /a context - calling object
    */
    function addItem(code, item, context) {
        if(!(code in items)) {
            items[code] = [];
        }
        items[code].push(item);
        updateData(baseUrl+sessions[code], {item_ids: items[code]}, context);
    }

    /**********DEVICE REQUESTS**********/

    /*Set device id corresponding to pairing code. A non empty value signals a connection to the table
      and an empty value signals a disconnection.
      /a code - pairing code
      /a item - item url to add
      /a context - calling object
    */
    function setDevice(code, device) {
        updateData(baseUrl+sessions[code], {device_id: device}, "");
    }

    /*Remove item from list
      /a code - pairing code
      /a item - item url to add
      /a context - calling object
    */
    function removeItem(code, item, context) {
        if(code in items && items[code].indexOf(item) > -1) {
            var index = items[code].indexOf(item);
            items[code].splice(index, 1);
            updateData(baseUrl+sessions[code], {item_ids: items[code]}, context);
        }
    }

}
