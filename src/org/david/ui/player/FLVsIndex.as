/**
 * Created by david on 1/5/15.
 */
package org.david.ui.player {
import com.adobe.serialization.json.JSONExt;

import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.utils.Dictionary;

import org.casalib.events.LoadEvent;
import org.casalib.load.DataLoad;
import org.david.ui.event.UIEvent;
import org.david.util.LogUtil;
import org.david.util.StrUtil;

public class FLVsIndex extends EventDispatcher {
//    public static var ParseOK:String = "ParseOK";
    public var flvsPath:String;
    public var flvsName:String;
    public var zero4Thirteenth:Boolean;
    private var _loadedFirst:Boolean;
    private var _indexUrl:String;
    private var loader:DataLoad;

    public var duration:Number;
    public var timestamp:Number;
    public var timeIndexItems:Array;
    public var parseOK:Boolean;


    public function FLVsIndex() {
    }

    private function parse(txts:String):void {
        //{"duration":2,"timestamp":1420622214,"length":2040903,"timeIndexItems":[{"start":0,"end":2011},{"start":2011,"end":4011}]}
        var index:Object = JSONExt.decode(txts);
        duration = index.duration;
        timestamp = index.timestamp;
        timeIndexItems = index.timeIndexItems;
        zero4Thirteenth = index.zero4Thirteenth;
        parseOK = true;
//        dispatchEvent(new UIEvent(FLVsIndex.ParseOK));
    }

    public function getFlvUrl(index:int):String {
        if (index > timeIndexItems.length)
            return null;
        if (zero4Thirteenth && !_loadedFirst) {
            _loadedFirst = true;
            return flvsPath + "/" + StrUtil.replace(flvsName, 0, timestamp);
        }
        return flvsPath + "/" + StrUtil.replace(flvsName, index, timestamp);
    }

    public function get indexUrl():String {
        return _indexUrl;
    }

    public function set indexUrl(value:String):void {
        _indexUrl = value;
        flvsPath = _indexUrl.substr(0, _indexUrl.lastIndexOf("\/"));
//        var reg:RegExp = /\d+-\d+/g;
//        flvsName = reg.exec(_indexUrl) + "-{0}-{1}.flv";
        flvsName = "{0}-{1}.flv";
        parseOK = false;
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
