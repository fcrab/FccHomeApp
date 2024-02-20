import 'package:flutter/material.dart';

// 可控制显示隐藏的widget
class CustomAction extends StatefulWidget {
  late CustomActionState _state;

  CustomAction(Widget origin, bool visible) {
    _state = CustomActionState(origin, visible);
  }

  void refresh(visible) {
    _state.refresh(visible);
  }

  @override
  State<StatefulWidget> createState() {
    return _state;
  }
}

class CustomActionState extends State<CustomAction> {
  late Widget custom;

  late bool visible = true;

  CustomActionState(this.custom, this.visible);

  void refresh(visible) {
    this.visible = visible;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      child: custom,
      visible: visible,
    );
  }
}
