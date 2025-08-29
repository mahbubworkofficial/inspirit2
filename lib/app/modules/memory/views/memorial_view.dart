import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../controllers/memory_controller.dart';
import 'memory_details_view.dart';

class MemorialView extends GetView<MemoryController> {
  const MemorialView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.personsList.isEmpty && !controller.isLoading.value) {
        controller.fetchPersons();
      }
    });
    return Obx(() {
      if (controller.isLoading.value && controller.personsList.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      return ListView.builder(
        itemCount:
        controller.personsList.length +
            (controller.isMoreLoading.value ? 1 : 0),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          if (controller.personsList.isEmpty) {
            return Center(child: Text('No events found'));
          }
          final person = controller.personsList[index];

          return InkWell(
            onTap: () {
            
              Get.to(
                    () => MemoryDetailsView(),
                transition: Transition.rightToLeftWithFade,
                arguments: {
                  'index': index.toString(),
                },
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: Container(
                height: 110.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColor.softBeige),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10.w),
                      child: Container(
                        height: 80.h,
                        width: 80.w,
                        decoration: BoxDecoration(
                          color: AppColor.blackColor,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image.network(
                            person.displayPicture != null
                                ? person.displayPicture!:ImageAssets.person,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          person.fullName,
                          style: TextStyle(
                            color: AppColor.greyTone,
                            fontSize: 18.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          person.dateOfBirth?? 'Not Available',
                          style: TextStyle(
                            color: AppColor.greyTone,
                            fontSize: 16.sp,
                            fontFamily: 'Montaga',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          person.dateOfDeath?? 'Not Available',
                          style: TextStyle(
                            color: AppColor.greyTone,
                            fontSize: 16.sp,
                            fontFamily: 'Montaga',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );}
    );
  }
}
