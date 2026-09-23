import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/constants/app_constants.dart';

enum AgoraCallType { video, audio }

enum AgoraEngineStatus {
  idle,
  requestingPermissions,
  initializing,
  joining,
  joined,
  reconnecting,
  error,
  left,
}

class AgoraService extends ChangeNotifier {
  static final AgoraService _instance = AgoraService._internal();
  factory AgoraService() => _instance;
  AgoraService._internal();

  RtcEngine? _engine;
  AgoraEngineStatus _status = AgoraEngineStatus.idle;
  String _channelName = AppConstants.agoraDefaultChannel;
  int? _remoteUid;
  bool _isLocalJoined = false;
  bool _isMuted = false;
  bool _isVideoOff = false;
  bool _isSpeaker = true;
  bool _isFrontCamera = true;
  int _latencyMs = 28;
  String? _errorMessage;
  int _callDurationSeconds = 0;
  Timer? _durationTimer;

  // Getters
  RtcEngine? get engine => _engine;
  AgoraEngineStatus get status => _status;
  String get channelName => _channelName;
  int? get remoteUid => _remoteUid;
  bool get isLocalJoined => _isLocalJoined;
  bool get isMuted => _isMuted;
  bool get isVideoOff => _isVideoOff;
  bool get isSpeaker => _isSpeaker;
  bool get isFrontCamera => _isFrontCamera;
  int get latencyMs => _latencyMs;
  String? get errorMessage => _errorMessage;
  int get callDurationSeconds => _callDurationSeconds;

  /// Request runtime permissions for Camera and Microphone
  Future<bool> requestPermissions(AgoraCallType callType) async {
    _status = AgoraEngineStatus.requestingPermissions;
    notifyListeners();

    if (callType == AgoraCallType.video) {
      final statuses = await [
        Permission.camera,
        Permission.microphone,
      ].request();

      final cameraGranted = statuses[Permission.camera]?.isGranted ?? false;
      final micGranted = statuses[Permission.microphone]?.isGranted ?? false;

      if (!cameraGranted || !micGranted) {
        _status = AgoraEngineStatus.error;
        _errorMessage = 'Camera and Microphone permissions are required for Video Calls.';
        notifyListeners();
        return false;
      }
    } else {
      final micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted) {
        _status = AgoraEngineStatus.error;
        _errorMessage = 'Microphone permission is required for Audio Calls.';
        notifyListeners();
        return false;
      }
    }

    return true;
  }

  /// Initialize real Agora RTC Engine
  Future<bool> initializeEngine() async {
    if (_engine != null) return true;

    try {
      _status = AgoraEngineStatus.initializing;
      notifyListeners();

      _engine = createAgoraRtcEngine();
      await _engine!.initialize(
        const RtcEngineContext(
          appId: AppConstants.agoraAppId,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );

      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            _isLocalJoined = true;
            _status = AgoraEngineStatus.joined;
            _errorMessage = null;
            notifyListeners();
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            _remoteUid = remoteUid;
            notifyListeners();
          },
          onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
            if (_remoteUid == remoteUid) {
              _remoteUid = null;
            }
            notifyListeners();
          },
          onRtcStats: (RtcConnection connection, RtcStats stats) {
            if (stats.lastmileDelay != null && stats.lastmileDelay! > 0) {
              _latencyMs = stats.lastmileDelay!;
              notifyListeners();
            }
          },
          onError: (ErrorCodeType err, String msg) {
            _errorMessage = 'Agora RTC Error ($err): $msg';
            notifyListeners();
          },
          onLeaveChannel: (RtcConnection connection, RtcStats stats) {
            _isLocalJoined = false;
            _remoteUid = null;
            _status = AgoraEngineStatus.left;
            notifyListeners();
          },
        ),
      );

      return true;
    } catch (e) {
      _status = AgoraEngineStatus.error;
      _errorMessage = 'Failed to initialize Agora RTC Engine: $e';
      notifyListeners();
      return false;
    }
  }

  /// Join real Agora Video Call Room
  Future<bool> joinVideoCall({
    String? channel,
    int uid = 0,
    String? token,
  }) async {
    final hasPermissions = await requestPermissions(AgoraCallType.video);
    if (!hasPermissions) return false;

    final initSuccess = await initializeEngine();
    if (!initSuccess || _engine == null) return false;

    try {
      _channelName = channel ?? AppConstants.agoraDefaultChannel;
      _status = AgoraEngineStatus.joining;
      _remoteUid = null;
      _isLocalJoined = false;
      _isMuted = false;
      _isVideoOff = false;
      _isSpeaker = true;
      _isFrontCamera = true;
      _callDurationSeconds = 0;
      notifyListeners();

      // Enable Real Video and start local camera preview
      await _engine!.enableVideo();
      await _engine!.startPreview();
      await _engine!.setEnableSpeakerphone(true);

      // Join Channel using provided App ID & Channel
      await _engine!.joinChannel(
        token: token ?? '',
        channelId: _channelName,
        uid: uid,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
        ),
      );

      _startTimer();
      return true;
    } catch (e) {
      _status = AgoraEngineStatus.error;
      _errorMessage = 'Failed to join video channel: $e';
      notifyListeners();
      return false;
    }
  }

  /// Join real Agora Audio Call Room
  Future<bool> joinAudioCall({
    String? channel,
    int uid = 0,
    String? token,
  }) async {
    final hasPermissions = await requestPermissions(AgoraCallType.audio);
    if (!hasPermissions) return false;

    final initSuccess = await initializeEngine();
    if (!initSuccess || _engine == null) return false;

    try {
      _channelName = channel ?? AppConstants.agoraDefaultChannel;
      _status = AgoraEngineStatus.joining;
      _remoteUid = null;
      _isLocalJoined = false;
      _isMuted = false;
      _isVideoOff = true;
      _isSpeaker = true;
      _callDurationSeconds = 0;
      notifyListeners();

      await _engine!.enableAudio();
      await _engine!.disableVideo();
      await _engine!.setEnableSpeakerphone(true);

      await _engine!.joinChannel(
        token: token ?? '',
        channelId: _channelName,
        uid: uid,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
          publishCameraTrack: false,
          publishMicrophoneTrack: true,
          autoSubscribeAudio: true,
          autoSubscribeVideo: false,
        ),
      );

      _startTimer();
      return true;
    } catch (e) {
      _status = AgoraEngineStatus.error;
      _errorMessage = 'Failed to join audio channel: $e';
      notifyListeners();
      return false;
    }
  }

  void _startTimer() {
    _durationTimer?.cancel();
    _callDurationSeconds = 0;
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _callDurationSeconds++;
      notifyListeners();
    });
  }

  /// Toggle Audio Mute on Agora RTC
  Future<void> toggleMute() async {
    if (_engine == null) return;
    _isMuted = !_isMuted;
    await _engine!.muteLocalAudioStream(_isMuted);
    notifyListeners();
  }

  /// Toggle Video Camera on Agora RTC
  Future<void> toggleVideo() async {
    if (_engine == null) return;
    _isVideoOff = !_isVideoOff;
    await _engine!.muteLocalVideoStream(_isVideoOff);
    if (_isVideoOff) {
      await _engine!.stopPreview();
    } else {
      await _engine!.startPreview();
    }
    notifyListeners();
  }

  /// Switch between Front and Rear Camera on Agora RTC
  Future<void> switchCamera() async {
    if (_engine == null) return;
    await _engine!.switchCamera();
    _isFrontCamera = !_isFrontCamera;
    notifyListeners();
  }

  /// Toggle Speakerphone on Agora RTC
  Future<void> toggleSpeaker() async {
    if (_engine == null) return;
    _isSpeaker = !_isSpeaker;
    await _engine!.setEnableSpeakerphone(_isSpeaker);
    notifyListeners();
  }

  /// Leave Channel and release Agora RTC
  Future<void> leaveChannel() async {
    _durationTimer?.cancel();
    _durationTimer = null;

    if (_engine != null) {
      try {
        await _engine!.stopPreview();
        await _engine!.leaveChannel();
      } catch (_) {}
    }

    _isLocalJoined = false;
    _remoteUid = null;
    _status = AgoraEngineStatus.left;
    _callDurationSeconds = 0;
    notifyListeners();
  }

  /// Dispose entire Agora engine when no longer needed
  Future<void> destroyEngine() async {
    await leaveChannel();
    if (_engine != null) {
      try {
        await _engine!.release();
      } catch (_) {}
      _engine = null;
    }
    _status = AgoraEngineStatus.idle;
    notifyListeners();
  }
}
