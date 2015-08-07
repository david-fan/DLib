package org.david.ui {
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

import org.david.ui.core.MUIComponent;
import org.david.ui.event.UIEvent;
import org.david.util.LogUtil;

/**
 * ...
 * @author david
 */
public class MScrollProgress extends MUIComponent {
    public static const ValueChange:String = "MScrollBar.ValueChange";
    //
    protected var _slide:DisplayObject;
    protected var _slidemask:Sprite;
    protected var _thumb:MButton;
    private var _value:Number = 0;
    private var _direction:String;
    private var _move:Boolean;
    protected var _maxX:int;
    protected var _maxY:int;
    private var _careThumbSize:Boolean;
    //
    protected var _progress:DisplayObject;
    protected var _progressMask:Sprite;


    private var _immediately:Boolean;

    public function MScrollProgress(slide:DisplayObject, thumb:DisplayObject, direction:String, progress:DisplayObject, background:DisplayObject, immediately:Boolean = true, careThumbSize:Boolean = true) {
        super(true);
        background.x = background.y = 0;
        this.background = background;
        this._direction = direction;
        this._progress = progress;
        this._immediately = immediately;
        this._careThumbSize = careThumbSize;

        thumb.x = thumb.y = 0;
        this._thumb = new MButton(thumb);


        slide.x = slide.y = 0;
        this._slide = slide;

        this._slidemask = new Sprite();
        this._slidemask.graphics.beginFill(0, 0);
        this._slidemask.graphics.drawRect(0, 0, this._slide.width, this._slide.height);
        this._slidemask.graphics.endFill();
        _slide.mask = _slidemask;

        init();
        addEventListener(MouseEvent.CLICK, onSlideClick);

        addChild(_progress);
        _progress.x = _progress.y = 0;
        this._progressMask = new Sprite();
        this._progressMask.graphics.beginFill(0, 0);
        this._progressMask.graphics.drawRect(0, 0, this._progress.width, this._progress.height);
        this._progressMask.graphics.endFill();
        _progress.mask = _progressMask;
        addChild(_progressMask);
        value = 0;
        addChild(_slide);
        addChild(_slidemask);
        addChild(_thumb);
    }

    private function init():void {
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
        updateByValue();
    }

    private function updateByValue():void {
        switch (_direction) {
            case MDirection.Horizon:
                _thumb.x = _maxX * _value;
                //this._progressMask.width = this._progress.width * _value;
                this._slidemask.width = this._slide.width * _value;
                break;
            case MDirection.Vertical:
                _thumb.y = _maxY * _value;
//                this._progressMask.height = this._progress.height * _value;
                this._slidemask.height = this._slide.height * _value;
                break;
        }
    }


    private function startMove(e:MouseEvent):void {
        _move = true;
    }

    private function stopMove(e:MouseEvent):void {
        if (_move == true) {
            _move = false;
            if (!_immediately)
                dispatchEvent(new UIEvent(ValueChange, _value));
        }
    }

    private function onMouseMove(e:MouseEvent):void {
        if (_move) {
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
                    this._slidemask.width = this._slide.width * _value;
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
                    this._slidemask.height = this._slide.height * _value;
                    break;
            }
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
                this._slidemask.width = this._slide.width * _value;
                break;
            case MDirection.Vertical:
                if (_careThumbSize)
                    _thumb.y = this.mouseY - _thumb.height / 2;
                else
                    _thumb.y = this.mouseY;
                if (_thumb.y < 0)
                    _thumb.y = 0;
                var my:Number = _slide.height - _thumb.height;
                if (_thumb.y > my)
                    _thumb.y = my;
                _value = _thumb.y / _maxY;
                this._slidemask.height = this._slide.height * _value;
                break;
        }
        dispatchEvent(new UIEvent(ValueChange, _value));
    }

    override public function set width(value:Number):void {
        background.width = value;
        _slide.width = value;
        _progress.width = value;
        init();
        updateByValue();
    }

    public function updateProgress(value:Number):void {

        switch (_direction) {
            case MDirection.Horizon:
                this._progressMask.width = this._progress.width * value;
                break;
            case MDirection.Vertical:
                this._progressMask.height = this._progress.height * value;
                break;
        }
    }

    override public function set height(value:Number):void {
        background.height = value;
        _slide.height = value;
        _progress.height = value;
        init();
        updateByValue();
    }
}
}