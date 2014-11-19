package org.david.util {
	import org.casalib.events.LoadEvent;
	import org.casalib.load.CasaLoader;
	import org.casalib.load.DataLoad;
	import org.casalib.load.GroupLoad;
	import org.casalib.load.ImageLoad;
	import org.casalib.load.LoadItem;
	import org.casalib.load.SwfLoad;
	import org.casalib.util.LoadItemUtil;

	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.utils.ByteArray;

	public class LoadUtil {
		private static var _baseUrl : String = "";

		public static function init(baseUrl : String) : void {
			_baseUrl = baseUrl;
		}

		public static function LoadUrls(urls : Array, complete : Function, progress : Function = null) : GroupLoad {
			var gl : GroupLoad = new GroupLoad();
			for each (var url:String in urls) {
				var li : LoadItem;
				try {
					li = LoadItemUtil.createLoadItem(_baseUrl + url);
				} catch(e : Error) {
					DebugUtil.error(e.message);
					continue;
				}
				gl.addLoad(li);
			}
			gl.addEventListener(LoadEvent.COMPLETE, complete);
			if (progress != null) {
				gl.addEventListener(LoadEvent.PROGRESS, progress);
			}
			gl.start();
			return gl;
		}

		public static  function getMovieClipByURL(groupLoad : GroupLoad, url : String) : MovieClip {
			var li : LoadItem = groupLoad.getLoad(_baseUrl + url);
			if (li == null) {
				throw new Error("not found:" + _baseUrl + url);
			}
			return (li as SwfLoad).contentAsMovieClip;
		}

		public static  function getDisplayObjectByURL(groupLoad : GroupLoad, url : String) : DisplayObject {
			var li : LoadItem = groupLoad.getLoad(_baseUrl + url);
			if (li == null) {
				throw new Error("not found:" + _baseUrl + url);
			}
			return (li as CasaLoader).content;
		}

		public static  function getBitmapByURL(groupLoad : GroupLoad, url : String) : Bitmap {
			var li : LoadItem = groupLoad.getLoad(_baseUrl + url);
			if (li == null) {
				throw new Error("not found:" + _baseUrl + url);
			}
			return (li as ImageLoad).contentAsBitmap;
		}

		public  static function getXMLByURL(groupLoad : GroupLoad, url : String) : XML {
			var li : LoadItem = groupLoad.getLoad(_baseUrl + url);
			if (li == null) {
				throw new Error("not found:" + _baseUrl + url);
			}
			return (li as DataLoad).dataAsXml;
		}

		public  static function getByteArrayByURL(groupLoad : GroupLoad, url : String) : ByteArray {
			var li : LoadItem = groupLoad.getLoad(_baseUrl + url);
			if (li == null) {
				throw new Error("not found:" + _baseUrl + url);
			}
			return (li as DataLoad).dataAsByteArray;
		}
	}
}