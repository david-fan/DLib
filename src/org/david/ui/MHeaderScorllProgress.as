/**
 * Created by thinkpad on 15-8-5.
 */
package org.david.ui {
import flash.display.DisplayObject;

public class MHeaderScorllProgress extends MScrollProgress {
    public function MHeaderScorllProgress(slide:DisplayObject, thumb:DisplayObject, direction:String, progress:DisplayObject, background:DisplayObject, immediately:Boolean = true, careThumbSize:Boolean = true) {
        super(slide, thumb, direction, progress, background, immediately, careThumbSize);
    }
}
}
