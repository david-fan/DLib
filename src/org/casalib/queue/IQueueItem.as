package org.casalib.queue {
	import flash.events.IEventDispatcher;

	/**
	 * @author david
	 */
	public interface IQueueItem  extends IEventDispatcher {
		function start() : void;

		function stop() : void;

		function finish() : void;
	}
}
