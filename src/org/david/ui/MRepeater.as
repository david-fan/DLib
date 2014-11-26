/**
 * Created by david on 11/11/14.
 */
package org.david.ui {
import flash.display.DisplayObject;

import org.david.ui.core.MContainer;


public class MRepeater extends MContainer {
    private var _distance:int;
    private var _width:Number = 348;
    private var _height:Number = 262;

    public function MRepeater(distance:int) {
        super();
        ;
        _distance = distance;
    }

    override protected function updateDisplayList():void {
        var tx:Number = _distance;
        var ty:Number = _distance;
        var tw:Number = 0;
        var th:Number = 0;
        for (var i:int = 0; i < _childs.length; i++) {
            var c:DisplayObject = _childs[i];
            if (_width > tw) {
                tw = tx + c.width;
                tx = tw + _distance;
                if (c.height > th)
                    th = c.height;
            } else {
                tx = 0;
                ty = th + _distance;
            }
            addChildXY(c, tx, ty);
        }
        super.updateDisplayList();
    }

    override public function set height(value:Number):void {
        _height = value;
    }

    override public function get height():Number {
        return _height;
    }

    override public function set width(value:Number):void {
        _width = value;
    }

    override public function get width():Number {
        return _width;
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

    protected function get minWidth():Number {
        var w:Number = 0;
        for (var i:int = 0; i < _childs.length; i++) {
            var object:DisplayObject = _childs[i];
            if (w == 0)
                w = object.width;
            if (object.width < w)
                w = object.width;
        }
        return w;
    }

    protected function get minHeight():Number {
        var h:Number = 0;
        for (var i:int = 0; i < _childs.length; i++) {
            var object:DisplayObject = _childs[i];
            if (h == 0)
                h = object.height;
            if (object.height < h)
                h = object.height;
        }
        return h;
    }

}
}
