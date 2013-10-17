/*
 * This class represents the remote call procedure (rpc)
 * @author Thibault Imbert (bytearray.org)
 * @version 0.1
 * @version 0.2 (moved to a Singleton implementation)
 */
package org.bytearray.remoting {
	import org.bytearray.remoting.events.FaultEvent;
	import org.bytearray.remoting.events.ResultEvent;

	import flash.events.EventDispatcher;
	import flash.net.NetConnection;
	import flash.net.Responder;

	public final class PendingCall extends EventDispatcher {
		private var responder : Responder;
		private var connector : NetConnection;
		private var request : String;
		private var concatParams : Array;
		private var parameters : Array;
		public var token : Object = new Object();

		public function PendingCall(connection : NetConnection, call : String, params : Array) {
			responder = new Responder(result, status);

			connector = connection;
			request = call;
			parameters = params;
		}

		private function result(pEvt : Object) : void {
			dispatchEvent(new ResultEvent(ResultEvent.RESULT, pEvt));
		}

		public function get MethodName() : String {
			return request;
		}

		private function status(pEvt : Object) : void {
			dispatchEvent(new FaultEvent(FaultEvent.FAULT, pEvt));
		}

		internal function execute() : void {
			concatParams = new Array(request, responder);

			connector.call.apply(connector, concatParams.concat(parameters));
		}
	}
}