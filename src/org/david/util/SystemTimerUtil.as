package org.david.util {
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	/**
	 * @author david
	 */
	public class SystemTimerUtil {
		private static var delay : int = 1000;
		private static var timer : Timer = new Timer(delay);
		private static var uid : int;
		private static var callDic : Dictionary = new Dictionary();
		private static var start : Number;

		public static function Start() : void {
			start = getTimer();
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
		}

		private static function onTimer(e : TimerEvent) : void {
			var now : Number = getTimer();
			var pass : Number = now - start;
			start = now;
			var count : int;
			for each (var obj:TimerCall in callDic) {
				obj.pass += pass;
				if (obj.pass >= obj.delay) {
					obj.pass -= obj.delay;
					obj.count++;
					obj.call(obj.count);
					if (obj.repeat == obj.count)
						delete callDic[obj.seed];
				}
				count++;
			}

			e.updateAfterEvent();
			// trace(count + " on time!");
		}

		/**
		 * @param call 定时调用的方法
		 * @param delay 间隔(秒)
		 * @param repeat 调用次数 0循环
		 */
		public static function addTimerCall(call : Function, delay : int, repeat : int = 0) : int {
			if (delay < 1)
				throw new Error("delay必须>=1秒！");
			uid++;
			var obj : TimerCall = new TimerCall();
			obj.seed = uid;
			obj.call = call;
			obj.delay = delay * 1000;
			obj.repeat = repeat;
			obj.pass = 0;
			obj.count = 0;
			callDic[uid] = obj;
			return uid;
		}

		public static function removeTimerCall(uid : int) : void {
			delete callDic[uid];
		}
	}
}
