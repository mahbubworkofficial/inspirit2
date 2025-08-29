import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../res/app_url/app_url.dart';
import '../../../../res/components/api_service.dart';
import '../../../../widgets/show_custom_snack_ber.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class ChatController extends GetxController {
  final ApiService apiService = ApiService();
  final AuthController authController = Get.find<AuthController>();
  final ProfileController profileController = Get.put(ProfileController());

  // Messages for current chat room
  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  final RxString message = ''.obs;
  final RxBool isTyping = false.obs;
  final TextEditingController textController = TextEditingController();
  final RxBool isMessageLoading = false.obs;

  WebSocketChannel? channel;
  int? currentRoomId;


  // Initialize chat for a specific room
  Future<void> initializeChat(int roomId) async {
    currentRoomId = roomId;
    messages.clear(); // Clear previous messages

    // Fetch existing messages
    await fetchMessages(roomId);

    // Connect to WebSocket
    _connectWebSocket(roomId);
  }

  // Fetch messages from the API
  Future<void> fetchMessages(int roomId) async {
    final token = authController.accessToken.value;
    isMessageLoading(true);

    try {
      final response = await apiService.fetchMessages(roomId.toString(), token);
      debugPrint("Response from API: ${response['statusCode']}");

      if (response['statusCode'] == 200) {
        final List<dynamic> messageData = response['data'];
        messages.assignAll(messageData.cast<Map<String, dynamic>>());
      } else {
        showCustomSnackBar(
            title: 'Error',
            message: response['data']['error'] ?? 'Failed to load messages',
            isSuccess: false
        );
      }
    } catch (e) {
      debugPrint('Error fetching messages: $e');
      showCustomSnackBar(
          title: 'Error',
          message: 'Failed to load messages',
          isSuccess: false
      );
    } finally {
      isMessageLoading(false);
    }
  }

  // Connect to WebSocket
  void _connectWebSocket(int roomId) {
    // Close existing connection if any
    channel?.sink.close();

    final token = authController.accessToken.value;
    final url = 'wss://circle-oxygen-verification-postal.trycloudflare.com/users/chat/$roomId/?token=$token';

    debugPrint('Connecting to WebSocket: $url');

    try {
      channel = WebSocketChannel.connect(Uri.parse(url));

      // Listen for messages from WebSocket
      channel!.stream.listen(
            (data) {
          debugPrint('WebSocket received: $data');
          try {
            final decodedData = jsonDecode(data);

            // Handle the WebSocket response format
            if (decodedData is Map<String, dynamic>) {
              // Create a message object matching the API format
              final newMessage = {
                'id': DateTime.now().millisecondsSinceEpoch, // Temporary ID
                'room': roomId,
                'sender': decodedData['sender'] ?? '',
                'content': decodedData['message'] ?? '',
                'timestamp': decodedData['timestamp'] ?? DateTime.now().toIso8601String(),
                'is_read': false,
              };

              // Add to messages list
              messages.add(newMessage);
            }
          } catch (e) {
            debugPrint('Error parsing WebSocket message: $e');
          }
        },
        onError: (error) {
          debugPrint("WebSocket Error: $error");
          showCustomSnackBar(
            title: 'Connection Error',
            message: 'Lost connection to chat',
            isSuccess: false,
          );
        },
        onDone: () {
          debugPrint("WebSocket connection closed");
        },
      );
    } catch (e) {
      debugPrint('Error connecting to WebSocket: $e');
      showCustomSnackBar(
        title: 'Connection Error',
        message: 'Failed to connect to chat',
        isSuccess: false,
      );
    }
  }

  // Send message through WebSocket
  void sendMessage() {
    if (message.value.trim().isEmpty || channel == null || currentRoomId == null) {
      return;
    }

    final messageContent = {
      'message': message.value.trim(), // Note: API expects 'message' not 'content'
    };

    try {
      // Send message to WebSocket
      channel!.sink.add(jsonEncode(messageContent));
      debugPrint('Sent message: ${jsonEncode(messageContent)}');

      // Add message to local list immediately for better UX
      final localMessage = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'room': currentRoomId,
        'sender': profileController.userName.value,
        'content': message.value.trim(),
        'timestamp': DateTime.now().toIso8601String(),
        'is_read': false,
      };
      messages.add(localMessage);

      // Clear message field
      message.value = '';
      textController.clear();
    } catch (e) {
      debugPrint('Error sending message: $e');
      showCustomSnackBar(
        title: 'Error',
        message: 'Failed to send message',
        isSuccess: false,
      );
    }
  }

  // Clean up when leaving chat
  void cleanupChat() {
    channel?.sink.close();
    channel = null;
    currentRoomId = null;
    messages.clear();
    textController.clear();
    message.value = '';
  }

  /// Chat room state
  final RxBool isRoomLoading = false.obs;
  final RxBool isRoomsLoading = false.obs;
  final RxString chatError = ''.obs;
  final RxString roomsError = ''.obs;
  final RxnInt roomId = RxnInt();
  final rooms = <Map<String, dynamic>>[].obs;

  String makeAbsolutePhoto(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    final host = AppUrl.chatRoomsUrl;
    final p = path.startsWith('/') ? path : '/$path';
    final normalized = p.contains('/media/') ? p : '/media$p';
    return '$host$normalized';
  }

  Future<void> fetchRooms() async {
    roomsError.value = '';
    final token = authController.accessToken.value;
    if (token.isEmpty) {
      roomsError.value = 'Please log in to view chats';
      showCustomSnackBar(title: 'Error', message: roomsError.value, isSuccess: false);
      return;
    }

    isRoomsLoading(true);
    try {
      final res = await apiService.fetchChatRooms(token);
      if (res['statusCode'] == 200) {
        final list = (res['data'] as List).cast<Map<String, dynamic>>();
        for (final room in list) {
          if (room['participants'] is List) {
            final parts = room['participants'] as List;
            for (final p in parts) {
              if (p is Map && p['profile_photo'] is String) {
                p['profile_photo'] = makeAbsolutePhoto(p['profile_photo']);
              }
            }
          }
        }
        rooms.assignAll(list);
      } else {
        roomsError.value = res['data']['error'] ?? 'Failed to load chat rooms';
        showCustomSnackBar(title: 'Error', message: roomsError.value, isSuccess: false);
      }
    } catch (e, st) {
      debugPrint('fetchRooms error: $e\n$st');
      roomsError.value = 'Failed to load chat rooms: $e';
      showCustomSnackBar(title: 'Error', message: roomsError.value, isSuccess: false);
    } finally {
      isRoomsLoading(false);
    }
  }

  Map<String, dynamic>? firstParticipant(Map<String, dynamic> room) {
    final parts = room['participants'];
    if (parts is List && parts.isNotEmpty) {
      final p = parts.first;
      return (p is Map<String, dynamic>) ? p : null;
    }
    return null;
  }

  String roomTitle(Map<String, dynamic> room) {
    final p = firstParticipant(room);
    if (p == null) return 'Unknown';
    return (p['name'] as String?)?.trim().isNotEmpty == true
        ? p['name']
        : ((p['username'] as String?)?.trim().isNotEmpty == true
        ? p['username']
        : 'User #${p['id']}');
  }

  String? roomAvatar(Map<String, dynamic> room) {
    final p = firstParticipant(room);
    return p?['profile_photo'] as String?;
  }

  String lastMessageText(Map<String, dynamic> room) {
    final lm = room['last_message'];
    return (lm is String && lm.trim().isNotEmpty) ? lm : 'No messages yet';
  }

  Future<void> openWithParticipants(List<int> participants) async {
    chatError.value = '';
    if (participants.length < 2) {
      chatError.value = 'Need two participants';
      showCustomSnackBar(
        title: 'Error',
        message: chatError.value,
        isSuccess: false,
      );
      return;
    }

    final token = authController.accessToken.value;
    if (token.isEmpty) {
      chatError.value = 'Please log in';
      showCustomSnackBar(
        title: 'Error',
        message: chatError.value,
        isSuccess: false,
      );
      return;
    }

    isRoomLoading(true);
    try {
      final res = await apiService.createOrGetChatRoom(
        token,
        participants: participants,
      );
      if (res['statusCode'] == 200) {
        final data = res['data'] as Map<String, dynamic>;
        roomId.value = (data['id'] as num).toInt();
        if (data['messages'] is List) {
          messages.assignAll(
            (data['messages'] as List).cast<Map<String, dynamic>>(),
          );
        } else {
          messages.clear();
        }
      } else {
        chatError.value = res['data']['error'] ?? 'Failed to open chat room';
        showCustomSnackBar(
          title: 'Error',
          message: chatError.value,
          isSuccess: false,
        );
      }
    } catch (e, st) {
      debugPrint('openWithParticipants error: $e\n$st');
      chatError.value = 'Failed to open chat room: $e';
      showCustomSnackBar(
        title: 'Error',
        message: chatError.value,
        isSuccess: false,
      );
    } finally {
      isRoomLoading(false);
    }
  }

  Future<void> openWithOtherUser({
    required int otherUserId,
    required int currentUserId,
  }) async {
    final ids = <int>{currentUserId, otherUserId}.toList();
    await openWithParticipants(ids);
  }

  // UI state variables
  RxBool isrequestsent = false.obs;
  RxString searchQuery = ''.obs;
  RxBool isuserblocked = false.obs;
  RxBool istapped = false.obs;
  Rxn<File> pickedImage = Rxn<File>();
  RxSet<String> selectedUsers = <String>{}.obs;
  var selectedGroupType = 'Public'.obs;

  void toggleSelection(String name) {
    if (selectedUsers.contains(name)) {
      selectedUsers.remove(name);
    } else {
      selectedUsers.add(name);
    }
  }

  bool isSelected(String name) {
    return selectedUsers.contains(name);
  }

  @override
  void onClose() {
    textController.dispose();
    channel?.sink.close();
    super.onClose();
  }

  final List<String> names = [
    'Livia Workman',
    'Ethan Rivers',
    'Mila Greene',
    'Noah Carter',
    'Ava Brooks',
    'Lucas Hale',
    'Emma Stone',
    'Liam Woods',
    'Olivia West',
    'Mason Hayes',
    'Isla Knight',
    'Elijah Ford',
    'Chloe Ray',
    'Logan King',
    'Sofia Lane',
    'James Cole',
    'Amelia Blake',
  ];
}