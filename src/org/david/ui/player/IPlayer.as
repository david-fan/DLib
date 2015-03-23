/**
 * Created by david on 10/30/14.
 */
package org.david.ui.player {
public interface IPlayer {
    function play():void;

    function pause():void;

    function resume():void;

    function stop():void;

    function seek(time:Number):void;

    function get mute():Boolean ;

    function set mute(value:Boolean):void;

    function get volume():Number;

    function set volume(value:Number):void;

    function set streamCreateCallback(value:Function):void;

    function set metaDataGetCallback(value:Function):void;

    function set playStatusCallback(value:Function):void;

    function get duration():Number;
}
}
