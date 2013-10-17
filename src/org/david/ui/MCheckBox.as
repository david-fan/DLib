package org.david.ui {
	import org.david.ui.core.MUIComponent;
	import org.david.util.FilterUtil;

	import flash.display.DisplayObject;
	import flash.events.MouseEvent;

	/**
	 * 勾选组件
	 */
	public class MCheckBox extends MUIComponent {
		private var _checked : Boolean;
		private var _checkedSkin : DisplayObject;

		public function MCheckBox(skin : DisplayObject, checkedSkin : DisplayObject, readOnly : Boolean = false) {
			super(true);
			this.buttonMode = true;
			this.mouseChildren = false;
			this.skin = skin;
			this._checkedSkin = checkedSkin;
			if (readOnly == false) {
				this.addEventListener(MouseEvent.CLICK, onClick);
			}
		}

		private function onClick(e : MouseEvent) : void {
			if (enable) {
				checked = !_checked;
			}
		}

		public function get checked() : Boolean {
			return _checked;
		}

		public function set checked(value : Boolean) : void {
			this._checked = value;
			if (value) {
				this.addChild(_checkedSkin);
			} else {
				if (this.contains(_checkedSkin)) {
					this.removeChild(_checkedSkin);
				}
			}
		}

		override public function set enable(value : Boolean) : void {
			super.enable = value;
			if (value) {
				this.filters = [];
				this.buttonMode = true;
			} else {
				this.filters = [FilterUtil.getBlackWhiteMatrixData()];
				this.buttonMode = false;
			}
		}

		override public function get width() : Number {
			return background.width;
		}
	}
}