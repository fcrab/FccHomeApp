import 'package:fcc_home/vm/detail_virtual_vm.dart';
import 'package:intl/intl.dart';

class DisplayVM {
  DetailVirtualVM? virtualVM;

  DisplayVM();

  DisplayVM.vm(this.virtualVM);

  List<String> urls = [];

  void deletePic(int index) {
    virtualVM?.removeAt(index);
    urls.removeAt(index);
  }

  Map<String, String> getDate(int index) {
    var info =
        virtualVM != null ? (virtualVM!.getInfo(index)) : <String, dynamic>{};
    var titles = <String, String>{};
    var date = info["date"] ?? "";
    if (date != null && date != "") {
      titles['title'] = formatFromSec(int.parse(date), "yyyy-MM-dd");
      titles['extra'] = formatFromSec(int.parse(date), "HH:mm:ss");
    } else {
      titles['title'] = info["name"] ?? "";
      titles['extra'] = "";
    }
    return titles;
  }

  String formatFromSec(int second, String format) {
    var dateTime = DateTime.fromMillisecondsSinceEpoch(second * 1000);
    return DateFormat(format).format(dateTime);
  }
}
