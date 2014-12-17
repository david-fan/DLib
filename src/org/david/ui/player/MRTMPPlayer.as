/**
 * Created with IntelliJ IDEA.
 * User: xiecc
 * Date: 13-12-4
 * Time: 下午3:26
 * To change this template use File | Settings | File Templates.
 */
package org.david.ui.player {
import flash.events.Event;
import flash.events.EventDispatcher;

import org.david.ui.*;

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
import org.david.util.LogUtil;
import org.david.util.StrUtil;

public class MRTMPPlayer extends EventDispatcher implements IPlayer {
    public static const Buffering:String = "Player.Buffering";
    public static const PlayStart:String = "Player.PlayStart";
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

    protected var _complete:Boolean;

    public function get complete():Boolean {
        return _complete;
    }

    protected var _isStop:Boolean;

    public function get isStop():Boolean {
        return _isStop;
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

    public function set mute(value:Boolean):void {
        _mute = value;
        setVolume();
    }

    private var _buffering:Boolean;
    public function set buffering(value:Boolean):void {
        _buffering = value;
    }

    public function get buffering():Boolean {
        return _buffering;
    }

//    private var _metaDataGetCallback:Function;
//    public function set metaDataGetCallback(value:Function):void {
//        _metaDataGetCallback = value;
//    }

    private function netStatusHandler(event:NetStatusEvent):void {
        LogUtil.log("NetStatusEvent:" + event.info.code);
        switch (event.info.code) {
            case "NetConnection.Connect.Success":
                connectStream();
                break;
            case "NetStream.Play.StreamNotFound":
                LogUtil.log("Stream not found: " + _filename);
                if (!_isStop && _autoRetry) {
                    LogUtil.log("AutoRetry :" + _filename + " in 2 second");
                    setTimeout(_play, 2 * 1000);
                }
                break;
            case "NetStream.Play.Start":
                _isPlaying = false;
                dispatchEvent(new UIEvent(PlayStart));
                break;
            case "NetStream.Play.Stop":
                if (_replay)
                    _stream.seek(1);
                _isStop = true;
                _isPlaying = false;
                _complete = true;
                break;
            case "NetStream.Buffer.Flush":
                _isStop = true;
                _isPlaying = false;
                _complete = true;
                break;
            case "NetStream.Buffer.Empty":
                dispatchEvent(new UIEvent(Buffering));
                if (!_complete)
                    buffering = true;
                break;
            case "NetStream.Buffer.Full":
                buffering = false;
                break;
            case "NetStream.Record.Stop":
                _isPlaying = false;
                break;
            case "NetStream.Video.DimensionChange":
                LogUtil.log(event.toString());
                break;
            case "NetConnection.Connect.Closed":
//                dispatchEvent(new UIEvent(NetConnectionStatus, "closed"));
                if (!_isStop && _autoRetry) {
                    LogUtil.log("AutoRetry :" + _filename + " in 2 second");
                    setTimeout(_play, 2 * 1000);
                }
                else {
                    if (_connection) {
                        _connection.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
                        _connection.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
                    }
                    if (_stream) {
                        _stream.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
                    }
                }
                break;
            case "NetConnection.Connect.Failed":
//                dispatchEvent(new UIEvent(NetConnectionStatus, "failed"));
                if (!_isStop && _autoRetry) {
                    LogUtil.log("AutoRetry :" + _filename + " in 2 second");
                    setTimeout(_play, 2 * 1000);
                }
                break;
            case "NetStream.Play.Complete":
//                _complete = true;
//                dispatchEvent(new UIEvent(NetConnectionStatus, "complete"));
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
        if (!_stream)
            return;
        var ns:NetStream = _stream;
        if (ns && _metaData) {
            var info:String = ("缓冲区：" + ns.bufferTime + "s\t\t已缓冲：" + ns.bufferLength + "s\t\t已下载：" + int(ns.bytesLoaded / 1024) + "k\t\t总：" + int(ns.bytesTotal / 1024) + "k\t\t速度:" + int((ns.bytesLoaded ) / 1024 / ((getTimer() - _start ) / 1000)) + "k/s" + "\n播放地址：" + _filename + "\n分辨率：" + _metaData.width + "*" + _metaData.height + "\t\tfps：" + _metaData.fps + "\t\tvideo：" + _metaData.videocodecid + " | " + _metaData.videodatarate + "\t\taudio：" + _metaData.audiocodecid + " | " + _metaData.audiodatarate + "\t\tprofile：" + _metaData.profile + "\t\tlevel：" + _metaData.level);
            var patten:RegExp = /undefined/g;
            var tempInfo:String = info.replace(patten, "\"\"");
        }
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
//            _stream.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
            _stream.close();
        }
        if (_connection != null) {
//            _connection.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
//            _connection.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            _connection.close();
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
    }

    public function stop():void {
        _streamCreateCallback = null;
        _metaDataCallback = null;
        _isStop = true;
        _isPlaying = false;
        _complete = true;
        _autoRetry = false;
        buffering = false;
        cleanupStream();
    }

    public function resume():void {
        if (_stream)
            _stream.resume();
        _ispause = false;
    }

    private var _streamCreateCallback:Function;
    public function set streamCreateCallback(value:Function):void {
        _streamCreateCallback = value;
    }

    private var _metaDataCallback:Function

    public function set metaDataGetCallback(value:Function):void {
        _metaDataCallback = value;
    }

    public function get server():String {
        return _server;
    }

    public function set server(value:String):void {
        _server = value;
    }

    public function get filename():String {
        return _filename;
    }

    public function set filename(value:String):void {
        _filename = value;
    }
}
}
