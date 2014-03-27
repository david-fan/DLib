/**
 * Created with IntelliJ IDEA.
 * User: xiecc
 * Date: 13-12-4
 * Time: 下午3:26
 * To change this template use File | Settings | File Templates.
 */
package org.david.ui {
import flash.events.NetStatusEvent;
import flash.events.SecurityErrorEvent;
import flash.media.SoundTransform;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.utils.getTimer;
import flash.utils.setInterval;
import flash.utils.setTimeout;

import org.david.ui.core.MSprite;
import org.david.ui.event.UIEvent;
import org.david.util.StrUtil;

public class MMediaPlayer extends MSprite {
    public static const Buffering:String = "Player.Buffering";
    public static const PlayStart:String = "Player.PlayStart";
    public static const DebugInfo:String = "Player.DebugInfo";
    public static const NetConnectionStatus:String = "NetConnectionStatus";
    private var _connection:NetConnection;
    protected var _stream:NetStream;
//    private var _bufferTime:Number;
    private var _server:String;
    private var _filename:String;
    private var _start:Number = 0;
    private var _autoRetry:Boolean;
    private var _log:Boolean;
    protected var _metaData:Object;

    public function MMediaPlayer(autoRetry:Boolean = false, debug:Boolean = false, log:Boolean = true) {
        super();

        _autoRetry = autoRetry;

//        _bufferTime = bufferTime;

        _log = log;

        if (debug) {
            setInterval(onEnterFrame, 1000);
        }
    }

    private var _ispause:Boolean;

    public function get ispause():Boolean {
        return _ispause;
    }

    private var _isPlaying:Boolean;

    public function get isPlaying():Boolean {
        return _isPlaying;
    }

    public function get autoRetry():Boolean {
        return _autoRetry;
    }

    public function set autoRetry(value:Boolean):void {
        _autoRetry = value;
    }

    private var _volume:Number = 0.6;

    public function get volume():Number {
        return _volume;
    }

    public function set volume(value:Number):void {
        _volume = value;
        setVolume();
    }

    private var _mute:Boolean;

    public function get mute():Boolean {
        return _mute;
    }

    private var _buffering:Boolean;
    public function set buffering(value:Boolean):void {
        _buffering = value;
    }

    public function get buffering():Boolean {
        return _buffering;
    }

    public function set mute(value:Boolean):void {
        _mute = value;
        setVolume();
    }

    private function netStatusHandler(event:NetStatusEvent):void {
        if (_log)
            trace("NetStatusEvent:", event.info.code);
        switch (event.info.code) {
            case "NetConnection.Connect.Success":
                connectStream();
                break;
            case "NetStream.Play.StreamNotFound":
                trace("Stream not found: " + _filename);
                if (_autoRetry) {
                    trace("AutoRetry :" + _filename + " in 2 second");
                    setTimeout(_play, 2 * 1000);
//                    play();
                }
                break;
            case "NetStream.Play.Start":
                _isPlaying = false;
                dispatchEvent(new UIEvent(PlayStart));
                break;
            case "NetStream.Play.Stop":
//                if (_autoRetry) {
//                    trace("AutoRetry url:" + _filename);
//                    play();
//                }
            case "NetStream.Buffer.Flush":
                _isPlaying = false;
                break;
            case "NetStream.Buffer.Empty":
                dispatchEvent(new UIEvent(Buffering));
                buffering = true;
                break;
            case "NetStream.Buffer.Full":
                buffering = false;
                break;
            case "NetStream.Record.Stop":
                _isPlaying = false;
//                buffering = false;
                break;
            case "NetStream.Video.DimensionChange":
                trace(event);
//                _videoWidth = _video.width;
//                _videoHeight = _video.height;
//                _bg.width = _videoWidth;
//                _bg.height = _videoHeight;
//                dispatchEvent(new UIEvent(AutoSize));
                break;
            case "NetConnection.Connect.Closed":
                dispatchEvent(new UIEvent(NetConnectionStatus, "closed"));
                break;
            case "NetConnection.Connect.Failed":
                dispatchEvent(new UIEvent(NetConnectionStatus, "failed"));
                break;
        }
    }

    private function securityErrorHandler(event:SecurityErrorEvent):void {
        trace("securityErrorHandler: " + event);
    }

    protected function connectStream():void {
        if (_stream == null) {
            _stream = new NetStream(_connection);
            _stream.bufferTime = _server ? 0 : 01;
            _stream.maxPauseBufferTime = 120;
            _stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
            _stream.client = this;
        }

        if (_start <= 0)
            _start = getTimer();
        if (_stream)
            _stream.play(_filename);
        buffering = true;

        setVolume();
    }

    private function onEnterFrame():void {
        var ns:NetStream = _stream;
        var info:String = ("缓冲区：" + ns.bufferTime + "s 已缓冲：" + ns.bufferLength + "s 已下载：" + int(ns.bytesLoaded / 1024) + "k 总：" + int(ns.bytesTotal / 1024) + "k 速度:" + int((ns.bytesLoaded ) / 1024 / ((getTimer() - _start ) / 1000)) + "k/s" +
                "\n播放地址:" + _filename + "");
        dispatchEvent(new UIEvent(DebugInfo, info));
    }

    public function onMetaData(info:Object):void {
        _metaData = info;
        trace("onMetaData: duration=" + info.duration + " width=" + info.width + " height=" + info.height + " framerate=" + info.framerate);

    }

    public function onCuePoint(info:Object):void {
        trace("onCuePoint: time=" + info.time + " name=" + info.name + " type=" + info.type);
    }

    public function onXMPData(info:Object):void {
        trace("onXMPData: time=" + info.time + " name=" + info.name + " type=" + info.type);
    }

    public function onPlayStatus(info:Object):void {
        trace("onPlayStatus: time=" + info.time + " name=" + info.name + " type=" + info.type + "code=" + info.code + "level=" + info.level);
    }

    public function onLastSecond(info:Object):void {
        trace("onLastSecond:" + info);
    }

    public function onFI(infoObj:Object):void {
        trace("stream onFI:" + infoObj);
    }

    protected function cleanupStream():void {
        if (_stream != null) {
            //if (dispose) {
            _stream.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
            _stream.close();
            _stream = null;
            // }
        }
        if (_connection != null) {
            //if (dispose) {
            _connection.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
            _connection.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            _connection.close();
            _connection = null;
            //}
        }
    }

    private function setVolume():void {
        if (_stream && _connection.connected) {
            if (_mute)
                _stream.soundTransform = new SoundTransform(0);
            else
                _stream.soundTransform = new SoundTransform(_volume);
        }
    }

    public function play(server:String = null, filename:String = null):void {
        if (server) {
            _server = server;
        }
        if (filename) {
            _filename = filename;
        }
        if (StrUtil.isNullOrEmpty(_filename)) {
            trace("Stream is null or empty:" + _filename);
            return;
        }
        cleanupStream();
        _play();
    }

    private function _play():void {
//        trace("PlayStream:" + _server + "," + _filename);
        if (_connection == null) {
            _connection = new NetConnection();
            _connection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
            _connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
        }
        _connection.connect(_server);

    }

    public function pause():void {
        if (_stream)
            _stream.pause();
        _ispause = true;
    }

    public function stop():void {
        cleanupStream();
        _isPlaying = false;

    }

    public function resume():void {
        _stream.resume();
        _ispause = false;
    }

    public function replay():void {
        cleanupStream();
        _play();
    }
}
}
