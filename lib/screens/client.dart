import 'package:flutter/material.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';

import 'package:client/screens/client_home_tab.dart';
import 'package:client/screens/client_message_tab.dart';

class Client extends StatefulWidget {
  const Client({Key? key}) : super(key: key);

  @override
  State<Client> createState() => _ClientState();
}

class _ClientState extends State<Client> {
  late PageController _pageController;
  int _selectedPage = 0;
  List<Widget> pages = [
    const ClientHome(title: 'Client Dashboard'),
    const ClientMessage()
  ];
  void _onItemTapped(int index){
    setState(() {
      _selectedPage = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        onPageChanged: (index) => setState(() {
          _selectedPage = index;
        }),
        controller: _pageController,
          children: [
            ...pages
          ],
      ),
      bottomNavigationBar: FlashyTabBar(
        selectedIndex: _selectedPage,
        showElevation: false,
        onItemSelected: (index) =>
          _onItemTapped(index),
        items: [
          FlashyTabBarItem(
              icon: const Icon(Icons.home_outlined, size: 23, color: Colors.cyan,),
              title: const Text('Home'),
          ),
          FlashyTabBarItem(
              icon: const Icon(Icons.message_outlined, size: 23, color: Colors.cyan,),
              title: const Text('Message'))
        ],
      ),
    );
  }
}
