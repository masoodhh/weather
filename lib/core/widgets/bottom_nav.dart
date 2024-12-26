import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  BottomNav({super.key, required this.controller});

  PageController controller;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    // TextTheme textTheme = Theme.of(context).textTheme;

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 5,
      color: primaryColor,
      child: SizedBox(
        height: 63,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
                onPressed: () {
                  controller.animateToPage(0,
                      duration: const Duration(microseconds: 300),
                      curve: Curves.easeInOut,);
                },
                icon: const Icon(Icons.home),),
            IconButton(
                onPressed: () {
                  controller.animateToPage(1,
                      duration: const Duration(microseconds: 300),
                      curve: Curves.easeInOut,);
                },
                icon: const Icon(Icons.bookmark),),
          ],
        ),
      ),
    );
  }
}
