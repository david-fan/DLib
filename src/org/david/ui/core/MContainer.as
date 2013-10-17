package org.david.ui.core {
	import org.david.ui.event.UIEvent;
	import org.david.util.UtilManager;

	import flash.display.DisplayObject;
	import flash.events.Event;

	[Event(name="UIEvent.DragIn", type="org.david.ui.event.UIEvent")]
	[Event(name="UIEvent.DragOut", type="org.david.ui.event.UIEvent")]
	[Event(name="UIEvent.DragDrop", type="org.david.ui.event.UIEvent")]
	/**
	 * 窗口组件
	 */
	public class MContainer extends MUIComponent implements IDragTarget {
		public static const add : String = "add";
		public static const remove : String = "remove";
		protected var _dragData : Object;
		protected var _childs : Array;
		private var _dragTarget : Boolean;

		/**
		 * @param dragTarget 是否接受拖拽
		 */
		public function MContainer(dragTarget : Boolean = false) {
			_dragTarget = dragTarget;
			_childs = new Array();
			super(_dragTarget);
			dragEnable = dragTarget;
		}

		public function set dragEnable(value : Boolean) : void {
			_dragTarget = value;
			if (_dragTarget) {
				if (this.stage)
					onAdd(null);
				this.addEventListener(Event.ADDED_TO_STAGE, onAdd);
				this.addEventListener(Event.REMOVED_FROM_STAGE, onRemove)	;
			} else {
				this.removeEventListener(Event.ADDED_TO_STAGE, onAdd);
				this.removeEventListener(Event.REMOVED_FROM_STAGE, onRemove)	;
				onRemove(null);
			}
		}

		public function get dragEnable() : Boolean {
			return _dragTarget;
		}

		// public function unDrag() : void {
		// this.removeEventListener(Event.ADDED_TO_STAGE, onAdd);
		// this.removeEventListener(Event.REMOVED_FROM_STAGE, onRemove)	;
		// onRemove(null);
		// }
		private function onAdd(e : Event) : void {
			UtilManager.dragUtil.regist(this);
		}

		private function onRemove(e : Event) : void {
			UtilManager.dragUtil.unregist(this);
		}

		public function setIn(dragData : Object) : void {
			_dragData = dragData;
			this.dispatchEvent(new UIEvent(UIEvent.DRAG_IN, dragData));
		}

		public function setDrop(dragData : Object) : void {
			_dragData = dragData;
			this.dispatchEvent(new UIEvent(UIEvent.DRAG_Drop, dragData));
		}

		public function setOut() : void {
			this.filters = [];
			this.dispatchEvent(new UIEvent(UIEvent.DRAG_OUT));
		}

		public function setDragFrom() : void {
		}

		override public function get numChildren() : int {
			return _childs.length;
		}

		override public function addChild(child : DisplayObject) : DisplayObject {
			_childs.push(child);
			if (child is MSprite)
				child.addEventListener(UIEvent.ViewChanged, onChildViewChanged);
			var r : DisplayObject = super.addChild(child);
			viewChanged();
			return r;
		}

		private function onChildViewChanged(e : UIEvent) : void {
			updateDisplayList();
		}

		override public function addChildAt(child : DisplayObject, index : int) : DisplayObject {
			_childs.splice(index, 0, child);
			var r : DisplayObject = super.addChildAt(child, index);
			viewChanged();
			return r;
		}

		override public function removeChild(child : DisplayObject) : DisplayObject {
			var index : int = _childs.indexOf(child);
			if (index > -1) {
				return removeChildAt(index);
			}
			return child;
		}

		override public function removeChildAt(index : int) : DisplayObject {
			if (index > -1) {
				var child : DisplayObject = _childs[index] as DisplayObject;
				if (child is MSprite)
					child.removeEventListener(UIEvent.ViewChanged, onChildViewChanged);
				_childs.splice(index, 1);
				if (super.contains(child)) {
					var r : DisplayObject = super.removeChild(child);
					viewChanged();
				}
				return r;
			}
			throw new Error("bad index");
		}
	}
}