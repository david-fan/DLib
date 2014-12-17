package org.david.ui.core {
	import org.david.ui.event.UIEvent;

	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;

	/**
	 * @author david
	 */
	public class ListSource {
		private static var _class : Dictionary = new Dictionary();

		public static function getItemRender(type : Class, data : Object) : IListItem {
			if (_class[type] == null)
				_class[type] = new Dictionary();
			var ili : IListItem = _class[type][data];
			if (ili == null) {
				ili = new type();
				ili.data = data;
				_class[type][data] = ili;
				var ed : EventDispatcher = ili as EventDispatcher;
				ed.addEventListener(MouseEvent.MOUSE_DOWN, function(e : MouseEvent) : void {
					ed.dispatchEvent(new UIEvent(UIEvent.ListItemMouseDown, ed, true));
				});
				ed.addEventListener(MouseEvent.MOUSE_UP, function(e : MouseEvent) : void {
					ed.dispatchEvent(new UIEvent(UIEvent.ListItemMouseUp, ed, true));
				});
			} else {
				trace("get old item.........");
			}
			return ili;
		}
	}
}
