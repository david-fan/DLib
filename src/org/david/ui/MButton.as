package org.david.ui {
import flash.display.DisplayObject;
import flash.events.MouseEvent;

import org.david.ui.core.IToolTipUI;
import org.david.ui.core.MUIComponent;

import flash.display.MovieClip;

/**
 * 基础按钮组件
 */
public class MButton extends MUIComponent implements IToolTipUI {
    public static var NormalOverSelectedOver:int = 0;
    public static var NormalOverSelected:int = 1;
    public static var NormalOver:int = 2;
    public static var NormalSelected:int = 3;
    public static var Normal:int = 4;
    public static var Cust:int = 5;

    protected var _skin:MovieClip;
    protected var _mode:int;

    protected var _currentSkinFrame:int = 1;

    private var _clickCallback:Function;
    private var _overCallback:Function;
    private var _outCallback:Function;

    /**
     *
     * @param skin 皮肤
     * @param mode 模式
     */
    public function MButton(skin:DisplayObject, mode:int = 4, clickCallback:Function = null, overCallback:Function = null, outCallback:Function = null) {
        super(true);
//        this.mouseEnabled = true;
        this.mouseChildren = false;
        this.buttonMode = true;
        _clickCallback = clickCallback;
        _overCallback = overCallback;
        _outCallback = outCallback;
        _mode = mode;
        if (skin) {
            if (skin.parent) {
                skin.parent.addChild(this);
                this.x = skin.x;
                this.y = skin.y;
                skin.x = skin.y = 0;
            }
            if (skin is MovieClip)
                _skin = skin as MovieClip;
            else {
                _skin = new MovieClip();
                _skin.addChild(skin);
            }

            addChild(_skin);
        }
        addEventListener(MouseEvent.ROLL_OVER, onRollOver);
        addEventListener(MouseEvent.ROLL_OUT, onRollOut);
        addEventListener(MouseEvent.CLICK, onClick);
        updateSkin();
    }

    protected var _over:Boolean;

    private function onRollOver(e:MouseEvent):void {
        if (!enable)
            return;
        _over = true;

        updateSkin();

        if (_overCallback)
            _overCallback(e);
    }

    private function onRollOut(e:MouseEvent):void {
        if (!enable)
            return;
        _over = false;

        updateSkin();

        if (_outCallback)
            _outCallback(e);
    }

    private function onClick(e:MouseEvent):void {
        if (!enable)
            return;
        if (_clickCallback)
            _clickCallback(e);
    }

//    private var _enable:Boolean = true;
//    public function set enable(value:Boolean):void {
//        _enable = value;
//
//        if (value) {
//            this.alpha = 1;
//        } else {
//            this.alpha = 0.3;
//        }
//    }
//
//    public function get enable():Boolean {
//        return _enable;
//    }
    override public function set enable(value:Boolean):void {
        super.enable = value;
        if (value) {
            this.alpha = 1;
        } else {
            this.alpha = 0.3;
        }
    }

    protected var _selected:Boolean;
    public function set selected(value:Boolean):void {
        _selected = value;
        updateSkin();
    }

    public function setSkin(frame:int):void {
        _currentSkinFrame = frame;
        if (_skin)
            _skin.gotoAndStop(_currentSkinFrame);
    }

    public function get selected():Boolean {
        return _selected;
    }

    public function updateSkin():void {
        if (!_skin)
            return;
        switch (_mode) {
            case Cust:
                _skin.gotoAndStop(_currentSkinFrame);
                break;
            case Normal:
                _skin.gotoAndStop(1);
                break;
            case  NormalSelected:
                if (_selected)
                    _skin.gotoAndStop(2);
                else
                    _skin.gotoAndStop(1);
                break;
            case NormalOver:
                if (_over)
                    _skin.gotoAndStop(2);
                else
                    _skin.gotoAndStop(1);
                break;
            case NormalOverSelected:
                if (_over)
                    _skin.gotoAndStop(2);
                else if (_selected)
                    _skin.gotoAndStop(3);
                else
                    _skin.gotoAndStop(1);
                break;
            case NormalOverSelectedOver:
                if (_selected) {
                    if (_over)
                        _skin.gotoAndStop(4);
                    else
                        _skin.gotoAndStop(3);
                } else {
                    if (_over)
                        _skin.gotoAndStop(2)
                    else
                        _skin.gotoAndStop(1);
                }
                break;
        }
    }

    // begin for ITollTipUI
    private var _tollTip:Object;

    public function set toolTip(value:Object):void {
        _tollTip = value;
    }

    public function get toolTip():Object {
        return _tollTip;
    }

    private var _toolTipData:Object;

    public function set toolTipData(value:Object):void {
        _toolTipData = value;
    }

    public function get toolTipData():Object {
        return _toolTipData;
    }

    private var _remain:int;

    public function set remain(value:int):void {
        _remain = value;
    }

    public function get remain():int {
        return _remain;
    }

    private var _delay:int;

    public function set delay(value:int):void {
        _delay = value;
    }

    public function get delay():int {
        return _delay;
    }

    // end for ITollTipUI
}
}