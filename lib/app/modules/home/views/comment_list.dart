// Replace your dummy ListView.builder(...) with this widget
// Requires: PostController with fetchCommentsOnPost(...), comments, isLoading, isMoreLoading, hasMore, currentCommentsPostId

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../explore/controller/post_controller.dart';
import '../widget/bottom_sheet.dart';

class CommentsList extends GetView<PostController> {
  final String postId; // <-- pass the current post id

  const CommentsList({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    // Kick off fetch for this post (only when needed)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.currentCommentsPostId.value != postId) {
        controller.openCommentsForPost(postId); // resets & loads first page
      } else if (controller.comments.isEmpty &&
          !controller.isLoading.value &&
          !controller.isMoreLoading.value) {
        controller.fetchCommentsOnPost(postId);
      }
    });

    return Obx(() {
      // Loading skeleton (initial)
      if (controller.isLoading.value) {
        return _shimmerList();
      }

      // Empty state with retry
      if (controller.comments.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'No comments found',
                style: TextStyle(
                  color: AppColor.greyTone,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 10.h),
              ElevatedButton(
                onPressed: () => controller.fetchCommentsOnPost(postId),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      // Data list (+1 loader row if hasMore)
      final items = controller.comments;
      final showLoaderRow = controller.hasMore.value;

      return ListView.builder(
        itemCount: items.length + (showLoaderRow ? 1 : 0),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          // Trigger load-more when reaching the loader row
          if (showLoaderRow && index == items.length) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              controller.fetchCommentsOnPost(postId, isLoadMore: true);
            });
            return _shimmerRow();
          }

          final c = items[index];
          final String avatar = (c['user_profile_picture'] ?? '') as String;
          final String name = (c['user_name'] ?? 'Unknown') as String;
          final String text = (c['text'] ?? '') as String;
          final String createdAt = (c['created_at'] ?? '') as String;
          return GestureDetector(
            onLongPress: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder:
                    (_) => ReportBottomSheet(
                      showTwoOptions: true,
                      firstOption: ReportOption(
                        icon: Icons.edit,
                        label: 'Edit',
                        onTap: ()async {
                              Navigator.pop(context);

                                final current = controller.comments[index]['text'] ?? '';
                                final tc = TextEditingController(text: current);

                                final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Edit comment'),
                                    content: TextField(
                                      controller: tc,
                                      maxLines: 5,
                                      decoration: const InputDecoration(hintText: 'Update your comment'),
                                    ),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
                                    ],
                                  ),
                                ) ?? false;
                                if (ok) {
                                  controller.editCommentByIndex(index, tc.text);
                                }
                        },
                      ),
                      secondOption: ReportOption(
                        icon: Icons.delete,
                        label: 'Delete',
                        onTap: () async{
                          Navigator.pop(context);
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Delete comment?'),
                              content: const Text('This action cannot be undone.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                              ],
                            ),
                          ) ?? false;

                          if (confirmed) {
                            controller.deleteCommentByIndex(index); // or deleteCommentById(items[index])
                          }
                        } ,
                      ),
                    ),
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20.r,
                    backgroundColor: AppColor.greyColor,
                    child: ClipOval(
                      child:
                          avatar.isNotEmpty
                              ? CachedNetworkImage(
                                imageUrl: avatar,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                placeholder:
                                    (_, _) =>
                                        Container(color: Colors.grey.shade100),
                                errorWidget:
                                    (_, _, _) => Image.asset(
                                      ImageAssets.person,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                              )
                              : Image.asset(
                                ImageAssets.person,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                name,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColor.darkGrey,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              _shortTime(createdAt),
                              style: TextStyle(
                                color: AppColor.greyTone,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          text,
                          style: TextStyle(
                            color: AppColor.greyTone,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Obx(() {
                    final c = items[index];
                    final int cId = (c['id'] as num).toInt();
                    final bool busy = controller.likingComment[cId] == true;
                    final bool liked = (c['is_liked'] ?? false) == true;
                    final int count =
                        (c['react_count'] ?? 0) is int
                            ? c['react_count']
                            : int.tryParse('${c['react_count']}') ?? 0;
                    return Column(
                      children: [
                        GestureDetector(
                          onTap:
                              busy
                                  ? null
                                  : () => controller.toggleCommentLikeByIndex(
                                    index,
                                  ),
                          child:
                              busy
                                  ? SizedBox(
                                    width: 24.w,
                                    height: 24.h,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : SvgPicture.asset(
                                    ImageAssets.love,
                                    width: 24.w,
                                    height: 24.h,
                                    colorFilter: ColorFilter.mode(
                                      liked
                                          ? AppColor.redColor
                                          : AppColor.greyTone,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                        ),
                        Text(
                          '$count',
                          style: TextStyle(color: AppColor.greyTone),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  // --- UI helpers ---
  Widget _shimmerList() => ListView.builder(
    itemCount: 6,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    padding: EdgeInsets.zero,
    itemBuilder: (_, _) => _shimmerRow(),
  );

  Widget _shimmerRow() => Padding(
    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40.r,
          height: 40.r,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 16.h, color: Colors.grey.shade100),
              SizedBox(height: 6.h),
              Container(
                width: 120.w,
                height: 14.h,
                color: Colors.grey.shade100,
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 25.h),
          child: Column(
            children: [
              Container(width: 20.w, height: 20.h, color: Colors.grey.shade100),
              SizedBox(height: 5.h),
              Container(width: 20.w, height: 14.h, color: Colors.grey.shade100),
            ],
          ),
        ),
      ],
    ),
  );

  String _shortTime(String iso) {
    // Keep it simple; you can replace with intl if you want.
    if (iso.isEmpty) return 'now';
    // e.g., "2025-08-26T04:23:59.028824Z" -> "2025-08-26"
    return iso.split('T').first;
  }
}
