package org.david.mvc {
	/**
	 * 基础视图接口，可以设置和读取数据Model
	 */
	public interface IView {
		function set Model(value : Object) : void;

		function get Model() : Object;
	}
}