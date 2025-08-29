import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../../../widgets/custom_button.dart';
import '../../chat/controllers/chat_controller.dart';
import '../../explore/views/event_list_view.dart';
import '../../explore/views/other_user_post.dart';
import '../../explore/views/post_view.dart';
import '../../memory/views/memorial_view.dart';
import '../controllers/profile_controller.dart';
import 'friend_list_view.dart';
import 'settings.dart';

enum AccountTab { memorial, post, event }

class AccountView extends GetView<ProfileController> {
  const AccountView({super.key, required this.arguments});
  final List<String?> arguments;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewType =
          (arguments.length > 1 && arguments[1] != null)
              ? arguments[1]!
              : 'myProfile';

      if (viewType == 'othersProfile') {
        final String? argUserId = (arguments.isNotEmpty) ? arguments[0] : null;
        if (argUserId == null || argUserId.isEmpty) return;
        controller.userId.value = argUserId;

        // We expect details to already be set by UserListView.
        // Only ensure posts are loaded for this user.

        if (controller.userProfile.value == null) {
          await controller.fetchUserProfile();
        }
      }
    });

    final String viewType =
        (arguments.length > 1 && arguments[1] != null)
            ? arguments[1]!
            : 'myProfile';
    final String? eventArg = (arguments.isNotEmpty) ? arguments[0] : null;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Obx(() {
            final bool waitingForOthers =
                viewType == 'othersProfile' &&
                controller.othersUserProfile.value == null;
            final bool waitingForMe =
                viewType != 'othersProfile' &&
                controller.userProfile.value == null;

            if (controller.isLoading.value &&
                (waitingForOthers || waitingForMe)) {
              return const Center(child: CircularProgressIndicator());
            }

            final Map<String, dynamic>? profile = _unifiedProfileMap(viewType);

            if (profile == null) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        controller.errorMessage.value.isEmpty
                            ? 'No profile loaded yet.'
                            : controller.errorMessage.value,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColor.greyTone,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      ElevatedButton(
                        onPressed: () {
                          controller.fetchUserProfile();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: viewType == 'othersProfile' ? 250.h : 215.h,
                  toolbarHeight: 55.h,
                  pinned: true,
                  automaticallyImplyLeading: false,
                  backgroundColor: AppColor.backgroundColor,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    titlePadding: EdgeInsets.symmetric(horizontal: 20.w),
                    title: Column(
                      children: [
                        if (viewType == 'myProfile')
                          _MyHeader(profile: profile),
                        if (viewType == 'othersProfile')
                          _OtherHeader(profile: profile),
                      ],
                    ),
                    background: _BackgroundSection(
                      viewType: viewType,
                      profile: profile,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      children: [
                        SizedBox(height: 20.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _TabButton(
                              label: 'Memorial',
                              isSelected:
                                  controller.accountSelectedTab.value ==
                                  'Memorial',
                              onTap:
                                  () => controller.setAccountSelectedTab(
                                    'Memorial',
                                  ),
                            ),
                            _TabButton(
                              label: 'Post',
                              isSelected:
                                  controller.accountSelectedTab.value == 'Post',
                              onTap:
                                  () =>
                                      controller.setAccountSelectedTab('Post'),
                            ),
                            _TabButton(
                              label: 'Event',
                              isSelected:
                                  controller.accountSelectedTab.value ==
                                  'Event',
                              onTap:
                                  () =>
                                      controller.setAccountSelectedTab('Event'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Obx(
                    () => IndexedStack(
                      index: [
                        'Memorial',
                        'Post',
                        'Event',
                      ].indexOf(controller.accountSelectedTab.value),
                      children: [
                        const MemorialView(),
                        viewType == 'myProfile'
                            ? const PostView()
                            : OtherUserPost(),
                        EventListView(arguments: eventArg),
                      ],
                    ),
                  ),
                ),
                const SliverFillRemaining(),
              ],
            );
          }),
        ),
      ),
    );
  }

  Map<String, dynamic>? _unifiedProfileMap(String viewType) {
    if (viewType == 'othersProfile') {
      return controller.othersUserProfile.value;
    }
    final me = controller.userProfile.value;
    if (me == null) return null;
    return {
      'id': me.id,
      'name': me.name,
      'username': me.username,
      'profilePhoto': me.profilePhoto,
      'friendsCount': me.friendsCount,
      'about': me.about,
      'email': me.email,
      'isFriend': me.isFriend,
    };
  }
}


class _MyHeader extends GetView<ProfileController> {
  const _MyHeader({required this.profile});
  final Map<String, dynamic> profile;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 25.r,
                backgroundColor: AppColor.backgroundColor,
                child: ClipOval(
                  child:
                      (profile['profilePhoto'] ?? '').toString().isNotEmpty
                          ? CachedNetworkImage(
                            imageUrl: profile['profilePhoto'],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            placeholder:
                                (context, url) =>
                                    Container(color: AppColor.backgroundColor),
                            errorWidget:
                                (context, url, error) => Image.asset(
                                  ImageAssets.image,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                          )
                          : Image.asset(
                            ImageAssets.image,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 155.w,
                    height: 20.h,
                    child: Text(
                      profile['name'] ?? '',
                      style: TextStyle(
                        color: AppColor.darkGrey,
                        fontWeight: FontWeight.w600,
                        fontSize: 18.sp,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 87.w,
                        child: Text(
                          profile['username'] ?? '',
                          style: TextStyle(
                            color: AppColor.subTitleGrey,
                            fontSize: 14.sp,
                            fontFamily: 'Montaga',
                            fontWeight: FontWeight.w400,
                            height: 1.31,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      InkWell(
                        onTap:
                            () => Get.to(
                              const FriendListView(),
                              transition: Transition.rightToLeft,
                            ),
                        child: Row(
                          children: [
                            Text(
                              '${profile['friendsCount'] ?? 0}',
                              style: TextStyle(
                                color: AppColor.subTitleGrey,
                                fontSize: 14.sp,
                                fontFamily: 'Montaga',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              'Friends',
                              style: TextStyle(
                                color: AppColor.subTitleGrey,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Montaga',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () => Get.to(Settings(), transition: Transition.rightToLeft),
          child: Image.asset(ImageAssets.settings),
        ),
      ],
    );
  }
}

class _OtherHeader extends GetView<ProfileController> {
  const _OtherHeader({required this.profile});
  final Map<String, dynamic> profile;
  @override
  Widget build(BuildContext context) {
    controller.userName=profile['userName'];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {
            if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
            Get.find<ProfileController>().otherUserPostsCount.value = 0;
            Get.back();
          },
          child: Icon(Icons.arrow_back_ios_new, color: AppColor.blackColor),
        ),
        SizedBox(width: 20.w),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 25.r,
              backgroundColor: AppColor.backgroundColor,
              child: ClipOval(
                child:
                    (profile['profilePhoto'] ?? '').toString().isNotEmpty
                        ? CachedNetworkImage(
                          imageUrl: profile['profilePhoto'],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          placeholder:
                              (context, url) =>
                                  Container(color: AppColor.backgroundColor),
                          errorWidget:
                              (context, url, error) => Image.asset(
                                ImageAssets.image,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                        )
                        : Image.asset(
                          ImageAssets.image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
              ),
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 155.w,
                  height: 20.h,
                  child: Text(
                    profile['name'] ?? '',
                    style: TextStyle(
                      color: AppColor.darkGrey,
                      fontWeight: FontWeight.w600,
                      fontSize: 18.sp,
                    ),
                  ),
                ),
                SizedBox(
                  width: 87.w,
                  child: Text(
                    profile['username'] ?? '',
                    style: TextStyle(
                      color: AppColor.subTitleGrey,
                      fontSize: 14.sp,
                      fontFamily: 'Montaga',
                      fontWeight: FontWeight.w400,
                      height: 1.31,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _BackgroundSection extends GetView<ProfileController> {
  final ChatController chat = Get.find<ChatController>();
   _BackgroundSection({required this.viewType, required this.profile});
  final String viewType;
  final Map<String, dynamic> profile;
  @override
  Widget build(BuildContext context) {
    final int otherUserId = int.parse(profile['id'].toString());
    final int currentUserId = controller.userProfile.value?.id ?? 0;
    return Container(
      color: AppColor.backgroundColor,
      child: Column(
        children: [
          if (viewType == 'myProfile') SizedBox(height: 20.h),
          if (viewType == 'othersProfile')
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: InkWell(
                    onTap: () {
                      if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
                      Get.back();
                    },
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: AppColor.blackColor,
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          if (viewType == 'othersProfile') SizedBox(height: 20.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50.r,
                        backgroundColor: Colors.grey.shade100,
                        child: ClipOval(
                          child:
                              (profile['profilePhoto'] ?? '')
                                      .toString()
                                      .isNotEmpty
                                  ? CachedNetworkImage(
                                    imageUrl: profile['profilePhoto'],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    placeholder:
                                        (context, url) => Container(
                                          color: Colors.grey.shade100,
                                        ),
                                    errorWidget:
                                        (context, url, error) => Image.asset(
                                          ImageAssets.image,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                  )
                                  : Image.asset(
                                    ImageAssets.image,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile['name'] ?? '',
                            style: TextStyle(
                              color: AppColor.darkGrey,
                              fontWeight: FontWeight.w600,
                              fontSize: 20.sp,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Row(
                            children: [
                              SizedBox(
                                width: 87.w,
                                child: Text(
                                  profile['username'] ?? '',
                                  style: TextStyle(
                                    color: AppColor.subTitleGrey,
                                    fontSize: 16.sp,
                                    fontFamily: 'Montaga',
                                    fontWeight: FontWeight.w400,
                                    height: 1.31,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              InkWell(
                                onTap:
                                    () => Get.to(
                                      const FriendListView(),
                                      transition: Transition.rightToLeft,
                                    ),
                                child: Row(
                                  children: [
                                    Text(
                                      '${profile['friendsCount'] ?? 0}',
                                      style: TextStyle(
                                        color: AppColor.subTitleGrey,
                                        fontSize: 14.sp,
                                        fontFamily: 'Montaga',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Text(
                                      'Friend',
                                      style: TextStyle(
                                        color: AppColor.subTitleGrey,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Montaga',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (viewType == 'myProfile')
                  InkWell(
                    onTap:
                        () => Get.to(
                          Settings(),
                          transition: Transition.rightToLeft,
                        ),
                    child: Image.asset(ImageAssets.settings),
                  ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            profile['about'] ?? 'About not updated yet.',
            style: TextStyle(
              color: AppColor.greyTone,
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 20.h),
          if (viewType == 'othersProfile')
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 45.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: CustomButton(
                      onPress: () async {
                        // print("otherUserId______________________ $otherUserId\n currentUserId______________________________ $currentUserId");
                        final chat = Get.put(ChatController());
                        await chat.openWithOtherUser(
                          otherUserId: otherUserId,
                          currentUserId: currentUserId, // or wherever you store it
                        );
                        if (chat.roomId.value != null) {
                          // Get.to(() => ChatScreen(roomId: chat.roomId.value!));
                        }
                      },
                      title: 'Message',
                      height: 42,
                      radius: 120,
                      borderColor: AppColor.greyTone,
                      buttonColor: AppColor.backgroundColor,
                      textColor: AppColor.greyTone,
                    ),
                  ),
                  SizedBox(width: 20.w),
                  Expanded(
                    child: CustomButton(
                      onPress: () async {
                        profile['isFriend'] ?? false
                            ? null
                            : controller.sendFriendRequest(profile['id']);
                      },
                      title:
                          profile['isFriend'] ?? false
                              ? 'Friend'
                              : 'Add Friend',
                      height: 42,
                      radius: 120,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color:
                    isSelected ? AppColor.buttonColor : AppColor.textGreyColor3,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10.h),
            Container(
              height: 2.h,
              width: double.infinity,
              color: isSelected ? AppColor.buttonColor : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
