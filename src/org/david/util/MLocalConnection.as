package org.david.util {
	import flash.events.AsyncErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.StatusEvent;
	import flash.net.LocalConnection;

	/**
	 * @author david
	 */
	public class MLocalConnection {
		public var conn_send : LocalConnection;
		public var conn_receive : LocalConnection;
		protected var sender_connection_name : String;

		public function MLocalConnection() {
			conn_send = new LocalConnection();
			conn_send.addEventListener(StatusEvent.STATUS, onStatus);
			conn_send.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
			conn_send.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSECURITYERROR);
		}

		public function Init(client : Object, remotecname : String, localcname : String, domain : String = null) : void {
			if (domain == null || domain.length == 0) {
				sender_connection_name = remotecname;
			} else {
				sender_connection_name = domain + ":" + remotecname;
			}

			conn_receive = new LocalConnection();
			conn_receive.allowDomain("*");
			conn_receive.client = client;
			if (!DebugError.debug)
				conn_receive.connect(localcname);
		}

		private function onStatus(e : StatusEvent) : void {
			trace(e);
		}

		private function onAsyncError(e : AsyncErrorEvent) : void {
			trace(e);
		}

		private function onSECURITYERROR(e : SecurityErrorEvent) : void {
			trace(e);
		}
	}
}
