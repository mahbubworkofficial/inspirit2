import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../res/colors/app_color.dart';
import '../../../../widgets/custom_button.dart';
import '../controllers/memory_controller.dart';
import 'add_memory_view.dart';
import 'condolences_history_list_view.dart';
import 'create_condolences_view.dart';
import 'memory_details_view.dart';
import 'memory_history_list_view.dart';

class MemoryHistoryView extends GetView<MemoryController> {
  const MemoryHistoryView({super.key});
  @override
  Widget build(BuildContext context) {
    final String index = Get.arguments?['index'] as String? ?? '0';
    debugPrint('index________________________ $index');
    final person = controller.personsList[int.parse(index)];
    controller.personId.value = person.id.toString();
    return Scaffold(
      resizeToAvoidBottomInset: true,

      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    backgroundColor: AppColor.backgroundColor,
                    automaticallyImplyLeading: false,
                    flexibleSpace: SafeArea(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                Get.to(
                                  MemoryDetailsView(),
                                  transition: Transition.leftToRight,
                                  arguments: {'index': index.toString()},
                                );
                              },
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                size: 20.sp,
                                color: AppColor.greyTone,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: Row(
                        children: [
                          Expanded(
                            child: Obx(
                              () => GestureDetector(
                                onTap: () {
                                  controller.setHistorySelectedTab('Memorial');
                                },
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Center(
                                      child: Text(
                                        'Memorial',
                                        style: TextStyle(
                                          color:
                                              controller
                                                          .hisrtorySelectedTab
                                                          .value ==
                                                      'Memorial'
                                                  ? AppColor.buttonColor
                                                  : AppColor.textGreyColor3,
                                          fontSize: 16.sp,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w400,
                                          height: 2,
                                          letterSpacing: 0.50,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                    Container(
                                      height: 2.h,
                                      width: 40.w,
                                      decoration: BoxDecoration(
                                        color:
                                            controller
                                                        .hisrtorySelectedTab
                                                        .value ==
                                                    'Memorial'
                                                ? AppColor.buttonColor
                                                : AppColor.textAreaColor,
                                        borderRadius: BorderRadius.circular(
                                          1.r,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Obx(
                              () => GestureDetector(
                                onTap: () {
                                  controller.setHistorySelectedTab(
                                    'Condolences',
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Center(
                                      child: Text(
                                        'Condolences',
                                        style: TextStyle(
                                          color:
                                              controller
                                                          .hisrtorySelectedTab
                                                          .value ==
                                                      'Condolences'
                                                  ? AppColor.buttonColor
                                                  : AppColor.textGreyColor3,
                                          fontSize: 16.sp,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w400,
                                          height: 2,
                                          letterSpacing: 0.50,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                    Container(
                                      height: 2.h,
                                      width: 40.w,
                                      decoration: BoxDecoration(
                                        color:
                                            controller
                                                        .hisrtorySelectedTab
                                                        .value ==
                                                    'Condolences'
                                                ? AppColor.buttonColor
                                                : AppColor.textAreaColor,
                                        borderRadius: BorderRadius.circular(1.r),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return Container(
                        width: double.infinity,
                        decoration: ShapeDecoration(
                          color: AppColor.backgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                        ),
                        child: Obx(
                          () => IndexedStack(
                            index: [
                              'Memorial',
                              'Condolences',
                            ].indexOf(controller.hisrtorySelectedTab.value),
                            children: [
                              MemoryHistoryListView(),
                              CondolencesHistoryListView(),
                            ],
                          ),
                        ),
                      );
                    }, childCount: 1),
                  ),
                ],
              ),
              Padding(
                padding:  EdgeInsets.symmetric(
                  vertical: 20.h,
                  horizontal: 20.w,
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: CustomButton(
                          onPress: () async {
                            Get.to(
                              CreateCondolencesView(),
                              transition: Transition.noTransition,
                              arguments: {'index': index.toString()},
                            );
                          },
                          title: 'Condolences',
                          height: 48,
                          radius: 10.r,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                          buttonColor: AppColor.backgroundColor,
                          textColor: AppColor.buttonColor,
                          borderColor: AppColor.buttonColor,
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: CustomButton(
                          onPress: () async {
                            Get.to(
                              AddMemoryView(),
                              transition: Transition.noTransition,
                              arguments: {'index': index.toString()},
                            );
                          },
                          title: 'Add Memory',
                          height: 48,
                          radius: 10.r,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }
}
