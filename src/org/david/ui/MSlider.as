package org.david.ui {
import org.david.ui.core.MSprite;
import org.david.ui.core.MUIComponent;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;

public class MSlider extends MUIComponent {
    private var _thumb:MSprite;
    private var _lBtn:MButton;
    private var _rBtn:MButton;
    private var _max:Number;
    private var _min:Number;
    private var _step:Number;
    /**
     * 当前值
     **/
    private var _currentValue:Number = 0;
    // 当前拖动按钮所在位置的比例值
    public var _value:Number = 0;
    // 当前拖动按钮所在位置的真实值
    private var _difference:Number = 0;
    private var _btnDif:int = 15;
    private var pStep:int;
    private var stepValue:Number;

    public function MSlider(track:DisplayObject, thumb:DisplayObject, step:Number, min:Number, max:Number, left:DisplayObject = null, right:DisplayObject = null, mouseEnabled:Boolean = true) {
        super(mouseEnabled);
        this.background = track;
        _thumb = new MSprite();
        _thumb.addChild(thumb);
        addChild(_thumb);
        _thumb.buttonMode = true;
        _thumb.mouseEnabled = mouseEnabled;
        _min = min;
        _max = max;
        _difference = _max - _min;
        _step = step;
        pStep = (_difference / _step );
        // 有多少个_step单位
        stepValue = background.width / pStep;
        if (left && right) {
            _lBtn = new MButton(left);
            _rBtn = new MButton(right);
            addChild(_lBtn);
            addChild(_rBtn);
            _lBtn.x = -_btnDif;
            _rBtn.x = background.width + _btnDif;
            _lBtn.addEventListener(MouseEvent.CLICK, onLClick);
            _rBtn.addEventListener(MouseEvent.CLICK, onRClick);
        }
        this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    private function onLClick(e:MouseEvent):void {
        setPoint();
        if (_value > _min) {
            _currentValue -= _step;
            setValue();
        }
    }

    private function onRClick(e:MouseEvent):void {
        setPoint();
        if (_value < _max) {
            _currentValue += _step;
            setValue();
        }
    }

    private function onAddedToStage(e:Event):void {
        _thumb.buttonMode = true;
        _thumb.addEventListener(MouseEvent.MOUSE_DOWN, onDargDown);
        stage.addEventListener(MouseEvent.MOUSE_UP, onDargUp);
    }

    private function onDargDown(e:MouseEvent):void {
        _thumb.startDrag(false, new Rectangle(background.x, 0, background.width, 0));
    }

    private function onDargUp(e:MouseEvent):void {
        _thumb.stopDrag();
        setPoint();
        setValue();
    }

    private function setPoint():void {
        _currentValue = Math.round(_thumb.x / stepValue);
        _value = _currentValue + _min;
    }

    private function setValue():void {
        _thumb.x = stepValue * _currentValue;
        this.dispatchEvent(new Event("value_change"));
        trace("currentValue:" + _currentValue, "value:" + _value, "x:" + _thumb.x);
    }
}
}