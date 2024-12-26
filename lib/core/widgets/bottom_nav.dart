import 'package:flutter/material.dart';

class BottomNav extends StatefulWidget {
  final PageController controller;

  const BottomNav({Key? key, required this.controller}) : super(key: key);

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onPageChanged);
    super.dispose();
  }

  void _onPageChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.4),
      height: 50,
      child: Row(
        children: [
          _buildNavItem(
            icon: Icons.home,
            pageIndex: 0,
          ),
          Container(color: Colors.white24,width: 1,height: double.infinity,),
          _buildNavItem(
            icon: Icons.bookmark,
            pageIndex: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required int pageIndex}) {
    return Expanded(
      child: GestureDetector(
        onTap: () => widget.controller.animateToPage(
          pageIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        ),
        child: Container(
          color: Colors.transparent,
          width: double.infinity,
          height: double.infinity,
          child: Icon(
            icon,
            size: 30,
            color: (widget.controller.hasClients && widget.controller.page?.round() == pageIndex)
                ? Colors.white
                : Colors.black,
          ),
        ),
      ),
    );
  }
}
