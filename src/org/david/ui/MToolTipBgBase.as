/**
 * Created by thinkpad on 15-8-13.
 */
package org.david.ui {
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

import org.david.ui.core.IToolTipBg;
import org.david.ui.core.MContainer;

public class MToolTipBgBase extends MContainer implements IToolTipBg {
    function MToolTipBgBase(){
        super();
    }
    public function set content(value:DisplayObject) : void {
        throw Error("must be override");

    }

    public function set target(value : DisplayObject) : void {
        throw Error("must be override");
    }

    public function drawBg(showbg : Boolean) : void {
        throw Error("must be override");
    }
}
}
