package org.david.util {
	import flash.display.DisplayObject;

	/**
	 * @author david
	 */
	public class WindowObj {
        public static var TweenPopUp:String="tween";
        public static var NormalPopUp:String="popUp" ;
		public var modal : DisplayObject;
		public var center : Boolean;
		public var priority : int;
		public var obj : DisplayObject;
		public var animation : Boolean;
		public var hideScene : Boolean;
        public var _x:Number;
        public var _y:Number;
        public var showModel:String;
	}
}
