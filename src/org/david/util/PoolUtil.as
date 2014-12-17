package org.david.util {
	import org.casalib.core.IDestroyable;
	import org.casalib.util.ArrayUtil;

	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	public class PoolUtil {
		private static var objPoolDict : Dictionary = new Dictionary();

		public static function pushObj(className : String, objInstance : Object) : void {
			if (objPoolDict[className] == null) {
				objPoolDict[className] = [];
			}
			if (objInstance == null) {
				return;
			}
			if (ArrayUtil.contains(objPoolDict[className], objInstance) == 0) {
				objPoolDict[className].push(objInstance);
			}
		}

		public static function getObj(className : String, needClean : Boolean = false) : Object {
			if (objPoolDict[className] == null)
				objPoolDict[className] = [];

			var obj : Object;
			var objs : Array = objPoolDict[className] as Array;
			if (objs.length == 0) {
				var c : Class = getDefinitionByName(className) as Class;
				obj = new c();
			} else {
				obj = (objPoolDict[className] as Array).pop();
				if (needClean && obj is IDestroyable)
					(obj as IDestroyable).destroy();
			}
			return obj;
		}

		public static function clearObjs(classNameOrObjInstance : *) : void {
			if (classNameOrObjInstance is String)
				delete objPoolDict[classNameOrObjInstance];
			else {
				var className : String = getQualifiedClassName(classNameOrObjInstance);
				delete objPoolDict[className];
			}
		}
	}
}
