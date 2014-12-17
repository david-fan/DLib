package org.david.util {
import flash.events.NetStatusEvent;
import flash.net.SharedObject;
import flash.net.SharedObjectFlushStatus;
import flash.system.Security;
import flash.system.SecurityPanel;

public class SharedObjectUtil extends Object {
    private static var sharedObject:SharedObject = SharedObject.getLocal(DefaultShareObjName, "/");
    // 1G
    private static const SIZE:uint = 1024 * 1024 * 1024;
    private static const DefaultShareObjName:String = "DefaultShareObjName";
    //
    private static var _allow:Boolean;
    //
    private static var _showCall:Function;
    private static var _removeCall:Function;
    private static var _resultCall:Function;

    public function SharedObjectUtil() {
    }

    // public static function writeSharedObjectData(name : String, key : String, data : Object, path : String = null, secure : Boolean = false) : void {
    // var so : SharedObject = SharedObject.getLocal(name, path, secure);
    // so.data[key] = data;
    // try {
    // so.flush(SIZE);
    // } catch (e : Error) {
    // }
    // }
    // public static function readSharedObjectData(name : String, key : String) : Object {
    // sharedObject = SharedObject.getLocal(name);
    // return sharedObject.data[key];
    // }
    public static function flush(showCall:Function, removeCall:Function, resultCall:Function):void {
        _showCall = showCall;
        _removeCall = removeCall;
        _resultCall = resultCall;
        try {
            var flushResult:String = sharedObject.flush(SIZE);
            // 请求容量
            // 如果flush()没成功执行,就替netStatus加个事件处理函数以确认用户是同意还是拒绝,否则只检验结果.
            if (flushResult == SharedObjectFlushStatus.PENDING) {
                // 替netStatus加个事件处理函数,使得我们可以检验用户是否同意以足够磁盘容量储存共享对象.当netStatus事件发生时,执行onStatus函数.
                sharedObject.addEventListener(NetStatusEvent.NET_STATUS, onStatus);
                if (_showCall != null)
                    _showCall();
            } else if (flushResult == SharedObjectFlushStatus.FLUSHED) {
                _allow = true;
                // 成功储存.把数据成功储存后你想执行的程序放在这里.
                if (_resultCall != null)
                    _resultCall(_allow);
            }
        } catch (e:Error) {
            // 这里表示用户把本地储存设置为"拒绝".如果储存数据很重要,你会想在此警告用户.
            // 此外,如果你想让用户可修改其设定值,可以用下面语句打开Player的"设置"对话框的本地储存页面.
            Security.showSettings(SecurityPanel.LOCAL_STORAGE);
            if (_showCall != null)
                _showCall();
        }
    }

    // 定义onStatus函数以处理共享对象的状态事件.flush()返回"pending"时,引发提示,而用户做了选择后所引发的事件.
    private static function onStatus(event:NetStatusEvent):void {
        if (event.info.code == "SharedObject.Flush.Success") {
            _allow = true;
            // 如果event.info.code内容是"SharedObject.Flush.Success",表示用户同意.把用户同意后你想执行的程序放在这里.
        } else if (event.info.code == "SharedObject.Flush.Failed") {
            _allow = false;
            // 如果event.info.code内容是"SharedObject.Flush.Failed",表示用户同意.把用户拒绝后你想执行的程序放在这里.
        }
        // 现在,移除事件监听器,因为我们只需监听一次.
        sharedObject.removeEventListener(NetStatusEvent.NET_STATUS, onStatus);
        if (_removeCall != null)
            _removeCall();
        if (_resultCall != null)
            _resultCall(_allow);
    }

    public static function get allow():Boolean {
        return _allow;
    }

    public static function writeSharedObject(key:*, value:Object):void {
        sharedObject.data[key] = value;
        if (_allow) {
            sharedObject.flush(SIZE);
        }
    }

    public static function readSharedObject(key:*):Object {
        var tkey:String;
        var value:Object;
        for (tkey in sharedObject.data) {
            if (tkey == key) {
                value = sharedObject.data[key];
                break;
            }
        }
        return value;
    }
}
}
