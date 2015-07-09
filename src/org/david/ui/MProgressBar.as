package org.david.ui {
import com.greensock.TweenLite;

import flash.events.MouseEvent;

import org.david.ui.core.MSprite;
import org.david.ui.core.MUIComponent;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Rectangle;

import org.david.ui.event.UIEvent;

public class MProgressBar extends MUIComponent {
    public static var Seek:String = "Seek";
    private var _content:DisplayObject;
    private var contentRect:Rectangle;
    private var maskSprite:Sprite;
    private var _textBlock:MStrokeText;
    private var _container:MSprite;
    private var _thumb:DisplayObject;
    private var _cursor:DisplayObject;
    private var _seek:Boolean;

    public function MProgressBar(contentSkin:DisplayObject, background:DisplayObject = null, thumb:DisplayObject = null, showTxt:Boolean = true, cursor:DisplayObject = null, seek:Boolean = false) {
        super();
        this.background = background;
        _container = new MSprite();
        addChild(_container);

        if (showTxt) {
            _textBlock = new MStrokeText("", 14, 16777215, 100, 4199680);
            _textBlock.x = 45;
            _textBlock.y = 5;
            _container.addChild(_textBlock);
        }

        if (background) {
            contentSkin.x = (background.width - contentSkin.width) / 2;
            contentSkin.y = (background.height - contentSkin.height) / 2;
        }
        if (contentRect == null)
            this.contentRect = new Rectangle(contentSkin.x, contentSkin.y, contentSkin.width, contentSkin.height);
        else
            this.contentRect = contentRect;
        this.content = contentSkin;

        if (thumb) {
            _thumb = thumb;
            addChild(_thumb);
        }

        if (cursor) {
            _cursor = cursor;
            _cursor.y = 4;
            addChild(_cursor);
        }
        _seek = seek;

        if (_seek) {
            addEventListener(MouseEvent.CLICK, onSeek);
            this.buttonMode = true;
            this.useHandCursor = true;
            this.mouseEnabled = true;
            this.mouseChildren = false;
        }
    }

    private function onSeek(e:MouseEvent):void {
        var p:Number = this.mouseX / this.width;
        dispatchEvent(new UIEvent(Seek, p));
        this.setProgress(this.mouseX, this.width);
    }

    protected function get content():DisplayObject {
        return this._content;
    }

    protected function set content(value:DisplayObject):void {
        this._content = value;
        this._content.x = this.contentRect.x;
        this._content.y = this.contentRect.y;
        this.maskSprite = new Sprite();
        this.maskSprite.graphics.beginFill(0, 0);
        this.maskSprite.graphics.drawRect(0, 0, this.contentRect.width, this.contentRect.height);
        this.maskSprite.graphics.endFill();
        this.maskSprite.x = this.contentRect.x;
        this.maskSprite.y = this.contentRect.y;
        this.maskSprite.width = this.contentRect.width;
        this.maskSprite.height = this.contentRect.height;
        _container.addChildAt(this.maskSprite, 0);
        _container.addChildAt(this._content, 0);
        this._content.mask = this.maskSprite;
    }

    public function setProgress(current:Number, total:Number, animation:Boolean = false):void {
        if (_textBlock)
            _textBlock.text = current + "/" + total;
        var value:Number = current / total;
        if (value > 1)
            value = 1;
        if (value < 0)
            value = 0;
        if (this.maskSprite) {
            if (animation)
                TweenLite.to(this.maskSprite, 2 * (1 - value), {width: this.contentRect.width * value});
            else
                this.maskSprite.width = this.contentRect.width * value;

            if (_thumb)
                _thumb.x = this.maskSprite.width;

            if (_cursor) {
                if (value < 1) {
                    _cursor.visible = true;
                    _cursor.x = this.maskSprite.x + this.maskSprite.width;
                } else {
                    _cursor.visible = false;
                }
            }
        }
    }
}
}
