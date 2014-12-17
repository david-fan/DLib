package org.casalib.queue {
	import org.casalib.events.LoadEvent;
	import org.casalib.events.RemovableEventDispatcher;
	import org.casalib.math.Percent;

	/**
	 * @author david
	 */
	[Event(name="complete", type="org.casalib.events.LoadEvent")]
	[Event(name="progress", type="org.casalib.events.LoadEvent")]
	public class QueueUtil extends RemovableEventDispatcher {
		private var _queue : Array = new Array();
		private var _finishCallback : Function;
		private var _currentQueue : IQueueItem;
		private var _start : Number;
		private var _id : int;
		private var _total : int;

		public function QueueUtil(id : int = 0, start : Number = 0) : void {
			_start = start;
			_id = id;
		}

		override public function destroy() : void {
			if (_currentQueue) {
				_currentQueue.stop();
				if (_currentQueue.hasEventListener(QueueEvent.Finish))
					_currentQueue.removeEventListener(QueueEvent.Finish, startNext);
				_currentQueue = null;
			}
			_finishCallback = null;
			_queue = null;
			super.destroy();
		}

		public function stop() : void {
			if (_currentQueue)
				_currentQueue.stop();
		}

		public function push(queue : IQueueItem) : void {
			_queue.push(queue);
		}

		public function start(finishCallback : Function) : void {
			_total = _queue.length;
			_finishCallback = finishCallback;
			startNext(null);
		}

		public function get total() : int {
			return _total;
		}

		public function get current() : int {
			return _queue.length;
		}

		private function startNext(e : QueueEvent) : void {
			var le : LoadEvent = new LoadEvent(LoadEvent.PROGRESS);
			le.progress = new Percent((total - current) / total);
			dispatchEvent(le);
			if (_currentQueue != null) {
				_currentQueue.removeEventListener(QueueEvent.Finish, startNext);
				_currentQueue = null;
			}
			if (_queue.length > 0) {
				_currentQueue = _queue.shift();
				_currentQueue.addEventListener(QueueEvent.Finish, startNext);
				_currentQueue.start();
			} else {
				dispatchEvent(new LoadEvent(LoadEvent.COMPLETE));
				if (_finishCallback != null) {
					_finishCallback();
					_finishCallback = null;
				}
			}
		}
	}
}
