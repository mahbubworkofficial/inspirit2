import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../res/assets/image_assets.dart';
import '../../home/widget/profile_card_widget.dart';
import '../controller/explore_controller.dart';
import 'event_view.dart';

class EventListView extends GetView<ExploreController> {
  // Make it nullable to handle cases where no argument is passed

  const EventListView({super.key, this.arguments});
  final String? arguments;
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.eventsList.isEmpty && !controller.isLoading.value) {
        controller.fetchEvents();
      }
    });
    return Obx(() {
      if (controller.isLoading.value && controller.eventsList.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      return ListView.builder(
        itemCount:
            controller.eventsList.length +
            (controller.isMoreLoading.value ? 1 : 0),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          if (controller.eventsList.isEmpty) {
            return Center(child: Text('No events found'));
          }
          final event = controller.eventsList[index];

          return InkWell(
            onTap: () {
              final String? origin =
                  arguments ?? Get.arguments?['origin'] as String?;
              Get.to(
                () => EventView(),
                transition: Transition.noTransition,
                arguments: {
                  'origin':
                      origin == 'ExporleView' ? 'ExporleView' : 'EventView',
                  'index': index.toString(),
                },
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: ProfileCardWidget(
                imagePath:
                    event.images.isNotEmpty
                        ? event.images.first.image
                        : ImageAssets
                            .flower, // Use first event image or fallback
                title: event.title,
                showSubtitle1: true,
                subtitle1: event.eventType,
                subtitle2: '${event.date} ${event.time}',
                subtitle2IconPath: ImageAssets.calender2,
              ),
            ),
          );
        },
      );
    });
  }
}
