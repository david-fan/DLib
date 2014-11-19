package org.david.util {
	import org.casalib.util.StageReference;
	import org.david.ui.core.IDragTarget;
	import org.david.ui.core.MSprite;

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class DragUtil {
		private var _parent : MSprite;
		private var _targets : Vector.<IDragTarget> = new Vector.<IDragTarget>();
		private var _dragObj : DisplayObject;
		private var _dragObjMirror : DisplayObject;
		private var _dragData : Object;
		private var _dragTarget : IDragTarget;
		private var _dragFrom : Object;
		//
		private var _stage : Stage;

		public function DragUtil(parent : MSprite) {
			_parent = parent;
		}

		public function startDrag(dragObj : DisplayObject, dragData : Object, from : DisplayObjectContainer, dragObjMirror : DisplayObject = null) : void {
			if (_stage == null)
				_stage = StageReference.getStage();
			_dragFrom = from;
			_dragData = dragData;
			_dragObj = dragObj;
			_dragObj.alpha = 0.8;
			_dragObjMirror = dragObjMirror;
			if (_dragObjMirror == null)
				_dragObjMirror = GetBitmapUtil.GetBitmap(_dragObj);
			_parent.addChild(_dragObjMirror);
			moveDragObjMirror();
			_stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			_stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}

		public function regist(dragTarget : IDragTarget) : void {
			if (dragTarget is DisplayObjectContainer) {
				_targets.push(dragTarget);
			}
		}

		private function checkCollision() : void {
			var collision : Boolean;
			for each (var target:DisplayObject in _targets) {
				if (target === _dragFrom)
					continue;
				if (target.hitTestPoint(_parent.mouseX, _parent.mouseY)) {
					collision = true;
					if (target === _dragTarget) {
					} else {
						if (_dragTarget)
							_dragTarget.setOut();
						var newTarget : IDragTarget = target as IDragTarget;
						newTarget.setIn(_dragData);
						_dragTarget = newTarget;
					}
					return;
				}
			}
			if (!collision) {
				if (_dragTarget) {
					_dragTarget.setOut();
					_dragTarget = null;
				}
			}
		}

		public function unregist(target : IDragTarget) : void {
			var index : int = _targets.indexOf(target);
			if (index > -1)
				_targets.splice(index, 1);
		}

		private function onEnterFrame(e : Event) : void {
			checkCollision();
			moveDragObjMirror();
		}

		private function moveDragObjMirror() : void {
			_dragObjMirror.x = _parent.mouseX - _dragObjMirror.width / 2;
			_dragObjMirror.y = _parent.mouseY - _dragObjMirror.height / 2;
		}

		private function onMouseUp(e : MouseEvent) : void {
			if (_parent.contains(_dragObjMirror))
				_parent.removeChild(_dragObjMirror);
			//
			for each (var target:DisplayObject in _targets) {
				if (target === _dragFrom)
					continue;
				if (target.hitTestPoint(_parent.mouseX, _parent.mouseY)) {
					var newTarget : IDragTarget = target as IDragTarget;
					newTarget.setDrop(_dragData);
					if (_dragFrom is IDragTarget) {
						var dragFrom : IDragTarget = _dragFrom as IDragTarget;
						dragFrom.setOut();
						dragFrom.setDragFrom();
					}
					break;
				}
			}

			_dragObj.alpha = 1;
			_stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			_stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);

			clear();
		}

		private function clear() : void {
			_dragObj = null;
			_dragObjMirror = null;
			_dragData = null;
			_dragTarget = null;
			_dragFrom = null;
		}
	}
}