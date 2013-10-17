package org.david.ui.core {
	public interface IToolTipUI {
		function set toolTip(value : Object) : void;

		function get toolTip() : Object;

		function set toolTipData(value : Object) : void;

		function get toolTipData() : Object;

		// function set toolTipDirection(value:String):void;
		// function get toolTipDirection():String;
		// function set follow(value:Boolean):void;
		// function get follow():Boolean;
		function set remain(value : int) : void;

		function get remain() : int;

        function set delay(value:int):void;

        function get delay():int;
	}
}