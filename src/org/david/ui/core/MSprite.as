package org.david.ui.core {
	import org.casalib.core.IDestroyable;
	import org.david.ui.event.UIEvent;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;

	/**
	 * 显示对象基础类
	 */
	public class MSprite extends Sprite implements IDestroyable {
		private var _events : Array;
		/**
		 * 视图是否发生变化
		 */
		protected var _viewChange : Boolean;

		public function MSprite() {
			super();
			_events = [];
			if (this.stage) {
				this.invalidate(null);
			} else {
				addEventListener(Event.ADDED_TO_STAGE, this.addedToStageHandler);
			}
			addEventListener(Event.RENDER, this.onRender);
		}

		public static function destroyDisplayObj(obj : DisplayObject) : void {
			if (obj) {
				if (obj.parent)
					obj.parent.removeChild(obj);
				obj = null;
			}
		}

		protected var _isDestroyed : Boolean;

		public function get destroyed() : Boolean {
			return this._isDestroyed;
		}

		public function destroy() : void {
			removeAllChildren(true);
			removeAllEventListener();
			this._isDestroyed = true;
		}

		public function addChildXY(child : DisplayObject, x : Number = 0, y : Number = 0) : void {
			addChild(child);
			child.x = x;
			child.y = y;
		}

		protected function addedToStageHandler(event : Event) : void {
			this.invalidate(event);
		}

		protected function invalidate(event : Event) : void {
			if (stage != null) {
				stage.invalidate();
			}
		}

		private function onRender(event : Event) : void {
			if (_viewChange)
				this.updateDisplayList();
		}

		/**
		 * 更新视图方法
		 */
		protected function updateDisplayList() : void {
			_viewChange = false;
			dispatchEvent(new UIEvent(UIEvent.ViewChanged));
		}

		/**
		 * 移除所有子显示对象
		 */
		public function removeAllChildren(dispose : Boolean = false) : void {
			while (numChildren > 0) {
				var child : DisplayObject = removeChildAt(0);
				if (dispose) {
					if (child is IDestroyable) {
						(child as IDestroyable).destroy();
					}
				}
			}
		}

		/**
		 * 数据发生变化，需要重新绘制视图
		 */
		protected function viewChanged() : void {
			_viewChange = true;
			if (stage != null) {
				stage.invalidate();
			}
		}

		override public function addEventListener(type : String, listener : Function, useCapture : Boolean = false, priority : int = 0, useWeakReference : Boolean = false) : void {
			_events.push({type:type, fun:listener});
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}

		override public function removeEventListener(type : String, listener : Function, useCapture : Boolean = false) : void {
			super. removeEventListener(type, listener, useCapture);
			for (var i : int = 0;i < _events.length;i++) {
				if ( _events[i].type == type && _events[i].fun == listener) {
					_events.splice(i, 1);
				}
			}
		}

		public function removeAllEventListener() : void {
			var ev : Object;
			while (_events.length > 0) {
				ev = _events.pop();
				super.removeEventListener(ev.type, ev.fun);
			}
			_events = new Array();
		}

        /*
        protected var _width:Number;

        override public function set width(value:Number):void {
            super.width =_width= value;
        }

        protected var _height:Number;


        override public function set height(value:Number):void {
            super.height=_height = value;
        }
        */
    }
}
