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
      appBar: AppBar(
        elevation: 20,
        title: Text('Facebook'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {},
          icon: Icon(Icons.menu, size: 33, color: Color.fromARGB(255, 0, 0, 0)),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.message, size: 25)),
          IconButton(onPressed: () {}, icon: Icon(Icons.search, size: 25)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          //crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container(
                //color: const Color.fromARGB(255, 148, 155, 176),
                margin: EdgeInsets.fromLTRB(20, 50, 20, 50),
                padding: EdgeInsets.all(11),
                height: 270,
                width: 266,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Flutter is an open source framework ",
                  style: TextStyle(
                    fontSize: 25,
                    //backgroundColor:Colors.blue
                    color: const Color.fromARGB(255, 0, 0, 0),
                    decoration: TextDecoration.underline,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                    letterSpacing: 0,
                    wordSpacing: 3,
                  ),
                  //maxLines: 2,
                  overflow: TextOverflow.fade,
                  textDirection: TextDirection.ltr,
                ),
              ),
            ),
            Text(
              "Samar",
              style: TextStyle(backgroundColor: Colors.teal, fontSize: 33),
            ),
            SizedBox(
              height: 300,
              child: Text("SAMAR", textAlign: TextAlign.center),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.favorite, size: 60, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
