//
//  JKHandlerSwiftJS.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/5.
//

import Foundation

let jsCode = """
    var zhiting = {

        invoke: function (funcName, params, callback) {
            var message;
            var timeStamp = new Date().getTime();
            var callbackID = funcName + '_' + timeStamp + '_' + 'callback';
            
            if (callback) {
                if (!WKBridgeEvent._listeners[callbackID]) {
                    WKBridgeEvent.addEvent(callbackID, function (data) {

                        callback(data);

                    });
                }
            }



            if (callback) {
                message = { 'func': funcName, 'params': params, 'callbackID': callbackID };

            } else {
                message = { 'func': funcName, 'params': params };

            }
            window.webkit.messageHandlers.WKEventHandler.postMessage(message);
        },

        callBack: function (callBackID, data, noFire) {

            WKBridgeEvent.fireEvent(callBackID, data);
            if (noFire) {
                WKBridgeEvent.removeEvent(callBackID);
            }
        },

        removeAllCallBacks: function (data) {
            WKBridgeEvent._listeners = {};
        }

    };




    var WKBridgeEvent = {

        _listeners: {},

        addEvent: function (callBackID, fn) {
            this._listeners[callBackID] = fn;
            return this;
        },


        fireEvent: function (callBackID, param) {
            var fn = this._listeners[callBackID];
            if (typeof callBackID === "string" && typeof fn === "function") {
                fn(JSON.parse(param));
            } else {
                delete this._listeners[callBackID];
            }
            return this;
        },

        removeEvent: function (callBackID) {
            delete this._listeners[callBackID];
            return this;
        }
    };
"""



