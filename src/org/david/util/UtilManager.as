package org.david.util {
	import org.david.ui.core.AppLayer;

	public class UtilManager {
		private static var _toolTipUtil : ToolTipUtil;
		private static var _dragUtil : DragUtil;
		private static var _cursorUtil : CursorUtil;
		private static var _popupUtil : PopUpUtil;

		public static function get toolTipUtil() : ToolTipUtil {
			if (_toolTipUtil == null)
				_toolTipUtil = new ToolTipUtil(AppLayer.TooltipLayer);
			return _toolTipUtil;
		}

		public static function get dragUtil() : DragUtil {
			if (_dragUtil == null)
				_dragUtil = new DragUtil(AppLayer.MouseLayer);
			return _dragUtil;
		}

		public static function get cursorUtil() : CursorUtil {
			if (_cursorUtil == null)
				_cursorUtil = new CursorUtil(AppLayer.MouseLayer);
			return _cursorUtil;
		}

		public static function get popUpUtil() : PopUpUtil {
			if (_popupUtil == null)
				_popupUtil = new PopUpUtil();
			return _popupUtil;
		}
	}
}