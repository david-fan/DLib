/**
 * Created by david on 10/30/14.
 */
package org.david.ui.player {
import flash.media.SoundTransform;

import org.mangui.hls.HLS;
import org.mangui.hls.event.HLSEvent;

public class MHLSPlayer extends HLS implements IPlayer {
    private var _m3u8Url:String;
    private var _position:Number = 0;
    private var _duration:Number = 0;
    private var _bufferedTime:Number = 0;

    public function MHLSPlayer() {
        super();
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
        addEventListener(HLSEvent.MANIFEST_LOADED, manifestHandler);
//        addEventListener(HLSEvent.MANIFEST_LOADED, manifestHandler);
//        addEventListener(HLSEvent.MEDIA_TIME, manifestHandler);
    }

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


    private function manifestHandler(event:HLSEvent):void {
        stream.play();
        _streamCreateCallback(stream);
//        if (event.mediatime) {
//            _position = Math.max(0, event.mediatime.position);
//            _duration = event.mediatime.duration;
//            _bufferedTime = event.mediatime.buffer + event.mediatime.position;
//        }
    }
}
}
