package org.david.util {
	/**
	 * @author david
	 */
	public class DebugError {
		public static var logCallback : Function;
		public static var errorCallback : Function;
		private static var _debug : Boolean;

		public static function get debug() : Boolean {
			return _debug;
		}

		public static function set debug(value : Boolean) : void {
			_debug = value;
		}

		public static function error(message : String) : void {
			if (errorCallback != null)
				errorCallback(message);
		}

		public static function log(message : String) : void {
			if (logCallback != null)
				logCallback(message);
		}
	}
}
