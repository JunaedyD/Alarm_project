import 'dart:async';
import 'dart:math';
import 'package:alarm/alarm_helper.dart';
import 'package:alarm/alarm_info.dart';
import 'package:alarm/chart_helper.dart';
import 'package:alarm/chart_info.dart';
import 'package:alarm/graphicPage.dart';
import 'package:alarm/localNotifymanager.dart';
import 'package:alarm/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:rxdart/subjects.dart';
import 'localNotifymanager.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double putarandetik = 0;
  double putaranmenit = pi / 30 * DateTime.now().minute;
  double putaranjam = (pi / 6 * DateTime.now().hour) +
      (pi / 45 * (pi / 30 * DateTime.now().minute));
  Timer timer;
  String jam;
  String menit;
  DateTime now;
  bool edit = false;
  AlarmHelper _alarmHelper = AlarmHelper();
  ChartHelper _chartHelper = ChartHelper();
  List<String> waktu;
  List<int> idwaktu;
  var initSetting;
  BehaviorSubject<ReceiveNotification> get didReceiveLocalNotificationSubject =>
      BehaviorSubject<ReceiveNotification>();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  int _menitalarmsetup = DateTime.now().minute.toInt();
  int _jamalarmsetup = DateTime.now().hour.toInt();
  NumberPicker horizontalNumberPicker;
  NumberPicker integerInfiniteDecoratedNumberPicker;

  String jamalarm = DateTime.now().hour.toString().padLeft(2, "0");
  String menitalarm = DateTime.now().minute.toString().padLeft(2, "0");
  final dbHelper = AlarmHelper.instance;

  Decoration _decoration = new BoxDecoration(
    border: new Border(
      top: new BorderSide(
        style: BorderStyle.solid,
        color: Colors.black26,
      ),
      bottom: new BorderSide(
        style: BorderStyle.solid,
        color: Colors.black26,
      ),
    ),
  );

  //inisialisasi scroll jam dan menit
  void _initializeNumberPickers() {
    horizontalNumberPicker = new NumberPicker.horizontal(
      initialValue: _menitalarmsetup,
      minValue: 00,
      maxValue: 59,
      step: 1,
      zeroPad: true,
      onChanged: (value) => setState(() {
        _menitalarmsetup = value;
        edit = true;
        putaranmenit = pi / 30 * value;
        putaranjam = (pi / 6 * _jamalarmsetup) +
            (pi / 45 * (pi / 30 * _menitalarmsetup));
      }),
    );

    integerInfiniteDecoratedNumberPicker = new NumberPicker.integer(
      initialValue: _jamalarmsetup,
      minValue: 00,
      maxValue: 23,
      step: 1,
      infiniteLoop: false,
      highlightSelectedValue: true,
      decoration: _decoration,
      onChanged: (value) => setState(() {
        _jamalarmsetup = value;
        //putaranjam = (pi / 6 * _jamalarmsetup) + (pi / 45 * _menitalarmsetup);
        putaranjam = (pi / 6 * _jamalarmsetup) +
            (pi / 45 * (pi / 30 * _menitalarmsetup));
        edit = true;
      }),
    );
  }


  



  initializePlatform() {
    var initSettingAndroid = AndroidInitializationSettings('app_icon');
    var initSettingIOS = IOSInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification: (id, title, body, payload) async {
          ReceiveNotification notification = ReceiveNotification(
              id: id, title: title, body: body, payload: payload);
          didReceiveLocalNotificationSubject.add(notification);
        });
    initSetting = InitializationSettings(initSettingAndroid, initSettingIOS);
  }

  setOnNotificationReceive(Function onNotificationReceive) {
    didReceiveLocalNotificationSubject.listen((notification) {
      onNotificationReceive(notification);
    });
  }

  setOnNotificationClick(Function onNotificationClick) async {
    await flutterLocalNotificationsPlugin.initialize(initSetting,
        onSelectNotification: (String payload) async {
      onNotificationClick(payload);
    });
  }

  @override
  void initState() {
    super.initState();
    initializePlatform();

    localNotifyManager.setOnNotificationClick(onNotificationReceive);
    localNotifyManager.setOnNotificationClick(onNotificationClick);
    
    _alarmHelper.initializeDatabase().then((value) {
      print('---------- database inisial');
    });

    //setiap 0.5 detik akan refresh untuk pergerakan jarum detik
    timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
    now = DateTime.now();

      setState(() {
        putarandetik = (pi / 30) * now.second;

        //refresh jarum menit
        if (now.second == 0) {
          if (edit == false) {
            putaranmenit = pi / 30 * now.minute;
          }
        }

        //refresh jarum jam
        if (now.minute == 0) {
          if (edit == false) {
            putaranjam = (pi / 6 * now.hour) + (pi / 45 * putaranmenit);
          }
        }

       

        jam = DateTime.now().hour.toString().padLeft(2, "0");
        menit = DateTime.now().minute.toString().padLeft(2, "0");

      });
    });
  }

  onNotificationReceive(ReceiveNotification notification) {
    print('Notification Received: ${notification.id}');
  }

  //ketika notification di click, hitung selisih waktu dan pindah ke History Page
  onNotificationClick(String payload) {
    print('Payload $payload');

    int jam = int.parse(payload.substring(0, 2));
    int menit = int.parse(payload.substring(2, 4));

    var startTime = DateTime(now.year, now.month, now.day, jam, menit);
    var endTime = DateTime.now();
    int diff = endTime.difference(startTime).inSeconds;

    var chartinfo = ChartInfo(
      time: "${jam.toString()}:${menit.toString()}",
      diff: diff,
    );

    //simpan di sqlite untuk history click
    _chartHelper.insertChart(chartinfo);

    //pindah ke chart
    Future.delayed(Duration(milliseconds: 1000), () {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return GraphPage(
            
            );
      }));
    });
  }

  //menghapus list alarm
  void deleteAlarm(int id) {
    _alarmHelper.delete(id);
    
  }

  @override
  Widget build(BuildContext context) {
    _initializeNumberPickers();
    return Scaffold(
      body: Container(
        child: ListView(
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            //jam digital sekarang
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(jam + " : " + menit,
                    style: TextStyle(color: Colors.white, fontSize: 60)),
              ),
            ),
            
            //jam analog
            Padding(
              padding: const EdgeInsets.only(top: 0.0),
              child: Container(
                //color: Colors.red,
                child: Stack(children: <Widget>[
                  Center(
                      child: Image.asset('asset/jam.png',
                          width: 250, height: 250)),

                  //dot ditengah
                  Container(
                    child: Container(
                        height: 15,
                        width: 15,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(50),
                        )),
                    alignment: Alignment(0, 0),
                  ),

                  //detik
                  Transform.rotate(
                    child: Container(
                      child: Container(
                          height: 110,
                          width: 3,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10),
                          )),
                      alignment: Alignment(0, -0.35),
                    ),
                    angle: putarandetik,
                  ),

                  //panjang (menit)
                  Transform.rotate(
                    child: Container(
                      child: Container(
                          height: 95,
                          width: 5,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10),
                          )),
                      alignment: Alignment(0, -0.35),
                    ),
                    angle: putaranmenit,
                  ),

                  //pendek (jam)
                  Transform.rotate(
                    child: Container(
                      child: Container(
                          height: 70,
                          width: 7,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10),
                          )),
                      alignment: Alignment(0, -0.2),
                    ),
                    angle: putaranjam,
                  ),
                ]),
                width: 250,
                height: 250,
              ),
            ),

            //pengaturan alarm
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 0.0),
                      child: Text('Jam',
                          style: Theme.of(context).textTheme.headline6),
                    ),
                    integerInfiniteDecoratedNumberPicker,
                    
                  ],
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: Text('Menit',
                          style: Theme.of(context).textTheme.headline6),
                    ),
                    horizontalNumberPicker,
                    Column(
                      children: [
                        Text("Alarm", style: TextStyle(fontSize: 20)),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                              _jamalarmsetup.toString().padLeft(2, "0") +
                                  " : " +
                                  _menitalarmsetup.toString().padLeft(2, "0"),
                              style:
                                  TextStyle(color: Colors.white, fontSize: 40)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            //add alarm
            Padding(
              padding: const EdgeInsets.only(top: 20.0, right: 50, left: 50, bottom: 30),
              child: Container(
                child: RaisedButton(
                  child: Text('Add Alarm'),
                  onPressed: () async {
                    // print("pressed");


                    String x =
                        "${_jamalarmsetup.toString().padLeft(2, "0")}${_menitalarmsetup.toString().padLeft(2, "0")}";

                    //set alarm
                    scheduleAlarm(_jamalarmsetup, _menitalarmsetup, x);

                    //simpan di sqlite untuk list alarm
                    var alarmInfo = AlarmInfo(
                        alarmDateTime: DateTime(now.year, now.month, now.day,
                            _jamalarmsetup, _menitalarmsetup),
                        title: 'Alarm',
                        gradientColorIndex: 1);

                    _alarmHelper.insertAlarm(alarmInfo);

                    //dialogbox pemberitahuan click
                    showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Row(children: [Text('Pemberitahuan ')]),
                              content: Text("Alarm akan berbunyi pada ${_jamalarmsetup.toString().padLeft(2, "0")}:${_menitalarmsetup.toString().padLeft(2, "0")}"),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text(
                                    "TUTUP",
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                  onPressed: () {
                                    //Put your code here which you want to execute on Cancel button click.
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          });

                   
                  },
                ),
              ),
            ),

            //list alarm
            Container(
              height: 1000,
              child: FutureBuilder<List<AlarmInfo>>(
                future: _alarmHelper.getAlarms(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    
                    return ListView(
                      physics: new NeverScrollableScrollPhysics(),
                      children: snapshot.data.map<Widget>((alarm) {
                        var alarmTime =
                            DateFormat('HH:mm').format(alarm.alarmDateTime);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 32),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black,
                                blurRadius: 8,
                                spreadRadius: 2,
                                offset: Offset(4, 4),
                              ),
                            ],
                            borderRadius: BorderRadius.all(Radius.circular(24)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.label,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        alarm.title + " ${alarm.id}",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'avenir'),
                                      ),
                                    ],
                                  ),
                                  
                                ],
                              ),
                              // Text(
                              //   'Mon-Fri',
                              //   style: TextStyle(
                              //       color: Colors.white, fontFamily: 'avenir'),
                              // ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    alarmTime,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'avenir',
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  IconButton(
                                      icon: Icon(Icons.delete),
                                      color: Colors.white,
                                      onPressed: () {
                                        deleteAlarm(alarm.id);
                                      }),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  }
                  return Center(
                    child: Text(
                      'Loading..',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                },
                // builder: (BuildContext context, AsyncSnapshot<List<AlarmInfo>> snapshot) {
                //   if (snapshot.hasData) {
                //     return ListView.builder(
                //       itemCount: snapshot.data.length,
                //       itemBuilder: (BuildContext context, int index) {
                //         AlarmInfo item = snapshot.data[index];
                //         return Dismissible(
                //           key: UniqueKey(),
                //           background: Container(color: Colors.red),
                //           onDismissed: (direction) {
                //             //DBProvider.db.deleteClient(item.id);
                //           },
                //           child: ListTile(
                //             title: Text(item.title),
                //             leading: Text(item.id.toString()),
                //             // trailing: Checkbox(
                //             //   onChanged: (bool value) {
                //             //     DBProvider.db.blockOrUnblock(item);
                //             //     setState(() {});
                //             //   },
                //             //   value: item.blocked,
                //             // ),
                //           ),
                //         );
                //       },
                //     );
                //   } else {
                //     return Text("List Kosong");
                //   }
                // },
              ),
            ),

            
          ],
        ),
        color: Colors.black54,
        alignment: Alignment(0, 0),
      ),
    );

    
  }
}

//set alarm
void scheduleAlarm(hour, minute, value) async {
  var time = Time(hour, minute, 0);

  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'alarm_notif',
    'alarm_notif',
    'Channel for Alarm notification',
    importance: Importance.Max,
    priority: Priority.High,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('_sound'),
    
  );

  var iOSPlatformChannelSpecifics = IOSNotificationDetails(
      sound: '_sound.wav',
      presentAlert: true,
      presentBadge: true,
      presentSound: true);
  var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);


  await flutterLocalNotificationsPlugin.showDailyAtTime(
      0, 'ALARM', 'Alarm berhasil', time, platformChannelSpecifics,
      payload: value);

}

