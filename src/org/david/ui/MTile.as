package org.david.ui {
	import org.david.ui.core.MContainer;

	import flash.display.DisplayObject;

	/**
	 * @author david
	 */
	public class MTile extends MContainer {
		private var _max : int;
		private var _direction : String;
		private var _distance : int;

		public function MTile(direction : String, max : int, distance : int) {
			super();
			_direction = direction;
			_max = max;
			_distance = distance;
		}

		override protected function updateDisplayList() : void {
			var mw : int = getMaxWidth();
			var mh : int = getMaxHeight();
			var r : int;
			var c : int;
			var row : int;
			var col : int;
			var index : int;
			var item : DisplayObject;
			switch(_direction) {
				case MDirection.Horizon:
					r = Math.ceil(_childs.length / _max);
					c = Math.min(_childs.length, _max);
					for ( row = 0;row < r;row++) {
						for (col = 0; col < c; col++) {
							index = row * c + col ;
							if (index < _childs.length) {
								item = _childs[index];
								item.x = col * (mw + this._distance);
								item.y = row * (mh + this._distance);
							} else
								break;
						}
					}
					break;
				case MDirection.Vertical:
					r = Math.min(_childs.length, _max);
					c = Math.ceil(_childs.length / _max);
					for ( col = 0; col < c; col++) {
						for ( row = 0;row < r;row++) {
							index = col * r + row ;
							if (index < _childs.length) {
								item = _childs[index];
								item.x = col * (mw + this._distance);
								item.y = row * (mh + this._distance);
							} else
								break;
						}
					}
					break;
				default:
			}
			super.updateDisplayList();
		}

		private function getMaxWidth() : int {
			var max : int;
			for (var i : int = 0; i < _childs.length - 1; i++) {
				max = Math.max(_childs[i].width, _childs[i + 1].width);
			}
			return max;
		}

		private function getMaxHeight() : int {
			var max : int;
			for (var i : int = 0; i < _childs.length - 1; i++) {
				max = Math.max(_childs[i].height, _childs[i + 1].height);
			}
			return max;
		}
	}
}
 