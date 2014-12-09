/**
 * Created by david on 12/9/14.
 */
package org.david.util {
import flash.text.Font;

public class FontUtil {
    private static var fonts:Array;

    public function FontUtil() {
    }

    public static function hasDeviceFont(fontName:String):Boolean {
        if (fonts == null)
            fonts = Font.enumerateFonts();
        for (var i:int = 0; i < arguments.length; i++) {
            var font:Font = arguments[i];
            if (font.fontName == fontName)
                return true;
        }
        return false;
    }
}
}
