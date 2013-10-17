package org.david.mvc {
	/**
	 * 消息类
	 */
	public class Notification {
		/**
		 * 消息类型
		 */
		public var type : String;
		/**
		 * 消息数据
		 */
		public var data : Object;
		/**
		 * 是否已经停止消息处理
		 */
		public var stop : Boolean;

		/**
		 * @param type 消息类型
		 * @param data 消息数据
		 */
		public function Notification(type : String, data : Object = null) {
			this.type = type;
			this.data = data;
		}

		/**
		 * 主动停止消息
		 */
		public function stopNotify() : void {
			stop = true;
		}
	}
}