package org.david.ui.core {
	public interface IDragTarget {
		function setIn(dragData : Object) : void;

		function setOut() : void;

		function setDrop(dragData : Object) : void;

		function setDragFrom() : void;
	}
}