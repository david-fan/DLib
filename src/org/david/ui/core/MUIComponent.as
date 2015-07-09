package org.david.ui.core {
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import org.david.util.UtilManager;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.events.MouseEvent;

[Event(name="UIEvent.ViewSizeChange", type="org.david.ui.event.UIEvent")]
/**
 * UI组件的基础类
 */
public class MUIComponent extends MSprite {
    private var _enable:Boolean = true;
    private var _background:DisplayObject;
    private var _skin:Object;

    public function get enable():Boolean {
        return _enable;
    }

    public function set enable(value:Boolean):void {
        _enable = value;
    }

    /**
     * 获取组件皮肤
     * @return
     */
    public function get skin():Object {
        return this._skin;
    }

    /**
     * 设置组件皮肤
     * @param value
     */
    public function set skin(value:Object):void {
        this._skin = value;
        if (value is DisplayObject) {
            this.background = value as DisplayObject;
        } else {
            this.background = null;
        }
    }

    /**
     * 获取背景对象
     * @return
     */
    public function get background():DisplayObject {
        return this._background;
    }

    /**
     * 设置组件背景，背景不响应鼠标事件
     * @param value
     */
    public function set background(value:DisplayObject):void {
        if (this._background && this.contains(this._background)) {
            super.removeChild(this._background);
        }
        this._background = value;
        if (this._background) {
            if (this._background is MovieClip) {
                var mc:MovieClip = (this._background as MovieClip);
                mc.gotoAndStop(1);
            }
            super.addChildAt(this._background, 0);
            this._background.cacheAsBitmap = true;
            if (_background is DisplayObjectContainer)
                (_background as DisplayObjectContainer).mouseChildren = false;
        }
        viewChanged();
    }

    /**
     * 组件的宽度，如果有skin/background则返回skin/background的宽度
     */
    override public function get width():Number {
        if (background != null)
            return background.width;
        return super.width;
    }

    /**
     * 组件的高度，如果有skin/background则返回skin/background的高度
     */
    override public function get height():Number {
        if (background != null)
            return background.height;
        return super.height;
    }

    public function MUIComponent(mouseEnabled:Boolean = false) {
        super();
        this.mouseEnabled = mouseEnabled;
        if (mouseEnabled)
            addMouseListener();
    }

    private function addMouseListener():void {
        this.addEventListener(MouseEvent.MOUSE_OVER, this.onMouseOver);
        this.addEventListener(MouseEvent.MOUSE_OUT, this.onMouseOut);
    }

    private var _tipDelayId:int;

    protected function onMouseOver(e:MouseEvent):void {
        var tui:IToolTipUI = this as IToolTipUI;
        if (tui != null) {
            if (tui.delay > 0)
                _tipDelayId = setTimeout(UtilManager.toolTipUtil.show, tui.delay * 1000, this);
            else
                UtilManager.toolTipUtil.show(this);
        }
    }


    protected function onMouseOut(e:MouseEvent):void {
        var tui:IToolTipUI = this as IToolTipUI;
        if (tui != null) {
            if (_tipDelayId > 0)
                clearTimeout(_tipDelayId);
            UtilManager.toolTipUtil.hide();
        }
    }
}
}