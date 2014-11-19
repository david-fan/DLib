package org.david.ui {
import org.david.util.FilterUtil;

/**
 * 描边的文本，使用系统字体
 */
public class MStrokeText extends MTextBlock {
    public function MStrokeText(text:String = null, size:Number = 14, color:uint = 0xffffff, width:Number = 100, fillterColor:uint = 0x632707) {
        super(text, size, color, width);
        this.filters = [FilterUtil.getColorFilter(fillterColor)];
    }
}
}