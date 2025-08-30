import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../res/components/api_service.dart';
import '../../../../widgets/show_custom_snack_ber.dart';
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
    if (token.isEmpty) {
      showCustomSnackBar(
        title: 'Error',
        message: 'Please log in',
        isSuccess: false,
      );
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
    if (token.isEmpty) {
      showCustomSnackBar(
        title: 'Error',
        message: 'Please log in',
        isSuccess: false,
      );
      return;
    }

    final toDelete = Map<String, dynamic>.from(comments[commentIndex]);
    final int id = (toDelete['id'] as num).toInt();
    if (deletingComment[id] == true) return;

    deletingComment[id] = true;

    // optimistic remove
    comments.removeAt(commentIndex);

    try {
      final res = await apiService.deleteComment(token, id.toString());
      if (res['statusCode'] != 200) {
        // revert on failure
        comments.insert(commentIndex, toDelete);
        showCustomSnackBar(
          title: 'Error',
          message: res['data']['error'] ?? 'Failed to delete comment',
          isSuccess: false,
        );
      }
    } catch (e) {
      comments.insert(commentIndex, toDelete);
      showCustomSnackBar(
        title: 'Error',
        message: 'Failed to delete comment: $e',
        isSuccess: false,
      );
    } finally {
      deletingComment.remove(id);
    }
  }

  Future<void> toggleCommentLikeByIndex(int commentIndex) async {
    if (commentIndex < 0 || commentIndex >= comments.length) return;

    final token = authController.accessToken.value;
    if (token.isEmpty) {
      showCustomSnackBar(
        title: 'Error',
        message: 'Please log in',
        isSuccess: false,
      );
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
      } else {
        // revert
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

  Future<void> toggleOthersLike(int postId, int index) async {
    final post = othersPost[index];
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
