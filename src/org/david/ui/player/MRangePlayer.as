/**
 * Created with IntelliJ IDEA.
 * User: david
 * Date: 5/5/14
 * Time: 5:31 PM
 * To change this template use File | Settings | File Templates.
 */
package org.david.ui.player {
import flash.events.EventDispatcher;

import com.adobe.net.URI;
import com.adobe.utils.StringUtil;

import flash.events.NetStatusEvent;
import flash.media.SoundTransform;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.net.NetStreamAppendBytesAction;
import flash.system.Security;

import org.david.ui.event.UIEvent;
import org.httpclient.HttpClient;
import org.httpclient.HttpRequest;
import org.httpclient.events.HttpDataEvent;
import org.httpclient.events.HttpResponseEvent;
import org.httpclient.events.HttpStatusEvent;
import org.httpclient.http.Get;

public class MRangePlayer extends EventDispatcher implements IPlayer {
    public static var StreamOK:String = "PlayStream.StreamOK";

    private var _playing:Boolean = true;
    private var _volume:Number = 1;

    private var _netstream:NetStream;
    private var _netConnection:NetConnection;
    private var _playUrl:String;
    private var _hasHeader:Boolean;
    private var _httpClient:HttpClient;
    private var _time:Number = 0;
    private var _metaData:Object = {};

    public function MRangePlayer() {
        super();

    }

    private var _lastHttpStatusCode:String;

    private function loadFLV(range:String = null):void {
        if (_httpClient) {
            _httpClient.cancel();
        }

        var policyUrl:String = "xmlsocket://" + getServerName(_playUrl) + ":843";
        trace("policy file: " + policyUrl);
        Security.loadPolicyFile(policyUrl);

        _httpClient = new HttpClient();

        trace("load flv", _playUrl, range);
        var uri:URI = new URI(_playUrl);
        var request:HttpRequest = new Get();
        if (range) {
            request.addHeader("Range", "bytes=" + range);//0-2000
        }

        _httpClient.listener.onStatus = onStatus;
        _httpClient.listener.onComplete = function (event:HttpResponseEvent):void {
            trace(event);
        };
        _httpClient.listener.onData = onData;
        _httpClient.request(uri, request);
    }

    private function onStatus(event:HttpStatusEvent):void {
        _lastHttpStatusCode = event.code;
        trace("*******************http status", _lastHttpStatusCode);
        trace(event.header.toString());
        switch (_lastHttpStatusCode) {
            case "302":
                _playUrl = event.header.getValue("Location");
                _playUrl = StringUtil.ltrim(_playUrl);
                loadFLV();
                break;
            case "200":
                break;
            case "206":
                break;
        }
    }

    private function onData(event:HttpDataEvent):void {
        if (["200", "206"].indexOf(_lastHttpStatusCode) == -1)
            return;
        _netstream.appendBytes(event.bytes);
    }

    public function play():void {
        _netConnection = new NetConnection();
        _netConnection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
        _netConnection.connect(null);
    }

    public function seek(time:Number):void {
        if (!_hasHeader)
            return;
        _netstream.seek(0);
        _netstream.appendBytesAction(NetStreamAppendBytesAction.RESET_SEEK);
        var keyframes:Object = _metaData.keyframes;
        for (var i:int = 0; i < keyframes.times.length; i++) {
            if (time < keyframes.times[i]) {
                if (i == 0)
                    i = 1;
                _time = keyframes.times[i - 1];
                loadFLV(keyframes.filepositions[i - 1] + "-");
                break;
            }
        }
    }

    public function get time():Number {
        if (_netstream)
            return _time + _netstream.time;
        else
            return 0;
    }

    public function get bufferTime():Number {
        if (_netstream)
            return _time + _netstream.bufferTime;
        else
            return 0;
    }

    public function get playing():Boolean {
        return _playing;
    }

    public function get volume():Number {
        return _netstream.soundTransform.volume;
    }

    public function set volume(value:Number):void {
        _volume = value;
        _netstream.soundTransform = new SoundTransform(_volume);
    }

    private var _streamCreateCallback:Function;
    public function set streamCreateCallback(value:Function):void {
        _streamCreateCallback = value;
    }

    public function togglePause():void {
        _netstream.togglePause();
        _playing = !_playing;
    }

    private function onNetStatus(e:NetStatusEvent):void {
        var code:String = e.info.code;
        trace(code);
        switch (code) {
            case "NetStream.SeekStart.Notify":
                trace(e.info);
                break;
            case "NetStream.Seek.Notify":
                trace(e.info);
                break;
            case "NetConnection.Connect.Success":
                _netstream = new NetStream(_netConnection);
                _streamCreateCallback(_netstream);
                _netstream.play(null);
                _netstream.client = this;
                _netstream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
                loadFLV();
                dispatchEvent(new UIEvent(StreamOK, _netstream));
                break;
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
        trace("metadata: duration=" + info.duration + " width=" + info.width + " height=" + info.height + " framerate=" + info.framerate);
        _hasHeader = true;

//        _metaDataGetCallback(info.width, info.height);
    }

    public function onCuePoint(info:Object):void {
        trace("cuepoint: time=" + info.time + " name=" + info.name + " type=" + info.type);
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
        _netstream.pause();
    }

    public function set mute(value:Boolean):void {
        var st:SoundTransform = new SoundTransform(0);
        _netstream.soundTransform = st;
    }

    public function get mute():Boolean {
        return _netstream.soundTransform.volume == 0;
    }

    public function stop():void {

    }

    protected function cleanupStream():void {
        if (_netstream != null) {
            _netstream.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
            _netstream.close();
            _netstream = null;
        }
        if (_netConnection != null) {
            _netConnection.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
            _netConnection.close();
            _netConnection = null;
        }
    }

    public function resume():void {
    }
}
}
