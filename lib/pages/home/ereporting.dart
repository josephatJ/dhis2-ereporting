import 'package:dhis2_flutter_sdk/d2_touch.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class EReportingPage extends StatefulWidget {
  const EReportingPage({Key? key}) : super(key: key);

  @override
  _EReportingPageState createState() => _EReportingPageState();
}

class _EReportingPageState extends State<EReportingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text('Reporting Tools'),
          automaticallyImplyLeading: false,
        ),
        body: Container(
          child: TextButton(
            onPressed: () {
              _getPrograms();
            },
            child: Text('Testing'),
          ),
        ));
  }

  Future<dynamic> _getPrograms() async {
    final dynamic response = await D2Touch.programModule.program.get();
    // final Map<Column, dynamic> responseMap = json.decode(response);
    print(response);
    print("################");
    return response;
  }
}
