package org.david.util {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;

	public class GetBitmapUtil {
		public function GetBitmapUtil() {
		}

		public static function GetBitmap(obj : DisplayObject) : Bitmap {
			var bd : BitmapData = GetBitmapData(obj);
			var bm : Bitmap = new Bitmap(bd);
			return bm;
		}

		public static function GetBitmapData(obj : DisplayObject) : BitmapData {
			var bd : BitmapData = new BitmapData(obj.width, obj.height, true, 0x00FFFFFF);
			// var matrix : Matrix = new Matrix();
			bd.draw(obj);
			return bd;
		}
	}
}