/**
 * Created with IntelliJ IDEA.
 * User: david
 * Date: 6/25/13
 * Time: 3:15 PM
 * To change this template use File | Settings | File Templates.
 */
package org.david.util {
import flash.events.ActivityEvent;
import flash.events.EventDispatcher;
import flash.events.NetStatusEvent;
import flash.events.StatusEvent;
import flash.media.Camera;
import flash.media.H264VideoStreamSettings;
import flash.media.Microphone;
import flash.media.MicrophoneEnhancedMode;
import flash.media.MicrophoneEnhancedOptions;
import flash.media.SoundCodec;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.net.ObjectEncoding;
import flash.system.Security;
import flash.system.SecurityPanel;

import org.david.ui.event.UIEvent;

public class MStreamPublisher extends EventDispatcher {
    public static var Rejected:String = "NetConnection.Connect.Rejected";
    public static var Failed:String = "NetConnection.Connect.Failed";
    public static var Closed:String = "NetConnection.Connect.Closed";
    public static var Start:String = "NetStream.Publish.Start";
    public static var BadName:String = "NetStream.Publish.BadName";
    public static var NoCam:String = "NoCam";
    public static var NoMic:String = "NoMic";
    public static var MicCamMute:String = "MicCamMute";
    public static var Stop:String = "Stop";

    public static var PublishStart:String = "MStreamPublisher.PublishStart";
    public static var PublishClose:String = "MStreamPublisher.PublishClose";

    private var _camera:Camera;
    private var _microphone:Microphone;
    private var publishConnection:NetConnection;
    private var _publishStream:NetStream;
    private var _liveId:String;
    private var _server:String;
    private var _publishing:Boolean;

    private var _video:Boolean;
    private var _audio:Boolean;

    private var _setting:Object = {width: 320, height: 240, fps: 15, quality: 0, buffer: 300, rate: 22, keyframes: 45, profile: "main", level: 3.1};//keyframes: 48


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

    public function get liveId():String {
        return _liveId;
    }

    public function set server(vaule:String):void {
        _server = vaule;
    }

    public function get server():String {
        return _server;
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
        LogUtil.debug("[NetStream Status]", evt.info.code, evt.info.message);
        switch (evt.info.code) {
            case Start :
                LogUtil.debug(_publishStream.videoStreamSettings);
                _publishing = true;
                dispatchEvent(new UIEvent(PublishStart));
                break;
            case BadName :
                cleanupPublishedStream(BadName);
                break;
        }
    }

    private function publishConnectionStatus(evt:NetStatusEvent):void {
        LogUtil.debug("[Connection Status]" + evt.info.code);
        switch (evt.info.code) {
            case "NetConnection.Connect.Success" :
                _publishStream = new NetStream(publishConnection);
                _publishStream.addEventListener(NetStatusEvent.NET_STATUS, publishStreamStatus);
                if (_audio) {
                    _microphone.setSilenceLevel(0);
                    _microphone.setUseEchoSuppression(true);

                    _microphone.rate = _setting.rate;
                    _microphone.framesPerPacket = 1;
                    _microphone.codec = SoundCodec.SPEEX;
                    _microphone.encodeQuality = 6;
                    _microphone.setLoopBack(false);
                    _microphone.noiseSuppressionLevel = -30

                    var options:MicrophoneEnhancedOptions = new MicrophoneEnhancedOptions();
                    //模式，默认使用全双工模式
                    options.mode = MicrophoneEnhancedMode.FULL_DUPLEX;
                    //是否启用自动增益控制
                    options.autoGain = false;
                    //回声路径,值越大，回声抑制效果越好，但声音的延迟会越大，消耗的资源会越多，值取128或256
                    options.echoPath = 128;
                    //非线性处理，处理乐音时最好关闭
                    options.nonLinearProcessing = true;
                    _microphone.enhancedOptions = options;

                    LogUtil.debug("microphone", _microphone.name);

                    _publishStream.attachAudio(_microphone);
                }
                if (_video) {
                    _camera.setKeyFrameInterval(_setting.keyframes);
                    _camera.setMode(_setting.width, _setting.height, _setting.fps);
                    _camera.setQuality(_setting.buffer * 128, _setting.quality);
                    _camera.addEventListener(ActivityEvent.ACTIVITY, onActivity);
                    var quality:int = 0;
                    var h264Settings:H264VideoStreamSettings = new H264VideoStreamSettings();
                    h264Settings.setProfileLevel(_setting.profile, _setting.level);
                    h264Settings.setKeyFrameInterval(_setting.keyframes);
                    h264Settings.setMode(_setting.width, _setting.height, _setting.fps);
                    h264Settings.setQuality(_setting.buffer * 128, quality);
//                    h264Settings.setQuality(0, 100);
                    _publishStream.videoStreamSettings = h264Settings;

                    LogUtil.debug("camera", _camera.name);

                    _publishStream.attachCamera(_camera);
                }
                if (_video || _audio) {
                    _publishStream.publish(_liveId, "live");
                    trace("*****push***** : " + _server, _liveId);
                }
                if (_video) {
                    var metaData:Object = new Object();
                    metaData.width = _setting.width;
                    metaData.height = _setting.height;
                    metaData.framerate = _setting.fps;
                    metaData.videodatarate = _setting.buffer;
                    metaData.hasAudio = true;
                    metaData.hasVideo = true;
                    //videocodecid = ["", "", "H263", "SCREEN", "VP6FLV", "VP6FLVALPHA", "SCREENV2", "AVC"];
//                    IF CodecID == 2
//                    H263VIDEOPACKET
//                    IF CodecID == 3
//                    SCREENVIDEOPACKET
//                    IF CodecID == 4
//                    VP6FLVVIDEOPACKET
//                    IF CodecID == 5
//                    VP6FLVALPHAVIDEOPACKET
//                    IF CodecID == 6
//                    SCREENV2VIDEOPACKET
//                    IF CodecID == 7
//                    AVCVIDEOPACKET
                    metaData.videocodecid = 7;
                    _publishStream.send("@setDataFrame", "onMetaData", metaData);
                }

                break;
            case Rejected :
            case Failed :
            case Closed:
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
        LogUtil.debug("connect to", _server);
    }

    private function checkMicCam():void {
        if (_audio) {
            if (!checkMic())
                return;
        }
        if (_video) {
            if (!checkCam())
                return;
        }
        if (_audio || _video)
            makeConnection();
    }

    private function checkMic():Boolean {
        if (_microphone == null) {
            _microphone = Microphone.getEnhancedMicrophone();
            if (_microphone == null) {
                cleanupPublishedStream(NoMic);
                return false;
            }
        }
        if (_microphone.muted) {
            _microphone.addEventListener(StatusEvent.STATUS, statusHandler);
//                cleanupPublishedStream(MicCamMute);
//                Security.exactSettings = true;
            Security.showSettings(SecurityPanel.PRIVACY);
            return false;
        }
        return true;
    }

    private function checkCam():Boolean {

        if (_camera == null) {
            _camera = Camera.getCamera();
            if (_camera == null) {
                cleanupPublishedStream(NoCam);
                return false;
            }
        }

        if (_camera.muted) {
            _camera.addEventListener(StatusEvent.STATUS, statusHandler);
//                cleanupPublishedStream(MicCamMute);
//                Security.exactSettings = true;
            Security.showSettings(SecurityPanel.PRIVACY);
            return false;
        }
        return true;
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

    private function onActivity(e:ActivityEvent):void {
        trace("Camera activating:", e.activating);
    }

    private function statusHandler(e:StatusEvent):void {
        checkMicCam();
//        trace("e.code", e.code);
//        if (e.code == "Microphone.Unmuted") {
//            if (_video && !checkCam())
//                return;
//            makeConnection();
//        }
//        if (e.code == "Microphone.Muted" || e.code == "Camera.Muted") {
//            cleanupPublishedStream(MicCamMute);
////            Security.showSettings(SecurityPanel.PRIVACY);
//        } else {
//            makeConnection();
//        }

//        private function statusHandler(e:StatusEvent):void {
//            trace("e.code", e.code);
//            if (e.code == "Microphone.Muted")
//                checkCam();
//            if (e.code == "Camera.Muted") {
//                checkMic();
//            }
////        cleanupPublishedStream(MicCamMute);
//            makeConnection();
//
//        }
    }

//    private function noCamMicAlert(message:String):void {
//        dispatchEvent(new UIEvent(PublishError, message));
//    }
}
}
