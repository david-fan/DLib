package org.david.ui {
	import org.david.ui.core.MContainer;
	import org.david.ui.event.UIEvent;
	import org.david.util.FilterUtil;

	import flash.display.DisplayObject;
	import flash.events.MouseEvent;

	/**
	 * @author david
	 */
	public class MNumberStep extends MContainer {
		public static const CountChange : String = "MNumberStep.CountChange";
		//
		private var _count : int = 1;
		private var _countLabel : MTextBlock;
		private var _min : int;
		private var _max : int;
		private var _box : MBox;
		private var _reduce : MButton;
		private var _incress : MButton;

		public function MNumberStep(incressSkin : DisplayObject, reduceSkin : DisplayObject, textBg : DisplayObject, textSize : int = 14, max : int = 100, min : int = 1) {
			super(false);
			_max = max;
			_min = min;

			_incress = new MButton(incressSkin);
			_incress.addEventListener(MouseEvent.CLICK, function(e : MouseEvent) : void {
				count++;

				_countLabel.text = count.toString();
			});
			_reduce = new MButton(reduceSkin);

			_reduce.addEventListener(MouseEvent.CLICK, function(e : MouseEvent) : void {
				count--;

				_countLabel.text = count.toString();
			});
			_countLabel = new MTextBlock(_count.toString(), textSize, 0xffffff);
			_countLabel.filters = [FilterUtil.getBlackStrokeFilter()];

			_box = new MBox(false, MDirection.Horizon, 5, true);
			_box.addChild(_reduce);
			_box.addChild(textBg);
			_box.addChild(_incress);
			addChild(_box);

			addChild(_countLabel);

			count = min;
		}

		override protected function updateDisplayList() : void {
			_countLabel.x = (this.width - _countLabel.width) / 2;
			_countLabel.y = (this.height - _countLabel.height) / 2;
			super.updateDisplayList();
		}

		public function set count(value : int) : void {
			_count = value;
			if (_count > _max)
				_count = _max;
			if (_count < _min)
				_count = _min;
			_countLabel.text = _count.toString();

			_reduce.enable = (_count != _min);
			_incress.enable = (_count != _max);

			dispatchEvent(new UIEvent(MNumberStep.CountChange, _count));
		}

		public function get count() : int {
			return _count;
		}
	}
}
