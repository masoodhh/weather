
import 'package:intl/intl.dart';

// ignore: avoid_classes_with_only_static_members
class DateConverter{

  /// change dt to our dateFormat ---Jun 23--- for Example
  // ignore: type_annotate_public_apis
  static String changeDtToDateTime(dt){
    final formatter = DateFormat.MMMd();
    final result = formatter.format(DateTime.fromMillisecondsSinceEpoch( dt * 1000,isUtc: true));

    return result;
  }

  /// change dt to our dateFormat ---5:55 AM/PM--- for Example
  static String changeDtToDateTimeHour(dt, timeZone){
    final formatter = DateFormat.jm();
    return formatter.format(
        DateTime.fromMillisecondsSinceEpoch(
            (dt * 1000) +
            timeZone * 1000,
            isUtc: true,),);
  }


}
