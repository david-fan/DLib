/**
 * Created by david on 10/28/14.
 */
package org.david.ui {
import com.greensock.TweenLite;

import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import org.david.ui.core.AppLayer;

import org.david.ui.core.MSprite;
import org.david.util.UtilManager;

public class MAlert extends MSprite {
//    public function MAlert() {
//        super();
//    }

    public static function show(msg:String, autoHide:Boolean = false, model:Boolean = true, delay:int = 2):MAlert {
        var alert:MAlert = new MAlert();
        alert.showAlert(msg, autoHide, model, delay);
        return alert;
    }

    private var _alert:sysalert = new sysalert();
    private var _alertRemoveId:int = 0;
    private var _alerting:Boolean;

    public function showAlert(msg:String, autoHide:Boolean = false, model:Boolean = true, delay:int = 2):void {
        _alert.msgText.text = msg;
        if (_alertRemoveId > 0)
            clearTimeout(_alertRemoveId);

        if (autoHide) {
            setTimeout(function ():void {
                _alertRemoveId = 0;
                hideAlert();
            }, 1000 * delay);
        }
        if (_alerting) {
            return;
        }
        _alert.x = (AppLayer.AppWidth - _alert.width) / 2;
        _alert.y = -_alert.height;
        UtilManager.popUpUtil.addPopUp(_alert, model, false);
        TweenLite.to(_alert, 0.3, {y: 0});
        _alerting = true;
    }

    public function hideAlert():void {
        UtilManager.popUpUtil.removePopUp(_alert);
        _alerting = false;
    }
}
}

import org.david.ui.MTextField;
import org.david.ui.core.MSprite;

class sysalert extends MSprite {
    public var msgText:MTextField=new MTextField(15,0,true);
    public function sysalert(){
        super();
        addChild(msgText);
    }
}
