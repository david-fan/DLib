/*
 ____ ____ ____ ____ ____ ____ ____ ____ 
||R |||e |||m |||o |||t |||i |||n |||g ||
||__|||__|||__|||__|||__|||__|||__|||__||
|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
 ____ ____ ____ ____ ____ ____ ____ 
||S |||e |||r |||v |||i |||c |||e ||
||__|||__|||__|||__|||__|||__|||__||
|/__\|/__\|/__\|/__\|/__\|/__\|/__\|

 * This class is a simple NetConnection wrapper for remoting calls
 * @author Thibault Imbert (bytearray.org)
 * @version 0.1
 * @version 0.2 (moved to a Singleton implementation)
 */
package org.bytearray.remoting {
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.NetConnection;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;

	public dynamic class Service extends Proxy implements IEventDispatcher {
		private var connection : NetConnection;
		private var dispatcher : EventDispatcher;
		private var gateway : String;
		private var appel : String;
		private var servicePath : String;
		private var rpc : PendingCall;
		private static var initialize : Boolean;
		private static var instance : Service;

		public function Service() {
			if ( !initialize )
				throw new Error('This is a singleton. Use Service.getInstance().');

			connection = new NetConnection();
			connection.client = this;
			dispatcher = new EventDispatcher(this);

			connection.addEventListener(NetStatusEvent.NET_STATUS, handleEvent);
			connection.addEventListener(IOErrorEvent.IO_ERROR, handleEvent);
			connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleEvent);
			connection.addEventListener(AsyncErrorEvent.ASYNC_ERROR, handleEvent);
		}

		public function setRemoteInfos(pGateway : String, pService : String, pEncoding : int = 0) : void {
			connection.objectEncoding = pEncoding;
			servicePath = pService;
			gateway = pGateway;
			connection.connect(gateway);
		}

		public static function getInstance() : Service {
			if ( instance == null ) {
				initialize = true;
				instance = new Service();
				initialize = false;
			}

			return instance;
		}

		/**
		 * This methods lets authenticate a user to the remote service
		 * @param remoteUserName The userName to use
		 * @param remotePassword The password to use
		 * 
		 */
		public function setRemoteCredentials(remoteUserName : String, remotePassword : String) : void {
			connection.addHeader("Credentials", false, {userid:remoteUserName, password:remotePassword});
		}

		/**
		 * 
		 * @param service The remote service to use (including full package and name)
		 * 
		 */
		public function set service(service : String) : void {
			servicePath = service;
		}

		/**
		 * 
		 * @return The remote service (including full package and name)
		 * 
		 */
		public function get service() : String {
			return servicePath;
		}

		/**
		 * 
		 * @param url The new gateway URL to use
		 * 
		 */
		public function set gatewayURL(url : String) : void {
			connection.connect(gateway = url);
		}

		/**
		 * 
		 * @return The gateway URL
		 * 
		 */
		public function get gatewayURL() : String {
			return gateway;
		}

		// --
		// -- proxy stuff
		// --
		override flash_proxy function hasProperty(name : *) : Boolean {
			return false;
		}

		override flash_proxy function getProperty(name : *) : * {
			return undefined;
		}

		// --
		// -- self description
		// --
		public function toString() : String {
			return "[object RemoteObject]";
		}

		// --
		// -- private
		// --
		private function handleEvent(pEvt : Event) : void {
			dispatcher.dispatchEvent(pEvt);
		}

		override flash_proxy function callProperty(methodName : *, ...parametres : *) : * {
			appel = servicePath + "." + methodName;

			rpc = new PendingCall(connection, appel, parametres);

			rpc.execute();

			return rpc;
		}

		// --
		// -- IEventDispatcher
		// --
		public function addEventListener(type : String, listener : Function, useCapture : Boolean = false, priority : int = 0, useWeakReference : Boolean = false) : void {
			dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}

		public function dispatchEvent(event : Event) : Boolean {
			return dispatcher.dispatchEvent(event);
		}

		public function hasEventListener(type : String) : Boolean {
			return dispatcher.hasEventListener(type);
		}

		public function removeEventListener(type : String, listener : Function, useCapture : Boolean = false) : void {
			dispatcher.removeEventListener(type, listener, useCapture);
		}

		public function willTrigger(type : String) : Boolean {
			return dispatcher.willTrigger(type);
		}
	}
}
