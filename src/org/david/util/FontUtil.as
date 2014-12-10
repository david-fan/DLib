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
        for (var i:int = 0; i < fonts.length; i++) {
            var font:Font = fonts[i];
            if (font.fontName == fontName)
                return true;
        }
        return false;
    }
}
}
