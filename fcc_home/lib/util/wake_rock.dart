import '../home_global.dart';

Future<void> enableScreen() async {
  await HomeGlobal.platform.invokeMethod("screenSwitch", true);
}

Future<void> disableScreen() async {
  await HomeGlobal.platform.invokeMethod("screenSwitch", false);
}
