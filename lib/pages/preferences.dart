import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:oktoast/oktoast.dart';
import '../github/github.dart';

class PreferencesPage extends StatefulWidget {

  @override
  _PreferencesPageState createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {

  Map<String, String> _prefs = {
    'token': '',
    'gistID': ''
  };
  bool _pageLoading = true;

  @override
  initState () {
    super.initState();
    this.getInitialPrefs();
  }

  getInitialPrefs () async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      _prefs['token'] = prefs.getString('prefs/token') == null ? '' : prefs.getString('prefs/token');
      _prefs['gistID'] = prefs.getString('prefs/gistID') == null ? '' : prefs.getString('prefs/gistID');
      _pageLoading = false;
    });
  }

  _validate (token) async {
    GithubClient client = new GithubClient(token: token);
    return client.login();
  }

  _showTokenInputModal (BuildContext context, { String fieldName = 'token' }) async {
    var _controller = TextEditingController.fromValue(TextEditingValue(text: _prefs[fieldName]));
    var confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return SimpleDialog(
          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          title: Text('请输入${fieldName[0].toUpperCase()}${fieldName.substring(1)}'),
          children: <Widget>[
            TextField(
              controller: _controller,
            ),
            Padding(padding: EdgeInsets.only(top: 8), child: Row(
              children: <Widget>[
                Expanded(child: SimpleDialogOption(
                  onPressed: () {
                    Navigator.of(context).canPop() && Navigator.of(context).pop(false);
                  },
                  child: Text('取消', textAlign: TextAlign.center,),
                )),
                Expanded(child: SimpleDialogOption(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text('确定', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).primaryColor),),
                ))
              ]
            )),
          ],
        );
      }
    );
    if (confirmed) {
      String text = _controller.value.text;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      try {
        await _validate(text);
        bool success = await prefs.setString('prefs/$fieldName', text);
        if (success) {
          showToast('修改成功', position: ToastPosition.bottom, textPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8));
          setState(() {
            _prefs['$fieldName'] = text;
          });
        } else {
          showToast('修改失败', position: ToastPosition.bottom, textPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8));
        }
      } catch (e) {
        print(e);
      }
    }
  }
  @override
  Widget build (BuildContext context) {
    return SafeArea(child: Material(child: _pageLoading ? Center(child: CircularProgressIndicator()) : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(children: <Widget>[
          IconButton(icon: Icon(Icons.arrow_back), iconSize: 24, onPressed: () {
            Navigator.of(context).pop();
          },),
          Text('设置', style: TextStyle(fontSize: 24),),
        ],),
        Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.black12,
          padding: EdgeInsets.all(10), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('基础设置', style: TextStyle(fontSize: 16, color: Colors.black54),),
            ]
          )
        ),
        Expanded(child: Container(
          margin: EdgeInsets.symmetric(horizontal: 12),
          child: ListView(
            itemExtent: 40,
            children: <Widget>[
              InkWell(
                child: Row(
                  children: <Widget>[
                    ConstrainedBox(
                      child: Text('Token', style: TextStyle(fontSize: 20),),
                      constraints: BoxConstraints(minWidth: 100),
                    ),
                    Expanded(child: Text(_prefs['token'], style: TextStyle(fontSize: 16, color: Colors.black54), overflow: TextOverflow.ellipsis,),)
                  ],
                ),
                onTap: () { _showTokenInputModal(context); },
              ),
              InkWell(
                child: Row(
                  children: <Widget>[
                    ConstrainedBox(
                      child: Text('GistID', style: TextStyle(fontSize: 20),),
                      constraints: BoxConstraints(minWidth: 100),
                    ),
                    Expanded(child: Text(_prefs['gistID'], style: TextStyle(fontSize: 16, color: Colors.black54), overflow: TextOverflow.ellipsis,),)
                  ],
                ),
                onTap: () { _showTokenInputModal(context, fieldName: 'gistID'); },
              ),
            ],
          )
        ))
      ],
    )));
  }
}