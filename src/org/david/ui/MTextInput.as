package org.david.ui {
import org.david.ui.core.MUIComponent;
import org.david.util.WordFilter;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.utils.ByteArray;

[Event(name="text_change", type="flash.events.Event")]
public class MTextInput extends MUIComponent {
    public static const TEXT_CHANGE:String = "text_change";
    //
    private var _text:String = "";
    private var _textColor:uint;
    private var _tf:TextField;
    private var _maxBitLen:int;
    //
    public static var checkWordsList:Array;


    /*
     * 构造函数
     * @param maxBitLen 一个中文2位
     */
    public function MTextInput(wordWrap:Boolean = true, maxBitLen:int = 0, size:uint = 14, color:Object = 0, bold:Object = false, bg:Boolean = true, bgColor:Number = 0xffffff) {
        super(false);
//        this.background = skin;
        //
        this._tf = new TextField();
        this._tf.type = TextFieldType.INPUT;
        this._tf.autoSize = TextFieldAutoSize.NONE;
        this._tf.wordWrap = wordWrap;
        this._tf.selectable = true;
        this._tf.textColor = 0;
//        this._tf.x = offsetx;
//        this._tf.y = offsety;
        this._tf.border = false;
        this._tf.text = "";
        this._tf.background = bg;
        this._tf.backgroundColor = bgColor;
//        if (skin) {
//            this._tf.height = skin.height - 2 * offsety;
//            this._tf.width = skin.width - 2 * offsetx;
//        }
        addChild(this._tf);
        var f:TextFormat = new TextFormat("宋体", size, color, bold);
        this._tf.defaultTextFormat = f;
        this._tf.addEventListener(Event.CHANGE, this.onChangeHandler);
        _maxBitLen = maxBitLen;
    }

    override public function set width(value:Number):void {
        this._tf.width = value;
//        if (background)
//            background.width = value;
    }

    override public function set height(value:Number):void {
        this._tf.height = value;
//        if (background)
//            background.height = value;
    }

    private function onChangeHandler(event:Event):void {
        setText(this._tf.text);
        dispatchEvent(new Event(TEXT_CHANGE));
    }

    public function get text():String {
        if (this._tf) {
            return this._tf.text;
        }
        return this._text;
    }

    public function set text(value:String):void {
        setText(value);
    }

    private function checkTextLen(input:String):String {
        if (_maxBitLen > 0) {
            var temp:String = "";
            var len:int = 0;
            var txtlen:int = input.length;
            var index:int = 0;
            while (index < txtlen) {
                var char:String = input.substr(index, 1);
                var bytes:ByteArray = new ByteArray();
                bytes.writeMultiByte(char, "utf-8");
                len += (bytes.length == 1 ? 1 : 2);
                index++;
                if (len > _maxBitLen) {
                    input = temp;
                    break;
                } else
                    temp += char;
            }
        }
        return input;
    }

    private function setText(value:String):void {
        value = checkTextLen(value);
        value = WordFilter.Forbid(value);
        _text = value;
        _tf.text = value;
    }

    public function set editAble(value:Boolean):void{
        if (value) {
            _tf.type = TextFieldType.INPUT;
        }
        else {
            _tf.type = TextFieldType.DYNAMIC;
        }
    }

    public function get textColor():uint {
        return this._textColor;
    }

    public function set textColor(value:uint):void {
        this._textColor = value;
        this._tf.textColor = value;
    }


    override public function set enable(value:Boolean):void {
        super.enable = value;
        if (value) {
            _tf.selectable = true;
            _tf.type = TextFieldType.INPUT;
        }
        else {
            _tf.selectable = false;
            _tf.type = TextFieldType.DYNAMIC;
        }
    }
}
}
