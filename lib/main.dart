import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

/* Mercado Libre Authentication URL
 - domain (for Brazil): https://auth.mercadolivre.com.br/authorization
 - response_type = token
 - client_id = YOUR_MERCADOLIBRE_APPLICATION_ID
*/
String myApplication = "YOUR_MERCADOLIBRE_APPLICATION_ID";
String url =
    "https://auth.mercadolivre.com.br/authorization?response_type=token&client_id=" +
        myApplication;
String accessToken;

void main() {
  runApp(new MaterialApp(
    debugShowCheckedModeBanner: false,
    home: new Oauth(),
  ));
}

class Oauth extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Login with Mercado Libre',
        routes: {
          "/": (_) => Home(),
          "/login": (_) => Login(),
          "/your_data": (_) => AccessToken(),
        });
  }
}

class Login extends StatefulWidget {
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final flutterWebviewPlugin = FlutterWebviewPlugin();

  StreamSubscription _onDestroy;
  StreamSubscription<String> _onUrlChanged;
  StreamSubscription<WebViewStateChanged> _onStateChanged;

  String token;

  @override
  void dispose() {
    // Every listener should be canceled, the same should be done with this stream.
    _onDestroy.cancel();
    _onUrlChanged.cancel();
    _onStateChanged.cancel();
    flutterWebviewPlugin.dispose();
    super.dispose();
  }

  void saveToken(String token) {
    accessToken = token;
  }

  @override
  void initState() {
    super.initState();

    flutterWebviewPlugin.close();

    // Add a listener to on destroy WebView, so you can make came actions.
    _onDestroy = flutterWebviewPlugin.onDestroy.listen((_) {});

    _onStateChanged = flutterWebviewPlugin.onStateChanged
        .listen((WebViewStateChanged state) {});

    // Add a listener to on url changed to get access_token
    _onUrlChanged = flutterWebviewPlugin.onUrlChanged.listen((String url) {
      if (mounted) {
        setState(() {
          if (url.contains("APP_USR")) {
            RegExp regExp = new RegExp(
                "#access_token=(APP_USR\-[0-9]+\-[0-9]+\-.*\-[0-9]+)");
            this.token = regExp.firstMatch(url)?.group(1);

            //Store access token on memory
            saveToken(token);

            Navigator.of(context).pushNamedAndRemoveUntil(
                "/your_data", (Route<dynamic> route) => false);
            flutterWebviewPlugin.close();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url: url,
      appBar: new AppBar(
        title: new Text("Login with Mercado Libre"),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class Home extends StatefulWidget {
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final webView = FlutterWebviewPlugin();
  TextEditingController controller = TextEditingController(text: url);

  @override
  void initState() {
    super.initState();
    webView.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: new Center(
      child: Container(
        child: RaisedButton(
          child: Text("Login with Mercado Libre",
              style: TextStyle(fontSize: 20.0)),
          onPressed: () {
            Navigator.of(context).pushNamed("/login");
          },
        ),
      ),
    ));
  }
}

class AccessToken extends StatefulWidget {
  _AccessTokenState createState() => _AccessTokenState();
}

class _AccessTokenState extends State<AccessToken> {
  final webView = FlutterWebviewPlugin();

  @override
  void initState() {
    super.initState();
    webView.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            "Access Token",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                Navigator.of(context).pushNamed("/");
              },
            ),
          ]),
      body: new Center(
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  accessToken,
                  style: TextStyle(fontSize: 20.0),
                ))
          ],
        ),
      ),
    );
  }
}
