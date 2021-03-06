/**
 * Created with IntelliJ IDEA.
 * User: xiecc
 * Date: 13-12-4
 * Time: 下午3:26
 * To change this template use File | Settings | File Templates.
 */
package org.david.ui.player {
import flash.events.EventDispatcher;

import flash.events.NetStatusEvent;
import flash.events.SecurityErrorEvent;
import flash.media.SoundTransform;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.utils.getTimer;
import flash.utils.setInterval;
import flash.utils.setTimeout;

import org.david.ui.MVideoPlayer;

import org.david.ui.event.UIEvent;
import org.david.util.LogUtil;
import org.david.util.StrUtil;

public class MRTMPPlayer extends EventDispatcher implements IPlayer {
//    public static var NetStatusUIEvent:String = "NetStatusUIEvent";
//    public static const Buffering:String = "Player.Buffering";
//    public static const PlayStart:String = "Player.PlayStart";
    public static const DebugInfo:String = "Player.DebugInfo";
//    public static const NetConnectionStatus:String = "NetConnectionStatus";
    private var _connection:NetConnection;
    protected var _stream:NetStream;
//    private var _bufferTime:Number;
    private var _server:String;
    private var _filename:String;
    private var _start:Number = 0;
    private var _autoRetry:Boolean;
    private var _replay:Boolean;
    private var _log:Boolean;
    protected var _metaData:Object;
    private var _bufferTime:Number = 0.5;

    public function MRTMPPlayer(autoRetry:Boolean = false, debug:Boolean = false, log:Boolean = true, replay:Boolean = false) {
        super();
        _autoRetry = autoRetry;
        _replay = replay;
        _log = log;

        if (debug) {
            setInterval(onEnterFrame, 1000);
        }
    }

    private var _ispause:Boolean;

    public function get ispause():Boolean {
        return _ispause;
    }

//    protected var _complete:Boolean;
//
//    public function get complete():Boolean {
//        return _complete;
//    }

//    protected var _isStop:Boolean;
//
//    public function get isStop():Boolean {
//        return _isStop;
//    }

//    private var _isPlaying:Boolean;
//
//    public function get isPlaying():Boolean {
//        return _isPlaying;
//    }

    public function get autoRetry():Boolean {
        return _autoRetry;
    }

    public function set autoRetry(value:Boolean):void {
        _autoRetry = value;
    }

    public function get duration():Number {
        if (_metaData)
            return _metaData.duration;
        return 0;
    }

    public function get time():Number {
        return _stream.time;
    }

    public function get bufferTime():Number {
        return _bufferTime;
    }

    public function set bufferTime(value:Number):void {
        _bufferTime = value;
    }

    private var _volume:Number = 1;

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

    public function set mute(value:Boolean):void {
        _mute = value;
        setVolume();
    }

//    private var _buffering:Boolean;
//    public function set buffering(value:Boolean):void {
//        _buffering = value;
//    }
//
//    public function get buffering():Boolean {
//        return _buffering;
//    }

//    private var _metaDataGetCallback:Function;
//    public function set metaDataGetCallback(value:Function):void {
//        _metaDataGetCallback = value;
//    }

    private function netStatusHandler(event:NetStatusEvent):void {
        var code:String = event.info.code;
        LogUtil.log("NetStatusEvent:" + code);
//        dispatchEvent(new UIEvent(NetStatusUIEvent, event));
        callPlayStatsCallback(code);
        switch (code) {
            case "NetConnection.Connect.Success":
                connectStream();
                break;
            case "NetStream.Play.StreamNotFound":
                LogUtil.log("Stream not found: " + _filename);
                if (_autoRetry) {
                    LogUtil.log("AutoRetry :" + _filename + " in 2 second");
                    setTimeout(_play, 2 * 1000);
                }
                break;
            case "NetStream.Play.Stop":
                if (_replay){
                    _stream.seek(1);
//                    _play();
                }
                callPlayStatsCallback(MVideoPlayer.Stop);
                break;
            case "NetConnection.Connect.Failed":
                if (_autoRetry) {
                    LogUtil.log("AutoRetry :" + _filename + " in 2 second");
                    setTimeout(_play, 2 * 1000);
                }
                break;

//            case "NetStream.Play.Start":
//                break;
            case "NetStream.Buffer.Flush":
                    LogUtil.log("AutoRetry",_autoRetry);
                if (_autoRetry) {
                    LogUtil.log("AutoRetry :" + _filename + " in 2 second");
                    setTimeout(_play, 2 * 1000);
                }
                break;
//            case "NetStream.Buffer.Empty":
//                break;
//            case "NetStream.Buffer.Full":
//                break;
//            case "NetStream.Record.Stop":
//                break;
//            case "NetStream.Video.DimensionChange":
//                break;
            case "NetConnection.Connect.Closed":
                _connection.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
                _connection.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
                _connection = null;
                if (_stream) {
                    _stream.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
                    _stream = null;
                }
                LogUtil.log("AutoRetry",_autoRetry);
                if (_autoRetry) {
                    LogUtil.log("AutoRetry :" + _filename + " in 2 second");
                    setTimeout(_play, 2 * 1000);
                }
                break;
        }
    }

    private function securityErrorHandler(event:SecurityErrorEvent):void {
        LogUtil.log("securityErrorHandler: " + event);
    }

    protected function connectStream():void {
        if (_stream == null) {
            _stream = new NetStream(_connection);
            if (_streamCreateCallback)
                _streamCreateCallback(_stream);
            _stream.bufferTime = _bufferTime;
            _stream.maxPauseBufferTime = 120;
            _stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
            _stream.client = this;
        }

        if (_start <= 0)
            _start = getTimer();
        if (_stream)
            _stream.play(_filename);
        if (_ispause)
            _stream.pause();
//        buffering = true;

        setVolume();
    }

    private function onEnterFrame():void {
        if (!_stream)
            return;

        var info:String;
        if (_stream) {
            info = ("缓冲区：" + _stream.bufferTime + "s\t\t已缓冲：" + _stream.bufferLength + "s\t\t已下载：" + int(_stream.bytesLoaded / 1024) + "k\t\t总：" + int(_stream.bytesTotal / 1024) + "k\t\t速度:" + int((_stream.bytesLoaded ) / 1024 / ((getTimer() - _start ) / 1000)) + "k/s" + "\n播放地址：" + _server + "," + _filename);
        }
        if (_metaData) {
            info += ("\n分辨率：" + _metaData.width + "*" + _metaData.height + "\t\tfps：" + _metaData.fps + "\t\tvideo：" + _metaData.videocodecid + " | " + _metaData.videodatarate + "\t\taudio：" + _metaData.audiocodecid + " | " + _metaData.audiodatarate + "\t\tprofile：" + _metaData.profile + "\t\tlevel：" + _metaData.level);
        }
        var patten:RegExp = /undefined/g;
        var tempInfo:String = info.replace(patten, "\"\"");
        dispatchEvent(new UIEvent(DebugInfo, tempInfo));
    }

    public function onMetaData(info:Object):void {
        _metaData = info;
        LogUtil.log("onMetaData: duration=" + info.duration + " width=" + info.width + " height=" + info.height + " framerate=" + info.framerate);
        if (_metaDataCallback)
            _metaDataCallback(info);
    }

    public function onBWCheck(...rest):Number {
        return 0;
    }

    public function onBWDone(...rest):Number {
        var p_bw:Number;
        if (rest.length > 0) p_bw = rest[0];
        // do something here
        LogUtil.log("bandwidth = " + p_bw + " Kbps.");
        //dColumbus added this
        return p_bw;
    }

    public function onCuePoint(info:Object):void {
        LogUtil.log("onCuePoint: time=" + info.time + " name=" + info.name + " type=" + info.type);
    }

    public function onXMPData(info:Object):void {
        LogUtil.log("onXMPData: time=" + info.time + " name=" + info.name + " type=" + info.type);
    }

    public function onPlayStatus(info:Object):void {
        LogUtil.log("onPlayStatus: time=" + info.time + " name=" + info.name + " type=" + info.type + "code=" + info.code + "level=" + info.level);
    }

    public function onLastSecond(info:Object):void {
        LogUtil.log("onLastSecond:" + info);
    }

    public function onFI(infoObj:Object):void {
        LogUtil.log("stream onFI:" + infoObj);
    }

    protected function cleanupStream():void {
        if (_stream != null) {
            _stream.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
            _stream.close();
            _stream = null;
        }
        if (_connection != null) {
            _connection.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
            _connection.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            _connection.close();
            _connection = null;
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

    public function play():void {
        LogUtil.log("***play***", server, filename);
        if (StrUtil.isNullOrEmpty(_filename)) {
            LogUtil.log("Stream is null or empty:" + _filename);
            return;
        }
        cleanupStream();
        _play();
    }

    private function _play():void {
        if (_connection == null) {
            _connection = new NetConnection();
            _connection.client = this;
            _connection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
            _connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
        }
        _connection.connect(_server);
        LogUtil.log("connect to ", _server);
    }

    public function pause():void {
        if (_stream)
            _stream.pause();
        _ispause = true;
        callPlayStatsCallback(MVideoPlayer.Pause);
    }

    public function stop():void {
        _streamCreateCallback = null;
        _metaDataCallback = null;
//        _isStop = true;
//        _isPlaying = false;
//        _complete = true;
        _autoRetry = false;
//        buffering = false;
        cleanupStream();
    }

    public function resume():void {
        if (_stream)
            _stream.resume();
        _ispause = false;
        callPlayStatsCallback(MVideoPlayer.Start);
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

    private function callPlayStatsCallback(status:String):void {
        if (_playStatusCallback)
            _playStatusCallback(status);
    }

    public function get server():String {
        return _server;
    }

    public function set server(value:String):void {
        _server = value;
//        _bufferTime = 0;
    }

    public function get filename():String {
        return _filename;
    }

    public function set filename(value:String):void {
        _filename = value;
    }

    public function seek(time:Number):void {
        if (_server) {
            _stream.seek(time);
        }
    }
    public function get bufferLength():Number {
        if (_stream)
            return _stream.bufferLength;
        return 0;
    }
}
}
