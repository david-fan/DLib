package org.david.util {
	public class MathUtil {
		public static function randRange(minNum : Number, maxNum : Number) : Number {
			return Math.round(Math.random() * (maxNum - minNum) + minNum);
		}
	}
}