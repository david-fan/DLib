package org.david.ui {
import flash.display.DisplayObject;
import flash.media.Camera;
import flash.media.SoundTransform;
import flash.text.TextField;
import flash.utils.getTimer;
import flash.utils.setInterval;

import org.david.ui.core.MUIComponent;

import flash.events.Event;
import flash.display.Sprite;
import flash.events.NetStatusEvent;
import flash.events.SecurityErrorEvent;
import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;

import org.david.ui.event.UIEvent;
import org.david.util.StrUtil;

public class MVideoPlayer extends MUIComponent {
    public static const Buffering:String = "Player.Buffering";
    public static const PlayStart:String = "Player.PlayStart";
    public static const AutoSize:String = "Player.SizeChange";
    public static const DebugInfo:String = "Player.DebugInfo";

    public function MVideoPlayer(autoRetry:Boolean = false, debug:Boolean = false, bufferTime:Number = 0.1, w:int = 0, h:int = 0, autoResize:Boolean = true) {
        super(true);
        _connection = new NetConnection();
        _connection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
        _connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);

        //_autoPlay = autoPlay;
        _autoRetry = autoRetry;

        _bufferTime = bufferTime;

        if (debug) {
            setInterval(onEnterFrame, 1000);
        }

        _bg = new Sprite();
        _bg.graphics.beginFill(0, 1);
        _bg.graphics.drawRect(0, 0, 1, 1);
        _bg.graphics.endFill();
        addChild(_bg);
        if (w > 0 && h > 0) {
            _videoWidth = w;
            _videoHeight = h;
            _video = new Video(w, h);
        } else
            _video = new Video(_videoWidth, _videoHeight);

        _autoResize = autoResize;
        addChild(_video);
    }

    protected var _video:Video;
    private var _connection:NetConnection;
    private var _stream:NetStream;
    private var _bufferTime:Number;
    private var _server:String;
    private var _filename:String;
    private var _start:Number = 0;
    private var _bg:Sprite;
    private var _videoWidth:Number = 640;
    //private var _autoPlay:Boolean;
    private var _videoHeight:Number = 480;
    private var _autoResize:Boolean;
    private var _ispause:Boolean;

    public function get ispause():Boolean {
        return _ispause;
    }

    private var _isstop:Boolean;

    public function get isstop():Boolean {
        return _isstop;
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

    private var _autoRetry:Boolean;

    public function get autoRetry():Boolean {
        return _autoRetry;
    }

    public function set autoRetry(value:Boolean):void {
        _autoRetry = value;
    }

    private var _bufferSprite:DisplayObject;

    public function get bufferSprite():DisplayObject {
        return _bufferSprite;
    }

    public function set bufferSprite(value:DisplayObject):void {
        _bufferSprite = value;
        bufferVisible = false;
    }

    public function set bufferVisible(value:Boolean):void {
        if (_bufferSprite)
            _bufferSprite.visible = value;
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
//        trace("PlayStream:" + _server + "," + _filename);

        _connection.connect(_server);

        _isstop = false;
    }

    public function stop():void {
        _isstop = true;
        if (_stream)
            _stream.close();
        _video.attachCamera(null);
        _video.attachNetStream(null);
        _video.clear();
    }

    /*
     public function setup(server:String, filename:String):void {
     release();
     _server = server;
     _filename = filename;
     _connection.connect(_server);
     }
     */

    public function pause():void {
        if (_stream)
            _stream.pause();
        _ispause = true;
    }

    public function resume():void {
        _stream.resume();
        _ispause = false;
    }

    public function replay():void {
        release();
        if (_filename)
            _connection.connect(_server);
    }

    public function onMetaData(info:Object):void {
        trace("onMetaData: duration=" + info.duration + " width=" + info.width + " height=" + info.height + " framerate=" + info.framerate);
        if (_autoResize) {
            _videoWidth = info.width;
            _videoHeight = info.height;
            _bg.width = _video.width = _videoWidth;
            _bg.height = _video.height = _videoHeight;
            dispatchEvent(new UIEvent(AutoSize));
        }
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

    public function onFI(infoObj:Object):void {
        trace("stream onFI:" + infoObj);
    }

    public function resize(w:Number, h:Number):void {
        _bg.width = w;
        _bg.height = h;
        if (_videoHeight > 0 && _videoWidth > 0) {
            var sx:Number = w / _videoWidth;
            var sy:Number = h / _videoHeight;
            if (sx > sy) {
                _video.width = _videoWidth * sy;
                _video.height = _videoHeight * sy;
            } else {
                _video.width = _videoWidth * sx;
                _video.height = _videoHeight * sx;
            }
            _video.x = (w - _video.width) / 2;
            _video.y = (h - _video.height) / 2;
        }
    }

    public function playCam(c:Camera):void {
        cleanupStream();
        _video.attachCamera(c);
        bufferVisible = false;
        _videoWidth = c.width;
        _videoHeight = c.height;
        _bg.width = _video.width = _videoWidth;
        _bg.height = _video.height = _videoHeight;
        dispatchEvent(new UIEvent(AutoSize));
        dispatchEvent(new UIEvent(PlayStart));
    }

    protected function connectStream():void {
        _stream = new NetStream(_connection);
        _stream.bufferTime = _bufferTime;
        _stream.maxPauseBufferTime = 120;
        _stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
        _stream.client = this;
        _video.attachNetStream(_stream);

        if (_start <= 0)
            _start = getTimer();
        if (_stream)
            _stream.play(_filename);
        bufferVisible = true;

        setVolume();
    }

    private function setVolume():void {
        if (_stream) {
            if (_mute)
                _stream.soundTransform = new SoundTransform(0);
            else
                _stream.soundTransform = new SoundTransform(_volume);
        }
    }

    private function release():void {
        if (_connection) {
            _connection.close();
        }
        if (_stream) {
            _stream.close()
        }
    }

    private function onEnterFrame():void {
        var ns:NetStream = _stream;
        var info:String = ("缓冲区：" + ns.bufferTime + "s 已缓冲：" + ns.bufferLength + "s 已下载：" + int(ns.bytesLoaded / 1024) + "k 总：" + int(ns.bytesTotal / 1024) + "k 速度:" + int((ns.bytesLoaded ) / 1024 / ((getTimer() - _start ) / 1000)) + "k/s" +
                "\n播放地址:" + _filename + "");
        dispatchEvent(new UIEvent(DebugInfo, info));
    }

    private function cleanupStream():void {
        if (_stream != null) {
            _stream.close();
        }
        if (_connection != null) {
            _connection.close();
        }
    }

    private function netStatusHandler(event:NetStatusEvent):void {
        trace("NetStatusEvent:", event.info.code);
        switch (event.info.code) {
            case "NetConnection.Connect.Success":
                connectStream();
                break;
            case "NetStream.Play.StreamNotFound":
                trace("Stream not found: " + _filename);
                if (_autoRetry) {
                    trace("AutoRetry url:" + _filename);
                    play();
                }
                break;
            case "NetStream.Play.Start":
                bufferVisible = false;
                dispatchEvent(new UIEvent(PlayStart));
                break;
            case "NetStream.Play.Stop":
                if (_autoRetry) {
                    trace("AutoRetry url:" + _filename);
                    play();
                }
            case "NetStream.Buffer.Flush":
                break;
            case "NetStream.Buffer.Empty":
                dispatchEvent(new UIEvent(Buffering));
                bufferVisible = true;
                break;
            case "NetStream.Buffer.Full":
                bufferVisible = false;
                break;
            case "NetStream.Record.Stop":
                bufferVisible = false;
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
                break;
        }
    }

    private function securityErrorHandler(event:SecurityErrorEvent):void {
        trace("securityErrorHandler: " + event);
    }
}
}
