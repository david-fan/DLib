package org.david.ui {
	import org.david.ui.core.ITollTip;
	import org.david.ui.core.MSprite;

	public class MMachineToolTip extends MSprite implements ITollTip {
		protected var _block : MMachineTextBlock;

		public function MMachineToolTip() {
			super();
			this.mouseChildren = false;
			this.mouseEnabled = false;
			_block = new MMachineTextBlock(null, 14, 0xffffff, 250);
			addChild(_block);
		}

		public function set data(value : Object) : void {
			if (value == null) {
				return;
			}
			_block.text = String(value);
		}

		public function get data() : Object {
			return _block.text;
		}

		public function get showbg() : Boolean {
			return true;
		}
	}
}