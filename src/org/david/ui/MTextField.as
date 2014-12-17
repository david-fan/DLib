/**
 * Created with IntelliJ IDEA.
 * User: david
 * Date: 13-1-16
 * Time: 下午4:35
 * To change this template use File | Settings | File Templates.
 */
package org.david.ui {
import flash.net.FileFilter;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import org.david.util.FilterUtil;

public class MTextField extends TextField {
    public function MTextField(size:int, color:uint, wrap:Boolean, fontType:String = null, select:Boolean = true) {
        super();
        autoSize = TextFieldAutoSize.LEFT;
        background = false;
        border = false;
        wordWrap = wrap;
        selectable = select;

        var tf:TextFormat = new TextFormat();
        tf.color = color;
        tf.size = size;
        tf.align=TextFormatAlign.CENTER;
        if (fontType)
            tf.font = fontType;
        this.defaultTextFormat = tf;
    }

    public function set enable(value:Boolean):void {
        if (value)
            this.filters = null;
        else
            this.filters = [FilterUtil.getBlackWhiteMatrixData()];
    }
}
}
