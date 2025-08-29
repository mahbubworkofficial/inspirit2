import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../controllers/memory_controller.dart';
import 'add_memory_view.dart';

class MemoryHistoryListView extends GetView<MemoryController> {
   const MemoryHistoryListView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.fetchMemories();
    });
    return Obx(() {
      if (controller.isLoading.value && controller.memoriesList.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      return ListView.builder(
        itemCount:
        controller.memoriesList.length +
            (controller.isMoreLoading.value ? 1 : 0),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          if (controller.memoriesList.isEmpty) {
            return Center(child: Text('No events found'));
          }
          final memory = controller.memoriesList[index];

          return Padding(
            padding:  EdgeInsets.only(left: 15.w, right: 15.w, top: 10.h),
            child: Stack(
              children: [
                Padding(
                  padding:  EdgeInsets.only(left: 6.5.w, top: 20.h),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          width: 2.w,
                          color: AppColor.buttonColor,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: 17.w, top: 10.h, bottom: 10.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            memory.title,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                              fontSize: 20.sp,
                              color: AppColor.textSendColor,
                            ),
                          ),
                          SizedBox(height: 5.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children:  [
                              Text(
                                "Added by ${memory.person.fullName}",
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14.sp,
                                  color: AppColor.textGreyColor2,
                                ),
                              ),
                              Text(
                                memory.dateOfMemory,
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w300,
                                  fontSize: 16.sp,
                                  color: AppColor.textGreyColor2,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          SizedBox(
                            height: 120.h,
                            child: ListView.separated(
                              itemCount:  memory.images
                              .toList().length,
                              scrollDirection: Axis.horizontal,
                              separatorBuilder: (context, index) => SizedBox(width: 20.w),
                              itemBuilder: (context, index) {
                                final image = memory.images
                                    .toList()[index];
                                return Container(
                                  decoration: BoxDecoration(
                                    color: AppColor.blackColor,
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.r),
                                    child: Image.network(
                                      image.image,
                                      height: 120.h,
                                      width: 120.w,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Image.asset(
                                          ImageAssets.image,
                                          height: 120.h,
                                          width: 120.w,
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                           SizedBox(height: 10.h),
                           Text(
                            memory.description,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w400,
                              fontSize: 15.sp,
                              color: AppColor.textGreyColor2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Image.asset(ImageAssets.border),
                     SizedBox(width: 10.w),
                     Text(
                      memory.dateOfMemory,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                        fontSize: 18.sp,
                        color: AppColor.textGreyColor,
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                        onTap: (){Get.to(
                          AddMemoryView(),
                          transition: Transition.noTransition,
                          arguments: {'memoryId': memory.id, 'memory': "updateMemory"},
                        );},
                        child: Image.asset(ImageAssets.edit1)),
                  ],
                ),
              ],
            ),
          );
        },
      );}
    );
  }
}
