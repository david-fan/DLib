/**
 * Created with IntelliJ IDEA.
 * User: david
 * Date: 6/25/13
 * Time: 3:15 PM
 * To change this template use File | Settings | File Templates.
 */
package org.david.util {
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.NetStatusEvent;
import flash.events.StatusEvent;
import flash.media.Camera;
import flash.media.H264Profile;
import flash.media.H264VideoStreamSettings;
import flash.media.Microphone;
import flash.media.SoundCodec;
import flash.media.SoundTransform;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.net.ObjectEncoding;
import flash.system.Security;
import flash.system.SecurityPanel;

import org.david.ui.event.UIEvent;

public class MStreamPublisher extends EventDispatcher {
    public static var Rejected:String = "NetConnection.Connect.Rejected";
    public static var Failed:String = "NetConnection.Connect.Failed";
    public static var Close:String = "NetConnection.Connect.Close";
    public static var Start:String = "NetStream.Publish.Start";
    public static var BadName:String = "NetStream.Publish.BadName";
    public static var NoCam:String = "NoCam";
    public static var NoMic:String = "NoMic";
    public static var MicCamMute:String = "MicCamMute";
    public static var Stop:String = "Stop";

    public static var PublishStart:String = "MStreamPublisher.PublishStart";
    public static var PublishClose:String = "MStreamPublisher.PublishClose";
//    public static var PublishError:String = "MStreamPublisher.PublishError";

    private var _camera:Camera;
    private var _microphone:Microphone;
    private var publishConnection:NetConnection;
    private var _publishStream:NetStream;
    private var _liveId:String;
    private var _server:String;
    private var _publishing:Boolean;

    private var _video:Boolean;
    private var _audio:Boolean;

    private var _muteMicCam:Boolean;

    private var _setting:Object = {width: 600, height: 480, fps: 15, quality: 0, buffer: 500, rate: 22,keyframes:45};//keyframes: 48


    public function get publishing():Boolean {
        return _publishing;
    }

    public function MStreamPublisher(liveId:String = null, server:String = null, video:Boolean = true, audio:Boolean = true) {
        _liveId = liveId;
        _server = server;
        _video = video;
        _audio = audio;
    }

    public function set liveId(value:String):void {
        _liveId = value;
    }

    public function set server(vaule:String):void {
        _server = vaule;
    }

    public function set video(value:Boolean):void {
        _video = value;
    }

    public function get video():Boolean {
        return _video;
    }

    public function set audio(value:Boolean):void {
        _audio = value;
    }

    public function get audio():Boolean {
        return _audio;
    }

    public function get publishStream():NetStream {
        return _publishStream;
    }

    public function get camera():Camera {
        return _camera;
    }

    public function set camera(value:Camera):void {
        _camera = value;
    }

    public function get microphone():Microphone {
        return _microphone;
    }

    public function set microphone(value:Microphone):void {
        _microphone = value;
    }

    private function cleanupPublishedStream(info:String = null):void {
        if (_publishStream != null) {
            _publishStream.close();
        }
        if (publishConnection != null) {
            publishConnection.close();
        }
        _publishStream = null;
        _publishing = false;
        if (info)
            dispatchEvent(new UIEvent(PublishClose, info));
    }

    private function publishStreamStatus(evt:NetStatusEvent):void {
        trace("[NetStream Status]", evt.info.code, evt.info.message);
        switch (evt.info.code) {
            case Start :
                trace(_publishStream.videoStreamSettings);
                _publishing = true;
                dispatchEvent(new UIEvent(PublishStart));
                break;
            case BadName :
                cleanupPublishedStream(BadName);
                break;
        }
    }

    private function publishConnectionStatus(evt:NetStatusEvent):void {
        trace("[Connection Status]" + evt.info.code);
        switch (evt.info.code) {
            case "NetConnection.Connect.Success" :
                _publishStream = new NetStream(publishConnection);
                _publishStream.addEventListener(NetStatusEvent.NET_STATUS, publishStreamStatus);
                if (_audio) {
                    _microphone.codec = SoundCodec.SPEEX;
                    _microphone.setSilenceLevel(0);
                    _microphone.encodeQuality = 6;
                    _microphone.rate = _setting.rate;
                    _publishStream.attachAudio(_microphone);
                }
                if (_video) {
                    _camera.setKeyFrameInterval(_setting.keyframes);
                    _camera.setMode(_setting.width, _setting.height, _setting.fps);
                    _camera.setQuality(_setting.buffer * 128, _setting.quality);

                    var quality:int = 0;
                    var h264Settings:H264VideoStreamSettings = new H264VideoStreamSettings();
                    h264Settings.setProfileLevel(H264Profile.MAIN, "1.3");
                    h264Settings.setKeyFrameInterval(_setting.keyframes);
                    h264Settings.setMode(_setting.width, _setting.height, _setting.fps);
                    h264Settings.setQuality(_setting.buffer * 128, quality);
                    _publishStream.videoStreamSettings = h264Settings;
                    _publishStream.attachCamera(_camera);
                }
                if (_video || _audio)
                    _publishStream.publish(_liveId, "live");
                if (_video) {
                    var metaData:Object = new Object();
                    metaData.width = _setting.width;
                    metaData.height = _setting.height;
                    metaData.framerate = _setting.fps;
                    metaData.videodatarate = _setting.buffer;
                    _publishStream.send("@setDataFrame", "onMetaData", metaData);
                }

                break;
            case Rejected :
            case Failed :
            case Close:
                cleanupPublishedStream(evt.info.code);
                break;
        }
    };


    public function startPublish(setting:Object = null):void {
        this.setting = setting;
        cleanupPublishedStream();
        checkMicCam();
    }

    private function makeConnection():void {
        publishConnection = new NetConnection();
        publishConnection.objectEncoding = ObjectEncoding.AMF0;
        publishConnection.addEventListener(NetStatusEvent.NET_STATUS, publishConnectionStatus);
        //var server:String = _rtmpUrl.substr(0, _rtmpUrl.lastIndexOf("\/"));
        publishConnection.connect(_server);
    }

    private function checkMicCam():void {
        if (_audio) {
            if (_microphone == null) {
                _microphone = Microphone.getMicrophone();
                if (_microphone == null) {
                    cleanupPublishedStream(NoMic);
                    return;
                }
            }
            if (_microphone.muted) {
                _microphone.addEventListener(StatusEvent.STATUS, statusHandler);
//                cleanupPublishedStream(MicCamMute);
//                Security.exactSettings = true;
                Security.showSettings(SecurityPanel.PRIVACY);
                return;
            }
        }
        if (_video) {
            if (_camera == null) {
                _camera = Camera.getCamera();
                if (_camera == null) {
                    cleanupPublishedStream(NoCam);
                    return;
                }
            }

            if (_camera.muted) {
                _camera.addEventListener(StatusEvent.STATUS, statusHandler);
//                cleanupPublishedStream(MicCamMute);
//                Security.exactSettings = true;
                Security.showSettings(SecurityPanel.PRIVACY);
                return;
            }
        }
        if (_audio || _video)
            makeConnection();
    }

    public function stopPublish():void {
        cleanupPublishedStream(Stop);
    }

    public function set setting(value:Object):void {
        if (setting) {
            for (var key in value) {
                _setting[key] = value[key];
            }
        }
//        _setting = value;
    }

    public function get setting():Object {
        return _setting;
    }

    private function statusHandler(e:StatusEvent):void {
        if (e.code == "Microphone.Muted" || e.code == "Camera.Muted") {
            cleanupPublishedStream(MicCamMute);
//            Security.showSettings(SecurityPanel.PRIVACY);
        } else {
            makeConnection();
        }
    }

//    private function noCamMicAlert(message:String):void {
//        dispatchEvent(new UIEvent(PublishError, message));
//    }
}
}
