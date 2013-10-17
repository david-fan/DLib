package org.david.ui {
	import org.david.ui.core.MUIComponent;
	import org.david.ui.event.UIEvent;

	import flash.display.DisplayObject;
	import flash.events.MouseEvent;

	public class MDialog extends MUIComponent {
		private var _buttonLayout : String;
		private var confirmBtn : DisplayObject;
		private var cancelBtn : DisplayObject;
		private var closeBtn : DisplayObject;
		public var edgeDistance : Number = 15;
		private var _buttonDistance : Number;
		public static const LAYOUT_LEFT : String = "left";
		public static const LAYOUT_RIGHT : String = "right";
		public static const LAYOUT_CENTER : String = "center";
		public static const LAYOUT_CUSTOM : String = "custom";

		public function MDialog(background : DisplayObject, confirm : DisplayObject = null, cancel : DisplayObject = null, close : DisplayObject = null, btnLayout : String = "center", btnDistance : Number = 20) {
			this.confirmBtn = confirm;
			this.cancelBtn = cancel;
			this.closeBtn = close;
			this._buttonLayout = btnLayout;
			this.background = background;
			this._buttonDistance = btnDistance;
			this.init();
			return;
		}

		private function init() : void {
			if (this.confirmBtn != null) {
				addChild(this.confirmBtn);
				this.confirmBtn.addEventListener(MouseEvent.CLICK, this.dialogConfirm);
			}
			if (this.cancelBtn != null) {
				addChild(this.cancelBtn);
				this.cancelBtn.addEventListener(MouseEvent.CLICK, this.dialogCancel);
			}
			if (this.closeBtn != null) {
				addChild(this.closeBtn);
				this.closeBtn.addEventListener(MouseEvent.CLICK, this.dialogClose);
			}
			this.updateDisplayList();
		}

		private function dialogConfirm(event : MouseEvent) : void {
			var e : UIEvent = new UIEvent(UIEvent.DIALOG_OK);
			dispatchEvent(e);
			return;
		}

		private function dialogCancel(event : MouseEvent) : void {
			var e : UIEvent = new UIEvent(UIEvent.DIALOG_CANCEL);
			dispatchEvent(e);
			return;
		}

		private function dialogClose(event : MouseEvent) : void {
			var e : UIEvent = new UIEvent(UIEvent.DIALOG_CLOSE);
			dispatchEvent(e);
			return;
		}

		override protected function updateDisplayList() : void {
			if (this.closeBtn != null) {
				this.closeBtn.x = background.x + background.width - this.closeBtn.width - 10;
				this.closeBtn.y = background.y + 10;
			}
			switch(this._buttonLayout) {
				case LAYOUT_RIGHT: {
					if (this.cancelBtn != null) {
						this.cancelBtn.x = background.x + background.width - this.cancelBtn.width - this.edgeDistance;
						this.cancelBtn.y = background.y + background.height - this.cancelBtn.height - this.edgeDistance;
					}
					if (this.confirmBtn != null) {
						if (this.cancelBtn != null) {
							this.confirmBtn.x = this.cancelBtn.x - this.confirmBtn.width - this._buttonDistance;
							this.confirmBtn.y = this.cancelBtn.y;
						} else {
							this.confirmBtn.x = background.x + background.width - this.confirmBtn.width - this.edgeDistance;
							this.confirmBtn.y = background.y + background.height - this.confirmBtn.height - this.edgeDistance;
						}
					}
					break;
				}
				case LAYOUT_LEFT: {
					if (this.confirmBtn != null) {
						this.confirmBtn.x = background.x + this.edgeDistance;
						this.confirmBtn.y = background.y + background.height - this.confirmBtn.height - this.edgeDistance;
					}
					if (this.cancelBtn != null) {
						if (this.confirmBtn != null) {
							this.cancelBtn.x = this.confirmBtn.x + this.confirmBtn.width + this._buttonDistance;
							this.cancelBtn.y = this.confirmBtn.y;
						} else {
							this.cancelBtn.x = background.x + this.edgeDistance;
							this.cancelBtn.y = background.y + background.height - this.cancelBtn.height - this.edgeDistance;
						}
					}
					break;
				}
				case LAYOUT_CENTER: {
					if (this.confirmBtn != null && this.cancelBtn != null) {
						this.confirmBtn.x = background.x + background.width / 2 - this._buttonDistance / 2 - this.confirmBtn.width;
						this.confirmBtn.y = background.y + background.height - this.edgeDistance - this.confirmBtn.height;
						this.cancelBtn.x = this.confirmBtn.x + this.confirmBtn.width + this._buttonDistance;
						this.cancelBtn.y = this.confirmBtn.y;
					}
					if (this.confirmBtn == null && this.cancelBtn != null) {
						this.cancelBtn.x = background.x + background.width / 2 - this.cancelBtn.width / 2;
						this.cancelBtn.y = background.y + background.height - this.cancelBtn.height - this.edgeDistance;
					}
					if (this.confirmBtn != null && this.cancelBtn == null) {
						this.confirmBtn.x = background.x + background.width / 2 - this.confirmBtn.width / 2;
						this.confirmBtn.y = background.y + background.height - this.confirmBtn.height - this.edgeDistance;
					}
					break;
				}
				case LAYOUT_CUSTOM: {
					break;
				}
				default: {
					break;
					break;
				}
			}
			super.updateDisplayList();
		}
	}
}
