import 'package:flutter/material.dart';

import 'package:get/get.dart';

class ThemeView extends GetView {
  const ThemeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ThemeView'), centerTitle: true),
      body: const Center(
        child: Text('ThemeView is working', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
