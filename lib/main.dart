import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import './pages/player.dart';
import './bloc/playing.dart';
import './pages/home.dart';
import './pages/preferences.dart';
import './pages/download.dart';
import './bloc/BlocProvider.dart';
import './bloc/list.dart';

void main() => runApp(StartApp());

class StartApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OKToast(child: BlocProvider<PlayingSongBLoC>(
      bloc: PlayingSongBLoC(),
      child: BlocProvider<SonglistBLoC>(
      bloc: SonglistBLoC(),
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
          '/preferences': (BuildContext context) => PreferencesPage(),
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
        },
      ),),
    ));
  }
}
