package org.david.ui {
	import org.david.ui.core.MContainer;

	import flash.display.DisplayObject;

	/**
	 * 自动排列的容器组件
	 */
	public class MBox extends MContainer {
		protected var _layout : String;
		protected var _gap : int;
		private var _center : Boolean;

		/**
		 * @param dragTarget 是否接受拖拽
		 * @param layout 布局方式 MBox.Horizon/MBox.Vertical
		 * @param gap 项之间的间隙
		 * @param center 是否居中对齐
		 */
		public function MBox(dragTarget : Boolean, layout : String, gap : int, center : Boolean) {
			super(dragTarget);
			_childs = new Array();
			_layout = layout;
			_gap = gap;
			_center = center;
		}

		/**
		 * 重设间隙
		 */
		public function set gap(value : int) : void {
			_gap = value;
			viewChanged();
		}

		override public function getChildAt(index : int) : DisplayObject {
			return _childs[index] as DisplayObject;
		}

		override protected function updateDisplayList() : void {
			var tw : int;
			var th : int;

			var child : DisplayObject = null;
			var nums : int = _childs.length;
			var index : int = 0;
			switch (_layout) {
				case MDirection.Horizon: {
					var tx : int;
					while (index < nums) {
						child = getChildAt(index);
						child.x = tx;
						tx = tx + child.width + _gap;

						if (child.height > th)
							th = child.height;

						index++;
					}
					if (_center) {
						index = 0;
						while (index < nums) {
							child = getChildAt(index);
							child.y = (th - child.height) / 2;
							index++;
						}
					}
					break;
				}
				case MDirection.Vertical: {
					var ty : int;
					while (index < nums) {
						child = getChildAt(index);
						child.y = ty;
						ty = ty + child.height + _gap;

						if (child.width > tw)
							tw = child.width;

						index++;
					}
					if (_center) {
						index = 0;
						while (index < nums) {
							child = getChildAt(index);
							child.x = (tw - child.width) / 2;
							index++;
						}
					}
					break;
				}
			}
			super.updateDisplayList();
		}
	}
}