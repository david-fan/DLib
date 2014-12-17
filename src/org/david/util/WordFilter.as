package org.david.util {
	import org.casalib.events.LoadEvent;
	import org.casalib.load.DataLoad;

	public class WordFilter {
		private static var _wordArray : Array = new Array();

		public static function init(url : String) : void {
			// System.useCodePage = true;
			var dl : DataLoad = new DataLoad(url);
			dl.addEventListener(LoadEvent.COMPLETE, onLoaded);
			dl.start();
		}

		private static function onLoaded(e : LoadEvent) : void {
			var dl : DataLoad = e.target as DataLoad;
			var stringList : String = dl.dataAsString;
			dl.destroy();
			_wordArray = stringList.split("\n");
			for (var i : int = 0; i < _wordArray.length; i++) {
				if (StrUtil.isNullOrEmpty(_wordArray[i]))
					_wordArray.splice(i, 1);
			}
		}

		public static function checkForbid(content : String) : Boolean {
			var r : String = Forbid(content);
			if (content == r) {
				return false;
			}
			return true;
		}

		public static function Forbid(content : String) : String {
			var temp : String = content;
			if (_wordArray.length > 0) {
				for each (var word:String in _wordArray) {
					if (content.indexOf(word) != -1) {
						var r : String = "";
						var i : int = word.length;
						do {
							r += "*";
							i--;
						} while (i > 0);
						var re : RegExp = new RegExp(word, "gi");
						temp = temp.replace(re, r);
					}
				}
			}
			return temp;
		}
	}
}