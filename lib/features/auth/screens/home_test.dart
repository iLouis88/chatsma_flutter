import 'package:flutter/material.dart';

class HomeTest extends StatefulWidget {
  static const String routeName ='/home-test';
  const HomeTest({Key? key}) : super(key: key);

  @override
  State<HomeTest> createState() => _HomeTestState();
}

class _HomeTestState extends State<HomeTest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),

      body: const Text('sssssssssssssss'),
    );
  }
}
