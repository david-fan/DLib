/**
 * Created with IntelliJ IDEA.
 * User: david
 * Date: 8/30/13
 * Time: 5:10 PM
 * To change this template use File | Settings | File Templates.
 */
package org.david.ui {
import flash.display.DisplayObject;
import flash.events.MouseEvent;

import org.david.ui.core.IListItem;

import org.david.ui.core.MUIComponent;
import org.david.ui.event.UIEvent;

public class MCombobox extends MUIComponent {
    private var _itemRender:Class;
//    private var _currentItem:DisplayObject;
    private var _listContainer:MTileList;
    private var _showSkin:DisplayObject;
    private var _hideSkin:DisplayObject;

    public function MCombobox(showSkin:DisplayObject, hideSkin:DisplayObject, itemRender:Class) {
        super(true);
        _listContainer = new MTileList(itemRender, 1, int.MAX_VALUE, 0, 0, null);
        _listContainer.addEventListener(UIEvent.ListItemMouseClick, onListItemClick);
        _showSkin = showSkin;
        _hideSkin = hideSkin;
        _showSkin.addEventListener(MouseEvent.CLICK, onCurrentItemClick);
        _hideSkin.addEventListener(MouseEvent.CLICK, onCurrentItemClick);
        _itemRender = itemRender;
        skin = _hideSkin;
//        this.useHandCursor = true;
    }

//    override public function set skin(value:Object):void {
//        super.skin = value;
//        _currentItem = value as DisplayObject;
//    }

    private var _selected:int = 0;

    private var _source:Array;

    public function set source(value:Array):void {
        _source = value;
        if (_source.length > 0) {
            _listContainer.source = _source;
            updateSelected();
        }
    }

    public function get source():Array {
        return _source;
    }

    private function onCurrentItemClick(e:MouseEvent):void {
        if (contains(_listContainer)) {
            skin = _hideSkin;
//            addChild(_hideSkin);
//            removeChild(_showSkin);
            removeChild(_listContainer);
        }
        else {
            skin = _showSkin;
//            addChild(_showSkin);
//            removeChild(_hideSkin);
            addChildXY(_listContainer, 0, _showSkin.height);
        }
    }

    private function updateSelected():void {
        (_showSkin as IListItem).data = _source[_selected];
        (_hideSkin as IListItem).data = _source[_selected];
    }

    private function onListItemClick(e:UIEvent):void {
        _selected = _source.indexOf(e.data.data);
        updateSelected();
        skin = _hideSkin;
//        addChild(_hideSkin);
        removeChild(_listContainer);
        dispatchEvent(new UIEvent(UIEvent.ItemSeleted, e.data.data));
    }

    public function get selected():int {
        return _selected;
    }

    public function set selected(value:int):void {
        _selected = value;
        updateSelected();
    }
    override public function get enable():Boolean{
        return super.enable;
    }
    override public function set enable(value:Boolean):void{
         super.enable=value;
         this.mouseEnabled = value;
         this.mouseChildren = value;
        if(value)
            this.alpha=1;
        else
            this.alpha=0.3;

    }
}
}
