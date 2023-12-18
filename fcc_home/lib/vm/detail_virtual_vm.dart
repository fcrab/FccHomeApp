/**
 * 预留之后自定义滑动事件的vm抽象
 *
 */
abstract class DetailVirtualVM {
  String getUrl(int index);

  Map<String, dynamic> getInfo(int index);

  void removeAt(int index);

  void goToNext();

  void goBack();
}
