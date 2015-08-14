package org.david.util {
	import org.david.ui.MToolTip;
import org.david.ui.MToolTipBg;
import org.david.ui.MToolTipBgBase;
import org.david.ui.core.ITollTip;
import org.david.ui.core.IToolTipUI;
	import org.david.ui.core.MSprite;

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;

	public class ToolTipUtil {
		private var _parent : MSprite;
		private var _tipInstances : Dictionary = new Dictionary();
		private var _contentBG : MToolTipBgBase ;
		private var _hideTimer : Timer = new Timer(3 * 1000, 1);

		public function ToolTipUtil(parent : MSprite) {
			_parent = parent;
			_hideTimer.addEventListener(TimerEvent.TIMER_COMPLETE, hide);
            _contentBG=new MToolTipBg();
		}
        public function set tipContentBg(tipBg:MToolTipBgBase):void{
                _contentBG=tipBg;
        }

		public function show(target : DisplayObject) : void {
			var tui : IToolTipUI = target as IToolTipUI;
			if (tui.toolTip is String && tui.toolTip.length != 0) {
				_show(target, MToolTip, tui.toolTip, tui.remain);
			} else if (tui.toolTip != null) {
				_show(target, tui.toolTip as Class, tui.toolTipData, tui.remain);
			}
		}

		public function hide(e : TimerEvent = null) : void {
			if (_parent.contains(_contentBG))
				_parent.removeChild(_contentBG);
		}

		private function _show(target : DisplayObject, toolTipClass : Class, data : Object, delay : int) : void {
			if (toolTipClass == null) {
				return;
			}
			_parent.addChild(_contentBG);
			var tooltip : ITollTip = getToolTipClassObj(toolTipClass);
			tooltip.data = data;
			_contentBG.drawBg(tooltip.showbg);
			_contentBG.target = target;
			_contentBG.content = tooltip as DisplayObject;
			// _contentBG.addEventListener(UIEvent.ViewChanged, function(e : UIEvent) : void {
			// positionBG(direction, target);
			// checkPosition(direction, tooltip as DisplayObject, target);
			// });
			_hideTimer.reset();
			if (delay > 0) {
				_hideTimer.delay = delay * 1000;
				_hideTimer.start();
			}
		}

		// private function positionBG(direction : String, target : DisplayObject) : void {
		// _contentBG.direction = direction;
		// var p : Point;
		// switch (direction) {
		// case MToolTipDirection.DOWN:
		// p = target.localToGlobal(new Point(target.width / 2, target.height));
		// _contentBG.y = p.y + _contentBG.yOffset;
		// _contentBG.x = p.x - _contentBG.width / 2;
		// break;
		// case MToolTipDirection.UP:
		// p = target.localToGlobal(new Point(target.width / 2, 0));
		// _contentBG.y = p.y - _contentBG.height - _contentBG.yOffset;
		// _contentBG.x = p.x - _contentBG.width / 2;
		// break;
		// case MToolTipDirection.LEFT:
		// p = target.localToGlobal(new Point(0, target.height / 2));
		// _contentBG.y = p.y - _contentBG.height / 2;
		// _contentBG.x = p.x - _contentBG.width - _contentBG.xOffset;
		// break;
		// case MToolTipDirection.RIGHT:
		// p = target.localToGlobal(new Point(target.width, target.height / 2));
		// _contentBG.y = p.y - _contentBG.height / 2;
		// _contentBG.x = p.x + _contentBG.xOffset;
		// break;
		// }
		// }
		// private function checkPosition(direction : String, dispalyObj : DisplayObject, target : DisplayObject) : Point {
		// var point : Point = null;
		// switch (direction) {
		// case MToolTipDirection.DOWN: {
		// point = dispalyObj.localToGlobal(new Point(dispalyObj.width / 2, dispalyObj.height));
		// if (point.y > _parent.height)
		// positionBG(MToolTipDirection.UP, target);
		// break;
		// }
		// case MToolTipDirection.UP: {
		// point = dispalyObj.localToGlobal(new Point(dispalyObj.width / 2, 0));
		// if (point.y < 0)
		// positionBG(MToolTipDirection.DOWN, target);
		// break;
		// }
		// case MToolTipDirection.LEFT: {
		// point = dispalyObj.localToGlobal(new Point(0, dispalyObj.height / 2));
		// if (point.x < 0)
		// positionBG(MToolTipDirection.RIGHT, target);
		// break;
		// }
		// case MToolTipDirection.RIGHT: {
		// point = dispalyObj.localToGlobal(new Point(dispalyObj.width, dispalyObj.height / 2));
		// if (point.x > _parent.width)
		// positionBG(MToolTipDirection.LEFT, target);
		// break;
		// }
		// default: {
		// break;
		// }
		// }
		// return point;
		// }
		private function getToolTipClassObj(toolTipClass : Class) : ITollTip {
			var className : String = getQualifiedClassName(toolTipClass);
			// trace("tooltipclassname:" + className);
			if (_tipInstances[className] == null) {
				var ttc : Object = new toolTipClass();

				if (ttc is DisplayObjectContainer) {
					ttc.mouseChildren = false;
					ttc.mouseEnabled = false;
				}
				if (ttc is InteractiveObject)
					ttc.mouseEnabled = false;
				_tipInstances[className] = ttc;
			}
			return _tipInstances[className] as ITollTip;
		}
	}
}