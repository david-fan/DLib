package org.david.util {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.geom.Rectangle;

	/**
	 * @author david
	 */
	public class BitmapSWF extends MovieClip {
		public function BitmapSWF() {
		}

		public static function getBitmap(displayObject : DisplayObject, bounds : Boolean) : Bitmap {
			var bitmapData : BitmapData;
			if (bounds) {
				var area : Rectangle = displayObject.getBounds(displayObject);
				bitmapData = new BitmapData(area.right, area.bottom, true, 0);
			} else {
				bitmapData = new BitmapData(displayObject.width, displayObject.height);
			}
			bitmapData.draw(displayObject);

			// var png : PNGEncoder = new PNGEncoder();
			// var pngStream : ByteArray = png.encode(bitmapData);
			var bitmap : Bitmap = new Bitmap(bitmapData);
			return bitmap;
		}
	}
}
