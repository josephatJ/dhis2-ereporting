import 'package:ereporting/pages/home/ereporting.dart';
import 'package:ereporting/pages/login/login.dart';
import 'package:flutter/widgets.dart';

final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
  '/': (context) => LoginPage(),
  '/home': (BuildContext context) => EReportingPage(),
};
