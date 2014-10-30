/**
 * Created by david on 10/17/14.
 */
package org.david.ui {
import flash.media.Video;

import org.david.ui.core.MSprite;
import org.mangui.hls.HLS;
import org.mangui.hls.event.HLSEvent;

public class MMediaHLSPlayer extends MSprite {

    private var hls:HLS = null;
    private var video:Video = null;

    public function MMediaHLSPlayer(width:Number = 640, height:Number = 480) {
        hls = new HLS();

        video = new Video(width, height);
        addChild(video);
        video.x = 0;
        video.y = 0;
        video.smoothing = true;
        video.attachNetStream(hls.stream);
        hls.addEventListener(HLSEvent.MANIFEST_LOADED, manifestHandler);
//        hls.load("http://domain.com/hls/m1.m3u8");
    }

    public function manifestHandler(event:HLSEvent):void {
        hls.stream.play();
    }

    public function play(m3u8:String):void {
        hls.load(m3u8);
    }

//    public function MMediaHLSPlayer() {
//    }
}
}
