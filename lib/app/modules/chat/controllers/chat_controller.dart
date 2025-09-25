import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jordyn/app/modules/chat/controllers/web_socket_service.dart';

import '../../../../res/app_url/app_url.dart';
import '../../../../res/components/api_service.dart';
import '../../../../widgets/show_custom_snack_bar.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class ChatController extends GetxController {
  final ApiService apiService = ApiService();
  final AuthController authController = Get.find<AuthController>();
  final ProfileController profileController = Get.put(ProfileController());

  WebSocketService? _wsService;

  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  final RxString message = ''.obs;
  final RxBool isTyping = false.obs;
  final TextEditingController textController = TextEditingController();
  final RxBool isMessageLoading = false.obs;
  final RxBool isRoomLoading = false.obs;
  final RxBool isRoomsLoading = false.obs;
  final RxString chatError = ''.obs;
  final RxString roomsError = ''.obs;
  final RxnInt roomId = RxnInt();
  final rooms = <Map<String, dynamic>>[].obs;
  final ImagePicker _picker = ImagePicker();
  final RxBool isFileUploading = false.obs;

  ScrollController? scrollController;

  int? currentRoomId;


  String makeAbsolutePhoto(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    final host = AppUrl.chatRoomsUrl;
    final p = path.startsWith('/') ? path : '/$path';
    final normalized = p.contains('/media/') ? p : '/media$p';
    return '$host$normalized';
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
  }void setScrollController(ScrollController controller) {
    scrollController = controller;
  }

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

  void sendMessage() {
    if (message.value.trim().isEmpty ||
        _wsService == null ||
        !_wsService!.isConnected) {
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
  }  void sendTypingStatus(bool typing) {
    if (_wsService != null && _wsService!.isConnected) {
      _wsService!.sendTypingStatus(typing);
    }
  }

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

  Future<void> fetchMessages(int roomId) async {
    final token = authController.accessToken.value;
    final refresh = authController.refreshToken.value;
    isMessageLoading(true);

    try {
      final response = await apiService.fetchMessages(roomId.toString(), token);
      debugPrint("Response from API: ${response['statusCode']}");

      if (response['statusCode'] == 200) {
        final List<dynamic> messageData = response['data'];
        messages.assignAll(messageData.cast<Map<String, dynamic>>());

        // Scroll to bottom after fetching messages
        Future.delayed(
          const Duration(milliseconds: 300),
              () => scrollToBottom(),
        );
      } else if (response['statusCode'] == 401) {
        final refreshed = await authController.refreshAccessToken();
        if (refreshed) {
          final newToken = await authController.getAccessToken();
          final retryResponse = await apiService.fetchMessages(roomId.toString(), newToken!);
          debugPrint("Retry Response from API: ${retryResponse['statusCode']}");

          if (retryResponse['statusCode'] == 200) {
            final List<dynamic> messageData = retryResponse['data'];
            messages.assignAll(messageData.cast<Map<String, dynamic>>());

            Future.delayed(
              const Duration(milliseconds: 300),
                  () => scrollToBottom(),
            );
          } else {
            final errorMsg = retryResponse['data']['error'] ?? 'Failed to load messages after token refresh';
            showCustomSnackBar(
              title: 'Error',
              message: errorMsg,
              isSuccess: false,
            );
            Get.offAllNamed('/login');
          }
        } else {
          showCustomSnackBar(
            title: 'Error',
            message: 'Failed to refresh token. Please log in again.',
            isSuccess: false,
          );
          Get.offAllNamed('/login');
        }
      } else {
        showCustomSnackBar(
          title: 'Error',
          message: response['data']['error'] ?? 'Failed to load messages',
          isSuccess: false,
        );
      }
    } catch (e) {
      debugPrint('Error fetching messages: $e');
      showCustomSnackBar(
        title: 'Error',
        message: 'Failed to load messages',
        isSuccess: false,
      );
    } finally {
      isMessageLoading(false);
    }
  }

  Future<void> sendImage({
    ImageSource source = ImageSource.gallery,
    required File file,
  }) async {
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

  Future<void> fetchRooms() async {
    final token = authController.accessToken.value;
    final refresh = authController.refreshToken.value;
    roomsError.value = '';
    if (token.isEmpty) {
      roomsError.value = 'Please log in to view chats';
      showCustomSnackBar(
        title: 'Error',
        message: roomsError.value,
        isSuccess: false,
      );
      Get.offAllNamed('/login');
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
      } else if (res['statusCode'] == 401) {
        final refreshed = await authController.refreshAccessToken();
        if (refreshed) {
          final newToken = await authController.getAccessToken();
          final retryRes = await apiService.fetchChatRooms(newToken!);
          if (retryRes['statusCode'] == 200) {
            final list = (retryRes['data'] as List).cast<Map<String, dynamic>>();
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
            final errorMsg = retryRes['data']['error'] ?? 'Failed to load chat rooms after token refresh';
            roomsError.value = errorMsg;
            showCustomSnackBar(
              title: 'Error',
              message: errorMsg,
              isSuccess: false,
            );
            Get.offAllNamed('/login');
          }
        } else {
          roomsError.value = 'Failed to refresh token. Please log in again.';
          showCustomSnackBar(
            title: 'Error',
            message: roomsError.value,
            isSuccess: false,
          );
          Get.offAllNamed('/login');
        }
      } else {
        roomsError.value = res['data']['error'] ?? 'Failed to load chat rooms';
        showCustomSnackBar(
          title: 'Error',
          message: roomsError.value,
          isSuccess: false,
        );
      }
    } catch (e, st) {
      debugPrint('fetchRooms error: $e\n$st');
      roomsError.value = 'Failed to load chat rooms: $e';
      showCustomSnackBar(
        title: 'Error',
        message: roomsError.value,
        isSuccess: false,
      );
    } finally {
      isRoomsLoading(false);
    }
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
    final refresh = authController.refreshToken.value;
    if (token.isEmpty) {
      chatError.value = 'Please log in';
      showCustomSnackBar(
        title: 'Error',
        message: chatError.value,
        isSuccess: false,
      );
      Get.offAllNamed('/login');
      return;
    }

    isRoomLoading(true);
    try {
      final res = await apiService.createOrGetChatRoom(token, participants: participants);
      if (res['statusCode'] == 200) {
        final data = res['data'] as Map<String, dynamic>;
        roomId.value = (data['id'] as num).toInt();
        if (data['messages'] is List) {
          messages.assignAll((data['messages'] as List).cast<Map<String, dynamic>>());
        } else {
          messages.clear();
        }

        Future.delayed(const Duration(milliseconds: 300), () => scrollToBottom());
      } else if (res['statusCode'] == 401) {
        final refreshed = await authController.refreshAccessToken();
        if (refreshed) {
          final newToken = await authController.getAccessToken();
          final retryRes = await apiService.createOrGetChatRoom(newToken!, participants: participants);
          if (retryRes['statusCode'] == 200) {
            final data = retryRes['data'] as Map<String, dynamic>;
            roomId.value = (data['id'] as num).toInt();
            if (data['messages'] is List) {
              messages.assignAll((data['messages'] as List).cast<Map<String, dynamic>>());
            } else {
              messages.clear();
            }

            Future.delayed(const Duration(milliseconds: 300), () => scrollToBottom());
          } else {
            final errorMsg = retryRes['data']['error'] ?? 'Failed to open chat room after token refresh';
            chatError.value = errorMsg;
            showCustomSnackBar(
              title: 'Error',
              message: errorMsg,
              isSuccess: false,
            );
            Get.offAllNamed('/login');
          }
        } else {
          chatError.value = 'Failed to refresh token. Please log in again.';
          showCustomSnackBar(
            title: 'Error',
            message: chatError.value,
            isSuccess: false,
          );
          Get.offAllNamed('/login');
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
