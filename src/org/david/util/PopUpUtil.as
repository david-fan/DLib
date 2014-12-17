package org.david.util {
import flash.display.DisplayObjectContainer;
import flash.events.Event;

import org.david.ui.event.UIEvent;

import com.greensock.TweenLite;

import org.david.ui.core.AppLayer;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.EventDispatcher;
import flash.utils.Dictionary;

/**
 * 弹出窗口工具类
 */
public class PopUpUtil extends EventDispatcher {
    // private var _parent : DisplayObjectContainer;
    protected var windowModalDic:Dictionary;
    protected var windowCenterDic:Dictionary;
    protected var windowPriorityDic:Dictionary;
    private var windowList:Array;

    public function PopUpUtil() {
        this.windowList = [];
        AppLayer.dispatch.addEventListener(AppLayer.Resize, resizeHandler);
    }

    private function getModalSprite():Sprite {
        var modalSprite:Sprite = new Sprite();
        modalSprite.graphics.beginFill(0, 0.5);
        modalSprite.graphics.drawRect(0, 0, AppLayer.AppWidth, AppLayer.AppHeight);
        modalSprite.graphics.endFill();
        return modalSprite;
    }

    private function resizeHandler(e:Event):void {
        for each (var wo:WindowObj in this.windowList) {
            if (wo.center == true) {
                var obj:DisplayObject = wo.obj as DisplayObject;
                obj.x = (AppLayer.AppWidth - obj.width) / 2;
                obj.y = (AppLayer.AppHeight - obj.height) / 2;
            }
        }

    }

    /**
     * 弹出一个显示对象
     * @param displayobj 显示对象
     * @param modal 是否模式窗口，阻止其它UI操作
     * @param center 是否居中显示
     * @param priority 优先级，大的优先
     * @param animation 动画显示弹出窗口
     */
    public function addPopUp(displayobj:DisplayObject, modal:Boolean = false, center:Boolean = true, priority:int = 1, animation:Boolean = false, hideScene:Boolean = false):void {
        displayobj.visible = false;
        var wo:WindowObj = new WindowObj();
        if (modal) {
            wo.modal = getModalSprite();
        }
        wo.hideScene = hideScene;
        wo.center = center;
        wo.priority = priority;
        wo.obj = displayobj;
        wo.animation = animation;
        this.windowList.push(wo);
        this.windowList.sortOn("priority", Array.NUMERIC);

        if (this.windowList[this.windowList.length - 1].obj === displayobj) {
            this._addPopUp(wo);
            var e:UIEvent = new UIEvent(UIEvent.POP_UP_OPEN, displayobj);
            dispatchEvent(e);
        }
    }

    public function createPopUp(displayclass:Class, modal:Boolean = false, center:Boolean = true, priority:int = 1):DisplayObject {
        var displayobj:DisplayObject = new displayclass() as DisplayObject;
        if (displayobj == null) {
            throw new Error("must be DisplayObject!");
        }
        this.addPopUp(displayobj, modal, center, priority);
        return displayobj;
    }

    private function _addPopUp(wo:WindowObj):void {
        if (wo.obj.visible)
            return;
        if (wo.modal) {
            AppLayer.PopupLayer.addChild(wo.modal);
        }
        if (wo.hideScene)
            AppLayer.hideSceneLayer();
        this.addPopUpToStage(wo.obj, wo.center, wo.animation);
    }

    protected function addPopUpToStage(displayobj:DisplayObject, center:Boolean, animation:Boolean):void {
        displayobj.visible = true;
        var px:Number;
        var py:Number;

        AppLayer.PopupLayer.addChild(displayobj);
        if (center) {
            px = (AppLayer.AppWidth - displayobj.width) / 2;
            py = (AppLayer.AppHeight - displayobj.height) / 2;
            if (false) {
                var scale:Number = 0.2;
                displayobj.x = (AppLayer.AppWidth - displayobj.width * scale) / 2;
                displayobj.y = (AppLayer.AppHeight - displayobj.height * scale) / 2;
                displayobj.scaleX = scale;
                displayobj.scaleY = scale;
                TweenLite.to(displayobj, 0.5, {x: px, y: py, scaleX: 1, scaleY: 1, onComplete: this.popUpComplete});
            } else {
                displayobj.x = px;
                displayobj.y = py;
            }
        }
    }

    private function popUpComplete():void {
        var e:UIEvent = new UIEvent(UIEvent.POP_UP_COMPLETE);
        dispatchEvent(e);
    }

    public function removePopUp(displayobj:DisplayObject):void {
        if (displayobj) {
            this.removePopUpToStage(displayobj);
        }
        for each (var wo:WindowObj in windowList) {
            if (wo.obj === displayobj) {
                this.windowList.splice(windowList.indexOf(wo), 1);
                if (wo.modal) {
                    if (AppLayer.PopupLayer.contains(wo.modal)) {
                        AppLayer.PopupLayer.removeChild(wo.modal);
                    }
                }
                if (wo.hideScene)
                    AppLayer.showSceneLayer();
                break;
            }
        }
        var e:UIEvent = new UIEvent(UIEvent.POP_UP_CLOSE, displayobj);
        dispatchEvent(e);
        if (this.windowList.length > 0) {
            this._addPopUp(this.windowList[(this.windowList.length - 1)]);
        }
    }

    protected function removePopUpToStage(displayobj:DisplayObject):void {
        if (AppLayer.PopupLayer.contains(displayobj))
            AppLayer.PopupLayer.removeChild(displayobj);
    }
}
}
