import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';
import '../services/api_service.dart';

class VoiceState {
  final Room? room;
  final String? currentChannelId;
  final List<String> participantIds; // Store participant IDs instead of RemoteParticipant objects
  final bool isConnecting;
  final bool isConnected;
  final String? error;

  const VoiceState({
    this.room,
    this.currentChannelId,
    this.participantIds = const [],
    this.isConnecting = false,
    this.isConnected = false,
    this.error,
  });

  VoiceState copyWith({
    Room? room,
    String? currentChannelId,
    List<String>? participantIds,
    bool? isConnecting,
    bool? isConnected,
    String? error,
  }) {
    return VoiceState(
      room: room ?? this.room,
      currentChannelId: currentChannelId ?? this.currentChannelId,
      participantIds: participantIds ?? this.participantIds,
      isConnecting: isConnecting ?? this.isConnecting,
      isConnected: isConnected ?? this.isConnected,
      error: error,
    );
  }
}

final voiceProvider = StateNotifierProvider<VoiceController, VoiceState>((ref) {
  return VoiceController(ref);
});

class VoiceController extends StateNotifier<VoiceState> {
  final Ref ref;

  VoiceController(this.ref) : super(const VoiceState());

  Future<void> joinVoice(String channelId) async {
    if (state.isConnecting || state.isConnected) {
      print('Voice: Already connecting or connected, ignoring join request');
      return;
    }

    try {
      print('Voice: Starting to join voice for channel $channelId');
      state = state.copyWith(isConnecting: true, error: null);

      final apiService = ref.read(apiServiceProvider);
      print('Voice: Calling API to get join token...');
      final joinData = await apiService.joinVoice(channelId);
      print('Voice: Got join data - serverUrl: ${joinData.serverUrl}, token: ${joinData.token.substring(0, 20)}...');

      // Create room options
      final roomOptions = RoomOptions(
        adaptiveStream: true,
        dynacast: true,
        defaultAudioCaptureOptions: const AudioCaptureOptions(
          echoCancellation: true,
          noiseSuppression: true,
          autoGainControl: true,
        ),
      );

      // Create and connect to room
      print('Voice: Creating Room instance...');
      final room = Room();
      
      print('Voice: Connecting to LiveKit room...');
      await room.connect(
        joinData.serverUrl,
        joinData.token,
        roomOptions: roomOptions,
      );
      print('Voice: Connected to LiveKit room successfully');

      // Enable microphone
      print('Voice: Enabling microphone...');
      await room.localParticipant?.setMicrophoneEnabled(true);
      print('Voice: Microphone enabled');

      // Set up event listeners
      room.addListener(() {
        // Update participants when room state changes
        // The listener will be called when participants join/leave
        _updateParticipants();
      });

      _updateParticipants();

      print('Voice: Updating state - connected: true, channelId: $channelId');
      state = state.copyWith(
        room: room,
        currentChannelId: channelId,
        isConnecting: false,
        isConnected: true,
        error: null,
      );
      print('Voice: State updated successfully');
    } catch (e, stackTrace) {
      print('Voice: Error joining voice: $e');
      print('Voice: Stack trace: $stackTrace');
      state = state.copyWith(
        isConnecting: false,
        isConnected: false,
        error: e.toString(),
      );
    }
  }

  void _updateParticipants() {
    final room = state.room;
    if (room == null) return;

    // Get all participant IDs including local participant
    final participantIds = <String>[];
    try {
      // Get local participant's identity
      final localParticipant = room.localParticipant;
      if (localParticipant?.identity != null) {
        participantIds.add(localParticipant!.identity);
      }
      
      // Get all remote participants' identities
      for (var participant in room.participants.values) {
        final identity = participant.identity;
        if (!participantIds.contains(identity)) {
          // Avoid duplicates (in case local participant is also in the list)
          participantIds.add(identity);
        }
      }
    } catch (e) {
      // If access fails, participants list will be empty
      // The listener will still trigger updates when participants change
    }
    
    // Update state with participant IDs
    state = state.copyWith(participantIds: participantIds);
  }

  Future<void> leaveVoice() async {
    final room = state.room;
    final channelId = state.currentChannelId;

    if (room != null) {
      try {
        await room.disconnect();
      } catch (e) {
        // Ignore errors during disconnect
      }
    }

    if (channelId != null) {
      try {
        final apiService = ref.read(apiServiceProvider);
        await apiService.leaveVoice();
      } catch (e) {
        // Log error but continue with cleanup
      }
    }

    state = const VoiceState();
  }

  Future<void> toggleMicrophone() async {
    final room = state.room;
    if (room == null) return;

    final localParticipant = room.localParticipant;
    if (localParticipant == null) return;

    final isEnabled = localParticipant.isMicrophoneEnabled();
    await localParticipant.setMicrophoneEnabled(!isEnabled);
  }

  bool isMicrophoneEnabled() {
    final room = state.room;
    if (room == null) return false;
    return room.localParticipant?.isMicrophoneEnabled() ?? false;
  }

  @override
  void dispose() {
    final room = state.room;
    if (room != null) {
      room.disconnect();
    }
    super.dispose();
  }
}

