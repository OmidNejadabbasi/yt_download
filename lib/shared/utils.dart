import 'package:intl/intl.dart';

String humanReadableByteCountBin(int bytes) {
  int absB = bytes;
  if (absB < 0) {
    return "0 B";
  }

  if (absB < 1024) {
    return absB.toString() + " B";
  }
  int value = absB;
  int counter = 0;
  String ci = ("KMGTPE");
  for (int i = 40; i >= 0 && absB > 0xfffcccccccccccc >> i; i -= 10) {
    value >>= 10;
    counter++;
  }
  value = value < 0?-value:value;
  var f = NumberFormat(".#", "en_US");
  return "${f.format(value / 1024.0)} ${ci[counter]}B";
}