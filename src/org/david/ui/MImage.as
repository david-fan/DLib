package org.david.ui {
import org.david.ui.core.IToolTipUI;
import org.david.ui.core.MSprite;
import org.david.ui.event.UIEvent;
import org.david.util.FilterUtil;
import org.david.util.UtilManager;

import flash.display.DisplayObject;
import flash.display.Loader;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.net.URLRequest;

/**
 * 图片显示对象
 */
public class MImage extends MSprite implements IToolTipUI {
    //
    public static const LOAD_COMPLETE_EVENT:String = "loadCompleteEvent";
    public static const CLIP:String = "clip";
    public static const SCALE:String = "scale";
    public static const AUTO:String = "auto";
    //
    protected var _source:Object;
    protected var _loader:Loader;
    protected var _wait:DisplayObject;
    private var _sizeType:String = "auto";
    private var _width:Number = 50;
    private var _height:Number = 50;

    /**
     * @param source 源可以是图片地址，或者显示对象
     * @param sizeType 尺寸处理方式 可选MImage.CLIP/SCALE/AUTO
     */
    public function MImage(source:Object = null, sizeType:String = "auto") {
        super();
        this.source = source;
        this.sizeType = sizeType;
        addMouseListener();
    }

    override public function destroy():void {
        super.destroy();
        if (_loader) {
            try {
                _loader.unloadAndStop();
            } catch (e:Error) {
                trace("can't unloadAndStop a MImage's loader!");
            }
            _loader = null;
        }
    }

    public function set wait(value:DisplayObject):void {
        _wait = value;
    }

    // public function setImagePosition(x : Number, y : Number) : void {
    // imageX = x;
    // imageY = y;
    // }
    private function addMouseListener():void {
        this.addEventListener(MouseEvent.ROLL_OVER, this.onMouseOver);
        this.addEventListener(MouseEvent.ROLL_OUT, this.onMouseOut);
    }

    protected function onMouseOver(e:MouseEvent):void {
        if (toolTip != null)
            UtilManager.toolTipUtil.show(this);
    }

    protected function onMouseOut(e:MouseEvent):void {
        if (toolTip != null)
            UtilManager.toolTipUtil.hide();
    }

    public function get source():Object {
        return this._source;
    }

    private var _image:DisplayObject;

    /**
     * 设置真实的显示对象
     */
    protected function set image(value:DisplayObject):void {
        if (_image != null && contains(_image))
            removeChild(_image);
        _image = value;
        if (_image != null) {
            addChild(_image);
            setSize();
        }
    }

    /**
     * 获取真实的显示对象(Loader.content)
     */
    protected function get image():DisplayObject {
        return _image;
    }

    /**
     * 源,可以是图片地址，或者显示对象
     */
    public function set source(value:Object):void {
        if (_source == value)
            return;
        times=0;
        _source = value;
        image = value as DisplayObject;
        if (value is String && value != "")
            loadImg();
    }

    private function loadImg():void {
        if (this._loader == null) {
            this._loader = new Loader();
            this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.onLoadCompletedHandler);
            this._loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.onIoError);
        }
        this._loader.load(new URLRequest(_source as String));
        this.showWait();
    }

//		override protected function updateDisplayList() : void {
//			if (this._source is String && this._source != "") {
//				this.showWait();
//				 if (this._loader == null) {
//				 this._loader = new Loader();
//				 this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.onLoadCompletedHandler);
//				 this._loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.onIoError);
//				 }
//				 this._loader.load(new URLRequest(_source as String));
//			} else {
//				setSize();
//				this.hideWait();
//			}
//		}


    override protected function updateDisplayList():void {
        _wait.x = (width - _wait.width) / 2;
        _wait.y = (height - _wait.height) / 2;
        setSize();
        super.updateDisplayList();
    }

    protected function showWait():void {
        if (_wait != null) {
            addChild(_wait);
        }
    }

    protected function hideWait():void {
        if (_wait != null && contains(_wait)) {
            removeChild(_wait);
            _wait = null;
        }
    }

    protected function onLoadCompletedHandler(event:Event):void {
        this.image = this._loader;
        super.updateDisplayList();
        //
        hideWait();
        this.dispatchEvent(new UIEvent(MImage.LOAD_COMPLETE_EVENT));
    }
    private var times:int=0;
    protected function onIoError(event:IOErrorEvent):void {
        trace("not load image:" + this.source);
        if(times<3)
            loadImg();
        times++;
        return;

    }

    private function setSize():void {
        if (this.image == null)
            return;
        switch (this.sizeType) {
            case CLIP:
            {
                this.image.scaleY = 1;
                this.image.scaleX = 1;
                this.image.scrollRect = new Rectangle(0, 0, this.width, this.height);
                break;
            }
            case SCALE:
            {
                this.image.scrollRect = null;
                this.image.width = this.width;
                this.image.height = this.height;
                break;
            }
            case AUTO:
            {
                this.image.scaleY = 1;
                this.image.scaleX = 1;
                this.image.scrollRect = null;
                break;
            }
        }
    }

    public function get sizeType():String {
        return this._sizeType;
    }

    public function set sizeType(value:String):void {
        this._sizeType = value;
        this.setSize();
    }

    override public function set width(value:Number):void {
        this._width = value;
        this.setSize();
    }

    override public function get width():Number {
        if (this.sizeType == AUTO && this._image != null) {
            return this._image.width;
        }
        return this._width;
    }

    override public function set height(value:Number):void {
        this._height = value;
        this.setSize();
    }

    override public function get height():Number {
        if (this.sizeType == AUTO && this._image != null) {
            return this._image.height;
        }
        return this._height;
    }

    private var _enable:Boolean = true;

    public function get enable():Boolean {
        return _enable;
    }

    public function set enable(value:Boolean):void {
        mouseEnabled = value;
        mouseChildren = value;
        if (value)
            this.filters = null;
        else
            this.filters = [FilterUtil.getBlackWhiteMatrixData()];
        _enable = value;
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