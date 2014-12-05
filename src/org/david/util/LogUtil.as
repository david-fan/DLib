/**
 * Created by david on 9/25/14.
 */
package org.david.util {
import flash.display.DisplayObjectContainer;
import flash.display.Shape;
import flash.events.Event;
import flash.external.ExternalInterface;
import flash.text.TextField;

//import flash.external.ExternalInterface;
public class LogUtil {
    public static var instance:LogUtil = new LogUtil();
    private var _textField:TextField;
    private var _bg:Shape;
//    private var _msgHistory:Vector.<String> = new Vector.<String>();

    public function LogUtil() {
        _bg = new Shape();
        _bg.graphics.beginFill(0, 0.2);
        _bg.graphics.drawRect(0, 0, 10, 10);
        _bg.graphics.endFill();

        _textField = new TextField();
        _textField.background = false;
        _textField.addEventListener(Event.ADDED_TO_STAGE, onAddToStage);
        _textField.addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
    }

    public static function showOrHideLog(container:DisplayObjectContainer):void {
        if (container.contains(instance._bg)) {
            container.removeChild(instance._textField);
            container.removeChild(instance._bg);
            return;
        }
        container.addChild(instance._textField);
        container.addChild(instance._bg);
        instance._textField.width = instance._bg.width = container.width;
        instance._textField.height = instance._bg.height = container.height;
    }

    private function onRemoveFromStage(e:Event):void {

    }

    private function onAddToStage(e:Event):void {
        _textField.text = "";
//        var temp:Vector.<String> = _msgHistory.splice(0, _msgHistory.length);
//        for (var i:int = 0; i < temp.length; i++) {
//            var msg:String = temp[i];
//            _textField.appendText(msg);
//            _textField.appendText("\n");
//        }
    }

    private function showMsg(msg:String, type:String):void {
        trace(type, msg);
        if (_textField.stage) {
            _textField.appendText("[" + type + "]");
            _textField.appendText(msg);
            _textField.appendText("\n");
        }
        else {
            if (CONFIG::LOGGING) {
                trace("[" + type + "]" + msg);
            } else {
                if (ExternalInterface.available)
                    ExternalInterface.call("console.log", "[" + type + "]" + msg + "\n");
            }
        }
//        else
//            _msgHistory.push("[" + type + "]", msg);
    }

    public static function log(...rest):void {
        instance.showMsg(rest.join(","), "log");
    }

    public static function error(...rest):void {
        instance.showMsg(rest.join(","), "error");
    }

    public static function warn(...rest):void {
        instance.showMsg(rest.join(","), "warn");
    }

    public static function debug(...rest):void {
        if (CONFIG::LOGGING) {
            trace(rest.join(","));
        }
    }
}
}
