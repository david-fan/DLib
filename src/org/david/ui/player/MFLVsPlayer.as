package org.david.ui.player {
import flash.events.EventDispatcher;
import flash.events.NetStatusEvent;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.net.NetStreamAppendBytesAction;
import flash.utils.ByteArray;
import flash.utils.setTimeout;

public class MFLVsPlayer extends EventDispatcher implements IPlayer {
//    private var _video:Video;

    private var _netStream:NetStream;
    private var _netConnection:NetConnection;

    private var _loader:FLVLoader;
    private var _nextUrl:String;
    private var _index:uint = 100;
    private var _pause:Boolean;
    private var _flvPath:String;
    private var _seek:int;

    public function MFLVsPlayer() {
//        _flvPath = QueryStringUtil.getValue("path");
//        _seek = parseInt(QueryStringUtil.getValue("seek"));
        play();
    }

    private function loadNext():void {
        trace(_netStream.bufferLength);
        if (_pause || _netStream.bufferLength > 20)
            setTimeout(loadNext, 1000);
        else
            _loadNext();
    }

    private function _loadNext():void {
        _nextUrl = getNextUrl();
        if (_nextUrl == null)
            end();
        _loader = new FLVLoader(_nextUrl, playBytes, loadNext);
        _loader.start();
    }

    private function getNextUrl():String {
        var url:String = _flvPath + "/" + _index + ".flv";
        _index++;
        return url;
    }

    public function play():void {
        _netConnection = new NetConnection();
        _netConnection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
        _netConnection.connect(null);
        _pause = false;
    }

    public function pause():void {
        _netStream.pause();
        _pause = true;
    }

    public function resume():void {
        _netStream.resume();
        _pause = false;
    }

    public function stop():void {
        if (_loader)
            _loader.close();
        if (_netConnection)
            _netConnection.close();
        if (_netStream)
            _netStream.close();
    }

    public function seek(time:Number):void {
        if (_netStream == null)
            return;
        _index = Math.floor(time / 2);
        _netStream.seek(0);
        _netStream.appendBytesAction(NetStreamAppendBytesAction.RESET_SEEK);
        if (_loader)
            _loader.close();
        loadNext();
    }

    private function playBytes(bytes:ByteArray):void {
        var buffers:ByteArray = new ByteArray();
        buffers.writeBytes(bytes, 13);
        bytes.clear();
        _netStream.appendBytes(buffers);
    }

    private function onNetStatus(e:NetStatusEvent):void {
        var code:String = e.info.code;
        switch (code) {
            case "NetStream.SeekStart.Notify":
//                trace(e.info);
                break;
            case "NetStream.Seek.Notify":
//                trace(e.info);
                break;
            case "NetConnection.Connect.Success":
                _netStream = new NetStream(_netConnection);
                _netStream.play(null);
                _netStream.client = this;
                _netStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
//                _video = new Video();
//                _video.attachNetStream(_netStream);
//                this.addChild(_video);
                if (_streamCreateCallback)
                    _streamCreateCallback(_netStream);
                reset();
                if (_seek > 0)
                    seek(_seek);
                else
                    loadNext();
                break;
            case "NetConnection.Connect.Closed":
                _netConnection.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
                _netStream.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
                if (_loader)
                    _loader.close();
                break
        }
    }

    private function reset():void {
        _netStream.appendBytesAction(NetStreamAppendBytesAction.RESET_BEGIN);
        _netStream.appendBytes(getHeader());
    }

    private function end():void {
        _netStream.appendBytesAction(NetStreamAppendBytesAction.END_SEQUENCE);
        _netStream.appendBytes(new ByteArray());
    }

    /** Get the FLV file header. **/
    public static function getHeader():ByteArray {
        var flv:ByteArray = new ByteArray();
        flv.length = 13;
        // "F" + "L" + "V".
        flv.writeByte(0x46);
        flv.writeByte(0x4C);
        flv.writeByte(0x56);
        // File version (1)
        flv.writeByte(1);
        // Audio + Video tags.
        flv.writeByte(1);
        // Length of the header.
        flv.writeUnsignedInt(9);
        // PreviousTagSize0
        flv.writeUnsignedInt(0);
        return flv;
    }


    private var _mute:Boolean;
    private var _volume:Number;

    public function get mute():Boolean {
        return _mute;
    }

    public function set mute(value:Boolean):void {
        _mute = value;
    }

    public function get volume():Number {
        return _volume;
    }

    public function set volume(value:Number):void {
        _volume = value;
    }

    private var _streamCreateCallback:Function;
    public function set streamCreateCallback(value:Function):void {
        _streamCreateCallback = value;
    }

    private var _metaDataGetCallback:Function;
    public function set metaDataGetCallback(value:Function):void {
        _metaDataGetCallback = value;
    }

    public function get flvPath():String {
        return _flvPath;
    }

    public function set flvPath(value:String):void {
        _flvPath = value;
    }
}
}
