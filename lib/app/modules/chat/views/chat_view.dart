// lib/app/modules/chat/views/chat.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../../../widgets/input_text_widget.dart';
import '../controllers/chat_controller.dart';
import 'create_group.dart';
import 'personal_chat.dart';
import 'search.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    // Kick off loading when screen appears (only if needed)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.rooms.isEmpty && !controller.isRoomsLoading.value) {
        controller.fetchRooms();
      }
    });

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: controller.fetchRooms,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              title: Text(
                'Chat',
                style: TextStyle(
                  fontSize: 25.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              centerTitle: true,
              automaticallyImplyLeading: false,
              actions: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: IconButton(
                    onPressed: () {
                      Get.to(CreateGroup(), transition: Transition.rightToLeft);
                    },
                    icon: Icon(
                      Icons.add_circle_outline,
                      size: 30,
                      color: AppColor.textBlackColor,
                    ),
                  ),
                ),
              ],
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 10.h),
                child: InputTextWidget(
                  onTap: () {
                    Get.to(Search(), transition: Transition.rightToLeft);
                  },
                  onChanged: (e) {},
                  borderColor: AppColor.backgroundColor,
                  hintText: 'Search',
                  readOnly: true,
                  hintTextColor: AppColor.textGreyColor2,
                  leadingIcon: ImageAssets.search,
                  textColor: AppColor.textGreyColor2,
                  leading: true,
                  height: 48,
                ),
              ),
            ),

            // Rooms list
            SliverToBoxAdapter(
              child: Obx(() {
                if (controller.isRoomsLoading.value) {
                  return Padding(
                    padding: EdgeInsets.only(top: 40.h),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                if (controller.roomsError.value.isNotEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 20.h,
                    ),
                    child: Center(
                      child: Text(
                        controller.roomsError.value,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColor.greyTone,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  );
                }

                if (controller.rooms.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 20.h,
                    ),
                    child: Center(
                      child: Text(
                        'No chat rooms',
                        style: TextStyle(
                          color: AppColor.greyTone,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: controller.rooms.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(vertical: 6.h),
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final room = controller.rooms[index];
                    final title = controller.roomTitle(room);
                    final subtitle = controller.lastMessageText(room);
                    final avatarUrl = controller.roomAvatar(room);
                    final lastTime = _formatTime(room['last_message_at']);

                    return ListTile(
                      onTap: () {
                        // Navigate to your chat room screen.
                        // If your PersonalChat accepts roomId, pass it:
                        // Get.to(() => PersonalChat(name: title, roomId: room['id']), transition: Transition.rightToLeft);
                        Get.to(
                          () => PersonalChat(name: title,image: avatarUrl,roomId: room['id']),
                          transition: Transition.rightToLeft,
                        );
                      },
                      leading: CircleAvatar(
                        radius: 28.r,
                        backgroundColor: AppColor.greyColor,
                        child: ClipOval(
                          child:
                              (avatarUrl != null && avatarUrl.isNotEmpty)
                                  ? CachedNetworkImage(
                                    imageUrl: avatarUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorWidget:
                                        (_, _, _) => Image.asset(
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
                      title: Text(
                        title,
                        style: TextStyle(
                          color: AppColor.darkGrey,
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      subtitle: Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColor.greyTone,
                          fontSize: 15.sp,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(height: 5.h),
                          Text(
                            lastTime ?? '',
                            style: TextStyle(
                              color: AppColor.greyTone,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          // If you want unread badge, plug your unread count here:
                          // _UnreadBadge(count: unreadCount),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  String? _formatTime(dynamic iso) {
    if (iso is! String || iso.isEmpty) return null;
    // Keep it simple; rely on server time string.
    // If you want, parse and format: DateFormat('h:mm a').format(DateTime.parse(iso).toLocal())
    return iso;
  }
}
