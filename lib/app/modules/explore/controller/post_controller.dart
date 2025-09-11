import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../res/components/api_service.dart';
import '../../../../widgets/show_custom_snack_bar.dart';
import '../../auth/controllers/auth_controller.dart';

class PostController extends GetxController {
  final ApiService apiService = ApiService();
  late AuthController authController;

  var posts = <Map<String, dynamic>>[].obs;
  var postsCount = 0.obs;
  var othersPost = <Map<String, dynamic>>[].obs;
  var othersPostCount = 0.obs;
  var isLoading = true.obs;
  var page = 1.obs;
  var hasMore = true.obs;
  var isMoreCommentsLoading = false.obs;
  var commentsPage = 1.obs;
  RxBool hasText = false.obs;
  final TextEditingController commentTextController = TextEditingController();
  var isCommentsLoading = false.obs;
  var commentsCount = 0.obs;
  var hasMoreComments = false.obs;
  final comments = <Map<String, dynamic>>[].obs;
  final RxMap<int, bool> editingComment = <int, bool>{}.obs;
  final isMoreLoading = false.obs;
  final RxString currentCommentsPostId = ''.obs;
  final RxBool isSendingComment = false.obs;
  final RxMap<int, bool> likingComment = <int, bool>{}.obs;
  final RxMap<int, bool> deletingComment = <int, bool>{}.obs;

  void onTextChanged(String value) {
    hasText.value = value.trim().isNotEmpty;
  }

  @override
  void onInit() {
    super.onInit();
    try {
      authController = Get.find<AuthController>();
      debugPrint('AuthController initialized: $authController');
      debugPrint('Access token: ${authController.accessToken.value}');
    } catch (e) {
      debugPrint('Error finding AuthController: $e');
      isLoading(false);
      showCustomSnackBar(
        title: 'Error',
        message: 'Authentication not initialized. Please log in.',
        isSuccess: false,
      );
      Get.offAllNamed('/login');
      return;
    }
    fetchPosts();
  }

  Future<void> editCommentByIndex(int commentIndex, String newText) async {
    if (commentIndex < 0 || commentIndex >= comments.length) return;

    final token = authController.accessToken.value;
    final refresh = authController.refreshToken.value;
    if (token.isEmpty) {
      showCustomSnackBar(
        title: 'Error',
        message: 'Please log in',
        isSuccess: false,
      );
      Get.offAllNamed('/login');
      return;
    }

    final prev = Map<String, dynamic>.from(comments[commentIndex]);
    final int id = (prev['id'] as num).toInt();
    if (editingComment[id] == true) return;

    final trimmed = newText.trim();
    if (trimmed.isEmpty) {
      showCustomSnackBar(
        title: 'Error',
        message: 'Comment cannot be empty',
        isSuccess: false,
      );
      return;
    }
    if ((prev['text'] ?? '') == trimmed) {
      // no change
      return;
    }

    editingComment[id] = true;

    // optimistic patch
    final patched = Map<String, dynamic>.from(prev)..['text'] = trimmed;
    comments[commentIndex] = patched;

    try {
      final res = await apiService.updateComment(token, id.toString(), trimmed);

      if (res['statusCode'] == 200 && res['data'] is Map<String, dynamic>) {
        final server = res['data'] as Map<String, dynamic>;
        // trust server payload
        comments[commentIndex] = {...comments[commentIndex], ...server};
      } else if (res['statusCode'] == 401) {
        final refreshed = await authController.refreshAccessToken(refresh);
        if (refreshed) {
          final newToken = await authController.getAccessToken();
          final retryRes = await apiService.updateComment(newToken!, id.toString(), trimmed);

          if (retryRes['statusCode'] == 200 && retryRes['data'] is Map<String, dynamic>) {
            final server = retryRes['data'] as Map<String, dynamic>;
            comments[commentIndex] = {...comments[commentIndex], ...server};
          } else {
            comments[commentIndex] = prev;
            showCustomSnackBar(
              title: 'Error',
              message: retryRes['data']['error'] ?? 'Failed to update comment after token refresh',
              isSuccess: false,
            );
            Get.offAllNamed('/login');
          }
        } else {
          comments[commentIndex] = prev;
          showCustomSnackBar(
            title: 'Error',
            message: 'Failed to refresh token. Please log in again.',
            isSuccess: false,
          );
          Get.offAllNamed('/login');
        }
      } else {
        // revert on failure
        comments[commentIndex] = prev;
        showCustomSnackBar(
          title: 'Error',
          message: res['data']['error'] ?? 'Failed to update comment',
          isSuccess: false,
        );
      }
    } catch (e, st) {
      debugPrint('editCommentByIndex error: $e\n$st');
      comments[commentIndex] = prev;
      showCustomSnackBar(
        title: 'Error',
        message: 'Failed to update: $e',
        isSuccess: false,
      );
    } finally {
      editingComment.remove(id);
    }
  }

  Future<void> editCommentById(String commentId, String newText) async {
    final id = int.tryParse(commentId);
    if (id == null) return;
    final idx = comments.indexWhere((c) => (c['id'] as num).toInt() == id);
    if (idx == -1) return;
    await editCommentByIndex(idx, newText);
  }

  Future<void> deleteCommentByIndex(int commentIndex) async {
    if (commentIndex < 0 || commentIndex >= comments.length) return;

    final token = authController.accessToken.value;
    final refresh = authController.refreshToken.value;
    if (token.isEmpty) {
      showCustomSnackBar(
        title: 'Error',
        message: 'Please log in',
        isSuccess: false,
      );
      Get.offAllNamed('/login');
      return;
    }

    final toDelete = Map<String, dynamic>.from(comments[commentIndex]);
    final int id = (toDelete['id'] as num).toInt();
    if (deletingComment[id] == true) return;

    deletingComment[id] = true;

    // Optimistic deletion
    comments.removeAt(commentIndex);
    commentsCount.value--;

    try {
      final res = await apiService.deleteComment(token, id.toString());

      if (res['statusCode'] == 200) {
        showCustomSnackBar(
          title: 'Success',
          message: 'Comment deleted successfully',
          isSuccess: true,
        );
      } else if (res['statusCode'] == 401) {
        final refreshed = await authController.refreshAccessToken(refresh);
        if (refreshed) {
          final newToken = await authController.getAccessToken();
          final retryRes = await apiService.deleteComment(newToken!, id.toString());

          if (retryRes['statusCode'] == 200) {
            showCustomSnackBar(
              title: 'Success',
              message: 'Comment deleted successfully',
              isSuccess: true,
            );
          } else {
            comments.insert(commentIndex, toDelete);
            commentsCount.value++;
            showCustomSnackBar(
              title: 'Error',
              message: retryRes['data']['error'] ?? 'Failed to delete comment after token refresh',
              isSuccess: false,
            );
            Get.offAllNamed('/login');
          }
        } else {
          comments.insert(commentIndex, toDelete);
          commentsCount.value++;
          showCustomSnackBar(
            title: 'Error',
            message: 'Failed to refresh token. Please log in again.',
            isSuccess: false,
          );
          Get.offAllNamed('/login');
        }
      } else {
        comments.insert(commentIndex, toDelete);
        commentsCount.value++;
        showCustomSnackBar(
          title: 'Error',
          message: res['data']['error'] ?? 'Failed to delete comment',
          isSuccess: false,
        );
      }
    } catch (e, st) {
      debugPrint('deleteCommentByIndex error: $e\n$st');
      comments.insert(commentIndex, toDelete);
      commentsCount.value++;
      showCustomSnackBar(
        title: 'Error',
        message: 'Failed to delete: $e',
        isSuccess: false,
      );
    } finally {
      deletingComment.remove(id);
    }
  }

  Future<void> toggleCommentLikeByIndex(int commentIndex) async {
    if (commentIndex < 0 || commentIndex >= comments.length) return;

    final token = authController.accessToken.value;
    final refresh = authController.refreshToken.value;
    if (token.isEmpty) {
      showCustomSnackBar(
        title: 'Error',
        message: 'Please log in',
        isSuccess: false,
      );
      Get.offAllNamed('/login');
      return;
    }

    final prev = Map<String, dynamic>.from(comments[commentIndex]);
    final int id = (prev['id'] as num).toInt();
    if (likingComment[id] == true) return; // already in-flight

    likingComment[id] = true;

    final bool wasLiked = (prev['is_liked'] ?? false) == true;
    final int prevCount =
    (prev['react_count'] ?? 0) is int
        ? prev['react_count']
        : int.tryParse('${prev['react_count']}') ?? 0;

    // optimistic
    final patched = Map<String, dynamic>.from(prev);
    patched['is_liked'] = !wasLiked;
    patched['react_count'] =
    wasLiked ? (prevCount - 1).clamp(0, 1 << 30) : prevCount + 1;
    comments[commentIndex] = patched;

    try {
      final res =
      wasLiked
          ? await apiService.unlikeComment(token, id.toString())
          : await apiService.likeComment(token, id.toString());

      if (res['statusCode'] == 200) {
        final server = res['data'];
        if (server is Map<String, dynamic>) {
          // reconcile if server sent back canonical values
          final merged = Map<String, dynamic>.from(comments[commentIndex]);
          if (server.containsKey('is_liked')) {
            merged['is_liked'] = server['is_liked'];
          }
          if (server.containsKey('react_count')) {
            merged['react_count'] = server['react_count'];
          }
          comments[commentIndex] = merged;
        }
      } else if (res['statusCode'] == 401) {
        final refreshed = await authController.refreshAccessToken(refresh);
        if (refreshed) {
          final newToken = await authController.getAccessToken();
          final retryRes =
          wasLiked
              ? await apiService.unlikeComment(newToken!, id.toString())
              : await apiService.likeComment(newToken!, id.toString());

          if (retryRes['statusCode'] == 200) {
            final server = retryRes['data'];
            if (server is Map<String, dynamic>) {
              final merged = Map<String, dynamic>.from(comments[commentIndex]);
              if (server.containsKey('is_liked')) {
                merged['is_liked'] = server['is_liked'];
              }
              if (server.containsKey('react_count')) {
                merged['react_count'] = server['react_count'];
              }
              comments[commentIndex] = merged;
            }
          } else {
            comments[commentIndex] = prev;
            showCustomSnackBar(
              title: 'Error',
              message: retryRes['data']['error'] ?? 'Failed to update like after token refresh',
              isSuccess: false,
            );
            Get.offAllNamed('/login');
          }
        } else {
          comments[commentIndex] = prev;
          showCustomSnackBar(
            title: 'Error',
            message: 'Failed to refresh token. Please log in again.',
            isSuccess: false,
          );
          Get.offAllNamed('/login');
        }
      } else {
        comments[commentIndex] = prev;
        showCustomSnackBar(
          title: 'Error',
          message: res['data']['error'] ?? 'Failed to update like',
          isSuccess: false,
        );
      }
    } catch (e, st) {
      debugPrint('toggleCommentLike error: $e\n$st');
      comments[commentIndex] = prev; // revert
      showCustomSnackBar(
        title: 'Error',
        message: 'Failed to update like: $e',
        isSuccess: false,
      );
    } finally {
      likingComment.remove(id);
    }
  }

  Future<void> submitComment(String postId) async {
    final token = authController.accessToken.value;
    final refresh = authController.refreshToken.value;
    if (token.isEmpty) {
      showCustomSnackBar(
        title: 'Error',
        message: 'Please log in to comment',
        isSuccess: false,
      );
      Get.offAllNamed('/login');
      return;
    }

    final text = commentTextController.text.trim();
    if (text.isEmpty || isSendingComment.value) return;

    isSendingComment.value = true;
    try {
      final res = await apiService.createCommentOnPost(token, postId, text);
      if (res['statusCode'] == 200) {
        final created = (res['data'] as Map<String, dynamic>);

        // Insert at top so user sees it immediately (API sorts desc by created_at)
        comments.insert(0, created);

        // Clear input
        commentTextController.clear();
        hasText.value = false;

        // (Optional) If you also track posts with comment_count, bump it here
        // final idx = othersPost.indexWhere((p) => p['id'].toString() == postId);
        // if (idx != -1) {
        //   final updated = Map<String, dynamic>.from(othersPost[idx]);
        //   updated['comment_count'] = (updated['comment_count'] ?? 0) + 1;
        //   othersPost[idx] = updated;
        //   othersPost.refresh();
        // }
      } else if (res['statusCode'] == 401) {
        final refreshed = await authController.refreshAccessToken(refresh);
        if (refreshed) {
          final newToken = await authController.getAccessToken();
          final retryRes = await apiService.createCommentOnPost(newToken!, postId, text);

          if (retryRes['statusCode'] == 200) {
            final created = (retryRes['data'] as Map<String, dynamic>);
            comments.insert(0, created);
            commentTextController.clear();
            hasText.value = false;
          } else {
            showCustomSnackBar(
              title: 'Error',
              message: retryRes['data']['error'] ?? 'Failed to create comment after token refresh',
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
          message: res['data']['error'] ?? 'Failed to create comment',
          isSuccess: false,
        );
      }
    } catch (e) {
      showCustomSnackBar(
        title: 'Error',
        message: 'Failed to create comment: $e',
        isSuccess: false,
      );
    } finally {
      isSendingComment.value = false;
    }
  }

  void openCommentsForPost(String postId, {bool force = false}) {
    if (!force && currentCommentsPostId.value == postId) return;

    currentCommentsPostId.value = postId;

    // reset comments state
    page.value = 1;
    hasMore.value = false; // set true if your API supports pagination
    comments.clear();

    // initial load
    isLoading.value = true;
    fetchCommentsOnPost(postId);
  }

  Future<void> fetchCommentsOnPost(
      String postId, {
        bool isLoadMore = false,
      }) async {
    if (authController.accessToken.value.isEmpty) {
      debugPrint('No auth token available');
      isLoading(false);
      hasMore(false);
      showCustomSnackBar(
        title: 'Error',
        message: 'Please log in to view comments',
        isSuccess: false,
      );
      Get.offAllNamed('/login');
      return;
    }

    final String token = authController.accessToken.value;
    final String refresh = authController.refreshToken.value;

    if (isLoadMore) {
      if (!hasMore.value || isMoreLoading.value) return;
      isMoreLoading(true);
      page.value += 1;
    } else {
      isLoading(true);
      page.value = 1;
      comments.clear();
    }

    debugPrint(
      'Calling fetchCommentsOnPost with token: $token, postId: $postId, page: ${page.value}',
    );
    try {
      final response = await apiService.fetchCommentsOnPost(token, postId);
      debugPrint('fetchCommentsOnPost response: $response');

      if (response['statusCode'] == 200) {
        final data = response['data'] as List<dynamic>;
        if (data.isEmpty) {
          hasMore(false);
          debugPrint('No more comments available');
          commentsCount++;
        } else {
          comments.addAll(data.cast<Map<String, dynamic>>());
          comments.refresh();
          debugPrint('Comments added: ${comments.length}');

          // Since this endpoint returns the full list (no page param),
          // we should stop load-more after first fetch to avoid duplicates.
          hasMore(false);
        }
      } else if (response['statusCode'] == 401) {
        final refreshed = await authController.refreshAccessToken(refresh);
        if (refreshed) {
          final newToken = await authController.getAccessToken();
          final retryResponse = await apiService.fetchCommentsOnPost(newToken!, postId);
          debugPrint('Retry fetchCommentsOnPost response: $retryResponse');

          if (retryResponse['statusCode'] == 200) {
            final data = retryResponse['data'] as List<dynamic>;
            if (data.isEmpty) {
              hasMore(false);
              debugPrint('No more comments available');
              commentsCount++;
            } else {
              comments.addAll(data.cast<Map<String, dynamic>>());
              comments.refresh();
              debugPrint('Comments added: ${comments.length}');
              hasMore(false);
            }
          } else {
            hasMore(false);
            final errorMsg = retryResponse['data']['error'] ?? 'Failed to load comments after token refresh';
            debugPrint('Retry fetchCommentsOnPost Error: $errorMsg');
            showCustomSnackBar(title: 'Error', message: errorMsg, isSuccess: false);
            Get.offAllNamed('/login');
          }
        } else {
          hasMore(false);
          showCustomSnackBar(
            title: 'Error',
            message: 'Failed to refresh token. Please log in again.',
            isSuccess: false,
          );
          Get.offAllNamed('/login');
        }
      } else {
        hasMore(false);
        final errorMsg = response['data']['error'] ?? 'Failed to load comments';
        debugPrint('fetchCommentsOnPost Error: $errorMsg');
        showCustomSnackBar(title: 'Error', message: errorMsg, isSuccess: false);
      }
    } catch (e, stackTrace) {
      debugPrint('fetchCommentsOnPost Exception: $e\n$stackTrace');
      hasMore(false);
      showCustomSnackBar(
        title: 'Error',
        message: 'Failed to load comments: $e',
        isSuccess: false,
      );
    } finally {
      isLoading(false);
      isMoreLoading(false);
    }
  }

  // Future<void> toggleLike(int index) async {
  //   if (index < 0 || index >= posts.length) return;
  //
  //   final token = authController.accessToken.value;
  //   final refresh = authController.refreshToken.value;
  //   if (token.isEmpty) {
  //     showCustomSnackBar(
  //       title: 'Error',
  //       message: 'Please log in',
  //       isSuccess: false,
  //     );
  //     Get.offAllNamed('/login');
  //     return;
  //   }
  //
  //   final post = Map<String, dynamic>.from(posts[index]);
  //   final String postId = (post['id'] as num).toString();
  //   final bool isLiked = post['is_liked'] ?? false;
  //   final int reactCount = (post['react_count'] as num?)?.toInt() ?? 0;
  //
  //   // Optimistic update
  //   final updatedPost = Map<String, dynamic>.from(post);
  //   updatedPost['is_liked'] = !isLiked;
  //   updatedPost['react_count'] = isLiked ? reactCount - 1 : reactCount + 1;
  //   posts[index] = updatedPost;
  //   posts.refresh();
  //
  //   try {
  //     final response = await apiService.toggleLike(token, postId);
  //
  //     if (response['statusCode'] == 200) {
  //       final serverData = response['data'] as Map<String, dynamic>;
  //       final mergedPost = Map<String, dynamic>.from(posts[index]);
  //       mergedPost['is_liked'] = serverData['is_liked'] ?? updatedPost['is_liked'];
  //       mergedPost['react_count'] = serverData['react_count'] ?? updatedPost['react_count'];
  //       posts[index] = mergedPost;
  //       posts.refresh();
  //     } else if (response['statusCode'] == 401) {
  //       final refreshed = await authController.refreshAccessToken(refresh);
  //       if (refreshed) {
  //         final newToken = await authController.getAccessToken();
  //         final retryResponse = await apiService.toggleLike(newToken!, postId);
  //
  //         if (retryResponse['statusCode'] == 200) {
  //           final serverData = retryResponse['data'] as Map<String, dynamic>;
  //           final mergedPost = Map<String, dynamic>.from(posts[index]);
  //           mergedPost['is_liked'] = serverData['is_liked'] ?? updatedPost['is_liked'];
  //           mergedPost['react_count'] = serverData['react_count'] ?? updatedPost['react_count'];
  //           posts[index] = mergedPost;
  //           posts.refresh();
  //         } else {
  //           posts[index] = post;
  //           posts.refresh();
  //           showCustomSnackBar(
  //             title: 'Error',
  //             message: retryResponse['data']['error'] ?? 'Failed to update like after token refresh',
  //             isSuccess: false,
  //           );
  //           Get.offAllNamed('/login');
  //         }
  //       } else {
  //         posts[index] = post;
  //         posts.refresh();
  //         showCustomSnackBar(
  //           title: 'Error',
  //           message: 'Failed to refresh token. Please log in again.',
  //           isSuccess: false,
  //         );
  //         Get.offAllNamed('/login');
  //       }
  //     } else {
  //       posts[index] = post;
  //       posts.refresh();
  //       showCustomSnackBar(
  //         title: 'Error',
  //         message: response['data']['error'] ?? 'Failed to update like',
  //         isSuccess: false,
  //       );
  //     }
  //   } catch (e, stackTrace) {
  //     debugPrint('toggleLike Exception: $e\n$stackTrace');
  //     posts[index] = post;
  //     posts.refresh();
  //     showCustomSnackBar(
  //       title: 'Error',
  //       message: 'Failed to update like: $e',
  //       isSuccess: false,
  //     );
  //   }
  // }
  Future<void> toggleLike(int postId, int index) async {
    final post = posts[index];
    final isLiked = post['is_liked'];
    final token = authController.accessToken.value;

    isLoading(true);

    try {
      final response = await apiService.toggleLike(postId, isLiked, token);

      if (response['statusCode'] == 200) {
        // Successfully toggled the like state
        debugPrint('Like toggled successfully');
        post['is_liked'] = !isLiked;
        post['react_count'] =
            isLiked ? post['react_count'] - 1 : post['react_count'] + 1;
        posts[index] = Map.from(post); // Update the post in the list
        posts.refresh(); // Refresh the UI
      } else {
        // Handle error from API
        Get.snackbar('Error', response['data']['error']);
      }
    } catch (e) {
      // Handle unexpected errors
      Get.snackbar('Error', 'Failed to update like: $e');
    } finally {
      isLoading(false); // Stop loading
    }
  }

  // Future<void> toggleOthersLike(int index) async {
  //   if (index < 0 || index >= othersPost.length) return;
  //
  //   final token = authController.accessToken.value;
  //   final refresh = authController.refreshToken.value;
  //   if (token.isEmpty) {
  //     showCustomSnackBar(
  //       title: 'Error',
  //       message: 'Please log in',
  //       isSuccess: false,
  //     );
  //     Get.offAllNamed('/login');
  //     return;
  //   }
  //
  //   final post = Map<String, dynamic>.from(othersPost[index]);
  //   final String postId = (post['id'] as num).toString();
  //   final bool isLiked = post['is_liked'] ?? false;
  //   final int reactCount = (post['react_count'] as num?)?.toInt() ?? 0;
  //
  //   // Optimistic update
  //   final updatedPost = Map<String, dynamic>.from(post);
  //   updatedPost['is_liked'] = !isLiked;
  //   updatedPost['react_count'] = isLiked ? reactCount - 1 : reactCount + 1;
  //   othersPost[index] = updatedPost;
  //   othersPost.refresh();
  //
  //   try {
  //     final response = await apiService.toggleLike(token, postId);
  //
  //     if (response['statusCode'] == 200) {
  //       final serverData = response['data'] as Map<String, dynamic>;
  //       final mergedPost = Map<String, dynamic>.from(othersPost[index]);
  //       mergedPost['is_liked'] = serverData['is_liked'] ?? updatedPost['is_liked'];
  //       mergedPost['react_count'] = serverData['react_count'] ?? updatedPost['react_count'];
  //       othersPost[index] = mergedPost;
  //       othersPost.refresh();
  //     } else if (response['statusCode'] == 401) {
  //       final refreshed = await authController.refreshAccessToken(refresh);
  //       if (refreshed) {
  //         final newToken = await authController.getAccessToken();
  //         final retryResponse = await apiService.toggleLike(newToken!, postId);
  //
  //         if (retryResponse['statusCode'] == 200) {
  //           final serverData = retryResponse['data'] as Map<String, dynamic>;
  //           final mergedPost = Map<String, dynamic>.from(othersPost[index]);
  //           mergedPost['is_liked'] = serverData['is_liked'] ?? updatedPost['is_liked'];
  //           mergedPost['react_count'] = serverData['react_count'] ?? updatedPost['react_count'];
  //           othersPost[index] = mergedPost;
  //           othersPost.refresh();
  //         } else {
  //           othersPost[index] = post;
  //           othersPost.refresh();
  //           showCustomSnackBar(
  //             title: 'Error',
  //             message: retryResponse['data']['error'] ?? 'Failed to update like after token refresh',
  //             isSuccess: false,
  //           );
  //           Get.offAllNamed('/login');
  //         }
  //       } else {
  //         othersPost[index] = post;
  //         othersPost.refresh();
  //         showCustomSnackBar(
  //           title: 'Error',
  //           message: 'Failed to refresh token. Please log in again.',
  //           isSuccess: false,
  //         );
  //         Get.offAllNamed('/login');
  //       }
  //     } else {
  //       othersPost[index] = post;
  //       othersPost.refresh();
  //       showCustomSnackBar(
  //         title: 'Error',
  //         message: response['data']['error'] ?? 'Failed to update like',
  //         isSuccess: false,
  //       );
  //     }
  //   } catch (e, stackTrace) {
  //     debugPrint('toggleOthersLike Exception: $e\n$stackTrace');
  //     othersPost[index] = post;
  //     othersPost.refresh();
  //     showCustomSnackBar(
  //       title: 'Error',
  //       message: 'Failed to update like: $e',
  //       isSuccess: false,
  //     );
  //   }
  // }
  Future<void> toggleOthersLike(int postId, int index) async {
    final post = othersPost[index];
    final isLiked = post['is_liked'] ?? false;
    final token = authController.accessToken.value;

    if (token.isEmpty) {
      showCustomSnackBar(
        title: 'Error',
        message: 'Please log in to like posts',
        isSuccess: false,
      );
      Get.offAllNamed('/login');
      return;
    }

    // Optimistic update
    final updatedPost = Map<String, dynamic>.from(post);
    updatedPost['is_liked'] = !isLiked;
    updatedPost['react_count'] =
    isLiked ? (post['react_count'] ?? 0) - 1 : (post['react_count'] ?? 0) + 1;
    othersPost[index] = updatedPost;
    othersPost.refresh(); // Refresh the UI for this specific change

    try {
      final response = await apiService.toggleLike(postId, isLiked, token);

      if (response['statusCode'] == 200) {
        debugPrint('Like toggled successfully');
        // Optionally, update with server data if additional fields are returned
        if (response['data'] is Map<String, dynamic>) {
          final serverData = response['data'] as Map<String, dynamic>;
          final mergedPost = Map<String, dynamic>.from(othersPost[index]);
          mergedPost['is_liked'] = serverData['is_liked'] ?? !isLiked;
          mergedPost['react_count'] = serverData['react_count'] ?? updatedPost['react_count'];
          othersPost[index] = mergedPost;
          othersPost.refresh();
        }
      } else {
        // Revert on failure
        othersPost[index] = post;
        othersPost.refresh();
        showCustomSnackBar(
          title: 'Error',
          message: response['data']['error'] ?? 'Failed to update like',
          isSuccess: false,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('toggleOthersLike Exception: $e\n$stackTrace');
      // Revert on error
      othersPost[index] = post;
      othersPost.refresh();
      showCustomSnackBar(
        title: 'Error',
        message: 'Failed to update like: $e',
        isSuccess: false,
      );
    }
  }

  Future<void> fetchPosts({bool isLoadMore = false}) async {
    if (authController.accessToken.value.isEmpty) {
      debugPrint('No auth token available');
      isLoading(false);
      hasMore(false);
      showCustomSnackBar(
        title: 'Error',
        message: 'Please log in to view posts',
        isSuccess: false,
      );
      Get.offAllNamed('/login');
      return;
    }

    final String token = authController.accessToken.value;
    final String refresh = authController.refreshToken.value;

    if (isLoadMore) {
      if (!hasMore.value || isMoreLoading.value) return;
      isMoreLoading(true);
      page.value += 1;
    } else {
      isLoading(true);
      page.value = 1;
      posts.clear();
    }

    debugPrint('Calling fetchPosts with token: $token, page: ${page.value}');
    try {
      final response = await apiService.fetchPosts(token);
      debugPrint('fetchPosts response: $response');

      if (response['statusCode'] == 200) {
        final data = response['data'] as List<dynamic>;
        if (data.isEmpty) {
          hasMore(false);
          debugPrint('No more posts available');
          postsCount++;
        } else {
          posts.addAll(data.cast<Map<String, dynamic>>());
          posts.refresh();
          debugPrint('Posts added: ${posts.length}');
        }
      } else if (response['statusCode'] == 401) {
        final refreshed = await authController.refreshAccessToken(refresh);
        if (refreshed) {
          final newToken = await authController.getAccessToken();
          final retryResponse = await apiService.fetchPosts(newToken!);
          debugPrint('Retry fetchPosts response: $retryResponse');

          if (retryResponse['statusCode'] == 200) {
            final data = retryResponse['data'] as List<dynamic>;
            if (data.isEmpty) {
              hasMore(false);
              debugPrint('No more posts available');
              postsCount++;
            } else {
              posts.addAll(data.cast<Map<String, dynamic>>());
              posts.refresh();
              debugPrint('Posts added: ${posts.length}');
            }
          } else {
            hasMore(false);
            final errorMsg = retryResponse['data']['error'] ?? 'Failed to load posts after token refresh';
            debugPrint('Retry fetchPosts Error: $errorMsg');
            showCustomSnackBar(title: 'Error', message: errorMsg, isSuccess: false);
            Get.offAllNamed('/login');
          }
        } else {
          hasMore(false);
          showCustomSnackBar(
            title: 'Error',
            message: 'Failed to refresh token. Please log in again.',
            isSuccess: false,
          );
          Get.offAllNamed('/login');
        }
      } else {
        hasMore(false);
        final errorMsg = response['data']['error'] ?? 'Failed to load posts';
        debugPrint('fetchPosts Error: $errorMsg');
        showCustomSnackBar(title: 'Error', message: errorMsg, isSuccess: false);
      }
    } catch (e, stackTrace) {
      debugPrint('fetchPosts Exception: $e\n$stackTrace');
      hasMore(false);
      showCustomSnackBar(
        title: 'Error',
        message: 'Failed to load posts: $e',
        isSuccess: false,
      );
    } finally {
      isLoading(false);
      isMoreLoading(false);
    }
  }

  Future<void> fetchOthersPost({bool isLoadMore = false}) async {
    if (authController.accessToken.value.isEmpty) {
      debugPrint('No auth token available');
      isLoading(false);
      hasMore(false);
      showCustomSnackBar(
        title: 'Error',
        message: 'Please log in to view posts',
        isSuccess: false,
      );
      Get.offAllNamed('/login');
      return;
    }

    final String token = authController.accessToken.value;
    final String refresh = authController.refreshToken.value;

    if (isLoadMore) {
      if (!hasMore.value || isMoreLoading.value) return;
      isMoreLoading(true);
      page.value += 1;
    } else {
      isLoading(true);
      page.value = 1;
      othersPost.clear();
    }

    debugPrint(
      'Calling fetchOthersPost with token: $token, page: ${page.value}',
    );
    try {
      final response = await apiService.fetchOthersPost(token);
      debugPrint('fetchOthersPost response: $response');

      if (response['statusCode'] == 200) {
        final data = response['data'] as List<dynamic>;
        if (data.isEmpty) {
          hasMore(false);
          debugPrint('No more posts available');
          othersPostCount++;
        } else {
          othersPost.addAll(data.cast<Map<String, dynamic>>());
          othersPost.refresh();
          debugPrint('Posts added: ${othersPost.length}');
        }
      } else if (response['statusCode'] == 401) {
        final refreshed = await authController.refreshAccessToken(refresh);
        if (refreshed) {
          final newToken = await authController.getAccessToken();
          final retryResponse = await apiService.fetchOthersPost(newToken!);
          debugPrint('Retry fetchOthersPost response: $retryResponse');

          if (retryResponse['statusCode'] == 200) {
            final data = retryResponse['data'] as List<dynamic>;
            if (data.isEmpty) {
              hasMore(false);
              debugPrint('No more posts available');
              othersPostCount++;
            } else {
              othersPost.addAll(data.cast<Map<String, dynamic>>());
              othersPost.refresh();
              debugPrint('Posts added: ${othersPost.length}');
            }
          } else {
            hasMore(false);
            final errorMsg = retryResponse['data']['error'] ?? 'Failed to load posts after token refresh';
            debugPrint('Retry fetchOthersPost Error: $errorMsg');
            showCustomSnackBar(title: 'Error', message: errorMsg, isSuccess: false);
            Get.offAllNamed('/login');
          }
        } else {
          hasMore(false);
          showCustomSnackBar(
            title: 'Error',
            message: 'Failed to refresh token. Please log in again.',
            isSuccess: false,
          );
          Get.offAllNamed('/login');
        }
      } else {
        hasMore(false);
        final errorMsg = response['data']['error'] ?? 'Failed to load posts';
        debugPrint('fetchOthersPost Error: $errorMsg');
        showCustomSnackBar(title: 'Error', message: errorMsg, isSuccess: false);
      }
    } catch (e, stackTrace) {
      debugPrint('fetchOthersPost Exception: $e\n$stackTrace');
      hasMore(false);
      showCustomSnackBar(
        title: 'Error',
        message: 'Failed to load posts: $e',
        isSuccess: false,
      );
    } finally {
      isLoading(false);
      isMoreLoading(false);
    }
  }
}
