import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../../../widgets/delete_confirmation_widget.dart';
import '../../home/views/navbar.dart';
import '../controller/explore_controller.dart';
import '../models/event.dart';
import 'add_event_view.dart';// Replace with actual path

class EventImageSlideshow extends GetView<ExploreController> {
  final Event event;

  const EventImageSlideshow({super.key, required this.event});


  void _showPopupMenu(BuildContext context, Offset position) {
    final String index = Get.arguments?['index'] as String? ?? '-1';
    debugPrint('index________________________ $index');
    final RenderBox overlay =
    Overlay.of(context).context.findRenderObject()! as RenderBox;
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx.w,
        position.dy.h + 20.h,
        overlay.size.width.w - position.dx.w,
        overlay.size.height.h - position.dy.h,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
      color: AppColor.backgroundColor,
      constraints: BoxConstraints(maxWidth: 144.w, minWidth: 144.w),
      items: [
        PopupMenuItem(
          height: 60.h,
          padding: EdgeInsets.zero,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 144.w, minWidth: 144.w),
            child: ClipRect(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    child: Text(
                      'Edit Event',
                      style: TextStyle(
                        color: AppColor.textGreyColor,
                        fontSize: 14.w,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Get.to(
                        AddEventView(),
                        transition: Transition.noTransition,
                        arguments: {'origin': 'EventView', 'index': index.toString()},
                      );
                    },
                  ),
                  SizedBox(height: 15.h),
                  InkWell(
                    child: Text(
                      'Delete Person',
                      style: TextStyle(
                        color: AppColor.textGreyColor,
                        fontSize: 14.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      showDeleteConfirmationPopup(
                        context: context,
                        title: 'Are You Sure?',
                        subtitle:
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse elementum ',
                        onDelete: () {
                          // Your delete logic here
                        },
                        arguments: 'EventView',
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    final String origin = Get.arguments?['origin'] as String? ?? 'ExploreView';

    // Use a PageController to manage sliding
    final pageController = PageController();
    // Track current page index reactively
    final currentPage = 0.obs;

    return Stack(
      children: [
        // Image slideshow using PageView
        PageView.builder(
          controller: pageController,
          itemCount: event.images.isEmpty ? 1 : event.images.length,
          onPageChanged: (index) {
            currentPage.value = index; // Update current page index
          },
          itemBuilder: (context, index) {
            if (event.images.isEmpty) {
              // Fallback image if no images are available
              return Image.asset(
                ImageAssets.flower, // Fallback image
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              );
            }
            return Image.network(
              event.images[index].image,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  ImageAssets.flower, // Fallback on error
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                );
              },
            );
          },
        ),
        Positioned(
          top: 75.h,
          left: 20.w,
          child: InkWell(
            onTap: () {
              Get.to(Navigation(), transition: Transition.leftToRight);
            },
            child: Container(
              height: 35.h,
              width: 35.w,
              decoration: ShapeDecoration(
                color: AppColor.backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.r),
                  side: BorderSide(color: AppColor.backgroundColor),
                ),
              ),
              child: Image.asset(ImageAssets.backArrow),
            ),
          ),
        ),
        if (origin == 'ExporleView')
          Positioned(
            top: 75.h,
            right: 20.w,
            child: Container(
              height: 35.h,
              width: 35.w,
              decoration: ShapeDecoration(
                color: AppColor.backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.r),
                  side: BorderSide(color: AppColor.backgroundColor),
                ),
              ),
              padding: EdgeInsets.all(6.sp),
              child: Image.asset(ImageAssets.share1),
            ),
          ),
        if (origin == 'EventView')
          Positioned(
            top: 75.h,
            right: 60.w,
            child: Container(
              height: 35.h,
              width: 35.w,
              decoration: ShapeDecoration(
                color: AppColor.backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.r),
                  side: BorderSide(color: AppColor.backgroundColor),
                ),
              ),
              padding: EdgeInsets.all(6.sp),
              child: Image.asset(ImageAssets.share1),
            ),
          ),
        if (origin == 'EventView')
          Positioned(
            top: 75.h,
            right: 20.w,
            child: InkWell(
              onTapDown: (details) {
                _showPopupMenu(context, details.globalPosition);
              },
              child: Container(
                height: 35.h,
                width: 35.w,
                decoration: ShapeDecoration(
                  color: AppColor.backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.r),
                    side: BorderSide(color: AppColor.backgroundColor),
                  ),
                ),
                padding: EdgeInsets.all(6.sp),
                child: Image.asset(ImageAssets.menu),
              ),
            ),
          ),
        // Image counter (e.g., "1/10")
        Positioned(
          top: 260.h,
          left: 20.w,
          child: Obx(() => Text(
            event.images.isEmpty
                ? '1/1'
                : '${currentPage.value + 1}/${event.images.length}',
            style: TextStyle(
              color: AppColor.whiteTextColor,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              fontFamily: 'Montserrat',
            ),
          )),
        ),
      ],
    );
  }
}