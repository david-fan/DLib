/**
 * Created by david on 11/11/14.
 */
package org.david.ui {
import flash.display.DisplayObject;

import org.david.ui.core.MContainer;


public class MRepeater extends MContainer {
    private var _distance:int;
    private var _direction:String;
    private var _width:Number = 348;
    private var _height:Number = 262;
    private var _count:int;
    private var _appendh:Number;
    private var _appendw:Number;

    public function MRepeater(direction:String, distance:int = 1) {
        super();
        _direction = direction;
        _distance = distance;
    }

    public function get distance():int {
        return _distance;
    }

    public function set distance(value:int):void {
        _distance = value;
    }

    private function computeCount():void {
        switch (_direction) {
            case MDirection.Horizon:
                _count = Math.max(Math.floor(_height / (itemHeight + _distance)), 1);
                _appendh = (_height % (itemHeight + _distance)) / (_count + 1);
                if (_appendh < 0)
                    _appendh = 0;
                _appendw = 0;
                break;
            case MDirection.Vertical:
                _count = Math.max(Math.floor(_width / (itemWidth + _distance)), 1);
                _appendh = 0;
                _appendw = (_width % (itemWidth + _distance)) / (_count + 1);
                if (_appendw < 0)
                    _appendw = 0;
                break;
        }

        viewChanged();
    }

//    private var _source:Array;
//
//    public function get source():Array {
//        return _source;
//    }
//
//    public function set source(value:Array):void {
//        _source = value || [];
//    }

    override protected function updateDisplayList():void {
        var tx:Number = _distance;
        var ty:Number = _distance;
        var tc:int = 0;
        var tr:int = 0;

        switch (_direction) {
            case MDirection.Horizon:
                for (var i:int = 0; i < _childs.length; i++) {
                    tx = _distance + _appendw + (_distance + itemWidth + _appendw) * tc;
                    ty = _distance + _appendh + (_distance + itemHeight + _appendh) * tr;
                    var c:DisplayObject = _childs[i];
                    c.x = tx;
                    c.y = ty;
                    tr++;
                    if (tr > (_count - 1)) {
                        tr = 0;
                        tc++;
                    }
                }
                break;
            case MDirection.Vertical:
                for (var i:int = 0; i < _childs.length; i++) {
                    tx = _distance + _appendw + (_distance + itemWidth + _appendw) * tc;
                    ty = _distance + _appendh + (_distance + itemHeight + _appendh) * tr;
                    var c:DisplayObject = _childs[i];
                    c.x = tx;
                    c.y = ty;
                    tc++;
                    if (tc > (_count - 1)) {
                        tc = 0;
                        tr++;
                    }
                }
                break;
        }
        super.updateDisplayList();
    }

    override public function set height(value:Number):void {
        _height = value;
        computeCount();
    }

    override public function get height():Number {
        return super.height;
    }

    override public function set width(value:Number):void {
        _width = value;
        computeCount();
    }

    override public function get width():Number {
        return super.width;
    }

    private var _itemWidth:Number = 0;
    private var _itemHeight:Number = 0;

    public function get itemWidth():Number {
        if (_itemWidth < 1)
            _itemWidth = getMaxWidth();
        return _itemWidth;
    }

    public function set itemWidth(value:Number):void {
        _itemWidth = value;
        computeCount();
    }

    public function get itemHeight():Number {
        if (_itemHeight < 1)
            _itemHeight = getMaxHeight();
        return _itemHeight;
    }

    public function set itemHeight(value:Number):void {
        _itemHeight = value;
        computeCount();
    }

    private function getMaxWidth():int {
        var max:int;
        for (var i:int = 0; i < _childs.length - 1; i++) {
            max = Math.max(_childs[i].width, _childs[i + 1].width);
        }
        return max;
    }

    private function getMaxHeight():int {
        var max:int;
        for (var i:int = 0; i < _childs.length - 1; i++) {
            max = Math.max(_childs[i].height, _childs[i + 1].height);
        }
        return max;
    }

//
//    protected function get minWidth():Number {
//        var w:Number = 0;
//        for (var i:int = 0; i < _childs.length; i++) {
//            var object:DisplayObject = _childs[i];
//            if (w == 0)
//                w = object.width;
//            if (object.width < w)
//                w = object.width;
//        }
//        return w;
//    }
//
//    protected function get minHeight():Number {
//        var h:Number = 0;
//        for (var i:int = 0; i < _childs.length; i++) {
//            var object:DisplayObject = _childs[i];
//            if (h == 0)
//                h = object.height;
//            if (object.height < h)
//                h = object.height;
//        }
//        return h;
//    }

}
}
