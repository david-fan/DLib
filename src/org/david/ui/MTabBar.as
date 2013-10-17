package org.david.ui {
	import org.david.ui.core.MUIComponent;
	import org.david.ui.event.UIEvent;

	import flash.events.MouseEvent;

	[Event(name="UIEvent.TabClick", type="org.david.ui.event.UIEvent")]
	/**
	 * 自动排列的按钮
	 */
	public class MTabBar extends MUIComponent {
		private var _mBox : MBox;
		private var _index : int = 0;

		/**
		 * @param direction 按钮排列方向 MBox.Horizon/MBox.Vertical
		 */
		public function MTabBar(direction : String, gap : int = 0) {
			this._tabs = new Array();
			this._mBox = new MBox(false, direction, gap, true);
			this.addChild(_mBox);
		}

		/**
		 * 添加一个按钮
		 */
		public function addTab(tab : MButton) : void {
			tab.addEventListener(MouseEvent.CLICK, onClick);
			this._tabs.push(tab);
			if (this._tabs.length == 1) {
				this._currTab = tab;
				tab.selected = true;
			} else {
				tab.selected = false;
			}
			_mBox.addChild(tab);
		}

		/**
		 * 重设按钮间隙
		 */
		public function set gap(value : int) : void {
			_mBox.gap = value;
		}

		private function onClick(e : MouseEvent) : void {
			var _target : MButton = e.target as MButton;

			if (this._currTab == _target) {
				return;
			}
			this._currTab = _target;
			setSelecteds();

			_index = this._tabs.indexOf(_target);
			dispatchEvent(new UIEvent(UIEvent.TAB_CLICK, _index, true, false));
		}

		private function setSelecteds() : void {
			for each (var mTab:MButton in this._tabs) {
				mTab.selected = false;
			}
			this._currTab.selected = true;
		}

		/**
		 * 设置被选按钮索引
		 */
		public function set selectedIndex(value : int) : void {
			_index = value;
			this._currTab = this._tabs[_index];
			setSelecteds();
		}

		/**
		 * 获取被选按钮索引
		 */
		public function get selectedIndex() : int {
			return _index;
		}

		public function get currentTab() : MButton {
			return _currTab;
		}

		private var _currTab : MButton;
		private var _tabs : Array;
	}
}