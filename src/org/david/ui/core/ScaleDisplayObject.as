package org.david.ui.core {
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	public class ScaleDisplayObject extends MSprite {
		private var offsetX : Number = 0;
		private var offsetY : Number = 0;
		private var child : Sprite;
		private var displayObject : DisplayObject;
		private var _width : Number = 0;
		private var _height : Number = 0;
		private var _scaleX : Number = 1;
		private var _scaleY : Number = 1;
		private var preX : Number = 0;
		private var preY : Number = 0;

		public function ScaleDisplayObject(displayObj : DisplayObject, offx : Number = 0, offy : Number = 0) {
			if (displayObj == null) {
				return;
			}
			this.offsetX = offx;
			this.offsetY = offy;
			this.displayObject = displayObj;
			this._width = displayObj.width;
			this._height = displayObj.height;
			this.child = new Sprite();
			displayObj.x = -this._width / 2 + offx;
			displayObj.y = -this._height / 2 + offy;
			this.child.addChild(displayObj);
			addChild(this.child);
			this.x = 0;
			this.y = 0;
			return;
		}

		override public function set width(value : Number) : void {
			this._width = value;
			this.displayObject.width = value;
			this.displayObject.x = -this._width / 2 + this.offsetX;
			this.x = this.preX;
			return;
		}

		override public function get width() : Number {
			return this._width;
		}

		override public function set height(value : Number) : void {
			this._height = value;
			this.displayObject.height = value;
			this.displayObject.y = -this._height / 2 + this.offsetY;
			this.y = this.preY;
			return;
		}

		override public function get height() : Number {
			return this._height;
		}

		override public function set scaleX(value : Number) : void {
			this._scaleX = value;
			this.child.scaleX = value;
			return;
		}

		override public function get scaleX() : Number {
			return this._scaleX;
		}

		override public function set scaleY(value : Number) : void {
			this._scaleY = value;
			this.child.scaleY = value;
			return;
		}

		override public function get scaleY() : Number {
			return this._scaleY;
		}

		override public function set x(value : Number) : void {
			this.preX = value;
			super.x = value + this._width / 2;
			return;
		}

		override public function get x() : Number {
			return super.x - this._width / 2;
		}

		override public function set y(value : Number) : void {
			this.preY = value;
			super.y = value + this._height / 2;
			return;
		}

		override public function get y() : Number {
			return super.y - this._height / 2;
		}
	}
}
