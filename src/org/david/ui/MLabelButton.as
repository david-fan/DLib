package org.david.ui {
import flash.display.DisplayObject;

/**
 * 文字按钮
 */
public class MLabelButton extends MButton {
    public static const blackwithe:String = "blackwithe";
    public static const redblack:String = "redblack";
    private var _tb:MTextField;

    public function MLabelButton(label:String = "", skin:DisplayObject = null, lableSize:int = 14, lableColor:int = 0xffffff, lableWidth:int = 200) {
        super(skin);
        _tb = new MTextField(lableSize, lableColor,false);
        _tb.text = label;
        _tb.width = lableWidth;
        this.addChild(_tb);
        viewChanged();
    }

    override protected function updateDisplayList():void {
        if (skin) {
            _tb.x = (skin.width - _tb.width) / 2;
            _tb.y = (skin.height - _tb.height) / 2;
        }
        super.updateDisplayList();
    }

    public function set label(value:String):void {
        _tb.text = value;

        viewChanged();
    }

    public function get label():String {
        return _tb.text;
    }

    override public function set enable(value:Boolean):void {
        super.enable = value;
        _tb.enable = value;
    }
}
}
