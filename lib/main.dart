import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RetroPod',
      home: Scaffold(
        body: BodyApp(),
      ),
    );
  }
}

class BodyApp extends StatelessWidget {
  const BodyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Container(
          color: const Color.fromRGBO(119, 119, 119, 1),
          child: const Column(
            children: [
              Expanded(
                  flex: 5,
                  child: SizedBox(
                    height: double.infinity,
                    width: double.infinity,
                  )),
              SizedBox(
                height: 1,
              ),
              Expanded(
                  flex: 4,
                  child: SizedBox(
                    height: double.infinity,
                    width: double.infinity,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
