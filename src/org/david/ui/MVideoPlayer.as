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
import org.david.ui.player.MFLVsPlayer;
import org.david.ui.player.MLetvPlayer;
import org.david.ui.player.MRTMPPlayer;
import org.david.ui.player.MRangePlayer;
import org.david.ui.player.MHLSPlayer;

public class MVideoPlayer extends MSprite {
    public static const Empty:String = "NetStream.Buffer.Empty";
    public static const Full:String = "NetStream.Buffer.Full";
    public static const Seek:String = "NetStream.Seek.Notify";
    public static const SeekStart:String = "NetStream.SeekStart.Notify";
    public static const Start:String = "NetStream.Play.Start";
    public static const Pause:String = "Pause";
    public static const Stop:String = "NetStream.Play.Stop";
    public static const PlayStatus:String = "PlayStatus";
    public static const AutoSize:String = "AutoSize";
    private var _player:IPlayer;
    protected var _video:Video;
    private var _stream:NetStream;
//    private var _videoWidth:Number = 640;
//    private var _videoHeight:Number = 480;
    private var _keepDefaultAspect:Boolean;


//    private var _bufferSprite:DisplayObject;

//    public function get bufferSprite():DisplayObject {
//        return _bufferSprite;
//    }
//
//    public function set bufferSprite(value:DisplayObject):void {
//        _bufferSprite = value;
//        bufferVisible = false;
//    }

//    public function set bufferVisible(value:Boolean):void {
//        if (_bufferSprite)
//            _bufferSprite.visible = value;
//    }

//    private var _buffering:Boolean;

//    public function set buffering(value:Boolean):void {
//        _buffering = value;
//        bufferVisible = _buffering;
//    }
//
//    public function get buffering():Boolean {
//        return _buffering;
//    }

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

    public function get video():Video {
        return _video;
    }

//    public function get duration():Number {
//        if (_player)
//            return _player.duration;
//        return 0;
//    }

    public function MVideoPlayer(w:Number = 640, h:Number = 480, keepDefaultAspect:Boolean = true) {
        _video = new Video(w, h);
        _video.smoothing = true;

        _keepDefaultAspect = keepDefaultAspect;
        addChild(_video);
    }

    public function resize(w:Number = 0, h:Number = 0):void {
        _video.width = w || _video.width;
        _video.height = h || _video.height;

        if (!_keepDefaultAspect || _stream == null) {
            return;
        }
        if (_video.videoWidth > 0 && _video.videoHeight > 0) {
            var sx:Number = _video.width / _video.videoWidth;
            var sy:Number = _video.height / _video.videoHeight;
            if (sx > sy) {
                _video.width = _video.videoWidth * sy;
                _video.height = _video.videoHeight * sy;
            } else {
                _video.width = _video.videoWidth * sx;
                _video.height = _video.videoHeight * sx;
            }
        }
    }

    public function playCam(c:Camera):void {
        _video.attachCamera(c);
        _video.width = c.width;
        _video.height = c.height;
        dispatchEvent(new UIEvent(AutoSize, _video));
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
        player.playStatusCallback = playStatusChange;
        player.streamCreateCallback = attachStream;
        player.server = server;
        player.filename = streamId;
        player.bufferTime = _bufferTime;

        _player = player;

        play();
    }

    public function playFLV(flvURL:String, range:Boolean = false, letv:Boolean = false):void {
        if (_player) {
            _player.stop();
            _player = null;
        }
        if (range) {
            if (letv) {
                var letvPlayer:MLetvPlayer = new MLetvPlayer();
                letvPlayer.streamCreateCallback = attachStream;
                letvPlayer.playStatusCallback = playStatusChange;
                letvPlayer.playUrl = flvURL;
                _player = letvPlayer;
            } else {
                var rangePlayer:MRangePlayer = new MRangePlayer();
                rangePlayer.streamCreateCallback = attachStream;
                rangePlayer.playStatusCallback = playStatusChange;
                rangePlayer.playUrl = flvURL;
                _player = rangePlayer;
            }
        } else {
            var rtmpplayer:MRTMPPlayer = new MRTMPPlayer(true);
            rtmpplayer.streamCreateCallback = attachStream;
            rtmpplayer.playStatusCallback = playStatusChange;
            rtmpplayer.server = null;
            rtmpplayer.filename = flvURL;
            _player = rtmpplayer;
        }
        play();
    }

    public function playFLVs(flvsIndexUrl:String, seek:int = 0):void {
        if (_player) {
            _player.stop();
            _player = null;
        }

        var rtmpplayer:MFLVsPlayer = new MFLVsPlayer();
        rtmpplayer.playStatusCallback = playStatusChange;
        rtmpplayer.streamCreateCallback = attachStream;
        rtmpplayer.flvsIndexUrl = flvsIndexUrl;
        _player = rtmpplayer;
        _player.mute = mute;
        _player.volume = volume;
        if (seek > 0)
            rtmpplayer.seek(seek);
        else {
            rtmpplayer.play();
        }

    }

    public function seek(time:Number):void {
        if (_player)
            _player.seek(time);
    }

    public function playM3U8(m3u8Url:String):void {
        if (_player) {
            _player.stop();
            _player = null;
        }
        var hls:MHLSPlayer = new MHLSPlayer();
        hls.playStatusCallback = playStatusChange;
        hls.streamCreateCallback = attachStream;
        hls.m3u8Url = m3u8Url;
        _player = hls;
        play();

        if (stage)
            hls.stage = stage;
        else
            addEventListener(Event.ADDED_TO_STAGE, onAddToStage);
    }

    private function onAddToStage(e:Event):void {
        if (_player is MHLSPlayer)
            (_player as MHLSPlayer).stage = this.stage;
        removeEventListener(Event.ADDED_TO_STAGE, onAddToStage);
    }

    private function playStatusChange(status:String):void {
        dispatchEvent(new UIEvent(PlayStatus, status));
    }

    private function attachStream(stream:NetStream):void {
        _video.attachNetStream(stream);
        _stream = stream;
        _player.metaDataGetCallback = metaDataGet;
    }

    private function metaDataGet(info:Object):void {
        resize();
        dispatchEvent(new UIEvent(AutoSize, _video));
    }

    public function stop():void {
        _video.attachCamera(null);
        _video.attachNetStream(null);
        _video.clear();
        if (_player) {
            _player.stop();
            _player = null;
        }
    }

    private var _bufferTime:Number = 0.5;

    public function set bufferTime(value:Number):void {
        _bufferTime = value;
        if (_player is MRTMPPlayer) {
            (_player as MRTMPPlayer).bufferTime = value;
        }
    }

    public function get time():Number {
        if (_player)
            return _player.time;
        return -1;
    }

    public function get duration():Number {
        if (_player)
            return _player.duration;
        return -1;
    }

//    override public function set height(value:Number):void {
//        super.height = value;
//    }
//
//    override public function get height():Number {
//        return super.height;
//    }
//
//    override public function set width(value:Number):void {
//        super.width = value;
//    }
//
//    override public function get width():Number {
//        return super.width;
//    }

    public function get aspect():Number {
        return _video.width / _video.height;
    }
}
}
