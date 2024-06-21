import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override 
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
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
          ),
          Expanded(
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
      ),
    );
  }
}
