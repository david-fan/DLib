package org.david.ui {
import org.david.ui.core.MContainer;
import org.david.ui.event.UIEvent;

import flash.events.MouseEvent;
import flash.geom.Rectangle;

/**
 * ...
 * @author david
 */
public class MScrollArea extends MContainer {
    public static var Scroll:String = "MScrollArea.Scroll";

    protected var _scrollBar:MScrollBar;
//    protected var _max:Number = 0;
    private var _scrollDirection:String;
    private var _layoutDirection:String;
    protected var _scrollContent:MScrollContent;
//    private var _scrollRect:Rectangle;

    public function MScrollArea(scrollContent:MScrollContent, scrollBar:MScrollBar, scrollRectangle:Rectangle, scrollDirection:String = null) {
        if (scrollBar) {
            if (scrollBar.direction == MDirection.Horizon) {
                _layoutDirection = MDirection.Vertical;
                _scrollDirection = MDirection.Horizon;
            } else {
                _layoutDirection = MDirection.Horizon;
                _scrollDirection = MDirection.Vertical;
            }
        } else {
            //垂直或者水平不重要，因为只有一个scrollContent
            _layoutDirection = MDirection.Horizon;
            _scrollDirection = scrollDirection;
        }

        super(false);
        _scrollContent = scrollContent;
        _scrollContent.cacheAsBitmap = true;
        _scrollContent.scrollRect = scrollRectangle;
        addChild(_scrollContent);
        //
        if (scrollBar == null)
            throw new Error("must have scrollbar!")

        _scrollBar = scrollBar;
        addChild(_scrollBar);
        _scrollBar.addEventListener(MScrollBar.ValueChange, onBarValueChange);
        if (_scrollDirection == MDirection.Horizon) {
            _scrollBar.x = scrollRectangle.x;
            _scrollBar.y = scrollRectangle.height + scrollRectangle.y;

        } else {
            _scrollBar.y = scrollRectangle.y;
            _scrollBar.x = scrollRectangle.width + scrollRectangle.x;//-_scrollBar.width;
        }
        //
        addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
    }

    override protected function updateDisplayList():void {
        super.updateDisplayList();
//        checkMax();
        this.doscroll();
    }

    public function get direction():String {
        return _scrollDirection;
    }

    private function onMouseWheel(e:MouseEvent):void {
        var rect:Rectangle = _scrollContent.scrollRect;
        switch (_scrollDirection) {
            case MDirection.Horizon:
                if (rect.width >= _scrollContent.contentWidth)
                    return;
                if (e.delta > 0)
                    rect.x -= 10 * Math.abs(e.delta);
                else
                    rect.x += 10 * Math.abs(e.delta);
                if (rect.x < 0)
                    rect.x = 0;
                if (rect.x >= _max)
                    rect.x = _max;
                _scrollContent.scrollRect = rect;
                _scroll = rect.x / _max;
                _scrollBar.value = _scroll;
                dispatchEvent(new UIEvent(Scroll));
                break;
            case MDirection.Vertical:
                if (rect.height >= _scrollContent.contentHeigth)
                    return;
                if (e.delta > 0)
                    rect.y -= 10 * Math.abs(e.delta);
                else
                    rect.y += 10 * Math.abs(e.delta);
                if (rect.y < 0)
                    rect.y = 0;
                if (rect.y >= _max)
                    rect.y = _max;
                _scrollContent.scrollRect = rect;
                _scroll = rect.y / _max;
                _scrollBar.value = _scroll;
                dispatchEvent(new UIEvent(Scroll));
                break;
        }
    }

    private var _scroll:Number = 0;

    public function set scroll(value:Number):void {
        if (isNaN(value) || value > 1
                || value < 0)
            return;
        _scroll = value;
        doscroll();
        dispatchEvent(new UIEvent(Scroll));
    }

    protected function doscroll():void {
        var rect:Rectangle = _scrollContent.scrollRect;
        switch (_scrollDirection) {
            case MDirection.Horizon:
                if (rect.width >= _scrollContent.contentWidth)
                    _scroll = 0;
                rect.x = _max * _scroll;
                break;
            case MDirection.Vertical:
                if (rect.height >= _scrollContent.contentHeigth)
                    _scroll = 0;
                rect.y = _max * _scroll;
                break;
        }
        _scrollContent.scrollRect = rect;
        _scrollBar.value = _scroll;
    }

    public function get scroll():Number {
        return _scroll;
    }

    private function get _max():Number {
        var temp:Number;
        if (_scrollDirection == MDirection.Horizon) {
            temp = _scrollContent.contentWidth - _scrollContent.scrollRect.width;
        } else {
            temp = _scrollContent.contentHeigth - _scrollContent.scrollRect.height;
        }
        if (temp < 0)
            temp = 0;
        return temp;
    }

    private function onBarValueChange(e:UIEvent):void {
        var sv:Number = _scrollBar.value;
        scroll = sv;
    }


    override public function get scrollRect():Rectangle {
        return _scrollContent.scrollRect;
    }


    override public function set scrollRect(value:Rectangle):void {
//        _scrollRect = value;
        _scrollContent.scrollRect = value;
    }

    override public function get height():Number {
        return super.height;
    }

    override public function set height(value:Number):void {
        var tempRect:Rectangle = _scrollContent.scrollRect;
        if (_scrollDirection == MDirection.Vertical) {
            tempRect.height = value;
            _scrollContent.scrollRect = tempRect;
            _scrollBar.height = value;
        } else {
            tempRect.height = value - _scrollBar.height;
            _scrollContent.scrollRect = tempRect;
            _scrollBar.y = value - _scrollBar.height;
        }
    }

    override public function get width():Number {
        return super.width;
    }

    override public function set width(value:Number):void {
        var tempRect:Rectangle = _scrollContent.scrollRect;
        if (_scrollDirection == MDirection.Vertical) {
            tempRect.width = value; //- _scrollBar.width;
            _scrollContent.scrollRect = tempRect;
            _scrollBar.x = value; //- _scrollBar.width;
        } else {
            tempRect.width = value;
            _scrollContent.scrollRect = tempRect;
            _scrollBar.width = value;
        }
    }

//    protected function update():void {
//        checkMax();
//        if (_scrollBar) {
//            if (_max == 0)
//                scroll = 0;
//            else
//                scroll = _scrollBar.value;
//        } else {
//            //TODO 设置默认scroll
//            scroll = 1;
//        }
//    }
}
}