package org.david.util {
	import org.casalib.events.LoadEvent;
	import org.casalib.load.DataLoad;

	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.net.URLLoaderDataFormat;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;

	/**
	 * @author david
	 */
	public class LoadMCHelper {
		private var _setMC : Function;
		private var _setMCParamer : Object;

		public function LoadMCHelper(bytes : ByteArray, setMCFunction : Function, setMCFunctioinParamer : Object) {
			_setMC = setMCFunction;
			_setMCParamer = setMCFunctioinParamer;
			var ld : Loader = new Loader();
			ld.contentLoaderInfo.addEventListener(Event.COMPLETE, onInit);
			var lc : LoaderContext = new LoaderContext(false);
			//lc.allowCodeImport = true;
			ld.loadBytes(bytes, lc);
		}

		private function onInit(e : Event) : void {
			var li : LoaderInfo = e.target as LoaderInfo;
			li.removeEventListener(Event.COMPLETE, onInit);
			var mc : MovieClip = (e.target as LoaderInfo).content as MovieClip;
			if (_setMC != null)
				_setMC(mc, _setMCParamer);
			_setMC = null;
			_setMCParamer = null;
		}

		//
		public static function loadMCBytes(url : String, setBytes : Function, obj : Object) : void {
			var dl : DataLoad = new DataLoad(url, URLLoaderDataFormat.BINARY);
			var onComplete : Function = function(e : LoadEvent) : void {
				if (setBytes != null)
					setBytes(dl.dataAsByteArray, obj);
				dl.destroy();
			};
			dl.addEventListener(LoadEvent.COMPLETE, onComplete);
			dl.start();
		}

		//
		public static function setMCFromBytes(bytes : ByteArray, setMC : Function, obj : Object) : LoadMCHelper {
			return new LoadMCHelper(bytes, setMC, obj);
		}
	}
}
