
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../res/colors/app_color.dart';

class TermsOfUse extends StatelessWidget {
  const TermsOfUse({super.key});

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
          'Terms of use',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding:  EdgeInsets.symmetric(horizontal:20.w),
        child: SingleChildScrollView(
            child: Column(
            children: [
            Text('Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse elementum dictum augue et iaculis. Ut id ullamcorper sapien. In neque neque, lobortis rhoncus ligula id, vestibulum laoreet eros. Cras quis vestibulum dui. Etiam feugiat ligula quis vehicula tincidunt. Ut ut consectetur ex. Fusce ut aliquet leo. Nunc massa lectus, semper fermentum dui eu, dapibus suscipit metus. Sed tempus consequat ante, sit amet rhoncus turpis tincidunt varius.',
            style: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 18,
            color: AppColor.greyTone,
            ),



            ),
            SizedBox(height: 10.h,),
            Text('Praesent egestas risus eu aliquam euismod. Cras nibh erat, iaculis sed vestibulum quis, hendrerit non dui. Etiam bibendum, erat ac ullamcorper rutrum, leo lorem ullamcorper purus, at ornare turpis mauris a massa. Sed a vulputate quam. Suspendisse cursus sit amet nulla a sagittis. Aenean pharetra tempus quam, facilisis venenatis elit pulvinar eu. Vivamus tempus arcu elit, eu elementum quam vestibulum vel. Vivamus a lobortis felis. Nam fermentum tortor quis leo maximus venenatis. Donec ut leo in diam hendrerit fringilla. Fusce non metus ultricies nunc porttitor finibus quis id lorem. Cras id nisl sit amet libero consequat aliquam. Suspendisse posuere, turpis ut hendrerit aliquet, dolor justo blandit nunc, in ornare urna arcu gravida elit. Nullam laoreet nisl risus, nec fermentum quam vestibulum eu. Fusce vestibulum porttitor malesuada. Nulla et urna tincidunt, dictum felis eget, euismod mi.',
            style: TextStyle(
            color: AppColor.greyTone,
            fontWeight: FontWeight.w300,
            fontSize: 18,
            ),



            ),
              SizedBox(height: 20.h,),
            ],
            ),
            ),
      )
    );
  }
}
