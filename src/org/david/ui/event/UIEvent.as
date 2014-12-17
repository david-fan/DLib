package org.david.ui.event {
import flash.events.Event;

public class UIEvent extends Event {
    private var _data:Object;
    public static const POP_UP_OPEN:String = "popUpOpen";
    public static const POP_UP_CLOSE:String = "popUpClose";
    public static const POP_UP_COMPLETE:String = "popUpComplete";

    public static const ViewChanged:String = "UIEvent.ViewChanged";
    public static const DRAG_IN:String = "UIEvent.DragIn";
    public static const DRAG_OUT:String = "UIEvent.DragOut";
    public static const DRAG_Drop:String = "UIEvent.DragDrop";
    public static const IMG_LOAD_COMPLETE:String = "UIEvent.ImgLoadComplete";
    // public static const VIEW_SIZE_CHANGE:String = "UIEvent.ViewSizeChange";
    public static const DIALOG_OK:String = "UIEvent.DialogOK";
    public static const DIALOG_CANCEL:String = "UIEvent.DialogCancel";
    public static const DIALOG_CLOSE:String = "UIEvent.DialogClose";
    public static const TAB_CLICK:String = "UIEvent.TabClick";
    public static const TabPanel_Change:String = "UIEvent.TabPanelChange";
    //
    public static const ListItemMouseDown:String = "UIEvent.ListItemMouseDown";
    public static const ListItemMouseUp:String = "UIEvent.ListItemMouseUp";
    public static const ListItemMouseClick:String = "UIEvent.ListItemMouseClick";
    public static const ListItemRollOver:String="UIEvent.ListItemRollOver";
    public static const ListItemRollOut:String="UIEvent.ListItemRollOut";
    //
    public static const ItemSeleted:String = "UIEvent.ItemSelected";

    public function UIEvent(type:String, eventdata:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.data = eventdata;
        return;
    }

    public function set data(value:Object):void {
        this._data = value;
        return;
    }

    public function get data():Object {
        return this._data;
    }

    override public function clone():Event {
        var e:UIEvent = new UIEvent(type, bubbles, cancelable);
        e.data = this.data;
        return e;
    }
}
}
