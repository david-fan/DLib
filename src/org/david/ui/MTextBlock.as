package org.david.ui {
import flash.text.engine.FontPosture;

import org.david.ui.core.MUIComponent;

import flash.text.engine.ElementFormat;
import flash.text.engine.FontDescription;
import flash.text.engine.FontLookup;
import flash.text.engine.FontWeight;
import flash.text.engine.TextBaseline;
import flash.text.engine.TextBlock;
import flash.text.engine.TextElement;
import flash.text.engine.TextLine;

/**
 * 文本组件，使用嵌入字体
 */
public class MTextBlock extends MUIComponent {
    public static var DefaultFontName:String = "宋体";
    protected var _element:TextElement;
    protected var _block:TextBlock;
    private var _textWidth:Number;
    private var style:ElementFormat;
    private var _color:uint;
    private var _size:int;

    public function MTextBlock(text:String = null, size:Number = 14, color:uint = 0x000000, textWidth:Number = 100, weight:String = FontWeight.NORMAL, posture:String = FontPosture.NORMAL) {
        super();
        this.mouseChildren = false;
        this.mouseEnabled = false;
        var fontDesc:FontDescription = new FontDescription();
        fontDesc.fontName=MTextBlock.DefaultFontName;
        fontDesc.fontLookup=FontLookup.EMBEDDED_CFF;
        _size = size;
        _color = color;

        var com = FontDescription.isFontCompatible(MTextBlock.DefaultFontName, FontWeight.NORMAL, FontPosture.NORMAL);
        trace(com);

        style = new ElementFormat();
        style.fontDescription = fontDesc;
        style.fontSize = size;
        style.color = color;
        style.trackingLeft = 1;
        style.trackingRight = 0;
        _textWidth = textWidth;
        //
        _element = new TextElement(text, style);

        _block = new TextBlock();
        _block.baselineZero = TextBaseline.IDEOGRAPHIC_TOP;
        _block.content = _element;
        this.text = text;
    }

    public function set text(value:String):void {
        if (value == null) {
            return;
        }
        _element.text = value;

        redraw();
    }

    private function redraw():void {
        removeAllChildren();
        var line:TextLine = _block.createTextLine(null, _textWidth, 0, true);
        var currentY:Number = 0;
        while (line) {
            line.y = currentY;
            currentY += line.textHeight;
            addChild(line);
            // trace(line.y + "," + line.textHeight);
            line = _block.createTextLine(line, _textWidth, 0, true);
        }
    }

    public function set color(value:uint):void {
        _color = value;
        _element.elementFormat = new ElementFormat(null, _size, _color);
        redraw();
    }

    public function get text():String {
        return _element.text;
    }

    override public function get enable():Boolean {
        return super.enable;
    }

    override public function set enable(value:Boolean):void {
        super.enable = value;
        this.mouseEnabled = value;
        this.mouseChildren = value;
    }
}
}
