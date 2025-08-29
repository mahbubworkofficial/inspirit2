import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../../widgets/show_custom_snack_ber.dart';
import '../app_url/app_url.dart';

class ApiService extends GetxService {
  //Auth
  final http.Client client;

  ApiService({http.Client? client}) : client = client ?? http.Client();


  Future<Map<String, dynamic>> fetchMessages(String roomId, String token) async {
    final url = Uri.parse('${AppUrl.chatUrl}$roomId/messages/');
    try {
      final response = await client.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        debugPrint("Messages: $data");
        return {'statusCode': 200, 'data': data};
      } else {
        final errorData = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return {
          'statusCode': response.statusCode,
          'data': {
            'error': errorData['detail'] ?? errorData['message'] ?? 'Failed to fetch messages',
          },
        };
      }
    } catch (e) {
      debugPrint('fetchMessages Exception: $e');
      return {
        'statusCode': 500,
        'data': {'error': e.toString()},
      };
    }
  }


  // Send a new message in a specific room
  Future<Map<String, dynamic>> sendMessage(String roomId, String token, Map<String, dynamic> messageContent) async {
    final url = Uri.parse('${AppUrl.chatUrl}$roomId/messages/');
    try {
      final response = await client.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(messageContent),
      );

      if (response.statusCode == 201) {
        return {'statusCode': 201, 'data': 'Message sent'};
      } else {
        final errorData = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return {
          'statusCode': response.statusCode,
          'data': {
            'error': errorData['detail'] ?? errorData['message'] ?? 'Failed to send message',
          },
        };
      }
    } catch (e, stackTrace) {
      debugPrint('sendMessage Exception: $e\nStack: $stackTrace');
      return {
        'statusCode': 500,
        'data': {'error': e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> fetchOtherUserEvents(
      String token,
      String userId,
      int page,
      ) async {
    final url = Uri.parse('${AppUrl.eventUrl}$userId/?page=$page');

    try {
      final response = await client.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('fetchOtherUserEvents URL: $url');
      debugPrint('fetchOtherUserEvents Status: ${response.statusCode}');
      debugPrint('fetchOtherUserEvents Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final otherUserEvents = data['posts'] ?? [];
        return {'statusCode': 200, 'data': otherUserEvents};
      } else {
        final errorData =
        response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return {
          'statusCode': response.statusCode,
          'data': {
            'error':
            errorData['detail'] ??
                errorData['message'] ??
                'Failed to load events',
          },
        };
      }
    } catch (e, stackTrace) {
      debugPrint('fetchOtherUserEvents Error: $e\nStack: $stackTrace');
      return {
        'statusCode': 500,
        'data': {'error': e.toString()},
      };
    }
  }


  Future<Map<String, dynamic>> fetchMemories(String token, String personId) async {
    final url = Uri.parse('${AppUrl.personUrl}$personId/memories/');

    try {
      final response = await client.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('fetchMemories URL: $url');
      debugPrint('fetchMemories Status: ${response.statusCode}');
      debugPrint('fetchMemories Response: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return {'statusCode': 200, 'data': data};
      } else {
        final errorData =
        response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return {
          'statusCode': response.statusCode,
          'data': {
            'error': errorData['detail'] ??
                errorData['message'] ??
                'Failed to load memories',
          },
        };
      }
    } catch (e, stackTrace) {
      debugPrint('fetchMemories Exception: $e\nStack: $stackTrace');
      return {
        'statusCode': 500,
        'data': {'error': e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> deletePerson(
      String token,
      String requestId,
      ) async {
    final url = Uri.parse('${AppUrl.personUrl}$requestId/');

    debugPrint('deletePerson URL: $url');
    debugPrint('deletePerson Token: $token');

    try {
      final response = await client.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('deleteFriendRequest URL: $url');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Response: ${response.body}');

      if (response.statusCode == 204) {
        return {
          'statusCode': 204,
          'data': {}, // No content for 204
        };
      } else {
        final errorData =
        response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return {
          'statusCode': response.statusCode,
          'data': {
            'error':
            errorData['detail'] ??
                errorData['message'] ??
                'Failed to delete person ',
          },
        };
      }
    } catch (e, stackTrace) {
      debugPrint('delete Person Exception: $e\nStack: $stackTrace');
      return {
        'statusCode': 500,
        'data': {'error': e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> fetchPersons(String token) async {
    final url = Uri.parse(AppUrl.personUrl);

    try {
      final response = await client.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('fetchPersons URL: $url');
      debugPrint('fetchPersons Status: ${response.statusCode}');
      debugPrint('fetchPersons Response: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return {'statusCode': 200, 'data': data};
      } else {
        final errorData =
        response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return {
          'statusCode': response.statusCode,
          'data': {
            'error': errorData['detail'] ??
                errorData['message'] ??
                'Failed to load persons',
          },
        };
      }
    } catch (e, stackTrace) {
      debugPrint('fetchPersons Exception: $e\nStack: $stackTrace');
      return {
        'statusCode': 500,
        'data': {'error': e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> updatePerson(
    String id,
    String name,
    String dateOfBirth,
    String dateOfDeath,
    String details,
    File?
    profilePhoto, // Make the file nullable for cases when no photo is provided
    String whoCanSee,
    String? token,
  ) async {
    final url = Uri.parse('${AppUrl.personUrl}$id/');
    debugPrint(
      'Creating Person with: name=$name, dob=$dateOfBirth, dod=$dateOfDeath, details=$details, whoCanSee=$whoCanSee',
    );
    debugPrint('name:____________ $name _______________');
    debugPrint('dateOfBirth:____________ $dateOfBirth _______________');
    debugPrint('dateOfDeath:____________ $dateOfDeath _______________');
    debugPrint('details:____________ $details _______________');
    debugPrint('imgae:____________ $profilePhoto _______________');
    debugPrint('whoCanSee:____________ $whoCanSee _______________');
    debugPrint('token:____________ $token _______________');
    debugPrint('url:____________ $url _______________');

    try {
      final multipartRequest = http.MultipartRequest('PATCH', url);

      multipartRequest.headers.addAll({
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });

      // Add required fields
      multipartRequest.fields['full_name'] = name;
      multipartRequest.fields['date_of_birth'] = dateOfBirth;
      multipartRequest.fields['date_of_death'] = dateOfDeath;
      multipartRequest.fields['description'] = details;
      multipartRequest.fields['privacy'] = whoCanSee;

      // Handle file upload if provided
      if (profilePhoto != null) {
        var mimeType =
            lookupMimeType(profilePhoto.path) ??
            'application/octet-stream'; // Ensure mime type is defined
        var photoFile = await http.MultipartFile.fromPath(
          'display_picture', // Field name in your backend
          profilePhoto.path,
          contentType: MediaType.parse(mimeType),
        );
        multipartRequest.files.add(photoFile); // Add the file to the request
      } else {
        debugPrint('No profile photo provided.');
      }

      // Send request
      final streamedResponse = await multipartRequest.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return {'statusCode': 200, 'data': data}; // Successfully created
      } else {
        final err = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return {
          'statusCode': response.statusCode,
          'data': {
            'error':
                err['detail'] ?? err['message'] ?? 'Failed to create person',
          },
        };
      }
    } catch (e) {
      debugPrint('API error: $e');
      return {
        'statusCode': 500,
        'data': {'error': e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> createPerson(
    String name,
    String dateOfBirth,
    String dateOfDeath,
    String details,
    File?
    profilePhoto, // Make the file nullable for cases when no photo is provided
    String whoCanSee,
    String? token,
  ) async {
    final url = Uri.parse(AppUrl.personUrl);
    debugPrint(
      'Creating Person with: name=$name, dob=$dateOfBirth, dod=$dateOfDeath, details=$details, whoCanSee=$whoCanSee',
    );
    debugPrint('name:____________ $name _______________');
    debugPrint('dateOfBirth:____________ $dateOfBirth _______________');
    debugPrint('dateOfDeath:____________ $dateOfDeath _______________');
    debugPrint('details:____________ $details _______________');
    debugPrint('imgae:____________ $profilePhoto _______________');
    debugPrint('whoCanSee:____________ $whoCanSee _______________');
    debugPrint('token:____________ $token _______________');
    debugPrint('url:____________ $url _______________');

    try {
      final multipartRequest = http.MultipartRequest('POST', url);

      multipartRequest.headers.addAll({
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });

      // Add required fields
      multipartRequest.fields['full_name'] = name;
      multipartRequest.fields['date_of_birth'] = dateOfBirth;
      multipartRequest.fields['date_of_death'] = dateOfDeath;
      multipartRequest.fields['description'] = details;
      multipartRequest.fields['privacy'] = whoCanSee;

      // Handle file upload if provided
      if (profilePhoto != null) {
        var mimeType =
            lookupMimeType(profilePhoto.path) ??
            'application/octet-stream'; // Ensure mime type is defined
        var photoFile = await http.MultipartFile.fromPath(
          'display_picture', // Field name in your backend
          profilePhoto.path,
          contentType: MediaType.parse(mimeType),
        );
        multipartRequest.files.add(photoFile); // Add the file to the request
      } else {
        debugPrint('No profile photo provided.');
      }

      // Send request
      final streamedResponse = await multipartRequest.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return {'statusCode': 200, 'data': data}; // Successfully created
      } else {
        final err = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return {
          'statusCode': response.statusCode,
          'data': {
            'error':
                err['detail'] ?? err['message'] ?? 'Failed to create person',
          },
        };
      }
    } catch (e) {
      debugPrint('API error: $e');
      return {
        'statusCode': 500,
        'data': {'error': e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> updateEvent(
    String id,
    String type,
    String title,
    String dateOfMemory,
    String time,
    String location,
    String description,
    List<File> imageFiles, // can be empty
    String? token,
  ) async {
    final url = Uri.parse("${AppUrl.eventUrl}$id/");
    debugPrint('url__________________________ $url');
    debugPrint('type__________________________ $type');
    debugPrint('title__________________________ $title');
    debugPrint('dateOfMemory__________________________ $dateOfMemory');
    debugPrint('time__________________________ $time');
    debugPrint('location__________________________ $location');
    debugPrint('description__________________________ $description');

    try {
      final request = http.MultipartRequest('PATCH', url);
      request.headers.addAll({
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });

      request.fields['event_type'] = type;
      request.fields['title'] = title;
      request.fields['date'] = dateOfMemory;
      request.fields['time'] = time;
      request.fields['location'] = location;
      request.fields['details'] = description;

      // ✅ Only add images if list is not empty
      // ✅ Support multiple uploads correctly
      for (var image in imageFiles) {
        if (image.path.isNotEmpty) {
          final mimeType = lookupMimeType(image.path) ?? 'image/jpeg';
          final multipartFile = await http.MultipartFile.fromPath(
            'image_files', // 👈 try this
            image.path,
            contentType: MediaType.parse(mimeType),
          );
          request.files.add(multipartFile);
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return {'statusCode': 200, 'data': data}; // Successfully created
      } else {
        final err = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return {
          'statusCode': response.statusCode,
          'data': {
            'error':
            err['detail'] ?? err['message'] ?? 'Failed to create person',
          },
        };
      }
    }catch (e) {
      debugPrint('API error: $e');
      return {
        'statusCode': 500,
        'data': {'error': e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> fetchEvents(String token) async {
    final url = Uri.parse(AppUrl.eventUrl);

    try {
      final response = await client.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('fetchEvents URL: $url');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Response: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return {'statusCode': 200, 'data': data};
      } else {
        final errorData =
            response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return {
          'statusCode': response.statusCode,
          'data': {
            'error':
                errorData['detail'] ??
                errorData['message'] ??
                'Failed to load events',
          },
        };
      }
    } catch (e, stackTrace) {
      debugPrint('fetchEvents Exception: $e\nStack: $stackTrace');
      return {
        'statusCode': 500,
        'data': {'error': e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> createEvent(
    String type,
    String title,
    String dateOfMemory,
    String time,
    String location,
    String description,
    List<File> imageFiles, // can be empty
    String? token,
  ) async {
    final url = Uri.parse(AppUrl.eventUrl);

    try {
      final request = http.MultipartRequest('POST', url);
      request.headers.addAll({
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });

      request.fields['event_type'] = type;
      request.fields['title'] = title;
      request.fields['date'] = dateOfMemory;
      request.fields['time'] = time;
      request.fields['location'] = location;
      request.fields['details'] = description;

      // ✅ Only add images if list is not empty
      // ✅ Support multiple uploads correctly
      for (var image in imageFiles) {
        if (image.path.isNotEmpty) {
          final mimeType = lookupMimeType(image.path) ?? 'image/jpeg';
          final multipartFile = await http.MultipartFile.fromPath(
            'image_files', // 👈 try this
            image.path,
            contentType: MediaType.parse(mimeType),
          );
          request.files.add(multipartFile);
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseData =
          response.body.isNotEmpty ? jsonDecode(response.body) : {};

      return {'statusCode': response.statusCode, 'data': responseData};
    } catch (e) {
      debugPrint('API error: $e');
      return {
        'statusCode': 500,
        'data': {'error': e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> updateMemory(
    String id,
    String title,
    String dateOfMemory,
    String description,
    List<File> imageFiles, // can be empty
    String? token,
  ) async {
    final url = Uri.parse("${AppUrl.memoryUrl}$id/");
    debugPrint('url__________________________ $url');
    debugPrint('title__________________________ $title');
    debugPrint('dateOfMemory__________________________ $dateOfMemory');
    debugPrint('description__________________________ $description');
    try {
      final request = http.MultipartRequest('PATCH', url);
      request.headers.addAll({
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });

      request.fields['title'] = title;
      request.fields['date_of_memory'] = dateOfMemory;
      request.fields['description'] = description;

      // ✅ Only add images if list is not empty
      // ✅ Support multiple uploads correctly
      for (var image in imageFiles) {
        if (image.path.isNotEmpty) {
          final mimeType = lookupMimeType(image.path) ?? 'image/jpeg';
          final multipartFile = await http.MultipartFile.fromPath(
            'image_files', // 👈 try this
            image.path,
            contentType: MediaType.parse(mimeType),
          );
          request.files.add(multipartFile);
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseData =
          response.body.isNotEmpty ? jsonDecode(response.body) : {};

      return {'statusCode': response.statusCode, 'data': responseData};
    } catch (e) {
      debugPrint('API error: $e');
      return {
        'statusCode': 500,
        'data': {'error': e.toString()},
      };
    }
  }
  Future<Map<String, dynamic>> createMemory(
    String id,
    String title,
    String dateOfMemory,
    String description,
    List<File> imageFiles, // can be empty
    String? token,
  ) async {
    final url = Uri.parse("${AppUrl.personUrl}$id/memories/");

    try {
      final request = http.MultipartRequest('POST', url);
      request.headers.addAll({
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });

      request.fields['title'] = title;
      request.fields['date_of_memory'] = dateOfMemory;
      request.fields['description'] = description;

      // ✅ Only add images if list is not empty
      // ✅ Support multiple uploads correctly
      for (var image in imageFiles) {
        if (image.path.isNotEmpty) {
          final mimeType = lookupMimeType(image.path) ?? 'image/jpeg';
          final multipartFile = await http.MultipartFile.fromPath(
            'image_files', // 👈 try this
            image.path,
            contentType: MediaType.parse(mimeType),
          );
          request.files.add(multipartFile);
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseData =
          response.body.isNotEmpty ? jsonDecode(response.body) : {};

      return {'statusCode': response.statusCode, 'data': responseData};
    } catch (e) {
      debugPrint('API error: $e');
      return {
        'statusCode': 500,
        'data': {'error': e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> fetchChatRooms(String token) async {
    final url = Uri.parse(AppUrl.chatRoomsUrl);
    try {
      final resp = await client.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('fetchChatRooms URL: $url');
      debugPrint('fetchChatRooms Status: ${resp.statusCode}');
      debugPrint('fetchChatRooms Response: ${resp.body}');

      if (resp.statusCode == 200) {
        final data = resp.body.isNotEmpty ? jsonDecode(resp.body) : [];
        // Server returns a LIST
        final rooms = (data is List) ? data : [];
        return {'statusCode': 200, 'data': rooms};
      } else {
        final err = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
        return {
          'statusCode': resp.statusCode,
          'data': {
            'error':
                err['detail'] ?? err['message'] ?? 'Failed to load chat rooms',
          },
        };
      }
    } catch (e, st) {
      debugPrint('fetchChatRooms Error: $e\n$st');
      return {
        'statusCode': 500,
        'data': {'error': e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> createOrGetChatRoom(
    String token, {
    required List<int> participants,
  }) async {
    final url = Uri.parse(AppUrl.chatRoomsUrl);
    try {
      final resp = await client.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'participants': participants}),
      );

      debugPrint('createOrGetChatRoom URL: $url');
      debugPrint('createOrGetChatRoom Status: ${resp.statusCode}');
      debugPrint('createOrGetChatRoom Response: ${resp.body}');

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
        return {'statusCode': 200, 'data': data};
      } else {
        final err = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
        return {
          'statusCode': resp.statusCode,
          'data': {
            'error':
                err['detail'] ?? err['message'] ?? 'Failed to open chat room',
          },
        };
      }
    } catch (e, st) {
      debugPrint('createOrGetChatRoom Error: $e\n$st');
      return {
        'statusCode': 500,
        'data': {'error': e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> updateComment(
    String token,
    String commentId,
    String text,
  ) async {
    final int id = int.tryParse(commentId) ?? -1;
    final url = Uri.parse("${AppUrl.commentReactUrl}/$id/");
    try {
      final resp = await client.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'text': text}),
      );

      debugPrint('updateComment URL: $url');
      debugPrint('updateComment Status: ${resp.statusCode}');
      debugPrint('updateComment Response: ${resp.body}');

      if (resp.statusCode == 200) {
        final data = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
        return {'statusCode': 200, 'data': data};
      } else {
        final err = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
        return {
          'statusCode': resp.statusCode,
          'data': {
            'error':
                err['detail'] ?? err['message'] ?? 'Failed to update comment',
          },
        };
      }
    } catch (e, st) {
      debugPrint('updateComment Error: $e\n$st');
      return {
        'statusCode': 500,
        'data': {'error': e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> deleteComment(
    String token,
    String commentId,
  ) async {
    final int id = int.tryParse(commentId) ?? -1;
    final url = Uri.parse("${AppUrl.commentReactUrl}/$id/");
    try {
      final resp = await client.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('deleteComment URL: $url');
      debugPrint('deleteComment Status: ${resp.statusCode}');
      debugPrint('deleteComment Response: ${resp.body}');

      // Common patterns: 204 No Content OR 200 with a message object
      if (resp.statusCode == 204 || resp.statusCode == 200) {
        return {
          'statusCode': 200,
          'data': {'ok': true},
        };
      } else {
        final err = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
        return {
          'statusCode': resp.statusCode,
          'data': {
            'error':
                err['detail'] ?? err['message'] ?? 'Failed to delete comment',
          },
        };
      }
    } catch (e, st) {
      debugPrint('deleteComment Error: $e\n$st');
      return {
        'statusCode': 500,
        'data': {'error': e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> likeComment(
    String token,
    String commentId,
  ) async {
    final int id = int.tryParse(commentId) ?? -1;
    final url = Uri.parse("${AppUrl.commentReactUrl}/$id/like/");
    try {
      final resp = await client.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('likeComment URL: $url');
      debugPrint('likeComment Status: ${resp.statusCode}');
      debugPrint('likeComment Response: ${resp.body}');

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
        return {'statusCode': 200, 'data': data};
      } else {
        final err = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
        return {
          'statusCode': resp.statusCode,
          'data': {
            'error':
                err['detail'] ?? err['message'] ?? 'Failed to like comment',
          },
        };
      }
    } catch (e, st) {
      debugPrint('likeComment Error: $e\n$st');
      return {
        'statusCode': 500,
        'data': {'error': e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> unlikeComment(
    String token,
    String commentId,
  ) async {
    final int id = int.tryParse(commentId) ?? -1;
    final url = Uri.parse("${AppUrl.commentReactUrl}/$id/unlike/");
    try {
      final resp = await client.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('unlikeComment URL: $url');
      debugPrint('unlikeComment Status: ${resp.statusCode}');
      debugPrint('unlikeComment Response: ${resp.body}');

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
        return {'statusCode': 200, 'data': data};
      } else {
        final err = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
        return {
          'statusCode': resp.statusCode,
          'data': {
            'error':
                err['detail'] ?? err['message'] ?? 'Failed to unlike comment',
          },
        };
      }
    } catch (e, st) {
      debugPrint('unlikeComment Error: $e\n$st');
      return {
        'statusCode': 500,
        'data': {'error': e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> createCommentOnPost(
    String token,
    String postId,
    String text,
  ) async {
    final int id = int.tryParse(postId) ?? -1;
    final url = Uri.parse("${AppUrl.commentUrl}/$id/");

    try {
      final resp = await client.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'text': text}),
      );

      debugPrint('createCommentOnPost URL: $url');
      debugPrint('createCommentOnPost Status: ${resp.statusCode}');
      debugPrint('createCommentOnPost Response: ${resp.body}');

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final decoded = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
        // Your API returns the created comment object
        return {'statusCode': 200, 'data': decoded};
      } else {
        final errorData = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
        return {
          'statusCode': resp.statusCode,
          'data': {
            'error':
                errorData['detail'] ??
                errorData['message'] ??
                'Failed to create comment',
          },
        };
      }
    } catch (e, st) {
      debugPrint('createCommentOnPost Error: $e\n$st');
      return {
        'statusCode': 500,
        'data': {'error': e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> fetchCommentsOnPost(
    String token,
    String postId,
  ) async {
    final int id = int.tryParse(postId) ?? -1;
    final url = Uri.parse("${AppUrl.commentUrl}/$id/");

    try {
      final response = await client.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('fetchCommentsOnPost URL: $url');
      debugPrint('fetchCommentsOnPost Status: ${response.statusCode}');
      debugPrint('fetchCommentsOnPost Response: ${response.body}');

      if (response.statusCode == 200) {
        final decoded =
            response.body.isNotEmpty ? jsonDecode(response.body) : {};
        // Normalize to a plain list like your fetchPosts() does
        // Your API returns { comments: [...], pagination: {...} }
        final comments =
            decoded is List ? decoded : (decoded['comments'] ?? []);
        return {'statusCode': 200, 'data': comments};
      } else {
        final errorData =
            response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return {
          'statusCode': response.statusCode,
          'data': {
            'error':
                errorData['detail'] ??
                errorData['message'] ??
                'Failed to load comments',
          },
        };
      }
    } catch (e, stackTrace) {
      debugPrint('fetchCommentsOnPost Error: $e\nStack: $stackTrace');
      return {
        'statusCode': 500,
        'data': {'error': e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> acceptFriendRequest(
    String token,
    String requestId,
  ) async {
    final url = Uri.parse('${AppUrl.friendRequestUrl}$requestId/accept/');

    try {
      final response = await client.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('acceptFriendRequest URL: $url');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'statusCode': response.statusCode,
          'data': response.body.isNotEmpty ? jsonDecode(response.body) : {},
        };
      } else {
        final errorData =
            response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return {
          'statusCode': response.statusCode,
          'data': {
            'error':
                errorData['detail'] ??
                errorData['message'] ??
                'Failed to accept friend request',
          },
        };
      }
    } catch (e, stackTrace) {
      debugPrint('acceptFriendRequest Exception: $e\nStack: $stackTrace');
      return {
        'statusCode': 500,
        'data': {'error': e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> rejectFriendRequest(
    String token,
    String requestId,
  ) async {
    final url = Uri.parse('${AppUrl.friendRequestUrl}$requestId/reject/');

    try {
      final response = await client.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('rejectFriendRequest URL: $url');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'statusCode': response.statusCode,
          'data': response.body.isNotEmpty ? jsonDecode(response.body) : {},
        };
      } else {
        final errorData =
            response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return {
          'statusCode': response.statusCode,
          'data': {
            'error':
                errorData['detail'] ??
                errorData['message'] ??
                'Failed to reject friend request',
          },
        };
      }
    } catch (e, stackTrace) {
      debugPrint('rejectFriendRequest Exception: $e\nStack: $stackTrace');
      return {
        'statusCode': 500,
        'data': {'error': e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> deleteFriendRequest(
    String token,
    String requestId,
  ) async {
    final url = Uri.parse('${AppUrl.friendRequestUrl}$requestId/');

    try {
      final response = await client.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('deleteFriendRequest URL: $url');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Response: ${response.body}');

      if (response.statusCode == 204) {
        return {
          'statusCode': 204,
          'data': {}, // No content for 204
        };
      } else {
        final errorData =
            response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return {
          'statusCode': response.statusCode,
          'data': {
            'error':
                errorData['detail'] ??
                errorData['message'] ??
                'Failed to delete friend request',
          },
        };
      }
    } catch (e, stackTrace) {
      debugPrint('deleteFriendRequest Exception: $e\nStack: $stackTrace');
      return {
        'statusCode': 500,
        'data': {'error': e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> sendFriendRequest(
    String token,
    String receiverId,
  ) async {
    final url = Uri.parse(AppUrl.friendRequestUrl);

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'receiver': receiverId}),
      );

      debugPrint('sendFriendRequest URL: $url');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'statusCode': response.statusCode,
          'data': data, // Returns {id, sender, receiver, status, created_at}
        };
      } else {
        final errorData =
            response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return {
          'statusCode': response.statusCode,
          'data': {
            'error':
                errorData['detail'] ??
                errorData['message'] ??
                'Failed to send friend request',
          },
        };
      }
    } catch (e, stackTrace) {
      debugPrint('sendFriendRequest Exception: $e\nStack: $stackTrace');
      return {
        'statusCode': 500,
        'data': {'error': e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> fetchUsers(String token) async {
    final url = Uri.parse(AppUrl.usersListUrl);

    try {
      final response = await client.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('fetchUsers URL: $url');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Response: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return {'statusCode': 200, 'data': data}; // ✅ list directly
      } else {
        final errorData =
            response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return {
          'statusCode': response.statusCode,
          'data': {
            'error':
                errorData['detail'] ??
                errorData['message'] ??
                'Failed to load users',
          },
        };
      }
    } catch (e, stackTrace) {
      debugPrint('fetchUsers Exception: $e\nStack: $stackTrace');
      return {
        'statusCode': 500,
        'data': {'error': e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> fetchFriends(String token) async {
    final url = Uri.parse(AppUrl.friendsListUrl);
    try {
      final response = await client.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('fetchFriends URL: $url');
      debugPrint('fetchFriends Status: ${response.statusCode}');
      debugPrint('fetchFriends Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return {'statusCode': 200, 'data': data};
      } else {
        final errorData =
            response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return {
          'statusCode': response.statusCode,
          'data': {
            'error':
                errorData['detail'] ??
                errorData['message'] ??
                'Failed to load friends',
          },
        };
      }
    } catch (e, stackTrace) {
      debugPrint('fetchFriends Error: $e\nStack: $stackTrace');
      return {
        'statusCode': 500,
        'data': {'error': e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> toggleLike(
    int postId,
    bool isLiked,
    String token,
  ) async {
    final url = Uri.parse(
      '${AppUrl.likeUrl}$postId/${isLiked ? 'unlike/' : 'like/'}',
    );

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Parse the response to check for success or failure
        final responseBody = jsonDecode(response.body);
        return {'statusCode': 200, 'data': responseBody};
      } else {
        return {
          'statusCode': response.statusCode,
          'data': {'error': 'Failed to update like'},
        };
      }
    } catch (e) {
      return {
        'statusCode': 500,
        'data': {'error': 'Network error: $e'},
      };
    }
  }

  Future<Map<String, dynamic>> fetchPosts(String token) async {
    final url = Uri.parse(AppUrl.getPostUrl);
    try {
      final response = await client.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('fetchPosts URL: $url');
      debugPrint('fetchPosts Status: ${response.statusCode}');
      debugPrint('fetchPosts Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Handle both direct list and paginated responses
        final posts = data is List ? data : (data['results'] ?? []);
        return {'statusCode': 200, 'data': posts};
      } else {
        final errorData =
            response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return {
          'statusCode': response.statusCode,
          'data': {
            'error':
                errorData['detail'] ??
                errorData['message'] ??
                'Failed to load posts',
          },
        };
      }
    } catch (e, stackTrace) {
      debugPrint('fetchPosts Error: $e\nStack: $stackTrace');
      return {
        'statusCode': 500,
        'data': {'error': e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> fetchOthersPost(String token) async {
    final url = Uri.parse(AppUrl.getOthersPostUrl);
    try {
      final response = await client.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('fetchOthersPost URL: $url');
      debugPrint('fetchOthersPost Status: ${response.statusCode}');
      debugPrint('fetchOthersPost Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Extract posts from the 'posts' key
        final othersPost = data['posts'] ?? [];
        return {'statusCode': 200, 'data': othersPost};
      } else {
        final errorData =
            response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return {
          'statusCode': response.statusCode,
          'data': {
            'error':
                errorData['detail'] ??
                errorData['message'] ??
                'Failed to load posts',
          },
        };
      }
    } catch (e, stackTrace) {
      debugPrint('fetchOthersPost Error: $e\nStack: $stackTrace');
      return {
        'statusCode': 500,
        'data': {'error': e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> fetchOtherUserPost(
    String token,
    String id,
  ) async {
    int parsedId = int.parse(id); //
    final url = Uri.parse("${AppUrl.fetchUserPostsUrl}/$parsedId/");
    try {
      final response = await client.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('fetchOtherUserPost URL: $url');
      debugPrint('fetchOtherUserPost Status: ${response.statusCode}');
      debugPrint('fetchOtherUserPost Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Extract posts from the 'posts' key
        final otherUserPosts = data['posts'] ?? [];
        return {'statusCode': 200, 'data': otherUserPosts};
      } else {
        final errorData =
            response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return {
          'statusCode': response.statusCode,
          'data': {
            'error':
                errorData['detail'] ??
                errorData['message'] ??
                'Failed to load posts',
          },
        };
      }
    } catch (e, stackTrace) {
      debugPrint('fetchOtherUserPost Error: $e\nStack: $stackTrace');
      return {
        'statusCode': 500,
        'data': {'error': e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> postCreate({
    required String content,
    File? image,
    String? scheduledDate,
    String? scheduledTime,
    String? token,
  }) async {
    final url = Uri.parse(AppUrl.createPostUrl); // Adjust your API URL

    try {
      final request = http.MultipartRequest('POST', url);
      request.headers.addAll({
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });

      // Attach content
      request.fields['content'] = content;

      if (scheduledDate != null) {
        request.fields['scheduled_date'] = scheduledDate;
      }
      if (scheduledTime != null) {
        request.fields['scheduled_time'] = scheduledTime;
      }

      // Add the image file (if present)
      if (image != null) {
        final imageBytes = await image.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'image_files', // This should be the field name in your API
            imageBytes,
            filename: image.uri.pathSegments.last,
            contentType: MediaType(
              'image',
              'jpeg',
            ), // Update based on image format
          ),
        );
      }

      // Send the request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        final data = jsonDecode(responseBody);
        return {
          'statusCode': response.statusCode,
          'data': data, // Return the post data
        };
      } else {
        return {
          'statusCode': response.statusCode,
          'data': jsonDecode(responseBody),
        };
      }
    } catch (e) {
      return {
        'statusCode': 500,
        'data': {'error': e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> getUserProfile(String token) async {
    final response = await http.get(
      Uri.parse(AppUrl.getProfileUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return {
      'statusCode': response.statusCode,
      'data': jsonDecode(response.body),
    };
  }

  Future<Map<String, dynamic>> createSubscription(
    String planId,
    String token,
    String successUrl,
    String cancelUrl,
  ) async {
    try {
      final uri = Uri.parse(AppUrl.buySubscriptionUrl);
      final headers = {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $token",
      };
      final body = jsonEncode({
        'plan_id': planId,
        'success_url': successUrl,
        'cancel_url': cancelUrl,
      });

      debugPrint('Sending POST to $uri with body: $body');
      debugPrint('Headers: $headers');

      final response = await http.post(uri, headers: headers, body: body);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else if (response.statusCode == 401) {
        throw Exception(
          'Unauthorized: Invalid or missing authentication token',
        );
      } else {
        throw Exception(
          'Failed to create subscription: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Error in createSubscription: $e');
      showCustomSnackBar(
        title: 'Error',
        message: 'Failed to create subscription: $e',
        isSuccess: false,
      );
      rethrow;
    }
  }

  Future<http.Response> signUpWithOther(String email, String fcmToken) async {
    final url = Uri.parse(AppUrl.signUpWithOtherUrl);
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final body = {'email': email, 'fcm_token': fcmToken};
    try {
      final response = await client.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      debugPrint('Request: POST $url');
      debugPrint('Body: ${jsonEncode(body)}');
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      return response;
    } catch (e) {
      debugPrint('API error: $e');
      rethrow; // Rethrow to handle in AuthController
    }
  }

  Future<Map<String, dynamic>> signup(
    String email,
    String password,
    String confirmPassword,
  ) async {
    final url = Uri.parse(AppUrl.signup);
    try {
      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'confirm_password': confirmPassword,
        }),
      );
      debugPrint('Request: POST $url');
      debugPrint(
        'Body: ${jsonEncode({'email': email, 'password': password, 'confirm_password': confirmPassword})}',
      );
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      return {
        'statusCode': response.statusCode,
        'data':
            response.statusCode == 201
                ? jsonDecode(response.body)
                : jsonDecode(response.body.isNotEmpty ? response.body : '{}'),
      };
    } catch (e) {
      debugPrint('API error: $e');
      return {
        'statusCode': 500,
        'data': {'error': e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse(AppUrl.loginUrl);
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );
      debugPrint('Request: POST $url');
      debugPrint('Body: ${jsonEncode({'email': email, 'password': password})}');
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      return {
        'statusCode': response.statusCode,
        'data':
            response.statusCode == 200
                ? jsonDecode(response.body)
                : jsonDecode(response.body.isNotEmpty ? response.body : '{}'),
      };
    } catch (e) {
      debugPrint('API error: $e');
      return {
        'statusCode': 500,
        'data': {'error': e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> setPassword(
    String email,
    String password,
    String confirmPassword,
  ) async {
    final url = Uri.parse(AppUrl.setPassword);
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'confirm_password': confirmPassword,
        }),
      );
      debugPrint('Request: POST $url');
      debugPrint(
        'Body: ${jsonEncode({'email': email, 'password': password, 'confirm_password': confirmPassword})}',
      );
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      return {
        'statusCode': response.statusCode,
        'data':
            response.statusCode == 201
                ? jsonDecode(response.body)
                : jsonDecode(response.body.isNotEmpty ? response.body : '{}'),
      };
    } catch (e) {
      debugPrint('API error: $e');
      return {
        'statusCode': 500,
        'data': {'error': e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> forget(String email) async {
    final url = Uri.parse(AppUrl.forget);
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email}),
      );
      debugPrint('Request: POST $url');
      debugPrint('Body: ${jsonEncode({'email': email})}');
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      return {
        'statusCode': response.statusCode,
        'data':
            response.statusCode == 200
                ? jsonDecode(response.body)
                : jsonDecode(response.body.isNotEmpty ? response.body : '{}'),
      };
    } catch (e) {
      debugPrint('API error: $e');
      return {
        'statusCode': 500,
        'data': {'error': e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otpCode) async {
    final url = Uri.parse(AppUrl.verifyOtp);
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'otp': otpCode}),
      );
      debugPrint('Request: POST $url');
      debugPrint('Body: ${jsonEncode({'email': email, 'otp': otpCode})}');
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      return {
        'statusCode': response.statusCode,
        'data':
            response.statusCode == 200
                ? jsonDecode(response.body)
                : jsonDecode(response.body.isNotEmpty ? response.body : '{}'),
      };
    } catch (e) {
      debugPrint('API error: $e');
      return {
        'statusCode': 500,
        'data': {'error': e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> verifyOtp1(String email, String otpCode) async {
    final url = Uri.parse(AppUrl.verifyOtp1);
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'otp': otpCode}),
      );
      debugPrint('Request: POST $url');
      debugPrint('Body: ${jsonEncode({'email': email, 'otp': otpCode})}');
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      return {
        'statusCode': response.statusCode,
        'data':
            response.statusCode == 200
                ? jsonDecode(response.body)
                : jsonDecode(response.body.isNotEmpty ? response.body : '{}'),
      };
    } catch (e) {
      debugPrint('API error: $e');
      return {
        'statusCode': 500,
        'data': {'error': e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> resendOtp(String email) async {
    final url = Uri.parse(AppUrl.resendOtp);
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email}),
      );
      debugPrint('Request: POST $url');
      debugPrint('Body: ${jsonEncode({'email': email})}');
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      return {
        'statusCode': response.statusCode,
        'data':
            response.statusCode == 200
                ? jsonDecode(response.body)
                : jsonDecode(response.body.isNotEmpty ? response.body : '{}'),
      };
    } catch (e) {
      debugPrint('API error: $e');
      return {
        'statusCode': 500,
        'data': {'error': e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> resendOtp1(String email) async {
    final url = Uri.parse(AppUrl.resendOtp1);
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email}),
      );
      debugPrint('Request: POST $url');
      debugPrint('Body: ${jsonEncode({'email': email})}');
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      return {
        'statusCode': response.statusCode,
        'data':
            response.statusCode == 200
                ? jsonDecode(response.body)
                : jsonDecode(response.body.isNotEmpty ? response.body : '{}'),
      };
    } catch (e) {
      debugPrint('API error: $e');
      return {
        'statusCode': 500,
        'data': {'error': e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> updateUserProfile(
    String username,
    String name,
    File imagePaths,
    String? token,
  ) async {
    final url = Uri.parse(AppUrl.updateProfileUrl);
    debugPrint('username:____________$username _______________');
    debugPrint('name:____________$name _______________');
    debugPrint('imgae:____________$imagePaths _______________');
    debugPrint('token:____________$token _______________');
    try {
      final multipartRequest = http.MultipartRequest('PUT', url);
      multipartRequest.headers.addAll({
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });
      multipartRequest.fields['username'] = username;
      multipartRequest.fields['name'] = name;
      // Handle file upload (profile photo)
      var mimeType =
          lookupMimeType(imagePaths.path) ??
          'application/octet-stream'; // Ensure mime type is defined
      var photoFile = await http.MultipartFile.fromPath(
        'profile_photo', // The name of the field in the backend
        imagePaths.path,
        contentType: MediaType.parse(mimeType),
      );
      // Add photo file to the request
      multipartRequest.files.add(photoFile);
      final streamedResponse = await multipartRequest.send();
      final response = await http.Response.fromStream(streamedResponse);
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      final responseData =
          response.body.isNotEmpty ? jsonDecode(response.body) : {};
      return {'statusCode': response.statusCode, 'data': responseData};
    } catch (e) {
      debugPrint('API error: $e');
      return {
        'statusCode': 500,
        'data': {'error': e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> updateUserProfile1(
    String username,
    String name,
    File imagePaths,
    String? token,
    String about,
  ) async {
    final url = Uri.parse(AppUrl.updateProfileUrl);

    if (imagePaths.path.isEmpty) {
      return {
        'statusCode': 400,
        'data': {'error': 'Profile photo is required'},
      };
    }

    try {
      final multipartRequest = http.MultipartRequest('PUT', url);
      multipartRequest.headers.addAll({
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });
      multipartRequest.fields['username'] = username;
      multipartRequest.fields['name'] = name;
      var mimeType =
          lookupMimeType(imagePaths.path) ?? 'application/octet-stream';
      var photoFile = await http.MultipartFile.fromPath(
        'profile_photo',
        imagePaths.path,
        contentType: MediaType.parse(mimeType),
      );
      multipartRequest.files.add(photoFile);
      multipartRequest.fields['about'] = about;

      final streamedResponse = await multipartRequest.send();
      final response = await http.Response.fromStream(streamedResponse);

      final responseData =
          response.body.isNotEmpty ? jsonDecode(response.body) : {};
      return {'statusCode': response.statusCode, 'data': responseData};
    } catch (e) {
      debugPrint('API error: $e');
      return {
        'statusCode': 500,
        'data': {'error': e.toString()},
      };
    }
  }
}
