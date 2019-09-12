import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class DownloadPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('下载')),
      body:  _Body()
    );
  }
}

class _Body extends StatefulWidget {

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  List<DownloadTask> downloadList = [];

  @override
  void initState() {
    super.initState();
    _getList();
  }

  _getList () async{
    var list = await FlutterDownloader.loadTasks();
    setState(() {
      downloadList = list;
    });
  }

  @override
  Widget build (BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // List<_DownloadItem>.from(downloadList.map((task) => _DownloadItem(task)).toList())
            // Text('123'),
            Expanded(child: ListView.builder(
              itemExtent: 60,
              itemBuilder: (ctx, index) {
                if (index < downloadList.length) {
                  return _DownloadItem(downloadList[index]);
                }
                return null;
              },
            ),),
          ],
        )
      );
  }
}

class _DownloadItem extends StatelessWidget {
  final DownloadTask task;

  _DownloadItem(this.task);

  onLongPress () {
    
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 72,
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade400, width: 1),)
      ),
      child: InkWell(
        onTap: () {
          task.status == DownloadTaskStatus.paused ? FlutterDownloader.resume(taskId: task.taskId) :
          task.status == DownloadTaskStatus.running ? FlutterDownloader.pause(taskId: task.taskId) : null;
        },
        onLongPress: onLongPress,
        child: Row(
          children: <Widget>[
            IconButton(
              icon: task.status == DownloadTaskStatus.complete ? Icon(Icons.cloud_done) :
                    task.status == DownloadTaskStatus.canceled ? Icon(Icons.cloud_off) :
                    task.status == DownloadTaskStatus.running ? Icon(Icons.pause_circle_outline) :
                    task.status == DownloadTaskStatus.paused ? Icon(Icons.play_circle_outline) :
                    task.status == DownloadTaskStatus.enqueued ? Icon(Icons.cloud_queue) : Icon(Icons.error_outline),
              onPressed: () { },
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(task.filename),
                      Text('${task.progress}/100')
                    ],
                  ),
                  SizedBox(
                    height: 2,
                    child: LinearProgressIndicator(value: task.progress.toDouble(),),
                  ),
                ]
              ),
            ),
            DropdownButton(
              onChanged: (String value) {

              },
              items: <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(
                  value: '123',
                  child: Text('123')
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}