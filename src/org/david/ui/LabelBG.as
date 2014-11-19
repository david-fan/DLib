package org.david.ui {
	import org.david.ui.core.MUIComponent;

	import flash.display.DisplayObject;

	/**
	 * @author fzw
	 */
	public class LabelBG extends MUIComponent {
		private var _bg : DisplayObject;
		private var _text : DisplayObject;
		private var _machineText : Boolean;

		public function LabelBG(bg : DisplayObject, label : String, size : int = 14, machineText : Boolean = false) {
			super();
			background = bg;
			this._machineText = machineText;
			if (machineText) {
				_text = new MStrokeMachineText(label, size);
				addChild(_text);
			} else {
				_text = new MStrokeText(label, size, 16777215, 250);
				addChild(_text);
			}
			viewChanged();
		}

		private var _cust : Boolean;

		public function customTextPosition(x : Number, y : Number) : void {
			_cust = true;
			_text.x = x;
			_text.y = y;
		}

		public function setText(value : String) : void {
			if (_machineText) {
				(_text as MStrokeMachineText).text = value;
			} else {
				(_text as MStrokeText).text = value;
			}
			viewChanged();
		}

		override protected function updateDisplayList() : void {
			if (!_cust) {
				_text.x = (background.width - _text.width) / 2;
				_text.y = (background.height - _text.height) / 2;
			}
			super.updateDisplayList();
		}
	}
}
