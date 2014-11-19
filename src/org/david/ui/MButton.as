package org.david.ui {
	import org.david.ui.core.IToolTipUI;
	import org.david.ui.core.MUIComponent;
	import org.david.util.FilterUtil;

	import flash.display.DisplayObject;
	import flash.display.MovieClip;

	/**
	 * 基础按钮组件
	 */
	public class MButton extends MUIComponent implements IToolTipUI {
		public function MButton(skin : DisplayObject = null) {
			super(true);
			this.buttonMode = true;
			this.mouseChildren = false;
			this.skin = skin;
		}

		override public function set skin(value : Object) : void {
			super.skin = value;
			if (_selected)
				this.skinGotoAndStop(2);
			else
				this.skinGotoAndStop(1);
		}

		private var _selected : Boolean;

		public function set selected(value : Boolean) : void {
			_selected = value;
			if (_selected)
				this.skinGotoAndStop(2);
			else
				this.skinGotoAndStop(1);
		}

		public function get selected() : Boolean {
			return _selected;
		}

		// override protected function onMouseOver(e : MouseEvent) : void {
		// super.onMouseOver(e);
		// if (enable) {
		// this.skinGotoAndStop(2);
		// }
		// }
		// override protected function onMouseOut(e : MouseEvent) : void {
		// super.onMouseOut(e);
		// if (enable) {
		// if (!selected)
		// this.skinGotoAndStop(1);
		// }
		// }
		override public function set enable(value : Boolean) : void {
			super.enable = value;
			mouseEnabled = value;
			mouseChildren = value;
			// this.skinGotoAndStop(1);
			if (value) {
				//this.filters = [];
				this.buttonMode = true;
			} else {
				//this.filters = [FilterUtil.getBlackWhiteMatrixData()];
				this.buttonMode = false;
			}
		}

		protected function skinGotoAndStop(frame : int) : void {
			var mc : MovieClip = null;
			if (this.skin is MovieClip) {
				mc = this.skin as MovieClip;
				if (mc.totalFrames >= frame) {
					mc.gotoAndStop(frame);
				}
			}
		}

		// begin for ITollTipUI
		private var _tollTip : Object;

		public function set toolTip(value : Object) : void {
			_tollTip = value;
		}

		public function get toolTip() : Object {
			return _tollTip;
		}

		private var _toolTipData : Object;

		public function set toolTipData(value : Object) : void {
			_toolTipData = value;
		}

		public function get toolTipData() : Object {
			return _toolTipData;
		}

		private var _remain : int;

		public function set remain(value : int) : void {
			_remain = value;
		}

		public function get remain() : int {
			return _remain;
		}

        private var _delay:int;

        public function set delay(value:int):void {
            _delay = value;
        }

        public function get delay():int {
            return _delay;
        }
		// end for ITollTipUI
	}
}