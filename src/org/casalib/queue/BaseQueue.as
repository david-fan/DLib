package org.casalib.queue {
	import flash.events.EventDispatcher;

	/**
	 * @author david
	 */
	public class BaseQueue extends EventDispatcher  implements IQueueItem {
		public function start() : void {
			dispatchEvent(new QueueEvent(QueueEvent.Start));
		}

		public function finish() : void {
			dispatchEvent(new QueueEvent(QueueEvent.Finish));
		}

		public function stop() : void {
		}
	}
}
