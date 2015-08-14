/**
 * Created by thinkpad on 15-8-13.
 */
package org.david.ui.core {
import flash.display.DisplayObject;

public  interface IToolTipBg {
   function set target(value:DisplayObject):void;
   function set content(value:DisplayObject):void;
    function drawBg(draw:Boolean):void;
}
}
