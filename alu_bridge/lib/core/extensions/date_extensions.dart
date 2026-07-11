import 'package:intl/intl.dart';

extension DateFormatting on DateTime {
  String get shortDate => DateFormat('d MMM y').format(this);

  String get shortDateTime => DateFormat('d MMM y, h:mm a').format(this);
}
