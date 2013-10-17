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
    protected var _scrollBar:MScrollBar;
    protected var _max:Number = 0;
    private var _scrollDirection:String;
    private var _layoutDirection:String;
    protected var _scrollContent:MScrollContent;

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
        if (scrollBar) {
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
        }

        //
        addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
    }

    override protected function updateDisplayList():void {
        super.updateDisplayList();
        checkMax();
    }

    public function get direction():String {
        return _scrollDirection;
    }

    private function onMouseWheel(e:MouseEvent):void {
        var rect:Rectangle = _scrollContent.scrollRect;
        switch (_scrollDirection) {
            case MDirection.Horizon:
                if (rect.width >= _scrollContent.width)
                    return;
                if (e.delta > 0)
                    rect.x -= 10;
                else
                    rect.x += 10;
                if (rect.x < 0)
                    rect.x = 0;
                if (rect.x >= _max)
                    rect.x = _max;
                _scrollContent.scrollRect = rect;
                if (_scrollBar)
                    _scrollBar.value = rect.x / _max;
                break;
            case MDirection.Vertical:
                if (rect.height >= _scrollContent.height)
                    return;
                if (e.delta > 0)
                    rect.y -= 10;
                else
                    rect.y += 10;
                if (rect.y < 0)
                    rect.y = 0;
                if (rect.y >= _max)
                    rect.y = _max;
                _scrollContent.scrollRect = rect;
                if (_scrollBar)
                    _scrollBar.value = rect.y / _max;
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
    }

    protected function doscroll():void {
        var rect:Rectangle = _scrollContent.scrollRect;
        switch (_scrollDirection) {
            case MDirection.Horizon:
                if (rect.width >= _scrollContent.width)
                    _scroll = 0;
                rect.x = _max * _scroll;
                break;
            case MDirection.Vertical:
                if (rect.height >= _scrollContent.height)
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

    protected function checkMax():void {
        if (_scrollDirection == MDirection.Horizon) {
            _max = _scrollContent.width - _scrollContent.scrollRect.width;
        } else {
            _max = _scrollContent.height - _scrollContent.scrollRect.height;
        }
        if (_max < 0)
            _max = 0;
        doscroll();
    }

    private function onBarValueChange(e:UIEvent):void {
        var sv:Number = _scrollBar.value;
        scroll = sv;
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