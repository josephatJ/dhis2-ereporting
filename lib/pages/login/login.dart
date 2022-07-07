import 'package:dhis2_flutter_sdk/d2_touch.dart';
import 'package:dhis2_flutter_sdk/modules/auth/user/models/login-response.model.dart';
import 'package:ereporting/pages/home/ereporting.dart';
import 'package:flutter/material.dart';
import 'package:ereporting/pages/login/metadata_sync_widget.dart';
import 'package:ereporting/shared/widgets/loaders/circular_progress_loader.dart';
import 'package:ereporting/shared/widgets/text_widgets/text_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String username = '';
  String password = '';
  String instance = '';
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController instanceController = TextEditingController();

  bool authenticating = false;
  bool showPassWord = false;
  bool loggedIn = true;
  bool errorLoginIn = false;
  late String errorMessage;

  checkAuth() async {
    bool authState = await D2Touch.isAuthenticated();
    setState(() {
      loggedIn = authState;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration:
        BoxDecoration(color: Theme.of(context).colorScheme.primary),
        width: double.maxFinite,
        height: double.maxFinite,
        child: ListView(
          children: [
            Container(
              padding: EdgeInsets.only(top: 80),
              alignment: Alignment.center,
              child: TextWidgetBold(
                text: "eReporting",
                size: 30,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(30)),
                padding:
                EdgeInsets.only(top: 20, bottom: 30, right: 10, left: 10),
                margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                child: Container(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Column(
                      children: [
                        TextWidgetBold(
                          text: "Login",
                          color: Theme.of(context).colorScheme.onSurface,
                          size: 25,
                          bottom: 20,
                        ),
                        TextWidget(
                            text:
                            'Please enter your credentials to login',
                            color: Colors.black54,
                            size: 15,
                            bottom: 20),
                        errorLoginIn
                            ? Text(
                          "Error logging in. Please confirm your credentials and retry",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error),
                        )
                            : SizedBox(
                          height: 0,
                        ),
                        Container(
                            margin: EdgeInsets.only(top: 10),
                            child: TextFormField(
                              controller: instanceController,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.cloud_done_outlined),
                                border: UnderlineInputBorder(),
                                labelText: 'Address',
                              ),
                            )),
                        Container(
                            margin: EdgeInsets.only(top: 10),
                            child: TextFormField(
                              controller: usernameController,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.person_outlined),
                                border: UnderlineInputBorder(),
                                labelText: 'Username',
                              ),
                            )),
                        Container(
                            margin: EdgeInsets.only(top: 15, bottom: 25),
                            child: TextFormField(
                              obscureText: !showPassWord,
                              controller: passwordController,
                              enableSuggestions: false,
                              autocorrect: false,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.lock_outlined),
                                // suffixIcon: Icon(Icons.person,),
                                suffixIcon: IconButton(
                                  icon: showPassWord
                                      ? Icon(Icons.visibility_sharp)
                                      : Icon(Icons.visibility_off_outlined),
                                  onPressed: () {
                                    setState(() {
                                      showPassWord = !showPassWord;
                                    });
                                  },
                                ),
                                border: UnderlineInputBorder(),
                                labelText: 'Password',
                              ),
                            )),
                        Container(
                          child: TextButton(
                              onPressed: () {
                                setState(() {
                                  instance = instanceController.text;
                                  username = usernameController.text;
                                  password = passwordController.text;
                                  authenticating = true;
                                  errorMessage = "";
                                  errorLoginIn = false;
                                });
                                _login(instance, username, password);
                              },
                              child: authenticating == false
                                  ? Text("Login",
                                  style: TextStyle(color: Colors.white))
                                  : CircularProgressLoader("Authenticating"),
                              style: ButtonStyle(
                                  backgroundColor:
                                  MaterialStateProperty.all(Colors.blue),
                                  padding: MaterialStateProperty.all(
                                      EdgeInsets.only(left: 30, right: 30)))),
                        )
                      ],
                    )))
          ],
        ),
      ),
    );
  }

  // Functionalities for logging IN HERE
  _login(String address, String username, String password) async {
    setState(() {
      authenticating = true;
    });

    LoginResponseStatus? onlineLogIn;

    try {
      onlineLogIn = await D2Touch.logIn(
          username: username,
          password: password,
          url: address
      );
    } catch (error) {
      onlineLogIn = null;
      setState(() {
        errorLoginIn = true;
        authenticating = false;
      });
    }

    bool isAuthenticated = await D2Touch.isAuthenticated();

    if (isAuthenticated) {
      setState(() => {
        authenticating = false,
        loggedIn = false,
        errorLoginIn = false,
      });

      final bool? result = await Navigator.push(
        context,
        // SelectionScreen in the next step.
        MaterialPageRoute(builder: (context) => MetadataSyncWidget()),
      );
      try {
        // Navigator.pushNamed(context, '/home');
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => EReportingPage())
        );
      } catch (error) {
        // print(error.toString());
      }
    } else {
      setState(() => {
        authenticating = false,
        loggedIn = false,
        errorLoginIn = true,
        errorMessage = "error message"
      });
    }
  }
}
