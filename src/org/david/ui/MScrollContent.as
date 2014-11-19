package org.david.ui {
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Rectangle;

import org.david.ui.core.MContainer;

/**
 * @author david
 */
public class MScrollContent extends MContainer {
    private var _content:DisplayObject;
    // private var _bg:Sprite;
//    override public function get height():Number {
//        return _content.height;
//    }
//
//    override public function get width():Number {
//        return _content.width;
//    }

    public function get contentWidth():Number {
        return _content.width;
    }

    public function get contentHeigth():Number {
        return _content.height;
    }

    public function MScrollContent(content:DisplayObject, dragTarget:Boolean = false) {
        super(dragTarget);
        _content = content;
        addChild(_content);
//        _content.x = _content.y = 0;
        // _bg=new Sprite();
        // _bg.graphics.beginFill(0,0.01);
        // _bg.graphics.drawRect(0,0,100,100);
        // _bg.graphics.endFill();
        // addChildAt(_bg, 0);
    }

    override public function set scrollRect(value:Rectangle):void {
        super.scrollRect = value;
//        trace(value.x, value.y);
        if (background) {
            background.width = value.width;
            background.height = value.height;
            background.x = value.x;
            background.y = value.y;
        }

        // _bg.width=value.width;
        // _bg.height=value.height;
        // _bg.x = value.x;
        // _bg.y = value.y;
    }

    override public function set width(value:Number):void {
        var rect:Rectangle = this.scrollRect;
        rect.width = value;
        this.scrollRect = rect;
    }

    override public function set height(value:Number):void {
        var rect:Rectangle = this.scrollRect;
        rect.height = value;
        this.scrollRect = rect;
    }
}
}
