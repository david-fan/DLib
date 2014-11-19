package org.david.mvc {
	import flash.utils.Dictionary;

	/**
	 * 消息的处理中心
	 */
	public class NotificationBus {
		private var _funsDic : Dictionary;
		private static var _instance : NotificationBus;

		public static function getInstance() : NotificationBus {
			if (_instance == null)
				_instance = new NotificationBus();
			return _instance;
		}

		public function NotificationBus() {
			_funsDic = new Dictionary();
		}

		/**
		 * 添加消息监听
		 * @param type 消息类型
		 * @param fun 监听方法，签名为function(n:Notification):void;
		 * @param priority 优先级，大的优先
		 */
		public function addFun(type : String, fun : Function, priority : int) : void {
			if (_funsDic[type] == null)
				_funsDic[type] = new Array();
			var funs : Array = _funsDic[type] as Array;
			var fo : Object = new Object();
			fo.fun = fun;
			fo.priority = priority;
			funs.push(fo);
			sortFun(funs);
		}

		/**
		 * 移除消息监听
		 * @param type 消息类型
		 * @param fun 原始监听方法
		 */
		public function removeFun(type : String, fun : Function) : void {
			var funs : Array = _funsDic[type] as Array;
			if (funs == null)
				return;
			for (var i : int = 0; i < funs.length; i++) {
				var fo : Object = funs[funs.length - i - 1];
				if (fo.fun === fun) {
					funs.splice(funs.indexOf(fo), 1);
					break;
				}
			}
		}

		/**
		 * 对外界的所有监听者，广播一个消息
		 */
		public function notify(n : Notification) : void {
			var funs : Array = _funsDic[n.type] as Array;
			if (funs == null)
				return;
			for (var i : int = 0; i < funs.length; i++) {
				var fo : Object = funs[funs.length - i - 1];
				fo.fun(n);
				if (n.stop)
					return;
			}
		}

		private function sortFun(funs : Array) : void {
			funs.sortOn("priority", Array.NUMERIC);
		}
	}
}