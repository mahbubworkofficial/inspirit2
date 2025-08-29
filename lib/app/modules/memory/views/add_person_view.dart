import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/input_text_widget.dart';
import '../../auth/controllers/authcameracontroller.dart';
import '../controllers/memory_controller.dart';

class AddPersonView extends GetView<MemoryController> {
  final AuthBottomSheetController as = Get.put(AuthBottomSheetController());
  AddPersonView({super.key});

  @override
  Widget build(BuildContext context) {
    final String from = Get.arguments?['from'] as String? ?? 'HomeView';
    final String index = Get.arguments?['index'] as String? ?? '0';
    debugPrint('index________________________ $index');
    debugPrint('from________________________ $from');
    final person = controller.personsList[int.parse(index)];
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios, size: 20.sp),
        ),
        title: Text(
          from == 'MemoryDetailsView' ? 'Edit Info ' : 'Add Person',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vestibulum sodales pulvinar accumsan raseing rhoncus neque',
                    style: TextStyle(
                      color: AppColor.greyTone,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Montserrat',
                    ),
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(height: 20.h),
                  Center(
                    child: Stack(
                      children: [
                        Obx(() {
                          controller.pickedImage.value = as.pickedImage.value;
                          final pickedImage = controller.pickedImage.value;
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(200.r),
                            child:
                                pickedImage != null
                                    ? Image.file(
                                      pickedImage,
                                      width: 120.w,
                                      height: 120.w,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Image.asset(
                                          ImageAssets.avatar,
                                          width: 120.w,
                                          height: 120.w,
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    )
                                    : from == 'MemoryDetailsView' &&
                                        person.displayPicture != null
                                    ? Container(
                                      width: 120.w,
                                      height: 120.w,
                                      color: AppColor.mutedBlueGrey,
                                      child: Image.network(
                                        person.displayPicture!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                    : Container(
                                      width: 120.w,
                                      height: 120.w,
                                      color: AppColor.mutedBlueGrey,
                                      child: Image.asset(
                                        ImageAssets.avatar,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                          );
                        }),
                        Positioned(
                          bottom: 0.h,
                          right: 0.w,
                          child: Container(
                            width: 30.w,
                            height: 30.w,
                            decoration: BoxDecoration(
                              color: AppColor.buttonColor,
                              borderRadius: BorderRadius.circular(100.r),
                            ),
                            child: Center(
                              child: IconButton(
                                icon: Icon(
                                  Icons.camera_alt,
                                  size: 18.sp,
                                  color: AppColor.whiteTextColor,
                                ),
                                onPressed: as.getBottomSheet,
                                padding: EdgeInsets.all(4.w),
                                constraints: BoxConstraints(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 35.h),
                  InputTextWidget(
                    onChanged: (value) {},
                    backgroundColor: AppColor.textAreaColor,
                    borderColor: Colors.transparent,
                    hintText: 'Person full name',
                    hintTextColor: AppColor.greyTone,
                    textEditingController:
                        // from == 'MemoryDetailsView'
                        //     ? TextEditingController(text: person.fullName)
                        //     :
                        controller.nameController,
                    textColor: AppColor.greyTone,
                  ),
                  SizedBox(height: 10.h),
                  InputTextWidget(
                    onChanged: (value) {},
                    backgroundColor: AppColor.textAreaColor,
                    borderColor: Colors.transparent,
                    hintText: 'Add date of birth',
                    textEditingController: controller.dobController,
                    hintTextColor: AppColor.greyTone,
                    backimageadd: true,
                    backimage: ImageAssets.calender3,
                    textColor: AppColor.greyTone,
                  ),
                  SizedBox(height: 10.h),
                  InputTextWidget(
                    onChanged: (value) {},
                    backgroundColor: AppColor.textAreaColor,
                    borderColor: Colors.transparent,
                    hintText: 'Date of passed on',
                    hintTextColor: AppColor.greyTone,
                    backimageadd: true,
                    textEditingController: controller.dodController,
                    backimage: ImageAssets.calender3,
                    textColor: AppColor.greyTone,
                  ),
                  SizedBox(height: 10.h),
                  InputTextWidget(
                    onChanged: (value) {},
                    backgroundColor: AppColor.textAreaColor,
                    borderColor: Colors.transparent,
                    hintText: 'Description',
                    hintTextColor: AppColor.greyTone,
                    textEditingController:
                         controller.detailsController,
                    passwordIcon: ImageAssets.time,
                    height: 148,
                    maxLines: 10,
                    vertical: 10,
                  ),
                  SizedBox(height: 10.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Who can see',
                        style: TextStyle(
                          color: AppColor.textGreyColor2,
                          fontSize: 16.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Obx(
                        () => Column(
                          children: [
                            RadioListTile<String>(
                              title: Text(
                                'Only me',
                                style: TextStyle(
                                  color: AppColor.textGreyColor,
                                  fontSize: 16.sp,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              value: 'private',
                              groupValue: controller.selectedRole.value,
                              onChanged: (value) {
                                controller.setSelectedRole(value!);
                              },
                              activeColor: AppColor.textBlackColor,
                            ),
                            RadioListTile<String>(
                              title: Text(
                                'Me and my friends',
                                style: TextStyle(
                                  color: AppColor.textGreyColor,
                                  fontSize: 16.sp,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              value: 'friends',
                              groupValue: controller.selectedRole.value,
                              onChanged: (value) {
                                controller.setSelectedRole(value!);
                              },
                              activeColor: AppColor.textBlackColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Obx(
                    () => CustomButton(
                      buttonColor: AppColor.buttonColor,
                      height: 48,
                      width: double.infinity,
                      radius: 30.r,
                      onPress:
                          controller.isLoading.value
                              ? null // Disable button when loading
                              : () async {
                                controller.personId.value =
                                    person.id.toString();
                                from == 'MemoryDetailsView'
                                    ? await controller.updatePerson()
                                    : await controller.postPerson();
                              },
                      loading: controller.isLoading.value,
                      title: 'Save',
                    ),
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
