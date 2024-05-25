import 'package:flutter/material.dart';
// import 'package:floating_action_wheel/floating_action_wheel.dart';

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
                    child: ButtonWheel(),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class ButtonWheel extends StatelessWidget {
  const ButtonWheel({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onPanUpdate: _panHandle,
            child: Container(
              height: 300,
              width: 300,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: Stack(
                children: [
                  Container(
                    alignment: Alignment.topCenter,
                    margin: const EdgeInsets.only(top: 20),
                    child: const Text(
                      "MENU",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    margin: const EdgeInsets.only(right: 20),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.fast_rewind),
                      iconSize: 24,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(left: 20),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.fast_rewind),
                      iconSize: 24,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    alignment: Alignment.bottomCenter,
                    margin: const EdgeInsets.only(bottom: 20),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.fast_rewind),
                      iconSize: 24,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white38,
            ),
          )
        ],
      ),
    );
  }

  void _panHandle(DragUpdateDetails d) {
    /// Pan movements
    bool panUp = d.delta.dy <= 0.0;
    bool panLeft = d.delta.dx <= 0.0;
    bool panRight = !panLeft;
    bool panDown = !panUp;

    /// Pan location on the wheel
    bool onTop = d.localPosition.dy <= 150; // 150 == radius of circle
    bool onLeftSide = d.localPosition.dx <= 150;
    bool onRightSide = !onLeftSide;
    bool onBottom = !onTop;

    /// Absoulte change on axis
    double yChange = d.delta.dy.abs();
    double xChange = d.delta.dx.abs();

    /// Directional change on wheel
    double vert = (onRightSide && panUp) || (onLeftSide && panDown)
        ? yChange
        : yChange * -1;

    double horz =
        (onTop && panLeft) || (onBottom && panRight) ? xChange : xChange * -1;

    // Total computed change with velocity
    double scrollOffsetChange = (horz + vert) * (d.delta.distance * 0.2);
  }
}
