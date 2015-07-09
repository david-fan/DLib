package org.david.ui {
	import com.greensock.TweenLite;

import org.david.ui.core.IText;

import org.david.ui.core.MSprite;

	import flash.display.DisplayObject;
	import flash.display.Sprite;

	/**
	 * 数据展示组件，有动画动画效果
	 */
	public class MScrollList extends MListBase {
		// for model 1
		protected var _pags : Array = new Array();
		protected var _scrollContainer : MSprite;
		protected var _mask : Sprite;
		private var _pageW : int;
		private var _pageH : int;
		private var _nPage : MTileList;
		//
		private var _currentTweenlite : TweenLite;

		/**
		 * @param itemClass 实现IListItem的类型，负责每一项数据的展示
		 * @param row 单页行数
		 * @param col 单面列数
		 * @param preBtn 前一面按钮的引用
		 * @param nextBtn 下一面按钮的引用
		 * @param pageInfo 总页数和当面页显示对象的引用
		 * @param itemHDistance 水平方向的项间距
		 * @param itemVDistance 垂直方向的项间距
		 * @param renderWhole 是否整体渲染
		 */
		public function MScrollList(itemClass : Class, row : int, col : int, preBtn : MButton, nextBtn : MButton, pageInfo : IText = null, itemHDistance : Number = 0, itemVDistance : Number = 0) {
			super(itemClass, row, col, preBtn, nextBtn, pageInfo, null, null, itemHDistance, itemVDistance);
			_scrollContainer = new MSprite();
			this.addChild(_scrollContainer);
			//
			var item : DisplayObject = new _itemClass();
			_pageW = _cHCount * (item.width + _itemHDistance) - _itemHDistance + 2;
			_pageH = _cVCount * (item.height + _itemVDistance) - _itemVDistance + 2;
			_mask = new Sprite();
			_mask.graphics.beginFill(0xffffff);
			_mask.graphics.drawRect(0, 0, _pageW, _pageH);
			_mask.graphics.endFill();
			_mask.alpha = 0.6;
			this.mask = _mask;
			this.addChild(_mask);
		}

		override protected function updatePage() : void {
			_scrollContainer.removeAllChildren(true);
			super.updatePage();
			// remove from this,and add to _scrollContainer
			_scrollContainer.addChild(_cPage);
			_scrollContainer.x = 0;
		}

		private function buildPage(index : int) : MTileList {
			var page : MTileList = new MTileList(_itemClass, _cHCount, _cVCount, _itemHDistance, _itemVDistance);
			_scrollContainer.addChild(page);
			page.source = getPageSource(index);
			return page;
		}

		override public function get width() : Number {
			return _pageW;
		}

		override public function get height() : Number {
			return _pageH;
		}

		override protected function prePage() : void {
			if (_currentTweenlite && _currentTweenlite.active)
				return;
			if (_currentPage > 0) {
				_currentPage--;
				_nPage = buildPage(_currentPage);
				_scrollContainer.addChildXY(_nPage, -_pageW);
				_currentTweenlite = TweenLite.to(_scrollContainer, 0.5, {x:_pageW, onComplete:finish});
				updatePageInfoAndBtns();
			}
		}

		private function finish() : void {
			_scrollContainer.removeChild(_cPage);
			_nPage.x = 0;
			_cPage = _nPage;
			_scrollContainer.x = 0;
			_nPage = null;
		}

		override protected function nextPage() : void {
			if (_currentTweenlite && _currentTweenlite.active)
				return;
			if (_currentPage < _totalPage - 1) {
				_currentPage++;
				_nPage = buildPage(_currentPage);
				_scrollContainer.addChildXY(_nPage, _pageW);
				_currentTweenlite = TweenLite.to(_scrollContainer, 0.5, {x:-_pageW, onComplete:finish});
				updatePageInfoAndBtns();
			}
		}
	}
}