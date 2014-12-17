package org.david.ui {
	import flash.display.DisplayObject;

	/**
	 * @author leehp
	 */
	public class MScaleLabelButton extends MScaleButton {
		private var _size : int = 14;
		protected var _labelBg : LabelBG;

		public function MScaleLabelButton(skin : DisplayObject, text : String = "", size : int = 14) {
			this._size = size;
			_labelBg = new LabelBG(skin, text, size);
			super(_labelBg);
		}

		public function setText(text : String) : void {
			// var bg:LabelBG = new LabelBG(_skin, text, _size);
			// super.background = bg;
			_labelBg.setText(text);
		}
	}
}
