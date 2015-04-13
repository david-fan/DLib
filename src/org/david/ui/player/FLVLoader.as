/**
 * Created by david on 12/19/14.
 */
package org.david.ui.player {
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray;

public class FLVLoader extends URLLoader {
    public var url:String;
    public var bytes:ByteArray;
    public var next:Function;
    public var complete:Function;

    public function FLVLoader(url:String, complete:Function, next:Function) {
        super(null);
        this.url = url;
        this.dataFormat = URLLoaderDataFormat.BINARY;
        this.next = next;
        this.complete = complete;
        this.addEventListener(Event.COMPLETE, onComplete);
        this.addEventListener(IOErrorEvent.IO_ERROR, onError);
    }

    public function start():void {
        load(new URLRequest(this.url));
    }

    private function onComplete(e:Event):void {
//        trace("complete", url);
        bytes = e.target.data;
        if (complete)
            complete(bytes);
        if (next)
            next();
    }

    private function onError(e:IOErrorEvent):void {
        trace("ioerror", url);
        if (next)
            next();
    }

}
}
