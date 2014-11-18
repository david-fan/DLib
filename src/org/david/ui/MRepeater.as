/**
 * Created by david on 11/11/14.
 */
package org.david.ui {
import flash.display.DisplayObject;

import org.david.ui.core.MContainer;


public class MRepeater extends MContainer {
    private var _direction:String;
    private var _distance:int;
    private var _w:Number;
    private var _h:Number;

    public function MRepeater(direction:String, distance:int, w:Number, h:Number) {
        _direction = direction;
        _distance = distance;
        _w = w;
        _h = h;
        super(mouseEnabled);
    }

    override public function addChild(child:DisplayObject):DisplayObject {
        return super.addChild(child);
    }

    override public function addChildXY(child:DisplayObject, x:Number = 0, y:Number = 0):void {
//        super.addChildXY(child, x, y);
        throw new Error("dot use this method and set x,y!");
    }

    override public function set height(value:Number):void {
        super.height = value;
    }

    override public function get height():Number {
        return super.height;
    }

    override public function get width():Number {
        return super.width;
    }

    override public function set width(value:Number):void {
        super.width = value;
    }

    override protected function updateDisplayList():void {
        removeAllChildren();
        var tx:Number = 0;
        var ty:Number = 0;
        var tw:Number = _w;
        var th:Number = _h;

        if (_direction == MDirection.Horizon) {
            for (var i:int = 0; i < _childs.length; i++) {
                var object:DisplayObject = _childs[i];
                if (i == 0)
                    super.addChildXY(object, tx, ty);
                else {

                }
                tx = object.width + _distance;
                ty = object.height + _distance;
            }
        } else if (_direction == MDirection.Vertical) {

        }
        super.updateDisplayList();
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
