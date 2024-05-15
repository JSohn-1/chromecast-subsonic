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
    return Container(
      color: const Color.fromARGB(255, 18, 18, 18),
      child: Stack(children: [
        if (screen == Screen.search) const SearchScreen(),
        if (screen == Screen.menu) const MenuScreen(),
        if (screen == Screen.playlists) const PlaylistsScreen(),
        if (screen == Screen.settings) const SettingsScreen(),
        Positioned(bottom: 0, child: NavigatorBar(changeMenu: changeScreen)),
      ],
      ),
    );
  }
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
    return Column(
      children: [
        Positioned(
          top: 0, 
          child: Container(
            alignment: Alignment.centerLeft,
            color: const Color.fromARGB(20, 255, 255, 255), 
            width: MediaQuery.of(context).size.width, 
            height: 70, 
            child: const Row(
              children: [
                Padding(padding: EdgeInsets.all(10)),
                Text('Menu', 
                  style: TextStyle(
                    fontSize: 24, 
                    color: Colors.white,
                    decoration: TextDecoration.none,
                  )
                ),
              ],
            ),
          )
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height - 140,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(width: MediaQuery.of(context).size.width - 20, height: 200, color: Colors.red),
                Container(width: MediaQuery.of(context).size.width - 20, height: 200, color: Colors.blue),
                Container(width: MediaQuery.of(context).size.width - 20, height: 200, color: Colors.green),
                Container(width: MediaQuery.of(context).size.width - 20, height: 200, color: Colors.purple),
              ],
            ),
          ),
        ),
        
      ],
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
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 70,
      color: const Color.fromARGB(20, 255, 255, 255),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white,),
            onPressed: () => changeMenu(0),
          ),
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white,),
            onPressed: () => changeMenu(1),
          ),
          IconButton(
            icon: const Icon(Icons.queue_music, color: Colors.white,),
            onPressed: () => changeMenu(2),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white,),
            onPressed: () => changeMenu(3),
          ),
        ],
      ),
    );
  }
}