package org.david.mvc {
	public class NotificationDispatch {
		public function NotificationDispatch() {
		}

		protected var _notificationBus : NotificationBus = NotificationBus.getInstance();

		/**
		 *
		 * @param type
		 * @param listener
		 * @param priority
		 */
		public function addListener(type : String, listener : Function, priority : int = 0) : void {
			_notificationBus.addFun(type, listener, priority);
		}

		/**
		 *
		 * @param n
		 * @return
		 */
		public function dispatch(n : Notification) : void {
			_notificationBus.notify(n);
		}

		/**
		 *
		 * @param type
		 * @param listener
		 */
		public function removeListener(type : String, listener : Function) : void {
			_notificationBus.removeFun(type, listener);
		}
	}
}