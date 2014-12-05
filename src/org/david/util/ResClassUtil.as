package org.david.util {
import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.MovieClip;
import flash.events.Event;
import flash.system.ApplicationDomain;
import flash.utils.Dictionary;

public class ResClassUtil {
    private static var _domain:ApplicationDomain;

    public function ResClassUtil() {
    }

    public static function getClassByName(className:String):Class {
        var dc:Class = _domain.getDefinition(className) as Class;
        return dc;
    }

    public static function getCommonDisplayObjectByName(className:String):DisplayObject {
        var dc:Class = _domain.getDefinition(className) as Class;
        return new dc();
    }

    public static function getMovieClipByName(className:String):MovieClip {
        var dc:Class = _domain.getDefinition(className) as Class;
        return new dc();
    }

    public static function init(domain:ApplicationDomain):void {
        _domain = domain;
    }

    // public static function getMovieClip(domain : ApplicationDomain, className : String) : MovieClip {
    // var dc : Class = _domain.getDefinition("MainRes_" + className) as Class;
    // var mc : MovieClip = new dc() as MovieClip;
    // mc.stop();
    // return mc;
    // }
//		public static function getMovieClipByName(className : String, setCallback : Function) : void {
//			var dc : Class = _domain.getDefinition("MainRes_" + className) as Class;
//			getMovieClipByClassType(dc, setCallback);
//		}
//
//		public static function getDisplayObjectByName(className : String) : DisplayObject {
//			var dc : Class = _domain.getDefinition("MainRes_" + className) as Class;
//			return new dc();
//		}

//		public static function getMovieClipByClassType(classType : Class, setCallback : Function) : void {
//			var mc : MovieClip = new classType() as MovieClip;
//			var loadCompleteListener : Function = function(e : Event) : void {
//				(e.target as LoaderInfo).removeEventListener(Event.COMPLETE, loadCompleteListener);
//				var newMC : MovieClip = MovieClip(e.target.content);
//				setCallback(newMC);
//			};
//			var loader : Loader = Loader(mc.getChildAt(0));
//			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadCompleteListener);
//			// loader.loadBytes(mc.movieClipData);
//		}

    private static var _bds:Dictionary = new Dictionary();

    public static function getBitmapByName(className:String):Bitmap {
        if (_bds[className] == null) {
            var dc:Class = _domain.getDefinition(className) as Class;
            var dcc:Bitmap = new dc();
            _bds[className] = dcc.bitmapData;
        }
        return new Bitmap(_bds[className]);
    }
}
}
