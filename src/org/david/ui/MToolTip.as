package org.david.ui {
	import org.david.ui.core.ITollTip;
	import org.david.ui.core.MSprite;

	import flash.text.engine.FontWeight;

	/**
	 * 标准文字提示
	 */
	public class MToolTip extends MSprite implements ITollTip {
		protected var _block : MTextBlock;

		public function MToolTip() {
			super();
			this.mouseChildren = false;
			this.mouseEnabled = false;
			_block = new MTextBlock(null, 14, 0xCCCCCC, 150);
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