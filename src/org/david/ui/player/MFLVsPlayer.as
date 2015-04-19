package org.david.ui.player {
import flash.events.EventDispatcher;
import flash.events.NetStatusEvent;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.net.NetStreamAppendBytesAction;
import flash.utils.ByteArray;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import org.david.ui.MVideoPlayer;

import org.david.util.LogUtil;

public class MFLVsPlayer extends EventDispatcher implements IPlayer {
    private var _netStream:NetStream;
    private var _netConnection:NetConnection;

    private var _loader:FLVLoader;
    private var _nextUrl:String;
    private var _index:uint = 1;
    private var _pause:Boolean;
    private var _stop:Boolean;

    private var _seek:int;

    private var _flvsIndex:FLVsIndex;
    private var _getZero:Boolean;
    private var _timeoutId:uint;

    public function MFLVsPlayer() {
        _flvsIndex = new FLVsIndex();
    }

    private function loadNext():void {
        LogUtil.debug("bufferLength", _netStream.bufferLength, "time", _netStream.time);
        if (_stop)
            return;
        if (!_flvsIndex.parseOK || _pause || _netStream.bufferLength > 20)
            _timeoutId = setTimeout(loadNext, 1000);
        else
            _loadNext();
    }

    private function _loadNext():void {
        _nextUrl = getNextUrl();
        if (_nextUrl == null) {
            end();
            return;
        }
        _loader = new FLVLoader(_nextUrl, playBytes, loadNext);
        _loader.start();
    }

    private function getNextUrl():String {
        var url:String = _flvsIndex.getFlvUrl(_index);
        _index++;
        return url;
    }

    public function play():void {
        _index = 1;
        cleanupStream();
        stopLoader();
        createStream();
//        _pause = false;
    }

    public function pause():void {
        if (_netStream)
            _netStream.pause();
        _pause = true;
        callPlayStatsCallback(MVideoPlayer.Pause);
    }

    public function resume():void {
        if (_netStream)
            _netStream.resume();
        _pause = false;
        callPlayStatsCallback(MVideoPlayer.Start);
    }

    public function stop():void {
        _stop = true;
        stopLoader();
        cleanupStream();
    }

    public function seek(time:Number):void {
        _seek = time;
        _index = Math.floor(time / 2);
        _getZero = false;
        cleanupStream();
        stopLoader();
        createStream();
    }

    private function resetSeek():void {
        _netStream.seek(0);
        _netStream.appendBytesAction(NetStreamAppendBytesAction.RESET_SEEK);
    }

    private function playBytes(bytes:ByteArray):void {
        _netStream.appendBytes(bytes);
    }

    private function onNetStatus(e:NetStatusEvent):void {
        LogUtil.debug("NetStatusEvent:", e.info.code);
        var code:String = e.info.code;
        switch (code) {
            default :
                callPlayStatsCallback(code);
                break;
        }
    }

    private function procTimestamp(buf:ByteArray, timestamp:uint):ByteArray {
        buf.position = 0;
        var result:ByteArray = new ByteArray();
        result.writeBytes(buf, 0, 13);//flv header
        buf.position = 13;
        while (buf.bytesAvailable > 0) {
            var type:int = buf.readByte();
            result.writeByte(type);
            var length:int = (buf.readByte() << 16 & 0xff0000) | (buf.readByte() << 8 & 0xff00) | (buf.readByte() & 0xff);
            writeUI24(result, length);
            length += 11;

            var data:ByteArray = new ByteArray();
            buf.readBytes(data, 0, length);
            data[0] = (timestamp >> 16 & 0xff);
            data[1] = (timestamp >> 8 & 0xff);
            data[2] = (timestamp & 0xff);
            trace("type", type, "timestamp", (data[0] << 16 & 0xff0000) | (data[1] << 8 & 0xff00) | (data[2] & 0xff));
            result.writeBytes(data);
        }
        return result;
    }

    public static function writeUI24(stream:*, p:uint):void {
        var byte1:int = p >> 16;
        var byte2:int = p >> 8 & 0xff;
        var byte3:int = p & 0xff;
        stream.writeByte(byte1);
        stream.writeByte(byte2);
        stream.writeByte(byte3);
    }

    private function resetBegin():void {
        _netStream.appendBytesAction(NetStreamAppendBytesAction.RESET_BEGIN);
//        _netStream.appendBytes(getHeader());
        loadZero();
    }

    private function loadZero():void {
        if (!_flvsIndex.parseOK) {
            setTimeout(loadZero, 1000);
            return;
        }

        var hasZero:Boolean = _flvsIndex.zero4Thirteenth;
        if (hasZero && !_getZero) {
            _getZero = true;
            var zeroFile:String = _flvsIndex.getFlvUrl(0);
            _loader = new FLVLoader(zeroFile, onLoadZero, null);
            _loader.start();
            var nextFile:String = _flvsIndex.getFlvUrl(_index);
            LogUtil.debug("load zero file,next is", nextFile);
        } else
            loadNext();
    }

    private function onLoadZero(bytes:ByteArray):void {
//        var clone:ByteArray = new ByteArray();
//        bytes.readBytes(clone);
//        bytes.position = 0;
//        _netStream.appendBytes(bytes);
//        resetSeek();
//        _netStream.appendBytes(clone);
        var zeroBuf:ByteArray = procTimestamp(bytes, _seek * 1000);
        _netStream.appendBytes(zeroBuf);
        loadNext();
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

    private var _playStatusCallback:Function

    public function set playStatusCallback(value:Function):void {
        _playStatusCallback = value;
    }

    private function callPlayStatsCallback(status:String):void {
        if (_playStatusCallback)
            _playStatusCallback(status);
    }

    public function get flvsIndexUrl():String {
        return _flvsIndex.indexUrl;
    }

    public function set flvsIndexUrl(value:String):void {
        /*
         # 获取索引文件
         http://42.62.95.7:8001/play/107549/107549-20150103212128/index.list
         # 获取第几片flv
         http://42.62.95.7:8001/play/107549/107549-20150103212128/107549-20150103212128-1-1420367092.flv
         */
        _flvsIndex.indexUrl = value;
    }

    public function get duration():Number {
//        if(_metaData)
//            return _metaData.duration;
        return 0;
    }

    public function get time():Number {
        return _netStream.time;
    }

    protected function createStream():void {
        _netConnection = new NetConnection();
        _netConnection.connect(null);
        _netStream = new NetStream(_netConnection);
        _netStream.play(null);
        _netStream.client = this;
        if (_pause)
            _netStream.pause();
        _netStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
        if (_streamCreateCallback)
            _streamCreateCallback(_netStream);
        resetBegin();
    }

    protected function cleanupStream():void {
        if (_netStream != null) {
            _netStream.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
            _netStream.close();
        }
        if (_netConnection != null) {
            _netConnection.close();
        }
    }

    protected function stopLoader():void {
        if (_timeoutId > 0)
            clearTimeout(_timeoutId);
        if (_loader) {
            try {
                _loader.close();
            }
            catch (e:Error) {
                LogUtil.error(e.message);
            }
        }
    }
}
}
