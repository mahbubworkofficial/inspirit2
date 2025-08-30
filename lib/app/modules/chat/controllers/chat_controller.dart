import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jordyn/app/modules/chat/controllers/web_socket_service.dart';

import '../../../../res/app_url/app_url.dart';
import '../../../../res/components/api_service.dart';
import '../../../../widgets/show_custom_snack_ber.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class ChatController extends GetxController {
  final ApiService apiService = ApiService();
  final AuthController authController = Get.find<AuthController>();
  final ProfileController profileController = Get.put(ProfileController());

  // WebSocket Service
  WebSocketService? _wsService;

  // Messages for current chat room
  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  final RxString message = ''.obs;
  final RxBool isTyping = false.obs;
  final TextEditingController textController = TextEditingController();
  final RxBool isMessageLoading = false.obs;

  // File handling
  final ImagePicker _picker = ImagePicker();
  final RxBool isFileUploading = false.obs;

  // Add scroll controller reference
  ScrollController? scrollController;

  int? currentRoomId;

  // Set scroll controller reference
  void setScrollController(ScrollController controller) {
    scrollController = controller;
  }

  // Scroll to bottom method
  void scrollToBottom({bool animate = true}) {
    if (scrollController?.hasClients == true) {
      if (animate) {
        scrollController!.animateTo(
          scrollController!.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        scrollController!.jumpTo(scrollController!.position.maxScrollExtent);
      }
    }
  }

  // Initialize chat for a specific room
  Future<void> initializeChat(int roomId) async {
    currentRoomId = roomId;
    messages.clear(); // Clear previous messages

    // Disconnect existing WebSocket if any
    _wsService?.disconnect();

    // Fetch existing messages
    await fetchMessages(roomId);

    // Connect to WebSocket using service
    _connectWebSocket(roomId);

    // Scroll to bottom after loading messages
    Future.delayed(const Duration(milliseconds: 500), () => scrollToBottom());
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

        // Scroll to bottom after fetching messages
        Future.delayed(const Duration(milliseconds: 300), () => scrollToBottom());
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

  // Connect to WebSocket using service
  void _connectWebSocket(int roomId) {
    final token = authController.accessToken.value;

    _wsService = WebSocketService(token);

    _wsService!.connect(
      roomId,
      onMessage: (data) {
        _handleWebSocketMessage(data, roomId);
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
  }

  // Handle incoming WebSocket messages
  void _handleWebSocketMessage(Map<String, dynamic> data, int roomId) {
    try {
      // Handle different message types
      if (data.containsKey('typing')) {
        // Handle typing indicator
        final senderUsername = data['sender'] ?? '';
        final currentUsername = profileController.userName.value;

        if (senderUsername != currentUsername) {
          isTyping.value = data['typing'] ?? false;
        }
        return;
      }

      // Handle regular messages (text, image, file)
      final newMessage = {
        'id': data['id'] ?? DateTime.now().millisecondsSinceEpoch,
        'room': roomId,
        'sender': data['sender'] ?? '',
        'content': data['message'] ?? '',
        'file': data['file'],
        'file_name': data['file_name'],
        'file_type': data['file_type'],
        'image': data['image'],
        'timestamp': data['timestamp'] ?? DateTime.now().toIso8601String(),
        'is_read': false,
      };

      // Add to messages list
      messages.add(newMessage);

      // Scroll to bottom when new message arrives
      Future.delayed(const Duration(milliseconds: 100), () => scrollToBottom());
    } catch (e) {
      debugPrint('Error handling WebSocket message: $e');
    }
  }

  // Send text message
  void sendMessage() {
    if (message.value.trim().isEmpty || _wsService == null || !_wsService!.isConnected) {
      debugPrint('Cannot send message - no content or not connected');
      return;
    }

    try {
      _wsService!.sendMessage(message.value.trim());

      // Clear message field
      message.value = '';
      textController.clear();

      debugPrint('Message sent successfully');
    } catch (e) {
      debugPrint('Error sending message: $e');
      showCustomSnackBar(
        title: 'Error',
        message: 'Failed to send message',
        isSuccess: false,
      );
    }
  }

  // Send image
  Future<void> sendImage({ImageSource source = ImageSource.gallery, required File file}) async {
    if (_wsService == null || !_wsService!.isConnected) {
      showCustomSnackBar(
        title: 'Error',
        message: 'Not connected to chat',
        isSuccess: false,
      );
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return;

      isFileUploading(true);

      final Uint8List bytes = await image.readAsBytes();
      final fileName = image.name;

      _wsService!.sendImage(
        bytes,
        fileName: fileName,
        caption: message.value.trim().isNotEmpty ? message.value.trim() : null,
      );

      // Clear caption if any
      if (message.value.trim().isNotEmpty) {
        message.value = '';
        textController.clear();
      }

      debugPrint('Image sent: $fileName');

    } catch (e) {
      debugPrint('Error sending image: $e');
      showCustomSnackBar(
        title: 'Error',
        message: 'Failed to send image',
        isSuccess: false,
      );
    } finally {
      isFileUploading(false);
    }
  }

  // Send file (for future use)
  Future<void> sendFile(File file) async {
    if (_wsService == null || !_wsService!.isConnected) {
      showCustomSnackBar(
        title: 'Error',
        message: 'Not connected to chat',
        isSuccess: false,
      );
      return;
    }

    try {
      isFileUploading(true);

      final Uint8List bytes = await file.readAsBytes();
      final fileName = file.path.split('/').last;
      final fileExtension = fileName.split('.').last.toLowerCase();

      String fileType = 'file';
      if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(fileExtension)) {
        fileType = 'image';
      } else if (['mp4', 'mov', 'avi', 'mkv'].contains(fileExtension)) {
        fileType = 'video';
      } else if (['pdf', 'doc', 'docx', 'txt'].contains(fileExtension)) {
        fileType = 'document';
      }

      _wsService!.sendFile(
        bytes,
        fileName: fileName,
        fileType: fileType,
        caption: message.value.trim().isNotEmpty ? message.value.trim() : null,
      );

      // Clear caption if any
      if (message.value.trim().isNotEmpty) {
        message.value = '';
        textController.clear();
      }

      debugPrint('File sent: $fileName');

    } catch (e) {
      debugPrint('Error sending file: $e');
      showCustomSnackBar(
        title: 'Error',
        message: 'Failed to send file',
        isSuccess: false,
      );
    } finally {
      isFileUploading(false);
    }
  }

  // Send typing status
  void sendTypingStatus(bool typing) {
    if (_wsService != null && _wsService!.isConnected) {
      _wsService!.sendTypingStatus(typing);
    }
  }

  // Handle text field changes
  void onTextChanged(String value) {
    message.value = value;

    // Send typing indicator
    if (value.isNotEmpty && !isTyping.value) {
      sendTypingStatus(true);
      isTyping.value = true;
    } else if (value.isEmpty && isTyping.value) {
      sendTypingStatus(false);
      isTyping.value = false;
    }

    // Auto-scroll when typing
    Future.delayed(const Duration(milliseconds: 100), () {
      scrollToBottom();
    });
  }

  // Clean up when leaving chat
  void cleanupChat() {
    _wsService?.disconnect();
    _wsService = null;
    currentRoomId = null;
    messages.clear();
    textController.clear();
    message.value = '';
    isTyping.value = false;
    scrollController = null;
  }

  /// Chat room state (existing code remains the same)
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

        // Scroll to bottom after opening room
        Future.delayed(const Duration(milliseconds: 300), () => scrollToBottom());
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
    _wsService?.disconnect();
    scrollController = null;
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