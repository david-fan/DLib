package org.david.mvc{

	/**
	 * @author david
	 */
	public class DispathUtil extends BaseController {
		private static var _instance : DispathUtil;

		public static function get instance() : DispathUtil {
			if (_instance == null)
				_instance = new DispathUtil();
			return _instance;
		}

		public static function dispathNotifaction(n : Notification) : void {
			instance.dispatch(n);
		}
	}
}
