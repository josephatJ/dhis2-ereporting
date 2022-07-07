import 'dart:async';

import 'package:dhis2_flutter_sdk/d2_touch.dart';
import 'package:dhis2_flutter_sdk/modules/metadata/program/queries/program.query.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MetadataSyncWidget extends StatefulWidget {
  const MetadataSyncWidget({Key? key}) : super(key: key);

  @override
  _MetadataSyncWidgetState createState() => _MetadataSyncWidgetState();
}

class _MetadataSyncWidgetState extends State<MetadataSyncWidget>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 4),
    vsync: this,
  )..repeat(reverse: true);
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.elasticInOut,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String currentProcess = "";
  String currentSubProcess = "";
  double processPercent = 0;
  bool processesRunning = false;
  int numberOfProcesses = 5;
  double progresIndicatorFractions = 0.0;
  List<String> succesfullProcesses = [];

  downloadMetaData() async {
    setState(() {
      processesRunning = true;
      // processPercent = 1.0;
    });

    setState(() {
      currentProcess = "Syncing organisation units";
    });

    try {
      //var programSyncResponse =
      await D2Touch.programModule.program.download((p0, p1) {
        print("##########################################################");
        print(p0.message);
        print("#########################################################");

        setState(() {
          processPercent = (p0.percentage + 200) / 600;
          currentSubProcess = p0.message;
        });
      });
      print("programSyncResponse");
    } catch (error) {
      print("the errorrrr");
      print(error);
    }

    try {
      var orgUnitSyncResponse = await D2Touch
          .organisationUnitModule.organisationUnit
          .download((p0, p1) {
        setState(() {
          processPercent = p0.percentage / 600;
          currentSubProcess = p0.message;
        });
      });
    } catch (error) {}
    setState(() {
      currentProcess = "Syncing program configurations";
      succesfullProcesses.add("Ous synced");
    });

    setState(() {
      currentProcess = "Syncing Attribute Reserved Values";
      succesfullProcesses.add("Program configurations synced");
    });

    try {
      var reserveValueSync =
          await D2Touch.trackerModule.attributeReservedValue.download((p0, p1) {
        // print(p0.percentage);
        // print(p0.message);
        setState(() {
          processPercent = (p0.percentage + 300) / 600;
          currentSubProcess = p0.message;
        });
      });
    } catch (error) {
      // print("error on syncing reserved vals");
      // print(error.toString());
    }

    setState(() {
      currentProcess = "Syncing Program Rules";
      succesfullProcesses.add("Reserved Values synced");
    });

    try {
      var rulesSync =
          await D2Touch.programModule.programRule.download((p0, p1) {
        setState(() {
          processPercent = (p0.percentage + 400) / 600;
          currentSubProcess = p0.message;
        });
      });
    } catch (error) {}

    setState(() {
      succesfullProcesses.add("Program Rules synced");
    });

    await updateMetadataSyncTime();

    Navigator.pop(context, true);
  }

  Future<void> updateMetadataSyncTime() async {
    DateTime syncCompletedAt = DateTime.now();

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
        "last_metadata_sync",
        syncCompletedAt.year.toString() +
            "-" +
            syncCompletedAt.month.toString() +
            "-" +
            syncCompletedAt.day.toString() +
            " " +
            syncCompletedAt.hour.toString() +
            ":" +
            syncCompletedAt.minute.toString());
  }

  @override
  void initState() {
    super.initState();

    downloadMetaData();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: processesRunning
                  ? [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.9,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            new CircularPercentIndicator(
                              animation: true,
                              radius: 80.0,
                              animateFromLastPercent: true,
                              lineWidth: 4.0,
                              animationDuration: 2000,
                              percent: processPercent,
                              center: Container(
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                    RotationTransition(
                                        turns: _animation,
                                        child: Image.asset(
                                          'images/ereporting.png',
                                          width: 50,
                                          height: 50,
                                        )),
                                    Container(
                                        padding: EdgeInsets.only(top: 15),
                                        child: new Text(
                                          "${(processPercent * 100).round()}%",
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary),
                                        )),
                                  ])),
                              progressColor:
                                  Theme.of(context).colorScheme.onPrimary,
                            ),
                          ],
                        ),
                      ),
                      Container(
                          height: MediaQuery.of(context).size.height * 0.1,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  currentSubProcess,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontSize: 12.0),
                                )
                              ]))
                    ]
                  : [],
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        onWillPop: () async {
          return false;
        });
  }
}
