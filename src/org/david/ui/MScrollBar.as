package org.david.ui {
import com.greensock.easing.Back;

import org.david.ui.core.MUIComponent;
import org.david.ui.event.UIEvent;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

/**
 * ...
 * @author david
 */
public class MScrollBar extends MUIComponent {
    public static const ValueChange:String = "MScrollBar.ValueChange";
    //
    protected var _slide:DisplayObject;
    protected var _thumb:MButton;
    private var _value:Number = 0;
    private var _direction:String;
    private var _move:Boolean;
    private var _maxX:int;
    private var _maxY:int;
    private var _careThumbSize:Boolean;
    //
    protected var _progess:DisplayObject;
    protected var _progressMask:Sprite;
    private var _immediately:Boolean;

    public function MScrollBar(slide:DisplayObject, thumb:DisplayObject, direction:String, progress:DisplayObject = null, immediately:Boolean = true, careThumbSize:Boolean = true) {
        super(true);
        slide.x = slide.y = 0;
        thumb.x = thumb.y = 0;
        this.background = this._slide = slide;
        this._thumb = new MButton(thumb);
        this._direction = direction;
        this._progess = progress;
        this._immediately = immediately;
        this._careThumbSize = careThumbSize;
        switch (_direction) {
            case MDirection.Horizon:
                if (_careThumbSize)
                    _maxX = _slide.width - _thumb.width;
                else
                    _maxX = _slide.width;
                _maxY = 0;
                _thumb.x = 0;
                var ty:Number = (_slide.height - _thumb.height) / 2;
                _thumb.y = ty;
                break;
            case MDirection.Vertical:
                _maxX = 0;
                if (_careThumbSize)
                    _maxY = _slide.height - _thumb.height;
                else
                    _maxY = _slide.height;
                var tx:Number = ( _slide.width - _thumb.width) / 2;
                _thumb.x = tx;
                _thumb.y = 0;
                break;
        }
        addChild(_slide);
        addEventListener(MouseEvent.CLICK, onSlideClick);
        if (_progess) {
            addChild(_progess);
            _progess.x = _progess.y = 0;
            this._progressMask = new Sprite();
            this._progressMask.graphics.beginFill(0, 0);
            this._progressMask.graphics.drawRect(0, 0, this._progess.width, this._progess.height);
            this._progressMask.graphics.endFill();
            _progess.mask = _progressMask;
            addChild(_progressMask);
        }
        addChild(_thumb);
        value = 0;
    }

    override protected function addedToStageHandler(event:Event):void {
        super.addedToStageHandler(event);
        _thumb.addEventListener(MouseEvent.MOUSE_DOWN, startMove);
        stage.addEventListener(MouseEvent.MOUSE_UP, stopMove);
        stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
    }

    public function get direction():String {
        return _direction;
    }

    public function get value():Number {
        return _value;
    }

    public function set value(value:Number):void {
        if (_move)
            return;
        _value = value;
        switch (_direction) {
            case MDirection.Horizon:
                _thumb.x = _maxX * _value;
                if (this._progressMask)
                    this._progressMask.width = this._progess.width * _value;
                break;
            case MDirection.Vertical:
                _thumb.y = _maxY * _value;
                if (this._progressMask)
                    this._progressMask.height = this._progess.height * _value;
                break;
        }
    }

    private function startMove(e:MouseEvent):void {
        _move = true;
//        if (!_in3d) {
//            switch (_direction) {
//                case MDirection.Horizon:
//                    _thumb.startDrag(false, new Rectangle(0, _thumb.y, _maxX, 0));
//                    break;
//                case MDirection.Vertical:
//                    _thumb.startDrag(false, new Rectangle(_thumb.x, 0, 0, _maxY));
//                    break;
//            }
//        }
    }

    private function stopMove(e:MouseEvent):void {
//        _thumb.stopDrag();
        if (_move == true) {
            _move = false;
            if (!_immediately)
                dispatchEvent(new UIEvent(ValueChange, _value));
        }
    }

    private function onMouseMove(e:MouseEvent):void {
        if (_move) {
//            if (_in3d) {
            switch (_direction) {
                case MDirection.Horizon:
                    if (_careThumbSize)
                        _thumb.x = this.mouseX - _thumb.width / 2;
                    else
                        _thumb.x = this.mouseX;
                    if (_thumb.x < 0)
                        _thumb.x = 0;
                    if (_thumb.x > _maxX)
                        _thumb.x = _maxX;
                    _value = _thumb.x / _maxX;
                    if (this._progressMask)
                        this._progressMask.width = this._progess.width * _value;
                    break;
                case MDirection.Vertical:
                    if (_careThumbSize)
                        _thumb.y = this.mouseY - _thumb.height / 2;
                    else
                        _thumb.y = this.mouseY;
                    if (_thumb.y < 0)
                        _thumb.y = 0;
                    if (_thumb.y > _maxY)
                        _thumb.y = _maxY;
                    _value = _thumb.y / _maxY;
                    if (this._progressMask)
                        this._progressMask.height = this._progess.height * _value;
                    break;
            }
//            } else {
//                switch (_direction) {
//                    case MDirection.Horizon:
//                        _value = _thumb.x / _maxX;
//                        if (this._progressMask)
//                            this._progressMask.width = this._progess.width * value;
//                        break;
//                    case MDirection.Vertical:
//                        _value = _thumb.y / _maxY;
//                        if (this._progressMask)
//                            this._progressMask.height = this._progess.height * value;
//                        break;
//                }
//            }
//            trace(_value);
            if (_immediately)
                dispatchEvent(new UIEvent(ValueChange, _value));
        }
    }

    private function onSlideClick(e:MouseEvent):void {
        switch (_direction) {
            case MDirection.Horizon:
                if (_careThumbSize)
                    _thumb.x = this.mouseX - _thumb.width / 2;
                else
                    _thumb.x = this.mouseX;
                if (_thumb.x < 0)
                    _thumb.x = 0;
                var mx:Number = _slide.width - _thumb.width;
                if (_thumb.x > mx)
                    _thumb.x = mx;
                _value = _thumb.x / _maxX;
                if (this._progressMask)
                    this._progressMask.width = this._progess.width * _value;

                break;
            case MDirection.Vertical:
                    if(_careThumbSize)
                _thumb.y = this.mouseY - _thumb.height / 2;
                    else
                    _thumb.y=this.mouseY;
                if (_thumb.y < 0)
                    _thumb.y = 0;
                var my:Number = _slide.height - _thumb.height;
                if (_thumb.y > my)
                    _thumb.y = my;
                _value = _thumb.y / _maxY;
                if (this._progressMask)
                    this._progressMask.height = this._progess.height * _value;
                break;
        }
        dispatchEvent(new UIEvent(ValueChange, _value));
    }
}
}