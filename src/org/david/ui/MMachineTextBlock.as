package org.david.ui {
import flash.text.Font;
import flash.text.engine.CFFHinting;
import flash.text.engine.FontLookup;
import flash.text.engine.FontPosture;
import flash.text.engine.FontWeight;
import flash.text.engine.RenderingMode;

import org.david.ui.core.MUIComponent;

import flash.text.engine.ElementFormat;
import flash.text.engine.FontDescription;
import flash.text.engine.TextBaseline;
import flash.text.engine.TextBlock;
import flash.text.engine.TextElement;
import flash.text.engine.TextLine;

/**
 * 文本组件，使用设备字体
 */
public class MMachineTextBlock extends MUIComponent {
    private var _size:int;
    private var _color:uint;
    protected var _element:TextElement;
    protected var _block:TextBlock;
    private var _textWidth:Number;
    private var _fontDes:FontDescription;

    public function MMachineTextBlock(text:String = null, size:Number = 14, color:uint = 0, textWidth:Number = 250, fontName:String = "宋体", fontWeight:String = FontWeight.NORMAL, fontPosture:String = FontPosture.NORMAL) {
        super();
        this.mouseChildren = false;
        this.mouseEnabled = false;
        //
//        var compatible = FontDescription.isDeviceFontCompatible(fontName, fontWeight, posture);
//        trace(compatible);
        _fontDes = new FontDescription(fontName, fontWeight, fontPosture, FontLookup.DEVICE);
        _size = size;
        _color = color;
        _textWidth = textWidth;
        var ef:ElementFormat = new ElementFormat(_fontDes, _size, _color);
        ef.trackingLeft = 1;
        ef.trackingRight = 0;
        //
        _element = new TextElement(text, ef);
        _block = new TextBlock();
        _block.baselineZero = TextBaseline.IDEOGRAPHIC_TOP;
        _block.content = _element;
        this.text = text;
    }

    public function set color(value:uint):void {
        _color = value;
        _element.elementFormat = new ElementFormat(_fontDes, _size, _color);
        redraw();
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
            currentY += line.textHeight + 3;
            addChild(line);
            // trace(line.y + "," + line.textHeight);
            line = _block.createTextLine(line, _textWidth, 0, true);
        }
    }

    public function set textWidth(value:Number):void {
        _textWidth = value;
        redraw();
    }

    public function get textWidth():Number {
        return _textWidth;
    }

    public function get text():String {
        return _element.text;
    }
}
}
