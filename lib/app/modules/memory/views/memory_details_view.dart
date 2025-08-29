import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/delete_confirmation_widget.dart';
import '../../home/views/navbar.dart';
import '../controllers/memory_controller.dart';
import 'add_person_view.dart';
import 'memory_history_view.dart';
import 'qr_code_view.dart';

class MemoryDetailsView extends GetView<MemoryController> {
  const MemoryDetailsView({super.key});

  void _showPopupMenu(BuildContext context, Offset position) {
    final String index = Get.arguments?['index'] as String? ?? '0';
    debugPrint('index________________________ $index');
    final person = controller.personsList[int.parse(index)];
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + 30,
        overlay.size.width - position.dx,
        overlay.size.height - position.dy,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
      color: AppColor.backgroundColor,
      constraints: BoxConstraints(maxWidth: 144.w, minWidth: 144.w),
      items: [
        PopupMenuItem(
          height: 60.h,
          padding: EdgeInsets.zero,
          child: ClipRect(
            child: Center(
              // <--- Add this to center the column content
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    child: Text(
                      'QR Code',
                      style: TextStyle(
                        color: AppColor.textGreyColor,
                        fontSize: 14.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Get.to(QrCodeView(), transition: Transition.noTransition);
                    },
                  ),
                  SizedBox(height: 15.h),
                  InkWell(
                    child: Text(
                      'Edit Info',
                      style: TextStyle(
                        color: AppColor.textGreyColor,
                        fontSize: 14.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Get.to(
                        AddPersonView(),
                        transition: Transition.noTransition,
                        arguments: {
                          'from': 'MemoryDetailsView',
                          'index': index.toString(),
                        },
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
                          controller.deletePerson((person.id).toString());
                        },
                        arguments: 'MemoryView',
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
    final String index = Get.arguments?['index'] as String? ?? '0';
    debugPrint('index________________________ $index');
    final person = controller.personsList[int.parse(index)];
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Image.asset(ImageAssets.memoryBackground, fit: BoxFit.fill),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 20.w, top: 20, right: 15.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Get.to(
                            Navigation(),
                            transition: Transition.leftToRight,
                          );
                        },
                        child: Icon(Icons.arrow_back_ios_new, size: 20.sp),
                      ),
                      GestureDetector(
                        onTapDown: (details) {
                          _showPopupMenu(context, details.globalPosition);
                        },
                        child: Image.asset(ImageAssets.menu),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 50.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(250.r),
                      child: person.displayPicture != null
                          ? Image.network(
                        person.displayPicture!,
                        width: 190.w,
                        height: 190.w,
                        fit: BoxFit.cover,
                      )
                          : Container(
                        width: 190.w,
                        height: 190.w,
                        color: AppColor.mutedBlueGrey,
                        child: Image.asset(ImageAssets.person,fit: BoxFit.cover,),
                      ),
                    ),
                        SizedBox(height: 12.h),
                        Text(
                          person.fullName,
                          style: TextStyle(
                            color: AppColor.buttonColor,
                            fontSize: 22.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          '${person.birthYear} - ${person.deathYear} ',
                          style: TextStyle(
                            color: AppColor.subTitleGrey,
                            fontSize: 16.sp,
                            fontFamily: 'Montaga',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          person.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColor.greyTone,
                            fontSize: 17.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Lorem ipsum dolor sit amet',
                            style: TextStyle(
                              color: AppColor.textSendColor,
                              fontSize: 16.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Image.asset(
                                ImageAssets.candle,
                                height: 200.h,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Expanded(
                              child: Image.asset(
                                ImageAssets.flower1,
                                height: 200.h,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        CustomButton(
                          onPress: () async {
                            Get.to(
                              MemoryHistoryView(),
                              transition: Transition.noTransition,
                              arguments: {
                                'index': index.toString(),
                              },
                            );
                          },
                          title: 'View Obituary',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          textColor: AppColor.buttonColor,
                          borderColor: AppColor.buttonColor,
                          buttonColor: Colors.transparent,
                          height: 48,
                          width: double.infinity,
                          radius: 10.r,
                        ),
                        SizedBox(height: 10.h),
                      ],
                    ),
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
