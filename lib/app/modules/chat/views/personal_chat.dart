

import 'dart:io';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

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

  @override
  void initState() {
    super.initState();
    // Initialize chat when screen opens
    if (widget.roomId != null) {
      controller.initializeChat(widget.roomId!);
    }
  }

  @override
  void dispose() {
    // Clean up when leaving chat
    controller.cleanupChat();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      controller.pickedImage.value = File(pickedFile.path);
    }
  }

  Future<void> _pickVideoOrImageFromGallery() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      controller.pickedImage.value = File(file.path);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
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

  @override
  Widget build(BuildContext context) {
    final currentUsername = profileController.userName.value;

    // Auto-scroll when new messages arrive
    controller.messages.listen((_) {
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    });

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
                  Get.to(Report(), transition: Transition.rightToLeft);
                } else if (value == 'Block User') {
                  Get.to(BlockUser(), transition: Transition.rightToLeft);
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
          // Messages List
          Expanded(
            child: Obx(() {
              if (controller.isMessageLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.messages.isEmpty) {
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

                  // Check if we need to show date header
                  bool showDateHeader = false;
                  if (currentDate != lastDate) {
                    showDateHeader = true;
                    lastDate = currentDate;
                  }

                  return Column(
                    children: [
                      // Date header
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

                      // Message bubble
                      Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          margin: EdgeInsets.only(
                            bottom: 8.h,
                            left: isMe ? 60.w : 0,
                            right: isMe ? 0 : 60.w,
                          ),
                          decoration: BoxDecoration(
                            color: isMe
                                ? AppColor.vividBlue.withOpacity(0.2)
                                : AppColor.softBeige,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message['content'] ?? '',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: AppColor.textBlackColor,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                _formatTime(timestamp),
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: AppColor.textBlackColor.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            }),
          ),

          // Input bar
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
              onChanged: (value) => controller.message.value = value,
              maxLines: null,
              keyboardType: TextInputType.multiline,
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
                FocusScope.of(context).unfocus();
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
