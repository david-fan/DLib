/**
 * Created with IntelliJ IDEA.
 * User: zyf
 * Date: 15-5-27
 * Time: 下午2:40
 * To change this template use File | Settings | File Templates.
 */
package org.david.ui {
import flash.display.DisplayObject;
import flash.events.MouseEvent;
import flash.geom.Rectangle;

import org.david.ui.MScrollArea;
import org.david.ui.MScrollBar;
import org.david.ui.MScrollContent;
import org.david.ui.MTileList;
import org.david.ui.core.IListItem;

import org.david.ui.core.MUIComponent;
import org.david.ui.event.UIEvent;

public class MComboxScroll extends MUIComponent {
    private var _itemRender:Class;
    private var _listContainer:MTileList;
    private var _scrollArea:MScrollArea;
    private var _showSkin:DisplayObject;
    private var _hideSkin:DisplayObject;
    private var _selected:int = -1;
    public function MComboxScroll(showSkin:DisplayObject, hideSkin:DisplayObject,itemRender:Class,scrollBar:MScrollBar,rectangle:Rectangle) {
        super(true);
        _listContainer = new MTileList(itemRender, 1, int.MAX_VALUE, 0, 0, null);
        _listContainer.addEventListener(UIEvent.ListItemMouseClick, onListItemClick);
        _scrollArea = new MScrollArea(new MScrollContent(_listContainer),scrollBar,rectangle);
        _showSkin = showSkin;
        _hideSkin = hideSkin;
        _showSkin.addEventListener(MouseEvent.CLICK, onCurrentItemClick);
        _hideSkin.addEventListener(MouseEvent.CLICK, onCurrentItemClick);
        _itemRender = itemRender;
        skin = _hideSkin;
    }
    private function onCurrentItemClick(e:MouseEvent):void {
        if (contains(_scrollArea)) {
            skin = _hideSkin;
            removeChild(_scrollArea);
        }
        else {
            skin = _showSkin;
            addChildXY(_scrollArea, 0, _showSkin.height);
            dispatchEvent(new UIEvent(UIEvent.ListShowClick));
        }
    }
    private function onListItemClick(e:UIEvent):void {
        _selected = _source.indexOf(e.data.data);
        updateSelected();
        skin = _hideSkin;
        removeChild(_scrollArea);
        dispatchEvent(new UIEvent(UIEvent.ItemSeleted, e.data.data));
    }
    public function get selected():int {
        return _selected;
    }

    public function set selected(value:int):void {
        _selected = value;
        updateSelected();
    }
    private function updateSelected():void {
        (_showSkin as IListItem).data = _source[_selected];
        (_hideSkin as IListItem).data = _source[_selected];
    }
    private var _source:Array;
    public function set source(value:Array):void {
        _source = value;
        if (_source.length > 0) {
            _selected=0;
            _listContainer.source = _source;
            updateSelected();
        }
    }

    public function get source():Array {
        return _source;
    }
}
}
