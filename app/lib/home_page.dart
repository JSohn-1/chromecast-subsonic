import 'package:flutter/material.dart';

enum Screen { search, menu, playlists, settings }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Screen screen = Screen.menu;
  void changeScreen(int screen) {
    setState(() => this.screen = Screen.values[screen]);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      if (screen == Screen.search) const SearchScreen(),
      if (screen == Screen.menu) const MenuScreen(),
      if (screen == Screen.playlists) const PlaylistsScreen(),
      if (screen == Screen.settings) const SettingsScreen(),
      Positioned(bottom: 0, child: NavigatorBar(changeMenu: changeScreen)),
    ],
    );
  }
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ],
      ),
    );
  }
}

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.search),
            title: Text('Search'),
          ),
          ListTile(
            leading: Icon(Icons.playlist_play),
            title: Text('Playlists'),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
          ),
        ],
      ),
    );
  }
}

class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          Text('Playlists'),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          Text('Settings'),
        ],
      ),
    );
  }
}

class NavigatorBar extends StatelessWidget {
  const NavigatorBar({super.key, required this.changeMenu});

 final void Function(int) changeMenu;


  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu),
          label: 'Menu',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.playlist_play),
          label: 'Playlists',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
      onTap: changeMenu,
    );
  }
}