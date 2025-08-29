import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../res/colors/app_color.dart';
import '../../explore/controller/explore_controller.dart';
import '../../explore/views/event_list_view.dart';
import '../controllers/memory_controller.dart';
import 'add_person_view.dart';
import '../../explore/views/create_event_view.dart';
import 'memorial_view.dart';

class Memory extends GetView<MemoryController> {
  final ExploreController exploreController= Get.find<ExploreController>();
   Memory({super.key, this.arguments});
  final String? arguments;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,

      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: ()async{exploreController.fetchEvents;controller.fetchPersons;},
            child: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      floating: true,
                      snap: true,
                      backgroundColor: AppColor.backgroundColor,
                      title: Text('My Memory'),
                      centerTitle: true,
                      automaticallyImplyLeading: false,
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Obx(
                                () => GestureDetector(
                                  onTap:
                                      () => controller.setSelectedTab('Memorial'),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Center(
                                        child: Text(
                                          'Memorial',
                                          style: TextStyle(
                                            color:
                                                controller.selectedTab.value ==
                                                        'Memorial'
                                                    ? AppColor.buttonColor
                                                    : AppColor.textGreyColor3,
                                            fontSize: 16,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w400,
                                            height: 1.5,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Container(
                                        height: 2,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          color:
                                              controller.selectedTab.value ==
                                                      'Memorial'
                                                  ? AppColor.buttonColor
                                                  : AppColor.textAreaColor,
                                          borderRadius: BorderRadius.circular(1),
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
                                  onTap: () => controller.setSelectedTab('Event'),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Center(
                                        child: Text(
                                          'Event',
                                          style: TextStyle(
                                            color:
                                                controller.selectedTab.value ==
                                                        'Event'
                                                    ? AppColor.buttonColor
                                                    : AppColor.textGreyColor3,
                                            fontSize: 16,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w400,
                                            height: 1.5,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Container(
                                        height: 2,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          color:
                                              controller.selectedTab.value ==
                                                      'Event'
                                                  ? AppColor.buttonColor
                                                  : AppColor.textAreaColor,
                                          borderRadius: BorderRadius.circular(1),
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
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Obx(
                            () => IndexedStack(
                              index: [
                                'Memorial',
                                'Event',
                              ].indexOf(controller.selectedTab.value),
                              children: [
                                MemorialView(),
                                EventListView(arguments: arguments),
                              ],
                            ),
                          ),
                        );
                      }, childCount: 1),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => {
              if (controller.selectedTab.value == 'Memorial')
                {Get.to(AddPersonView(), transition: Transition.noTransition)},
              if (controller.selectedTab.value == 'Event')
                {
                  Get.to(
                    CreateEventView(),
                    transition: Transition.noTransition,
                  ),
                },
            },
        backgroundColor: AppColor.beigeBrown,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Icon(Icons.add, size: 40, color: AppColor.whiteTextColor),
      ),
    );
  }
}
