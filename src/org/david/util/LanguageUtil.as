package org.david.util {
	public class LanguageUtil extends Object {
		private static var textDic : Object = new Object();

		public static function initialize(contentXml : XML) : void {
			var groups : XMLList = null;
			var group : XML = null;
			var item : XML = null;
			var value : String = null;
			if (contentXml) {
				groups = contentXml.group;
				for each (group in groups) {
					for each (item in group.item) {
						value = item[0];
						textDic[group.@key + "." + item.@key] = value;
					}
				}
			}
		}

		public static function getText(name : String, replaceTxts : Array = null) : String {
			var value : String = null;
			var index : int = 0;
			var txtLen : int = 0;
			var re : String = null;
			var regExp : RegExp = null;
			if (textDic[name] != null) {
				value = textDic[name];
			} else {
				value = name;
			}
			if (replaceTxts) {
				index = 0;
				txtLen = replaceTxts.length;
				while (index < txtLen) {
					re = "\\{" + index + "\\}";
					regExp = new RegExp(re, "g");
					value = value.replace(regExp, replaceTxts[index]);
					index++;
				}
			}
			return value;
		}
	}
}
