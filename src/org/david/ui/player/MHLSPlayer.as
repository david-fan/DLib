/**
 * Created by david on 10/30/14.
 */
package org.david.ui.player {
import flash.media.SoundTransform;

import org.david.ui.MVideoPlayer;

import org.mangui.hls.HLS;
import org.mangui.hls.HLSSettings;
import org.mangui.hls.event.HLSEvent;

public class MHLSPlayer extends HLS implements IPlayer {
    private var _m3u8Url:String;

    private var _hasManifest:Boolean;
    protected var _media_position:Number;
    protected var _duration:Number;
    private var _seek:Number;

    public function MHLSPlayer() {
        super();
        HLSSettings.maxBufferLength = 120;
        HLSSettings.lowBufferLength = 60;
    }

    public function get duration():Number {
//        if(_metaData)
//            return _metaData.duration;
        return _duration;
    }

    public function get time():Number {
//        return stream.time;
        return _media_position;
    }

    private var _volume:Number;

    public function set volume(value:Number):void {
        _volume = value;
        setVolume();
    }

    public function get volume():Number {
        return _volume;
    }

    private function setVolume():void {
        if (_mute)
            stream.soundTransform = new SoundTransform(0);
        else
            stream.soundTransform = new SoundTransform(_volume);
    }

    public function pause():void {
        stream.pause();
    }

    public function play():void {
        load(_m3u8Url);
        addEventListener(HLSEvent.MANIFEST_LOADED, onManifestLoaded);
//        addEventListener(HLSEvent.MEDIA_TIME, onManifestLoaded);
        addEventListener(HLSEvent.PLAYBACK_COMPLETE, onPlayComplete);

        addEventListener(HLSEvent.ERROR, _errorHandler);
//        _hls.addEventListener(HLSEvent.FRAGMENT_LOADED, _fragmentLoadedHandler);
//        _hls.addEventListener(HLSEvent.FRAGMENT_PLAYING, _fragmentPlayingHandler);
//        _hls.addEventListener(HLSEvent.MANIFEST_LOADED, _manifestHandler);
        addEventListener(HLSEvent.MEDIA_TIME, onMediaTime);
//        _hls.addEventListener(HLSEvent.PLAYBACK_STATE, _stateHandler);
//        _hls.addEventListener(HLSEvent.LEVEL_SWITCH, _levelSwitchHandler);
//        _hls.addEventListener(HLSEvent.AUDIO_TRACKS_LIST_CHANGE, _audioTracksListChange);
//        _hls.addEventListener(HLSEvent.AUDIO_TRACK_CHANGE, _audioTrackChange);
    }
    private function _errorHandler(event:HLSEvent):void{
        if (_playStatusCallback)
            _playStatusCallback(MVideoPlayer.PlayError);
    }
    protected function onMediaTime(event:HLSEvent):void {
        _duration = event.mediatime.duration;
        _media_position = event.mediatime.position;
    }

    protected function onPlayComplete(event:HLSEvent):void {
        if (_playStatusCallback)
            _playStatusCallback(MVideoPlayer.Complete);
    };

    public function resume():void {
        stream.resume();
    }

    public function stop():void {
        _streamCreateCallback = null;
        _metaDataCallback = null;
        stream.close();
    }

    private var _mute:Boolean;
    public function get mute():Boolean {
        return _mute;
    }

    public function set mute(value:Boolean):void {
        _mute = value;
        setVolume();
    }

    private var _streamCreateCallback:Function;
    public function set streamCreateCallback(value:Function):void {
        _streamCreateCallback = value;
    }

    private var _metaDataCallback:Function;

    public function set metaDataGetCallback(value:Function):void {
        _metaDataCallback = value;
    }

    private var _playStatusCallback:Function

    public function set playStatusCallback(value:Function):void {
        _playStatusCallback = value;
    }

//    private var _metaDataGetCallback:Function;
//    public function set metaDataGetCallback(value:Function):void {
//        _metaDataGetCallback = value;
//    }

    public function get m3u8Url():String {
        return _m3u8Url;
    }

    public function set m3u8Url(value:String):void {
        _m3u8Url = value;
    }


    private function onManifestLoaded(event:HLSEvent):void {
        _hasManifest = true;
        stream.play();
        _streamCreateCallback(stream);
        _playStatusCallback(MVideoPlayer.Full);
        if (_seek > 0)
            stream.seek(_seek);
//        if (event.mediatime) {
//            _position = Math.max(0, event.mediatime.position);
//            _duration = event.mediatime.duration;
//            _bufferedTime = event.mediatime.buffer + event.mediatime.position;
//        }
    }

    public function seek(time:Number):void {
        _seek = time;
        if (_hasManifest)
            stream.seek(time);
    }
    public function get bufferLength():Number {
        if (stream)
            return stream.bufferLength;
        return 0;
    }
}
}
