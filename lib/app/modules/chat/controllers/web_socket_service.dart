import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketService {
  WebSocketChannel? _channel;
  final String baseUrl = 'wss://atmosphere-reservation-sorted-customs.trycloudflare.com/users/chat';
  final String token;
  bool _isConnected = false;

  WebSocketService(this.token);

  bool get isConnected => _isConnected;

  // Connect to WebSocket
  void connect(int roomId, {
    required Function(Map<String, dynamic>) onMessage,
    Function(dynamic)? onError,
    Function()? onDone,
  }) {
    try {
      final uri = Uri.parse('$baseUrl/$roomId/?token=$token');
      debugPrint('Connecting to WebSocket: $uri');

      _channel = WebSocketChannel.connect(uri);
      _isConnected = true;

      _channel!.stream.listen(
            (message) {
          try {
            debugPrint('WebSocket received: $message');
            final data = jsonDecode(message);
            if (data is Map<String, dynamic>) {
              onMessage(data);
            }
          } catch (e) {
            debugPrint('Error parsing WebSocket message: $e');
            onError?.call(e);
          }
        },
        onError: (error) {
          debugPrint('WebSocket error: $error');
          _isConnected = false;
          onError?.call(error);
        },
        onDone: () {
          debugPrint('WebSocket connection closed');
          _isConnected = false;
          onDone?.call();
        },
      );
    } catch (e) {
      debugPrint('Error connecting to WebSocket: $e');
      _isConnected = false;
      onError?.call(e);
    }
  }

  // Send text message
  void sendMessage(String message) {
    if (!_isConnected || _channel == null) {
      debugPrint('WebSocket not connected');
      return;
    }

    try {
      final data = jsonEncode({
        'message': message,
      });

      _channel!.sink.add(data);
      debugPrint('Sent message: $data');
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  // Send file/image with metadata
  void sendFile(Uint8List fileBytes, {
    required String fileName,
    required String fileType,
    String? caption,
  }) {
    if (!_isConnected || _channel == null) {
      debugPrint('WebSocket not connected');
      return;
    }

    try {
      // Convert file to base64 for JSON transmission
      final base64File = base64Encode(fileBytes);

      final data = jsonEncode({
        'file': base64File,
        'file_name': fileName,
        'file_type': fileType,
        'caption': caption,
      });

      _channel!.sink.add(data);
      debugPrint('Sent file: $fileName ($fileType)');
    } catch (e) {
      debugPrint('Error sending file: $e');
    }
  }

  // Send image specifically
  void sendImage(Uint8List imageBytes, {
    required String fileName,
    String? caption,
  }) {
    sendFile(
      imageBytes,
      fileName: fileName,
      fileType: 'image',
      caption: caption,
    );
  }

  // Send typing indicator
  void sendTypingStatus(bool isTyping) {
    if (!_isConnected || _channel == null) return;

    try {
      final data = jsonEncode({
        'typing': isTyping,
      });

      _channel!.sink.add(data);
      debugPrint('Sent typing status: $isTyping');
    } catch (e) {
      debugPrint('Error sending typing status: $e');
    }
  }

  // Disconnect
  void disconnect() {
    try {
      _channel?.sink.close(status.goingAway);
      _isConnected = false;
      debugPrint('WebSocket disconnected');
    } catch (e) {
      debugPrint('Error disconnecting WebSocket: $e');
    }
  }

  // Check connection status
  void checkConnection() {
    debugPrint('WebSocket connected: $_isConnected');
  }
}