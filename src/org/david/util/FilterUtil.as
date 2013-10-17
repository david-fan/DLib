package org.david.util {
	import flash.display.DisplayObject;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;
	import flash.utils.Dictionary;

	public class FilterUtil extends Object {
		private static var _filters : Dictionary = new Dictionary();

		public static function getBlackWhiteMatrixData() : ColorMatrixFilter {
			if (_filters["getBlackWhiteMatrixData"] == null)
				_filters["getBlackWhiteMatrixData"] = new ColorMatrixFilter([0.3086, 0.6094, 0.082, 0, 0, 0.3086, 0.6094, 0.082, 0, 0, 0.3086, 0.6094, 0.082, 0, 0, 0, 0, 0, 1, 0]);
			return _filters["getBlackWhiteMatrixData"] as ColorMatrixFilter;
		}

		public static function getColor(r : Number, g : Number, b : Number, a : Number = 1) : Array {
			var matrix : Array = new Array();
			matrix = matrix.concat([r, 0, 0, 0, 0]);
			// red
			matrix = matrix.concat([0, g, 0, 0, 0]);
			// green
			matrix = matrix.concat([0, 0, b, 0, 0]);
			// blue
			matrix = matrix.concat([0, 0, 0, a, 0]);
			// alpha
			return matrix;
		}

		public static function getRed() : Array {
			var matrix : Array = new Array();
			matrix = matrix.concat([1, 0, 0, 0, 0]);
			// red
			matrix = matrix.concat([0, 0, 0, 0, 0]);
			// green
			matrix = matrix.concat([0, 0, 0, 0, 0]);
			// blue
			matrix = matrix.concat([0, 0, 0, 1, 0]);
			// alpha
			return matrix;
		}

		public static function getGreen() : Array {
			var matrix : Array = new Array();
			matrix = matrix.concat([0, 0, 0, 0, 0]);
			// red
			matrix = matrix.concat([0, 1, 0, 0, 0]);
			// green
			matrix = matrix.concat([0, 0, 0, 0, 0]);
			// blue
			matrix = matrix.concat([0, 0, 0, 1, 0]);
			// alpha
			return matrix;
		}

		public static function getBlue() : Array {
			var matrix : Array = new Array();
			matrix = matrix.concat([0, 0, 0, 0, 0]);
			// red
			matrix = matrix.concat([0, 0, 0, 0, 0]);
			// green
			matrix = matrix.concat([0, 0, 1, 0, 0]);
			// blue
			matrix = matrix.concat([0, 0, 0, 1, 0]);
			// alpha
			return matrix;
		}

		public static function applyFilter(child : DisplayObject, matrix : Array) : void {
			var filter : ColorMatrixFilter = new ColorMatrixFilter(matrix);
			var filters : Array = new Array();
			filters.push(filter);
			child.filters = filters;
		}

		public static function getGoldGlowFilter() : GlowFilter {
			if (_filters["goldGlowFilter"] == null) {
				_filters["goldGlowFilter"] = new GlowFilter(0xffde00);
			}
			return _filters["goldGlowFilter"];
		}

		public static function getGreenGlowFilter() : GlowFilter {
			if (_filters["glowGreenFilter"] == null) {
				_filters["glowGreenFilter"] = new GlowFilter(0x00ff00);
			}
			return _filters["glowGreenFilter"];
		}

		public static function getBlackStrokeFilter() : GlowFilter {
			if (_filters["blackStrokeFilter"] == null) {
				_filters["blackStrokeFilter"] = new GlowFilter(0x000000, 1, 3, 3, 10, 1);
			}
			return _filters["blackStrokeFilter"];
		}

		public static function getColorFilter(color : Number) : GlowFilter {
			if (_filters[color] == null) {
				_filters[color] = new GlowFilter(color, 1, 4, 4, 14, 1);
			}
			return _filters[color];
		}

		public static function getCampItemFilter(color : Number = 0x06f2db) : GlowFilter {
			if (_filters[color] == null) {
				_filters[color] = new GlowFilter(color, 1, 8, 8, 14, 1);
			}
			return _filters[color];
		}

		public static function getWhiteStrokeFilter() : GlowFilter {
			if (_filters["whiteStrokeFilter"] == null) {
				var color : Number = 0xFFFFFF;
				var alpha : Number = 1;
				var blurX : Number = 3;
				var blurY : Number = 3;
				var strength : Number = 2;
				var inner : Boolean = false;
				var knockout : Boolean = false;
				var quality : Number = BitmapFilterQuality.MEDIUM;

				_filters["whiteStrokeFilter"] = new GlowFilter(color, alpha, blurX, blurY, strength, quality, inner, knockout);
			}
			return _filters["whiteStrokeFilter"];
		}
	}
}
