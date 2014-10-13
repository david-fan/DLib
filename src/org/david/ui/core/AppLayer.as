package org.david.ui.core {
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

import org.david.util.LogUtil;

/**
 * 显示对象分层
 * */
public class AppLayer {
    public static var Resize:String = "AppLayer.Resize";

    public static var MouseLayer:MSprite = new MSprite();
    public static var TooltipLayer:MSprite = new MSprite();
    public static var PopupLayer:MSprite = new MSprite();
    public static var GameGuidLayer:MSprite = new MSprite();
    public static var UILayer:MSprite = new MSprite();
    public static var SceneLayer:MSprite = new MSprite();
    public static var Main:Sprite;
    public static var AppWidth:Number = 760;
    public static var AppHeight:Number = 580;

    public static var dispatch:EventDispatcher;

    public static function init(main:Sprite):void {
        Main = main;
        Main.addChild(SceneLayer);
        Main.addChild(UILayer);
        Main.addChild(GameGuidLayer);
        Main.addChild(PopupLayer);
        Main.addChild(TooltipLayer);
        Main.addChild(MouseLayer);

        dispatch = new EventDispatcher();
        AppWidth = Main.stage.stageWidth;
        AppHeight = Main.stage.stageHeight;
        Main.stage.addEventListener(Event.RESIZE, onResize);

        Main.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
    }

    private static function onKeyDown(e:KeyboardEvent):void {
        if (e.ctrlKey && e.altKey && (e.keyCode == Keyboard.D)) {
            LogUtil.showOrHideLog(Main);
        }
    }

    private static function onResize(e:Event):void {
        AppLayer.AppWidth = Main.stage.stageWidth;
        AppLayer.AppHeight = Main.stage.stageHeight;
        dispatch.dispatchEvent(new Event(Resize));
    }

    public static function removeLayers(layers:Array):void {
        for each (var layer:MSprite in layers) {
            if (Main.contains(layer))
                Main.removeChild(layer);
        }
    }

    public static function addLayers2Bottom(layers:Array):void {
        for each (var layer:MSprite in layers) {
            Main.addChildAt(layer, 0);
        }
    }

    private static var _sceneLayerBitmap:Bitmap;

    public static function showSceneLayer():void {
        removeBitmap();
        Main.addChildAt(SceneLayer, 0);
    }

    private static function removeBitmap():void {
        if (_sceneLayerBitmap != null) {
            if (Main.contains(_sceneLayerBitmap))
                Main.removeChild(_sceneLayerBitmap);
        }
    }

    public static function hideSceneLayer(capture:Boolean = true):void {
        if (capture) {
            var captureBD:BitmapData = new BitmapData(AppLayer.AppWidth, AppLayer.AppHeight, true, 0);
            captureBD.draw(AppLayer.SceneLayer);
            removeBitmap();
            _sceneLayerBitmap = new Bitmap(captureBD);
            Main.addChildAt(_sceneLayerBitmap, 0);
            if (Main.contains(SceneLayer)) {
                Main.removeChild(SceneLayer);
            }
        }
    }
}
}