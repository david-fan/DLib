package org.david.ui {
import flash.display.DisplayObject;
import flash.events.Event;
import flash.media.Camera;
import flash.display.Sprite;
import flash.media.Video;
import flash.net.NetStream;

import org.david.ui.core.MSprite;

import org.david.ui.event.UIEvent;
import org.david.ui.player.IPlayer;
import org.david.ui.player.MRTMPPlayer;
import org.david.ui.player.MRangePlayer;
import org.david.ui.player.MHLSPlayer;
import org.david.util.LogUtil;

public class MVideoPlayer extends MSprite {
    public static const AutoSize:String = "Player.SizeChange";

    private var _player:IPlayer;
//    private var _metaData:Object;

    protected var _video:Video;
    private var _stream:NetStream;
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

    public function set buffering(value:Boolean):void {
//        super.buffering = value;
        bufferVisible = value;
    }

    private var _mute:Boolean;
    public function get mute():Boolean {
        return _mute;
    }

    public function set mute(value:Boolean):void {
        _mute = value;
        if (_player)
            _player.mute = value;
    }

    private var _volume:Number = 1;
    public function get volume():Number {
        return _volume;
    }

    public function set volume(value:Number):void {
        _volume = value;
        if (_player)
            _player.volume = value;
    }

//
//    private var _loop:Boolean;
//
//    public function get loop():Boolean {
//        return _loop;
//    }
//
//    public function set loop(value:Boolean):void {
//        _loop = value;
//    }

    public function MVideoPlayer(w:Number, h:Number, keepDefaultAspect:Boolean = true) {
        _bg = new Sprite();
        _bg.graphics.beginFill(0x000000, 1);
        _bg.graphics.drawRect(0, 0, 1, 1);
        _bg.graphics.endFill();
        addChild(_bg);
        if (w > 0 && h > 0) {
            _videoWidth = w;
            _videoHeight = h;
            _video = new Video(w, h);
        } else
            _video = new Video(_videoWidth, _videoHeight);
        _video.smoothing = true;

        _keepDefaultAspect = keepDefaultAspect;
        addChild(_video);
    }


//    public function onMetaData(info:Object):void {
////        super.onMetaData(info);
//        if (_keepDefaultAspect) {
////            _video.width = info.width;
////            _video.height = info.height;
//            _bg.width = _videoWidth;
//            _bg.height = _videoHeight;
//
//            var sx:Number = _videoWidth / info.width;
//            var sy:Number = _videoHeight / info.height;
//            if (sx > sy) {
//                _video.width = info.width * sy;
//                _video.height = info.height * sy;
//            } else {
//                _video.width = info.width * sx;
//                _video.height = info.height * sx;
//            }
//            _video.x = (_videoWidth - _video.width) / 2;
//            _video.y = (_videoHeight - _video.height) / 2;
//            dispatchEvent(new UIEvent(AutoSize));
//        }
//    }

    public function resize(w:Number=0,h:Number=0):void {
        if(w&&h){
            _bg.width = _videoWidth=w;
            _bg.height = _videoHeight=h;
        }else{
            _bg.width = _videoWidth;
            _bg.height = _videoHeight;
        }
        if (!_keepDefaultAspect) {
            _video.width = _videoWidth;
            _video.height = _videoHeight;
            _video.x = 0;
            _video.y = 0;
            return;
        }
        if (_stream == null){
            _video.width = _videoWidth;
            _video.height = _videoHeight;
        }else {
            if (_video.videoWidth > 0 && _video.videoHeight > 0 && _videoWidth > 0 && _videoHeight > 0) {
                var sx:Number = _videoWidth / _video.videoWidth;
                var sy:Number = _videoHeight / _video.videoHeight;
                if (sx > sy) {
                    _video.width = _video.videoWidth * sy;
                    _video.height = _video.videoHeight * sy;
                } else {
                    _video.width = _video.videoWidth * sx;
                    _video.height = _video.videoHeight * sx;
                }
                _video.x = (_videoWidth - _video.width) / 2;
                _video.y = (_videoHeight - _video.height) / 2;
            }
        }

    }

    public function playCam(c:Camera):void {
//        cleanupStream();
        _video.attachCamera(c);
        bufferVisible = false;
        _videoWidth = c.width;
        _videoHeight = c.height;
        _bg.width = _video.width = _videoWidth;
        _bg.height = _video.height = _videoHeight;
        dispatchEvent(new UIEvent(AutoSize));
//        dispatchEvent(new UIEvent(PlayStart));
    }

    private function play():void {
        if (_player) {
            _player.mute = mute;
            _player.volume = volume;
            _player.play();
        }
    }

    public function pause():void {
        if (_player)
            _player.pause();
    }

    public function resume():void {
        if (_player)
            _player.resume();
    }

    public function playRTMP(server:String, streamId:String):void {
        if (_player) {
            _player.stop();
            _player = null;
        }
        var player:MRTMPPlayer = new MRTMPPlayer(true);
        player.streamCreateCallback = attachStream;
        player.server = server;
        player.filename = streamId;

        _player = player;
        play();
    }

    public function playFLV(flvURL:String, range:Boolean = false):void {
        if (_player) {
            _player.stop();
            _player = null;
        }
        if (range) {
            var rangePlayer:MRangePlayer = new MRangePlayer();
            rangePlayer.streamCreateCallback = attachStream;
            rangePlayer.playUrl = flvURL;
            _player = rangePlayer;
        } else {
            var rtmpplayer:MRTMPPlayer = new MRTMPPlayer(true);
            rtmpplayer.streamCreateCallback = attachStream;
            rtmpplayer.server = null;
            rtmpplayer.filename = flvURL;
            _player = rtmpplayer;
        }
        play();
    }

    public function playM3U8(m3u8Url:String):void {
        if (_player) {
            _player.stop();
            _player = null;
        }
        var hls:MHLSPlayer = new MHLSPlayer();
        hls.streamCreateCallback = attachStream;
        hls.m3u8Url = m3u8Url;
        _player = hls;
        play();

        if (stage)
            hls.stage = stage
        else
            addEventListener(Event.ADDED_TO_STAGE, onAddToStage);
    }

    private function onAddToStage(e:Event):void {
        (_player as MHLSPlayer).stage = this.stage;
        removeEventListener(Event.ADDED_TO_STAGE, onAddToStage);
    }

    private function attachStream(stream:NetStream):void {
        _video.attachNetStream(stream);
        _stream = stream;
        _player.metaDataGetCallback=metaData;
    }
    private function metaData(info:Object):void{
        resize();
    }
    public function stop():void {
//        super.stop();
        _video.attachCamera(null);
        _video.attachNetStream(null);
        _video.clear();
        if (_player) {
            _player.stop();
            _player = null;
        }
    }

    public function replay():void {
        LogUtil.error("no replay implement");
    }

}
}
