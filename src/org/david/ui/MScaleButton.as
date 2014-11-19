package org.david.ui {
	import com.greensock.TweenLite;

	import org.david.ui.core.ScaleDisplayObject;

	import flash.display.DisplayObject;
	import flash.events.MouseEvent;

	/**
	 * 响应鼠标缩放的按钮
	 */
	public class MScaleButton extends MButton {
		public function MScaleButton(skin : DisplayObject = null) {
			super(skin);
			this.addEventListener(MouseEvent.ROLL_OVER, onRollOver);
			this.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
		}

		// override public function set background(value : DisplayObject) : void {
		// super.background = new ScaleDisplayObject(value);
		// }
		override public function set skin(value : Object) : void {
			super.skin = new ScaleDisplayObject(value as DisplayObject);
		}

		private function onRollOver(e : MouseEvent) : void {
			TweenLite.to(this.skin, 0.3, {scaleX:1.2, scaleY:1.2});
		}

		private function onRollOut(e : MouseEvent) : void {
			TweenLite.to(this.skin, 0.3, {scaleX:1, scaleY:1});
		}
	}
}
