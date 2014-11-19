package org.david.util {
	import org.david.ui.core.MSprite;

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;

	/**
	 * ...
	 * @author Armen Abrahamyan
	 */
	public class CursorUtil {
		public static var _busyCursor : DisplayObject;
		private var _cursor : DisplayObject;
		private var _xOffset : Number;
		private var _yOffset : Number;
		private var _parent : MSprite;

		public function CursorUtil(parent : MSprite) {
			_parent = parent;
		}

		/**
		 *  sets display object as cursor ( removes prev cursor automatically)
		 * @param	pCursor  new cursor
		 * @param	pXoffset x offset from mouse position
		 * @param	pYoffset y offset from mouse position
		 */
		public function setCursor(cursor : DisplayObject, xoffset : Number = 0, yoffset : Number = 0) : void {
			if (!_parent) {
				throw new Error("set root using init(pRoot)");
			}
			if (_cursor) {
				removeCursor();
			}
			Mouse.hide();
			_cursor = cursor;
			if (_cursor is InteractiveObject) {
				InteractiveObject(_cursor).mouseEnabled = false;
				if (_cursor is DisplayObjectContainer) {
					DisplayObjectContainer(_cursor).mouseChildren = false;
				}
			}

			_xOffset = xoffset;
			_yOffset = yoffset;
			_cursor.x = _parent.mouseX + _xOffset;
			_cursor.y = _parent.mouseY + _yOffset;
			_parent.addChild(_cursor);
			_parent.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}

		/**
		 * update cursor position
		 * @param	e
		 */
		private function onMouseMove(e : MouseEvent) : void {
			_cursor.x = _parent.mouseX + _xOffset;
			_cursor.y = _parent.mouseY + _yOffset;
			e.updateAfterEvent();
		}

		/**
		 * brings cursor on top of display list in case u add another displayobjext on stage
		 */
		public function bringToFront() : void {
			if (_cursor) {
				_parent.addChild(_cursor);
			}
		}

		/**
		 * removes cursor created by last setCursor() method, resotres original system cursor
		 */
		public function removeCursor() : void {
			if (!_cursor) {
				return;
			}
			_parent.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			_parent.removeChild(_cursor);
			_cursor = null;
			Mouse.show();
		}
		// /**
		// * works exactly same way as removeCursor()
		// */
		// public function destroy():void
		// {
		// if (_cursor)
		// {
		// removeCursor();
		// }
		// }
	}
}