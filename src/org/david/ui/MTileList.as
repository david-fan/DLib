package org.david.ui {
import org.david.ui.core.IListItem;
import org.david.ui.core.ISelectable;
import org.david.ui.core.MUIComponent;
import org.david.ui.event.UIEvent;

import flash.display.DisplayObject;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;

/**
 * 单页数据源展示组件
 */
public class MTileList extends MUIComponent {
    private var _itemClass:Class;
    private var _itemHDistance:Number = 0;
    private var _itemVDistance:Number = 0;
    private var _cHCount:int;
    private var _cVCount:int;
    private var _source:Array;
    private var _items:Array;
    private var _olditems:Array;
    private var _currentItem:ISelectable;

    /**
     * @param itemClass 实现IListItem的类型，负责每一项数据的展示
     * @param row 单页行数
     * @param col 单面列数
     * @param columnDistance 水平方向的项间距
     * @param rowDistance 垂直方向的项间距
     * @param source 数据源
     */
    public function MTileList(itemClass:Class, column:int, row:int, columnDistance:Number = 10, rowDistance:Number = 10, source:Array = null) {
        super();
        if (column <= 0 || row <= 0) {
            return;
        }

        this._itemClass = itemClass;
        this._cHCount = column;
        this._cVCount = row;
        this._itemHDistance = columnDistance;
        this._itemVDistance = rowDistance;
        if (source)
            this.source = source;
    }

    /**
     * 重设数据源
     */
    public function set source(value:Array):void {
        _olditems = _items;
        _items = new Array();
        removeAllChildren(true);
        _source = value||[];
        for (var row:int = 0; row < this._cVCount; row++) {
            for (var col:int = 0; col < this._cHCount; col++) {
                var index:int = row * _cHCount + col;
                if (index < this._source.length) {
                    var item:DisplayObject = new _itemClass();
//                    var ed:EventDispatcher = item as EventDispatcher;
                    item.addEventListener(MouseEvent.MOUSE_DOWN, function (e:MouseEvent):void {
                        var target:EventDispatcher = e.currentTarget as EventDispatcher;
                        target.dispatchEvent(new UIEvent(UIEvent.ListItemMouseDown, target, true));
                    });
                    item.addEventListener(MouseEvent.MOUSE_UP, function (e:MouseEvent):void {
                        var target:EventDispatcher = e.currentTarget as EventDispatcher;
                        target.dispatchEvent(new UIEvent(UIEvent.ListItemMouseUp, target, true));
                    });
                    item.addEventListener(MouseEvent.CLICK, function (e:MouseEvent):void {
                        var target:EventDispatcher = e.currentTarget as EventDispatcher;
                        target.dispatchEvent(new UIEvent(UIEvent.ListItemMouseClick, target, true));
                        if (target is ISelectable) {
                            if (_currentItem)
                                _currentItem.selected = false;
                            _currentItem = target as ISelectable;
                            _currentItem.selected = true;
                        }
                    });
                    // ListSource.getItemRender(_itemClass, this._source[index]) as DisplayObject;
                    item.x = col * (item.width + this._itemHDistance);
                    item.y = row * ( item.height + this._itemVDistance);
                    this.addChild(item);
                    (item as IListItem).data = _source[index];
                    _items.push(item);
                } else {
                    viewChanged();
                    return;
                }
            }
        }
        viewChanged();
    }

    public function get source():Array {
        return _source;
    }

    public function get items():Array {
        return _items;
    }

    public function get selectedItem():ISelectable {
        return _currentItem;
    }

    public function set selectedItem(value:ISelectable):void {
        _currentItem = value;
    }
}
}