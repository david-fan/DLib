package org.david.ui {
	import org.david.util.FilterUtil;

	/**
	 * 描边的文本，使用设备字体
	 */
	public class MStrokeMachineText extends MMachineTextBlock {
		public function MStrokeMachineText(text : String = "", size : Number = 14, color : uint = 0xF9DE73, width : Number = 200, fillterColor : uint = 0x632707, fontName : String = "SimSun", fontWeight : String = "normal") {
			super(text, size, color, width, fontName, fontWeight);
			this.filters = [FilterUtil.getColorFilter(fillterColor)];
		}
	}
}