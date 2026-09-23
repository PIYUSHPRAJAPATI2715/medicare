import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';

enum AgoraCallType { video, audio }

enum AgoraConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  ended,
}

class AgoraChannelSession {
  final String appId;
  final String appCertificate;
  final String channelName;
  final int localUid;
  final int remoteDoctorUid;
  final String token;
  final AgoraCallType callType;
  final DateTime joinedAt;

  AgoraChannelSession({
    required this.appId,
    required this.appCertificate,
    required this.channelName,
    required this.localUid,
    required this.remoteDoctorUid,
    required this.token,
    required this.callType,
    required this.joinedAt,
  });
}

class AgoraService extends ChangeNotifier {
  static final AgoraService _instance = AgoraService._internal();
  factory AgoraService() => _instance;
  AgoraService._internal();

  AgoraConnectionState _connectionState = AgoraConnectionState.disconnected;
  AgoraChannelSession? _activeSession;

  bool _isMuted = false;
  bool _isVideoDisabled = false;
  bool _isSpeakerOn = true;
  bool _isFrontCamera = true;
  int _latencyMs = 24;
  int _callDurationSeconds = 0;
  Timer? _durationTimer;
  Timer? _latencyTimer;

  // Getters
  AgoraConnectionState get connectionState => _connectionState;
  AgoraChannelSession? get activeSession => _activeSession;
  bool get isMuted => _isMuted;
  bool get isVideoDisabled => _isVideoDisabled;
  bool get isSpeakerOn => _isSpeakerOn;
  bool get isFrontCamera => _isFrontCamera;
  int get latencyMs => _latencyMs;
  int get callDurationSeconds => _callDurationSeconds;
  String get appId => AppConstants.agoraAppId;
  String get channelId => _activeSession?.channelName ?? AppConstants.agoraDefaultChannel;

  /// Generate deterministic token for Agora Channel
  String generateToken({
    required String channelName,
    required int uid,
    int expirationSeconds = 3600,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    // Format standardized Agora token signature preview
    return '006${AppConstants.agoraAppId}IAC${uid}T${timestamp + expirationSeconds}X${AppConstants.agoraAppCertificate.substring(0, 8)}';
  }

  /// Initialize and join consultation room
  Future<bool> joinConsultation({
    required String doctorId,
    required String patientId,
    required AgoraCallType callType,
    String? customChannel,
  }) async {
    _connectionState = AgoraConnectionState.connecting;
    notifyListeners();

    final channelName = customChannel ?? '${AppConstants.agoraDefaultChannel}-$doctorId';
    final localUid = 1000 + (DateTime.now().millisecondsSinceEpoch % 9000);
    final remoteDoctorUid = 2000 + (doctorId.hashCode.abs() % 9000);

    final token = generateToken(channelName: channelName, uid: localUid);

    // Simulate Agora handshake latency
    await Future.delayed(const Duration(milliseconds: 600));

    _activeSession = AgoraChannelSession(
      appId: AppConstants.agoraAppId,
      appCertificate: AppConstants.agoraAppCertificate,
      channelName: channelName,
      localUid: localUid,
      remoteDoctorUid: remoteDoctorUid,
      token: token,
      callType: callType,
      joinedAt: DateTime.now(),
    );

    _connectionState = AgoraConnectionState.connected;
    _callDurationSeconds = 0;
    _isMuted = false;
    _isVideoDisabled = false;
    _isSpeakerOn = true;
    _isFrontCamera = true;

    // Start timer for duration
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _callDurationSeconds++;
      notifyListeners();
    });

    // Network jitter simulation
    _latencyTimer?.cancel();
    _latencyTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      _latencyMs = 20 + (DateTime.now().second % 15);
      notifyListeners();
    });

    notifyListeners();
    return true;
  }

  /// Toggle Audio Mute
  void toggleMute() {
    _isMuted = !_isMuted;
    notifyListeners();
  }

  /// Toggle Local Video Camera
  void toggleVideo() {
    _isVideoDisabled = !_isVideoDisabled;
    notifyListeners();
  }

  /// Switch between Front and Rear Camera
  void switchCamera() {
    _isFrontCamera = !_isFrontCamera;
    notifyListeners();
  }

  /// Toggle Speakerphone
  void toggleSpeaker() {
    _isSpeakerOn = !_isSpeakerOn;
    notifyListeners();
  }

  /// End Agora Call Session
  Future<void> endCall() async {
    _durationTimer?.cancel();
    _latencyTimer?.cancel();
    _durationTimer = null;
    _latencyTimer = null;
    _connectionState = AgoraConnectionState.ended;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));
    _activeSession = null;
    _connectionState = AgoraConnectionState.disconnected;
    _callDurationSeconds = 0;
    notifyListeners();
  }
}
