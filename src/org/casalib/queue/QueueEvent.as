package org.casalib.queue {
	import flash.events.Event;

	/**
	 * @author david
	 */
	public class QueueEvent extends Event {
		public static const Finish : String = "QueueEvent.Finish";
		public static const Start : String = "QueueEvent.Start";

		public function QueueEvent(type : String, bubbles : Boolean = false, cancelable : Boolean = false) {
			super(type, bubbles, cancelable);
		}
	}
}
