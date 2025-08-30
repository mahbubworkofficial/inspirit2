import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../home/views/report.dart';
import '../../profile/controllers/profile_controller.dart';
import '../controllers/chat_controller.dart';
import '../widget/option_menu.dart';
import 'block_user.dart';

class PersonalChat extends StatefulWidget {
  final String name;
  final String? image;
  final int? roomId;

  const PersonalChat({
    super.key,
    required this.name,
    this.image,
    this.roomId,
  });

  @override
  State<PersonalChat> createState() => _PersonalChatState();
}

class _PersonalChatState extends State<PersonalChat> {
  final ChatController controller = Get.find<ChatController>();
  final ProfileController profileController = Get.put(ProfileController());
  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _textFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    controller.setScrollController(_scrollController);

    if (widget.roomId != null) {
      controller.initializeChat(widget.roomId!);
    }

    _textFocusNode.addListener(() {
      if (_textFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () {
          controller.scrollToBottom();
        });
      }
    });

    ever(controller.messages, (messages) {
      Future.delayed(const Duration(milliseconds: 100), () {
        controller.scrollToBottom();
      });
    });
  }

  @override
  void dispose() {
    controller.cleanupChat();
    _scrollController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        controller.pickedImage.value = file;
        await controller.sendImage(file: file);
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _pickVideoOrImageFromGallery() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (file != null) {
        final fileExtension = file.path.split('.').last.toLowerCase();
        if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(fileExtension)) {
          final imageFile = File(file.path);
          controller.pickedImage.value = imageFile;
          await controller.sendImage(file: imageFile);
        } else {
          _showError('Unsupported file type');
        }
      }
    } catch (e) {
      _showError('Failed to pick media: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showFullImage(dynamic image) {
    if (image == null) return;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            width: double.infinity,
            height: 0.8.sh,
            child: image is File
                ? Image.file(
              image,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.error,
                color: Colors.white,
                size: 50,
              ),
            )
                : CachedNetworkImage(
              imageUrl: image,
              fit: BoxFit.contain,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(
                Icons.error,
                color: Colors.white,
                size: 50,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final dateTime = DateTime.parse(timestamp).toLocal();
      return DateFormat('h:mm a').format(dateTime);
    } catch (e) {
      return '';
    }
  }

  String _getDateHeader(String? timestamp) {
    if (timestamp == null) return 'Today';
    try {
      final dateTime = DateTime.parse(timestamp).toLocal();
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else {
        return DateFormat('MMMM d, y').format(dateTime);
      }
    } catch (e) {
      return 'Today';
    }
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isMe) {
    final content = message['content'] ?? '';
    final timestamp = message['timestamp'] as String?;
    final image = message['image'];
    final hasImage = image != null && (image is String && image.isNotEmpty || image is File);

    return GestureDetector(
      onTap: hasImage ? () => _showFullImage(image) : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        margin: EdgeInsets.only(
          bottom: 8.h,
          left: isMe ? 60.w : 0,
          right: isMe ? 0 : 60.w,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppColor.vividBlue.withOpacity(0.2) : AppColor.softBeige,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image content
            if (hasImage) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: image is File
                    ? Image.file(
                  image,
                  fit: BoxFit.cover,
                  width: 200.w,
                  height: 200.h,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 200.w,
                    height: 200.h,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  ),
                )
                    : CachedNetworkImage(
                  imageUrl: image,
                  fit: BoxFit.cover,
                  width: 200.w,
                  height: 200.h,
                  placeholder: (context, url) => Container(
                    width: 200.w,
                    height: 200.h,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 200.w,
                    height: 200.h,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  ),
                ),
              ),
              if (content.isNotEmpty) SizedBox(height: 8.h),
            ],
            // Text content
            if (content.isNotEmpty) ...[
              SelectableText(
                content,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColor.textBlackColor,
                  height: 1.3,
                ),
              ),
              SizedBox(height: 4.h),
            ],
            // Timestamp
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _formatTime(timestamp),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColor.textBlackColor.withOpacity(0.6),
                  ),
                ),
                if (isMe) ...[
                  SizedBox(width: 4.w),
                  Icon(
                    message['is_read'] == true ? Icons.done_all : Icons.done,
                    size: 12.sp,
                    color: message['is_read'] == true ? AppColor.vividBlue : AppColor.greyColor,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUsername = profileController.userName.value;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColor.blackColor,
          ),
        ),
        leadingWidth: 40.w,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20.r,
              backgroundColor: AppColor.greyColor,
              child: ClipOval(
                child: (widget.image != null && widget.image!.isNotEmpty)
                    ? CachedNetworkImage(
                  imageUrl: widget.image!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorWidget: (_, _, _) => Image.asset(
                    ImageAssets.person2,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                )
                    : Image.asset(
                  ImageAssets.person2,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                widget.name,
                style: TextStyle(
                  color: AppColor.darkGrey,
                  fontWeight: FontWeight.w600,
                  fontSize: 18.sp,
                  letterSpacing: 1.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          Obx(
                () => CustomAppBarMenu(
              options: controller.isuserblocked.value
                  ? ['Clear Chat', 'Unblock User']
                  : ['Mute', 'Clear Chat', 'Report User', 'Block User'],
              onSelected: (value) {
                if (value == 'Report User') {
                  Get.to(() => const Report(), transition: Transition.rightToLeft);
                } else if (value == 'Block User') {
                  Get.to(() => const BlockUser(), transition: Transition.rightToLeft);
                } else if (value == 'Unblock User') {
                  controller.isuserblocked.value = false;
                }
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Obx(() => controller.isMessageLoading.value
              ? Container(
            width: double.infinity,
            color: Colors.blue[100],
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Text(
              'Loading messages...',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.sp, color: Colors.blue[700]),
            ),
          )
              : const SizedBox.shrink()),
          Expanded(
            child: Obx(() {
              if (controller.messages.isEmpty && !controller.isMessageLoading.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64.sp,
                        color: AppColor.greyColor,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No messages yet',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppColor.greyColor,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Start a conversation!',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColor.greyColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                );
              }

              String? lastDate;

              return ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  final isMe = message['sender'] == currentUsername;
                  final timestamp = message['timestamp'] as String?;
                  final currentDate = _getDateHeader(timestamp);

                  bool showDateHeader = false;
                  if (currentDate != lastDate) {
                    showDateHeader = true;
                    lastDate = currentDate;
                  }

                  return Column(
                    children: [
                      if (showDateHeader)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: Row(
                            children: [
                              Expanded(child: Divider(color: AppColor.softBeige)),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.w),
                                child: Text(
                                  currentDate,
                                  style: TextStyle(
                                    color: AppColor.beigeBrown,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: AppColor.softBeige)),
                            ],
                          ),
                        ),
                      Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: _buildMessageBubble(message, isMe),
                      ),
                    ],
                  );
                },
              );
            }),
          ),
          Obx(
                () => controller.isuserblocked.value
                ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Text(
                'Unblock User to continue Chat',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColor.greyTone,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            )
                : _buildInputBar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(12.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColor.white3Color,
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Obx(
                () => controller.message.value.isEmpty
                ? GestureDetector(
              child: CircleAvatar(
                radius: 18.r,
                backgroundColor: AppColor.default1Color,
                child: Icon(
                  Icons.camera_alt,
                  color: AppColor.whiteColor,
                  size: 18.sp,
                ),
              ),
              onTap: () {
                _pickImage(ImageSource.camera);
              },
            )
                : const SizedBox.shrink(),
          ),
          SizedBox(width: controller.message.value.isEmpty ? 10.w : 0),
          Expanded(
            child: TextField(
              controller: controller.textController,
              focusNode: _textFocusNode,
              onChanged: (value) {
                controller.message.value = value;
                Future.delayed(const Duration(milliseconds: 100), () {
                  controller.scrollToBottom();
                });
              },
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: 'Message...',
                hintStyle: TextStyle(
                  color: AppColor.greyColor1,
                  fontSize: 14.sp,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8.h),
              ),
            ),
          ),
          Obx(
                () => controller.message.value.isEmpty
                ? Row(
              children: [
                GestureDetector(
                  onTap: () {
                    // TODO: Implement voice recording
                  },
                  child: Image.asset(
                    ImageAssets.microphone,
                    width: 28.w,
                    height: 28.h,
                  ),
                ),
                SizedBox(width: 10.w),
                GestureDetector(
                  onTap: () {
                    _pickVideoOrImageFromGallery();
                  },
                  child: Image.asset(
                    ImageAssets.gallery,
                    width: 28.w,
                    height: 28.h,
                  ),
                ),
              ],
            )
                : GestureDetector(
              onTap: () {
                controller.sendMessage();
                _textFocusNode.requestFocus();
                Future.delayed(const Duration(milliseconds: 200), () {
                  controller.scrollToBottom();
                });
              },
              child: SvgPicture.asset(
                ImageAssets.send,
                height: 24.h,
                width: 24.w,
              ),
            ),
          ),
        ],
      ),
    );
  }
}