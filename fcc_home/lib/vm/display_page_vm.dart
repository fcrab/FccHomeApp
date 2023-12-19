import 'package:fcc_home/vm/detail_virtual_vm.dart';

class DisplayVM {
  DetailVirtualVM? virtualVM;

  DisplayVM();

  DisplayVM.vm(this.virtualVM);

  List<String> urls = [];

  void deletePic(int index) {
    virtualVM?.removeAt(index);
    urls.removeAt(index);
  }

  String getName(int index) {
    return virtualVM?.getInfo(index)["name"];
  }
}
