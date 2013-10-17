package org.david.ui {
import flash.geom.Point;

import org.david.ui.core.MUIComponent;
import org.david.ui.event.UIEvent;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;

/**
 * ...
 * @author david
 */
public class MScrollBar extends MUIComponent {
    public static const ValueChange:String = "MScrollBar.ValueChange";
    //
    private var _slide:DisplayObject;
    private var _thumb:MButton;
    private var _value:Number = 0;
    private var _direction:String;
    private var _move:Boolean;
    private var _maxX:int;
    private var _maxY:int;
    //
    private var _progess:DisplayObject;
    private var _progressMask:Sprite;

    public function MScrollBar(slide:DisplayObject, thumb:DisplayObject, direction:String, progress:DisplayObject = null) {
        super(true);
        slide.x = slide.y = 0;
        thumb.x = thumb.y = 0;
        this.background = this._slide = slide;
        this._thumb = new MButton(thumb);
        this._direction = direction;
        this._progess = progress;
        switch (_direction) {
            case MDirection.Horizon:
                _maxX = _slide.width - _thumb.width;
                _maxY = 0;
                _thumb.x = 0;
                var ty:Number = (_slide.height - _thumb.height) / 2;
                _thumb.y = ty;
                break;
            case MDirection.Vertical:
                _maxX = 0;
                _maxY = _slide.height - _thumb.height;
                var tx:Number = ( _slide.width - _thumb.width) / 2;
                _thumb.x = tx;
                _thumb.y = 0;
                break;
        }
        addChild(_slide);
        addEventListener(MouseEvent.CLICK, onSlideClick);
        if (_progess) {
            addChild(_progess);
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
        _value = value;
        switch (_direction) {
            case MDirection.Horizon:
                _thumb.x = _maxX * value;
                if (this._progressMask)
                    this._progressMask.width = this._progess.width * value;
                break;
            case MDirection.Vertical:
                _thumb.y = _maxY * value;
                if (this._progressMask)
                    this._progressMask.height = this._progess.height * value;
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
        _move = false;
    }

    private function onMouseMove(e:MouseEvent):void {
        if (_move) {
//            if (_in3d) {
                switch (_direction) {
                    case MDirection.Horizon:
                        _thumb.x = _slide.globalToLocal(new Point(e.stageX, e.stageY)).x - _thumb.width / 2;
                        if (_thumb.x < 0)
                            _thumb.x = 0;
                        if (_thumb.x > _maxX)
                            _thumb.x = _maxX;
                        _value = _thumb.x / _maxX;
                        if (this._progressMask)
                            this._progressMask.width = this._progess.width * value;
                        break;
                    case MDirection.Vertical:
                        _thumb.y = _slide.globalToLocal(new Point(e.stageX, e.stageY)).y - _thumb.height / 2;
                        if (_thumb.y < 0)
                            _thumb.y = 0;
                        if (_thumb.y > _maxY)
                            _thumb.y = _maxY;
                        _value = _thumb.y / _maxY;
                        if (this._progressMask)
                            this._progressMask.height = this._progess.height * value;
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
            trace(_value);
            dispatchEvent(new UIEvent(ValueChange, _value));
        }
    }

    private function onSlideClick(e:MouseEvent):void {
        switch (_direction) {
            case MDirection.Horizon:
                _thumb.x = this.mouseX - _thumb.width / 2;
                if (_thumb.x < 0)
                    _thumb.x = 0;
                var mx:Number = _slide.width - _thumb.width;
                if (_thumb.x > mx)
                    _thumb.x = mx;
                _value = _thumb.x / _maxX;
                if (this._progressMask)
                    this._progressMask.width = this._progess.width * value;

                break;
            case MDirection.Vertical:
                _thumb.y = this.mouseY - _thumb.height / 2;
                if (_thumb.y < 0)
                    _thumb.y = 0;
                var my:Number = _slide.height - _thumb.height;
                if (_thumb.y > my)
                    _thumb.y = my;
                _value = _thumb.y / _maxY;
                if (this._progressMask)
                    this._progressMask.height = this._progess.height * value;
                break;
        }
        dispatchEvent(new UIEvent(ValueChange, _value));
    }
}
}