package org.david.ui {
import flash.display.DisplayObject;

import org.david.ui.core.MSprite;
	import org.david.ui.core.MUIComponent;
	import org.david.ui.event.UIEvent;

	[Event(name="UIEvent.TabPanelChange", type="org.david.ui.event.UIEvent")]
	/**
	 * 分页标签显示的面板
	 */
	public class MTabPanel extends MUIComponent {
		/**
		 * @param tabBarDirection 标签方向
		 */
		public function MTabPanel(tabBarDirection : String = "horizon") {
			super();
			_contents = new Array();

			this._tabBar = new MTabBar(tabBarDirection);
			this.addEventListener(UIEvent.TAB_CLICK, onTabClick);

			_contentContainer = new MSprite();

			this.addChild(_tabBar);
			this.addChild(_contentContainer);
		}

		/**
		 * 设置标签的位置和间隙
		 */
		public function setTabPosition(x : Number, y : Number, gap : int = 0) : void {
			this._tabBar.x = x;
			this._tabBar.y = y;
			this._tabBar.gap = gap;
		}

		/**
		 * 设置内容对象的位置
		 */
		public function setContentPosition(x : Number, y : Number) : void {
			_contentContainer.x = x;
			_contentContainer.y = y;
		}

		/**
		 * 添加一个标签和对象的内容对象
		 */
		public function addTab(tab : MButton, panel : DisplayObject) : void {
			_tabBar.addTab(tab);
			this._contents.push(panel);
			if (this._contents.length == 1) {
				addToContent(panel);
			}
		}

		private function onTabClick(e : UIEvent) : void {
			updateContent();
		}

		private function updateContent() : void {
			var panel : MSprite = _contents[_tabBar.selectedIndex] as MSprite;
			addToContent(panel);
		}

		private function addToContent(panel : DisplayObject) : void {
			if (_panel != panel) {
				_panel = panel;
				_contentContainer.removeAllChildren();
				_contentContainer.addChild(panel);
				dispatchEvent(new UIEvent(UIEvent.TabPanel_Change));
			}
		}

		/**
		 * 设置被选索引
		 */
		public function set selectedIndex(value : int) : void {
			_tabBar.selectedIndex = value;
			var panel : MSprite = _contents[_tabBar.selectedIndex] as MSprite;
			addToContent(panel);
		}

		/**
		 * 获取被选索引
		 */
		public function get selectedIndex() : int {
			return _tabBar.selectedIndex;
		}

		// public function get tabBar() : MTabBar {
		// return _tabBar;
		// }
		// public function set tabBar(value : MTabBar) : void {
		// _tabBar = value;
		// }
		/**
		 * 当前显示的标签内容
		 */
		public function get panel() : DisplayObject {
			return _panel;
		}

		private var _tabBar : MTabBar;
		private var _contentContainer : MSprite;
		private var _contents : Array;
		private var _panel : DisplayObject;
	}
}