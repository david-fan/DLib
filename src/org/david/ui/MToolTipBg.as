package org.david.ui {
	import org.david.ui.core.AppLayer;
	import org.david.ui.core.MContainer;
	import org.david.ui.core.MSprite;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;

	/**
	 * 标准提示背景
	 */
	public class MToolTipBg extends MContainer {
		private var _triangleSprite : Sprite;
		private var _bgalpha : Number = 0.6;
		private var _lineColor : uint = 0xffffff;
		private var _lineWidth : uint = 1;
		private var _bgColor : uint = 0x666666;
		private var _padding : int = 5;
		private const dis : int = 10;
		private var _triangleWidth : int = 10;
		private var _triangleHeight : int = 10;
		private var _width : Number = 50;
		private var _height : Number = 25;
		private var _content : MSprite = new MSprite();
		private var _showbg : Boolean;
		private var points : Array;
		private var _obj : Object;
		private var _target : DisplayObject;
		private var arrow : Array;
		private var _curPos : Point;
		/**
		 * 	0:上边线	1:右边线	2:下边线	3:左边线
		 */
		private var direct : int;

		public function MToolTipBg() {
			this.mouseEnabled = false;
			this.mouseChildren = false;
			this._triangleSprite = new Sprite();
		}

		public function get xOffset() : int {
			if (_showbg)
				return this._triangleWidth;
			else
				return 0;
		}

		public function get yOffset() : int {
			if (_showbg)
				return this._triangleHeight;
			else
				return 0;
		}

		private function positionContent() : void {
			_content.x = (width - _content.width) / 2;
			_content.y = (height - _content.height) / 2;
		}

		private function setPosition() : void {
			positionContent();
			if (!_showbg)
				return;
		}

		override protected function updateDisplayList() : void {
			if (_target == null)
				return;
			clear();
			_curPos = new Point();
			direct = 0;
			this.graphics.lineStyle(this._lineWidth, this._lineColor, 1, true);
			this.graphics.beginFill(this._bgColor, _bgalpha);
			drawCure();
			setPosition();
			positionThis();
			super.updateDisplayList();
		}

		/**
		 * 获取要显示tips的对象
		 */
		public function set target(value : DisplayObject) : void {
			_curPos = new Point();
			direct = 0;
			// 把target的坐标转为全局坐标
			var point : Point = value.parent.localToGlobal(new Point(value.x, value.y));
			_obj = new Object();
			_obj.x = point.x;
			_obj.y = point.y;
			_obj.width = value.width;
			_obj.height = value.height;
			//
			_target = value;
			if (!_showbg) {
				positionThis();
				return;
			}
		}

		/**
		 * 四个圆角
		 */
		private function drawCure() : void {
			if (!_showbg) return;
			switch(direct) {
				case 0:
					this.graphics.moveTo(0, 5);
					this.graphics.curveTo(0, 0, 5, 0);
					setCurPos(5, 0);
					break;
				case 1:
					this.graphics.curveTo(width, 0, width, 5);
					setCurPos(width, 5);
					break;
				case 2:
					this.graphics.curveTo(width, height, width - 5, height);
					setCurPos(width - 5, height);
					break;
				case 3:
					this.graphics.curveTo(0, height, 0, height - 5);
					setCurPos(0, height - 5);
					break;
			}
			drawGroove();
		}

		/**
		 * tips边缘装饰性凹槽
		 */
		private function drawGroove() : void {
			points = [];
			var point1 : Point;
			var point2 : Point;
			var point3 : Point;

			setArrow();

			var grooveNum : int;
			if (direct == 0 || direct == 2) {
				grooveNum = width / 50;
			} else if (direct == 1 || direct == 3) {
				grooveNum = height / 50;
			}
            grooveNum=0;

			for (var i : int = 0;i < grooveNum;i++) {
				points[i] = [];

				switch(direct) {
					case 0:
						if (arrowPos == 1) {
							point1 = new Point(0, curPos.y);
							point1.x = i * 40 + 15 + Math.random() * 20;

							point2 = new Point(0, deep);
							point2.x = point1.x - 4 + grooveWidth;

							point3 = new Point(0, 0);
							point3.x = point1.x + grooveWidth;
						}
						break;
					case 1:
						point1 = new Point(width, curPos.y);
						point1.y = i * 40 + 15 + Math.random() * 20;
						point2 = new Point(width - deep, 0);
						point2.y = point1.y - 4 + grooveWidth;
						point3 = new Point(width, 0);
						point3.y = point1.y + grooveWidth;
						break;
					case 2:
						if (arrowPos == 0) {
							point1 = new Point(0, curPos.y);
							point1.x = width - i * 40 - 15 - Math.random() * 20;

							point2 = new Point(0, height - deep);
							point2.x = point1.x + 7 - grooveWidth;

							point3 = new Point(0, height);
							point3.x = point1.x - grooveWidth;
						}
						break;
					case 3:
						point1 = new Point(0, 0);
						point1.y = height - i * 40 - 15 - Math.random() * 20;
						point2 = new Point(deep, 0);
						point2.y = point1.y + 7 - grooveWidth;
						point3 = new Point(0, 0);
						point3.y = point1.y - grooveWidth;
						break;
				}

				points[i].push(point1);
				points[i].push(point2);
				points[i].push(point3);
			}

			if (points[0] != null && points[0][0] != null) {
				// 画直线
				this.graphics.lineTo(points[0][0].x, points[0][0].y);

				// 画凹槽
				for (i = 0;i < points.length;i++) {
					for (var j : int = 0;j < 3;j++) {
						this.graphics.lineTo(points[i][j].x, points[i][j].y);
						setCurPos(points[i][j].x, points[i][j].y);
					}
					for (j = i;j < points.length - 1;j++) {
						this.graphics.lineTo(points[i + 1][0].x, points[i + 1][0].y);
						setCurPos(points[i + 1][0].x, points[i + 1][0].y);
					}
				}
			} else if (arrowPos == 0 && direct == 0 || arrowPos == 1 && direct == 2) {
				for (var m : int = 0;m < arrow.length;m++) {
					this.graphics.lineTo(arrow[m].x, arrow[m].y);
					setCurPos(arrow[m].x, arrow[m].y);
				}
			}

			// 画直线
			switch(direct) {
				case 0:
					this.graphics.lineTo(width - 5, 0);
					setCurPos(width - 5, 0);
					direct = 1;
					break;
				case 1:
					this.graphics.lineTo(width, height - 5);
					setCurPos(width, height - 5);
					direct = 2;
					break;
				case 2:
					this.graphics.lineTo(5, height);
					setCurPos(5, height);
					direct = 3;
					break;
				case 3:
					this.graphics.lineTo(0, 5);
					setCurPos(0, 5);
					this.graphics.endFill();
					return;
			}
			drawCure();
		}

		public function get curPos() : Point {
			return _curPos;
		}

		public function setCurPos(_x : Number, _y : Number) : void {
			_curPos.x = _x;
			_curPos.y = _y;
		}

		private function get deep() : Number {
			return 5 + Math.random() * 5;
		}

		public function get grooveWidth() : Number {
			return 5 + Math.random() * 10;
		}

		/**
		 * 0:出现在上边	1:出现在下边
		 */
		private function get arrowPos() : int {
			if (height + dis > _obj.y) {
				return 0;
			} else {
				return 1;
			}
		}

		/**
		 * 画箭头
		 */
		private function setArrow() : void {
			var arrX : int = 0;
			var arrY : int = 0;
			var arrWidth : int = 0;
			var arrHeight : int = 0;
			arrow = [];
			var point1 : Point;
			var point2 : Point;
			var point3 : Point;
			// 对象坐标
			var point : Point = _target.localToGlobal(new Point(0, 0));

			if (point.x + _target.width > AppLayer.AppWidth) {
				arrX = this.width - AppLayer.AppWidth + point.x + _target.width / 2;
			} else if (point.x + (_target.width + this.width) / 2 > AppLayer.AppWidth) {
				arrX = point.x + _target.width / 2 - AppLayer.AppWidth + this.width;
			} else {
				arrX = point.x + _target.width / 2;
			}
			arrY = point.y;
			arrWidth = width;
			arrHeight = height;

			if (_obj.x < width / 2 || AppLayer.AppWidth - _obj.x < width / 2) {
				// 箭头显示在上面
				if (height + dis > _obj.y) {
					point1 = new Point(arrX - 5, 0);
					point2 = new Point(arrX, -10);
					point3 = new Point(arrX + 5, 0);
				} else {
					// 箭头显示在下面
					point1 = new Point(arrX + 5, height);
					point2 = new Point(arrX, height + 10);
					point3 = new Point(arrX - 5, height);
				}
			} else {
				if (height + dis > _obj.y) {
					point1 = new Point(arrWidth / 2 - 5, 0);
					point2 = new Point(arrWidth / 2, -10);
					point3 = new Point(arrWidth / 2 + 5, 0);
				} else {
					// 箭头显示在下面
					point1 = new Point(arrWidth / 2 + 5, height);
					point2 = new Point(arrWidth / 2, height + 10);
					point3 = new Point(arrWidth / 2 - 5, height);
				}
			}
			arrow.push(point1);
			arrow.push(point2);
			arrow.push(point3);
		}

		/**
		 * 设置tips的x，y
		 */
		private function positionThis() : void {
			var point : Point = _target.localToGlobal(new Point(0, 0));
			this.x = point.x - (this.width - _target.width) / 2;
			if (this.x < 0) {
				this.x = 0;
			} else if (this.x + width > AppLayer.AppWidth) {
				this.x = AppLayer.AppWidth - width;
			}

			if (_obj.x < width / 2 || AppLayer.AppWidth - _obj.x < width / 2) {
				if (height + dis > _obj.y) {
					this.y = _obj.y + _obj.height + 10;
				} else {
					this.y = _obj.y - this.height - 10;
				}
			} else {
				if (height + dis > _obj.y) {
					this.y = _obj.y + _obj.height + 10;
				} else {
					this.y = _obj.y - this.height - 10;
				}
			}
		}

		override public function get width() : Number {
			return Math.max(this._width, _content.width + _padding * 2);
		}

		override public function get height() : Number {
			return Math.max(this._height, _content.height + _padding * 2);
		}

		public function get content() : MSprite {
			return this._content;
		}

		public function set content(value : MSprite) : void {
			if (this.contains(_content))
				this.removeChild(_content);
			this._content = value;
			this.addChild(value);
		}

		public function drawBg(showbg : Boolean) : void {
			_showbg = showbg;
		}

		private function clear() : void {
			if (contains(this._triangleSprite))
				removeChild(this._triangleSprite);
			graphics.clear();
		}
	}
}
