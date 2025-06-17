// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';

//Boilerplate code wich is necessary in each flutter application like main in java
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      home: FirstProject(),
    );
  }
}

class FirstProject extends StatelessWidget {
  const FirstProject({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar.new(
        elevation: 20,
        title: Text('Facebook'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {},
          icon: Icon(Icons.menu, size: 33, color: Color.fromARGB(255, 0, 0, 0)),
        ),
        actions: [IconButton(onPressed: (){}, icon: Icon(Icons.message , size:25)),
        IconButton(onPressed: (){}, icon:Icon(Icons.search,size: 25,))],
      ),
      body: Center(child: Text("Hello, Samar❤️" , style: TextStyle(fontSize: 40),)),
    );
  }
}
