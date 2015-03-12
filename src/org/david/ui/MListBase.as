package org.david.ui {
import org.david.ui.core.IText;
import org.david.ui.core.MUIComponent;

	import flash.events.MouseEvent;

	/**
	 * 数据展示组件，无分页动画效果
	 */
	public class MListBase extends MUIComponent {
		protected var _itemClass : Class;
		protected var _itemHDistance : Number;
		protected var _itemVDistance : Number;
		protected var _cHCount : int = 0;
		protected var _cVCount : int = 0;
		protected var _source : Array;
		protected var _cPage : MTileList;
		protected var _isEmpty : Boolean = false;
		protected var _pageSize : int;
		protected var _totalPage : int;
		protected var _currentPage : int;
		public var _nextBtn : MButton;
		public var _preBtn : MButton;
		public var _pageInfo : IText;
		public var _firstBtn : MButton;
		public var _lastBtn : MButton;

		/**
		 * @param itemClass 实现IListItem的类型，负责每一项数据的展示
		 * @param row 单页行数
		 * @param col 单面列数
		 * @param preBtn 前一面按钮的引用
		 * @param nextBtn 下一面按钮的引用
		 * @param firstBtn 第一面按钮的引用
		 * @param lastBtn 最后一面按钮的引用
		 * @param pageInfo 总页数和当面页显示对象的引用
		 * @param itemHDistance 水平方向的项间距
		 * @param itemVDistance 垂直方向的项间距
		 */
		public function MListBase(itemClass : Class, row : int, col : int, preBtn : MButton, nextBtn : MButton, pageInfo : IText = null, firstBtn : MButton = null, lastBtn : MButton = null, itemHDistance : Number = 0, itemVDistance : Number = 0) {
			super(false);
			this._itemClass = itemClass;
			this._itemVDistance = itemVDistance;
			this._itemHDistance = itemHDistance;
			this._cHCount = col;
			this._cVCount = row;
			this._pageSize = _cHCount * _cVCount;
			this._nextBtn = nextBtn;
			this._preBtn = preBtn;
			this._pageInfo = pageInfo;
			this._firstBtn = firstBtn;
			this._lastBtn = lastBtn;

			nextBtn.addEventListener(MouseEvent.CLICK, onNextPage);
			preBtn.addEventListener(MouseEvent.CLICK, onPrePage);
			if (firstBtn != null) {
				firstBtn.addEventListener(MouseEvent.CLICK, onFirstPage);
			}
			if (lastBtn != null) {
				lastBtn.addEventListener(MouseEvent.CLICK, onLastPage);
			}
		}

		protected function onNextPage(e : MouseEvent) : void {
			nextPage();
		}

		protected function onPrePage(e : MouseEvent) : void {
			prePage();
		}

		protected function onFirstPage(e : MouseEvent) : void {
			firstPage();
		}

		protected function onLastPage(e : MouseEvent) : void {
			lastPage();
		}

		protected function updatePage() : void {
			if (_cPage == null) {
				_cPage = new MTileList(this._itemClass, this._cHCount, this._cVCount, this._itemHDistance, this._itemVDistance);
				addChild(_cPage);
			}
			_cPage.source = getPageSource(_currentPage);
			viewChanged();
		}

		private function _updatePageInfoAndBtns() : void {
			_preBtn.enable = true;
			_nextBtn.enable = true;
			if (_firstBtn)
				_firstBtn.enable = true;
			if (_lastBtn)
				_lastBtn.enable = true;
			if (_currentPage == 0) {
				if (_firstBtn)
					_firstBtn.enable = false;
				_preBtn.enable = false;
			}
			if (_currentPage >= _totalPage - 1) {
				if (_lastBtn)
					_lastBtn.enable = false;
				_nextBtn.enable = false;
			}
			if (_pageInfo)
				_pageInfo.text = (_currentPage + 1) + " / " + (_totalPage == 0 ? 1 : _totalPage);
		}

		/**
		 * 更新页面与按钮状态
		 */
		public function updatePageInfoAndBtns() : void {
			viewChanged();
		}

		/**
		 * 设置数据源
		 */
		public function setSource(val : Array) : void {
			if (val == null)
				this._source = [];
			else
				this._source = val.concat();
			var rc : int = _source.length;
			_totalPage = int(rc / _pageSize) + (rc % _pageSize == 0 ? 0 : 1);
			if (_currentPage >= (_totalPage - 1))
				_currentPage = 0;

			updatePage();
		}

		protected function nextPage() : void {
			if (_currentPage < _totalPage - 1) {
				_currentPage++;
				updatePage();
			}
		}

		protected function prePage() : void {
			if (_currentPage > 0) {
				_currentPage--;
				updatePage();
			}
		}

		protected function lastPage() : void {
			if (_currentPage < _totalPage - 1) {
				_currentPage = _totalPage - 1;
				updatePage();
			}
		}

		protected function firstPage() : void {
			if (_currentPage > 0) {
				_currentPage = 0;
				updatePage();
			}
		}

		protected function getPageSource(page : int) : Array {
			var temp : Array = new Array();
			var index : int = page * _pageSize;
			for (var i : int = 0;i < _pageSize;i++) {
				var data : Object = _source[index + i];
				if (data)
					temp.push(data);
				else if (_isEmpty)
					temp.push(new Object());
			}
			return temp;
		}

		/**
		 * 获取当前页面的数据展示对象(IListItem)的集合
		 */
		public function get items() : Array {
			if (_cPage == null) {
				return null;
			}
			return _cPage.items;
		}

		override protected function updateDisplayList() : void {
			_updatePageInfoAndBtns();
			super.updateDisplayList();
		}
	}
}