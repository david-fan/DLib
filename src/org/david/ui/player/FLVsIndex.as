/**
 * Created by david on 1/5/15.
 */
package org.david.ui.player {
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.utils.Dictionary;

import org.casalib.events.LoadEvent;
import org.casalib.load.DataLoad;
import org.david.ui.event.UIEvent;
import org.david.util.LogUtil;
import org.david.util.StrUtil;

public class FLVsIndex extends EventDispatcher {
    public static var ParseOK:String = "ParseOK";
    public var flvsPath:String;
    public var flvsName:String;
    private var _indexUrl:String;
    private var loader:DataLoad;

    public var totalTimeLength:Number;
    public var timeStamp:Number;
    public var flvs:Dictionary;
    public var parseOK:Boolean;

    public function FLVsIndex() {
    }

    private function parse(txts:String):void {
        flvs = new Dictionary();
        var r:RegExp = /^\d+$/;
        var temps:Array = txts.split("\n");
        for (var i:int = 0; i < temps.length; i++) {
            var line:String = temps[i];
            var strs:Array = line.split(":");
            var prefix:String = strs[0];
            if (r.test(prefix)) {
                flvs[parseInt(prefix)] = {start: parseFloat(strs[1]), end: parseFloat(strs[2])};
            } else if (prefix == "totalTimeLength") {
                totalTimeLength = parseFloat(strs[1]);
            } else if (prefix == "timestamp") {
                timeStamp = parseFloat(strs[1]);
            }
        }
        parseOK = true;
        dispatchEvent(new UIEvent(FLVsIndex.ParseOK));
    }

    public function getFlvUrl(index:int):String {
        return flvsPath + "/" + StrUtil.replace(flvsName, index, timeStamp);
    }

    public function get indexUrl():String {
        return _indexUrl;
    }

    public function set indexUrl(value:String):void {
        _indexUrl = value;
        flvsPath = _indexUrl.substr(0, _indexUrl.lastIndexOf("\/"));
        var reg:RegExp = /\d+-\d+/g;
        flvsName = reg.exec(_indexUrl) + "-{0}-{1}.flv";
        if (loader)
            loader.stop();

        loader = new DataLoad(_indexUrl)
        loader.addEventListener(LoadEvent.COMPLETE, onComplete);
        loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
        loader.start();
    }

    private function onIOError(e:IOErrorEvent):void {
        LogUtil.error("network error:", _indexUrl);
    }

    private function onComplete(e:LoadEvent):void {
        parse(loader.dataAsString);
    }
}
}
