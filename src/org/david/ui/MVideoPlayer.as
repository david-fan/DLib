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

public class MVideoPlayer extends MMediaPlayer {

    public static const AutoSize:String = "Player.SizeChange";

    public function MVideoPlayer(autoRetry:Boolean = false, debug:Boolean = false,w:int = 0, h:int = 0, keepDefaultAspect:Boolean = true) {
        super(autoRetry, debug);


        //_autoPlay = autoPlay;


        _bg = new Sprite();
        _bg.graphics.beginFill(0, 1);
        _bg.graphics.drawRect(0, 0, 1, 1);
        _bg.graphics.endFill();
        addChild(_bg);
        _bg.x = -1;
        _bg.y=-1;
        if (w > 0 && h > 0) {
            _videoWidth = w;
            _videoHeight = h;
            _video = new Video(w, h);
        } else
            _video = new Video(_videoWidth, _videoHeight);

        _keepDefaultAspect = keepDefaultAspect;
        addChild(_video);
    }

    protected var _video:Video;


    private var _bg:Sprite;
    private var _videoWidth:Number = 640;
    private var _videoHeight:Number = 480;
    private var _keepDefaultAspect:Boolean;


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

    override public function set buffering(value:Boolean):void {
        super.buffering = value;
        bufferVisible = value;
    }

    override public function onMetaData(info:Object):void {
        super.onMetaData(info);
        if (_keepDefaultAspect) {
//            _video.width = info.width;
//            _video.height = info.height;
            _bg.width=_videoWidth+2;
            _bg.height=_videoHeight+2;

            var sx:Number =  _videoWidth/info.width;
            var sy:Number =  _videoHeight/info.height;
            if (sx > sy) {
                _video.width = info.width * sy;
                _video.height = info.height * sy;
            } else {
                _video.width =  info.width * sx;
                _video.height = info.height * sx;
            }
            _video.x = (_videoWidth - _video.width) / 2;
            _video.y = (_videoHeight - _video.height) / 2;
            dispatchEvent(new UIEvent(AutoSize));
        }
    }

    /*
     public function setup(server:String, filename:String):void {
     release();
     _server = server;
     _filename = filename;
     _connection.connect(_server);
     }
     */


    public function resize(w:Number, h:Number):void {
        _bg.width = _videoWidth=w;
        _bg.height =_videoHeight= h;
        if(_metaData==null)
            return;
        if (w > 0 && h > 0) {
            var sx:Number = w / _metaData.width;
            var sy:Number = h / _metaData.height;
            if (sx > sy) {
                _video.width = _metaData.width * sy;
                _video.height = _metaData.height * sy;
            } else {
                _video.width = _metaData.width * sx;
                _video.height = _metaData.height * sx;
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

    override protected function connectStream():void {
        super.connectStream();
        _video.attachNetStream(_stream);
    }

    override protected function cleanupStream():void{
        super.cleanupStream();
        _video.attachNetStream(null);
    }

    override public function stop():void {
        super.stop();
        _video.attachCamera(null);
        _video.attachNetStream(null);
        _video.clear();

    }


}
}
