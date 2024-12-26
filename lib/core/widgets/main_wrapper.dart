import 'package:flutter/material.dart';
import 'package:weather/core/widgets/bottom_nav.dart';

// import 'package:weather/features/feature_weather/presentation/screens/home_page.dart';
import 'package:weather/features/feature_weather/presentation/screens/home_screen.dart';
import 'package:weather/features/feature_bookmark/presentation/screens/bookmark_screen.dart';
import 'package:weather/core/widgets/app_background.dart';

class MainWrapper extends StatelessWidget {
  MainWrapper({super.key});

  final PageController pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    final List<Widget> pageViewWidget = [
      const HomeScreen(),
      BookMarkScreen(
        pageController: pageController,
      )
    ];
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false, // جلوگیری از تغییر اندازه صفحه هنگام باز شدن کیبورد
      bottomNavigationBar: BottomNav(
        controller: pageController,
      ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(image: AppBackground.getBackGroundImage(), fit: BoxFit.cover)),
        height: height,
        child: PageView(controller: pageController, children: pageViewWidget),
      ),
    );
  }
}
