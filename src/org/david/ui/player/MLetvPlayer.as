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

import flash.events.NetStatusEvent;
import flash.media.SoundTransform;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.net.NetStreamAppendBytesAction;
import flash.system.Security;

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
//    public static var StreamOK:String = "PlayStream.StreamOK";

    private var _playing:Boolean = true;
    private var _volume:Number = 1;

    private var _netStream:NetStream;
    private var _netConnection:NetConnection;
    private var _playUrl:String;
    private var _hasHeader:Boolean;
//    private var _httpClient:HttpClient;
    private var _time:Number = 0;
    private var _metaData:Object = {};
    private var _filename:String;
    private var _seekTime:int;

    public function MLetvPlayer() {
        super();

    }

    private var _lastHttpStatusCode:String;


    private function loadFLV():void {
        var keyframes:Object = _metaData.keyframes;
        for (var i:int = 0; i < keyframes.times.length; i++) {
            if (_seekTime < keyframes.times[i]) {
                if (i == 0)
                    i = 1;
                _time = keyframes.times[i - 1];
                _playUrl = _filename + "?start=" + (keyframes.filepositions[i - 1]);
                play();
                break;
            }
        }
    }

    public function play():void {
        _netConnection = new NetConnection();
        _netConnection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
        _netConnection.connect(null);
    }

    public function seek(time:Number):void {
        _seekTime = time;
        if (!_hasHeader)
            return;
        cleanupStream();
        loadFLV();
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

    private var _metaDataCallback:Function;

    public function set metaDataGetCallback(value:Function):void {
        _metaDataCallback = value;
    }

    private var _playStatusCallback:Function;

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
            case "NetConnection.Connect.Success":
                _netStream = new NetStream(_netConnection);
                _netStream.soundTransform = new SoundTransform(_volume);
                if (_streamCreateCallback)
                    _streamCreateCallback(_netStream);
                _netStream.play(_playUrl);
                _netStream.client = this;
                _netStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
                break;
        }
    }

    public function onMetaData(info:Object):void {
        for (var key:String in info) {
            _metaData[key] = info[key];
        }
        trace("metadata: duration=" + info.duration + " width=" + info.width + " height=" + info.height + " framerate=" + info.framerate);
        _hasHeader = true;
        if (_metaDataCallback)
            _metaDataCallback(info);
        if (_seekTime > 0) {
            loadFLV();
            _seekTime = 0;
        }
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

    public function get filename():String {
        return _filename;
    }

    public function set filename(value:String):void {
        _playUrl = _filename = value;
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
            _netStream.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
            _netStream.close();
            _netStream = null;
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
