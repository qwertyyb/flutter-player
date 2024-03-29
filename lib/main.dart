import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import './pages/player.dart';
import './pages/home.dart';
import './pages/download.dart';
import './providers/playing.dart';
import './providers/songlist.dart';

void main() => runApp(StartApp());

class StartApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OKToast(child: MultiProvider(
        providers: [
          ChangeNotifierProvider<Playing>.value(value: Playing()),
          ChangeNotifierProvider<Songlist>.value(value: Songlist()),
        ],
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            // This is the theme of your application.
            //
            // Try running your application with "flutter run". You'll see the
            // application has a blue toolbar. Then, without quitting the app, try
            // changing the primarySwatch below to Colors.green and then invoke
            // "hot reload" (press "r" in the console where you ran "flutter run",
            // or simply save your changes to "hot reload" in a Flutter IDE).
            // Notice that the counter didn't reset back to zero; the application
            // is not restarted.
            primarySwatch: Colors.green,
          ),
          home: HomePage(title: '首页'),
          routes: <String, WidgetBuilder> {
            '/player': (BuildContext context) => PlayerPage(),
            '/download': (BuildContext context) => DownloadPage(),
          },
          onGenerateRoute: (RouteSettings settings) {
            if (settings.name == '/list') {
              return MaterialPageRoute(
                builder: (ctx) => HomePage(
                  title: (settings.arguments as Map)['title'],
                  list: (settings.arguments as Map)['list']
                ),
              );
            }
            return MaterialPageRoute();
          },
      ),),
    );
  }
}
