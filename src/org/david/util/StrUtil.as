package org.david.util {


import flash.utils.ByteArray;

import org.casalib.util.StringUtil;

/**
	 * @author david
	 */
	public class StrUtil {
		public static function isNullOrEmpty(source : String) : Boolean {
			if (source == null)
				return true;
			var temp : String = StringUtil.trim(source);
			if (temp.length == 0)
				return true;
			return false;
		}

        public static  function replace(str:String, ...params):String
        {
            var pattern:RegExp = /{\d}/g;
            var ar:Array = str.match(pattern);

            var i:uint = 0;
            for(i; i<ar.length; i++)
            {
                str = str.split(ar[i]).join(params[i]);
            }

            return str;
        }

		public static function substr(input : String, length : int = 10, suffix : String = "...") : String {
			if (length > 0) {
				var temp : String = "";
				var len : int = 0;
				var txtlen : int = input.length;
				var index : int = 0;
				while (index < txtlen) {
					var char : String = input.substr(index, 1);
					var bytes : ByteArray = new ByteArray();
					bytes.writeMultiByte(char, "utf-8");
					len += (bytes.length == 1 ? 1 : 2);
					index++;
					if (len > length) {
						input = temp;
						input += suffix;
						break;
					} else
						temp += char;
				}
			}
			return input;
		}
	}
}
