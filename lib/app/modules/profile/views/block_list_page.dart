
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';
import '../../chat/controllers/chat_controller.dart';

class BlockListPage extends StatelessWidget {
  final ChatController controller = Get.find();
  BlockListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios, size: 20),
        ),
        title: Text(
          'Block List',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              Text(
                'Vestibulum sodales pulvinar accumsan raseing rhoncus neque',
                style: TextStyle(
                  color: AppColor.textGreyColor,
                  fontSize: 20,
                  fontFamily: 'Schuyler',
                ),
                textAlign: TextAlign.start,
              ),
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Blocked Users',
                    style: TextStyle(
                      color: AppColor.textBlackColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),

                  ),
                  SizedBox(width: 5.w,),
                  Text(
                    '(12)',
                    style: TextStyle(
                      color: AppColor.textGreyColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                    ),

                  ),

                ],
              ),
              SizedBox(height: 10,),
              ListView.builder(
                padding: EdgeInsets.zero,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      _buildUserTile(controller.names[index]),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildUserTile(String name) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),

      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          radius: 28.r,
          backgroundColor:AppColor.greyColor,
          child: ClipOval(
            child: Image.asset(
              ImageAssets.person2,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            color: AppColor.darkGrey,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        subtitle: Text(
          '_$name',
          style: TextStyle(
            color: AppColor.greyTone,
            fontSize: 15,

          ),
        ),
        trailing:Text(
          'Unblock',
          style: TextStyle(
              color: AppColor.greyTone,
              fontSize: 15,
              fontWeight: FontWeight.w400
          ),
        ),
      ),
    );
  }
}
