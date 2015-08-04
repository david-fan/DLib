/**
 * Created with IntelliJ IDEA.
 * User: david
 * Date: 5/5/14
 * Time: 5:31 PM
 * To change this template use File | Settings | File Templates.
 */
package org.david.ui.player {
import com.adobe.serialization.json.JSONExt;

import flash.events.EventDispatcher;

import com.adobe.net.URI;

import flash.events.NetStatusEvent;
import flash.media.SoundTransform;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.net.NetStreamAppendBytesAction;
import flash.net.URLLoader;
import flash.system.Security;

import org.casalib.events.LoadEvent;

import org.casalib.load.DataLoad;

import org.casalib.util.StringUtil;

import org.david.ui.event.UIEvent;
import org.david.util.LogUtil;
import org.httpclient.HttpClient;
import org.httpclient.HttpRequest;
import org.httpclient.events.HttpDataEvent;
import org.httpclient.events.HttpResponseEvent;
import org.httpclient.events.HttpStatusEvent;
import org.httpclient.http.Get;

public class MLetvPlayer extends EventDispatcher implements IPlayer {
    public static var StreamOK:String = "PlayStream.StreamOK";

    private var _playing:Boolean = true;
    private var _volume:Number = 1;

    private var _netStream:NetStream;
    private var _netConnection:NetConnection;
    private var _playUrl:String;
    private var _realUrl:String;
    private var _hasHeader:Boolean;
    private var _httpClient:HttpClient;
    private var _time:Number = 0;
    private var _metaData:Object = {};

    private var _seek:int = 0;

    public function MLetvPlayer() {
        super();

    }

    private var _lastHttpStatusCode:String;

    private function checkSeekLocation():void {
        var formatUrl:String = _playUrl + "?format=1";
        LogUtil.debug("formatUrl", formatUrl);
        var dl:DataLoad = new DataLoad(formatUrl);
        dl.addEventListener(LoadEvent.COMPLETE, function (e:LoadEvent):void {
            var locationObject:Object = JSONExt.decode(dl.dataAsString);
            _realUrl = decodeURIComponent(locationObject.location);
//            if (position > 0)
//                loadFLV(realUrl, 13);
            loadFLV(0);
        });
        dl.start();
    }

    private function loadFLV(range:uint):void {//range:uint
        if (_httpClient) {
            _httpClient.cancel();
        }

//        var policyUrl:String = "xmlsocket://" + getServerName(_playUrl) + ":843";
//        LogUtil.log("policy file: " + policyUrl);
//        Security.loadPolicyFile(policyUrl);

        _httpClient = new HttpClient();

        LogUtil.log("load flv", _realUrl);
        var uri:URI = new URI(_realUrl);
        var request:HttpRequest = new Get();
        if (range) {
            request.addHeader("Range", "bytes=" + range + "-");//0-2000
            LogUtil.log("Range", range + "-")
        }

        _httpClient.listener.onStatus = onStatus;
        _httpClient.listener.onComplete = function (event:HttpResponseEvent):void {
            LogUtil.log(event);
        };
        _httpClient.listener.onData = onData;
        _httpClient.request(uri, request);
    }

    private function onStatus(event:HttpStatusEvent):void {
        _lastHttpStatusCode = event.code;
        LogUtil.log("*******************http status", _lastHttpStatusCode);
        LogUtil.log(event.header.toString());
//        switch (_lastHttpStatusCode) {
//            case "302":
//                _playUrl = event.header.getValue("Location");
//                _playUrl = StringUtil.trimLeft(_playUrl);
//                loadFLV();
//                break;
//            case "200":
//                break;
//            case "206":
//                break;
//        }
    }

    private function onData(event:HttpDataEvent):void {
        if (["200", "206"].indexOf(_lastHttpStatusCode) == -1)
            return;
//        LogUtil.log("_netStream.appendBytes");
        _netStream.appendBytes(event.bytes);
    }

    public function play():void {
        _netConnection = new NetConnection();
        _netConnection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
        _netConnection.connect(null);
        checkSeekLocation();
    }

    public function seek(time:Number):void {
        _seek = time;
        if (!_hasHeader)
            return;
        _netStream.seek(0);
        _netStream.appendBytesAction(NetStreamAppendBytesAction.RESET_SEEK);
        var keyframes:Object = _metaData.keyframes;
        for (var i:int = 0; i < keyframes.times.length; i++) {
            if (_seek < keyframes.times[i]) {
                if (i == 0)
                    i = 1;
                _time = keyframes.times[i - 1];
                loadFLV(keyframes.filepositions[i - 1]);
                break;
            }
        }
        _seek = 0;
    }

    public function get duration():Number {
        if (_metaData)
            return _metaData.duration;
        return 0;
    }

    public function get time():Number {
        if (_netStream)
            return _time + _netStream.time;
        else
            return 0;
    }

    public function get bufferLength():Number {
        if (_netStream)
            _netStream.bufferLength;
        return 0;
    }

    public function get bufferTime():Number {
        if (_netStream)
            return _time + _netStream.bufferTime;
        else
            return 0;
    }

    public function get playing():Boolean {
        return _playing;
    }

    public function get volume():Number {
        return _volume;
    }

    public function set volume(value:Number):void {
        _volume = value;
        if (_netStream)
            _netStream.soundTransform = new SoundTransform(_volume);
    }

    private var _streamCreateCallback:Function;
    public function set streamCreateCallback(value:Function):void {
        _streamCreateCallback = value;
    }

    private var _metaDataCallback:Function

    public function set metaDataGetCallback(value:Function):void {
        _metaDataCallback = value;
    }

    private var _playStatusCallback:Function

    public function set playStatusCallback(value:Function):void {
        _playStatusCallback = value;
    }

    public function togglePause():void {
        _netStream.togglePause();
        _playing = !_playing;
    }

    private function onNetStatus(e:NetStatusEvent):void {
        var code:String = e.info.code;
        LogUtil.log(e.info.code, e.info.message);
        switch (code) {
            case "NetStream.SeekStart.Notify":
//                LogUtil.log(e.info);
                break;
            case "NetStream.Seek.Notify":
//                LogUtil.log(e.info);
                break;
            case "NetConnection.Connect.Success":
                _netStream = new NetStream(_netConnection);
                _netStream.soundTransform = new SoundTransform(_volume);
                if (_streamCreateCallback)
                    _streamCreateCallback(_netStream);
                _netStream.play(null);
                _netStream.client = this;
                _netStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
//                loadFLV();
                dispatchEvent(new UIEvent(StreamOK, _netStream));
                break;
            case "NetConnection.Connect.Closed":
                _netConnection.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
                _netStream.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
                break
        }
    }

//    private var _metaDataGetCallback:Function;
//    public function set metaDataGetCallback(value:Function):void {
//        _metaDataGetCallback = value;
//    }

    public function onMetaData(info:Object):void {
        for (var key:String in info) {
            _metaData[key] = info[key];
        }
        LogUtil.log("metadata: duration=" + info.duration + " width=" + info.width + " height=" + info.height + " framerate=" + info.framerate);
        _hasHeader = true;
        if (_metaDataCallback)
            _metaDataCallback(info);
        if (_seek > 0)
            seek(_seek);
//        _metaDataGetCallback(info.width, info.height);
    }

    public function onCuePoint(info:Object):void {
        LogUtil.log("cuepoint: time=" + info.time + " name=" + info.name + " type=" + info.type);
    }

    public static function getServerNameWithPort(url:String):String {
        // Find first slash; second is +1, start 1 after.
        var start:int = url.indexOf("/") + 2;
        var length:int = url.indexOf("/", start);
        return length == -1 ? url.substring(start) : url.substring(start, length);
    }

    public static function getServerName(url:String):String {
        var sp:String = getServerNameWithPort(url);

        // If IPv6 is in use, start looking after the square bracket.
        var delim:int = indexOfLeftSquareBracket(sp);
        delim = (delim > -1) ? sp.indexOf(":", delim) : sp.indexOf(":");

        if (delim > 0)
            sp = sp.substring(0, delim);
        return sp;
    }

    private static function indexOfLeftSquareBracket(value:String):int {
        var delim:int = value.indexOf(SQUARE_BRACKET_LEFT);
        if (delim == -1)
            delim = value.indexOf(SQUARE_BRACKET_LEFT_ENCODED);
        return delim;
    }

    private static const SQUARE_BRACKET_LEFT:String = "]";
    private static const SQUARE_BRACKET_RIGHT:String = "[";
    private static const SQUARE_BRACKET_LEFT_ENCODED:String = encodeURIComponent(SQUARE_BRACKET_LEFT);
    private static const SQUARE_BRACKET_RIGHT_ENCODED:String = encodeURIComponent(SQUARE_BRACKET_RIGHT);

    public function get playUrl():String {
        return _playUrl;
    }

    public function set playUrl(value:String):void {
        _playUrl = value;
    }


    public function pause():void {
        _netStream.pause();
    }

    public function set mute(value:Boolean):void {
        _volume = value ? 0 : 1;
        if (_netStream) {
            var st:SoundTransform = new SoundTransform(0);
            _netStream.soundTransform = st;
        }
    }

    public function get mute():Boolean {
        return (_volume == 0);
    }

    public function stop():void {
        _metaDataCallback = null;
        _streamCreateCallback = null;
        cleanupStream();
    }

    protected function cleanupStream():void {
        if (_netStream != null) {
//            _netstream.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
            _netStream.close();
//            _netstream = null;
        }
        if (_netConnection != null) {
//            _netConnection.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
            _netConnection.close();
//            _netConnection = null;
        }
    }

    public function resume():void {
    }
}
}
