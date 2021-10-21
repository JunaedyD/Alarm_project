import 'package:alarm/function/chart_helper.dart';
import 'package:alarm/class/chart_info.dart';
import 'package:alarm/class/graph_info.dart';
import 'package:alarm/view/graph_show.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/src/painting/text_style.dart' as textstylist;

class GraphPage extends StatefulWidget {
  final List<ChartInfo> data;
  GraphPage({this.data});


  @override
  _GraphPageState createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  ChartHelper _chartHelper = ChartHelper();
  List<ChartInfo> _data;
  List<charts.Series<ChartInfo, String>> _chartdata;
  List<Graph> datagraphver = [
    Graph(waktu: "15:20", lama: 5),
    Graph(waktu: "15:21", lama: 10),
    Graph(waktu: "15:22", lama: 18),
    Graph(waktu: "15:23", lama: 30),
    Graph(waktu: "15:24", lama: 15),
    Graph(waktu: "15:25", lama: 8),
    Graph(waktu: "15:26", lama: 20),
  ];

  void _makeData() {
    _data = new List<ChartInfo>();
    _chartdata = new List<charts.Series<ChartInfo, String>>();

    _chartdata.add(new charts.Series(
        id: "Alarm History",
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        fillPatternFn: (_, __) => charts.FillPatternType.solid,
        data: _data,
        domainFn: (ChartInfo series, _) => series.time,
        measureFn: (ChartInfo series, _) => series.diff));

    print("jumlah data ==>" + _data.length.toString());
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _makeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("History"),
        actions: <Widget>[
          Row(
            children: [
              GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return GraphShow(
                          data: datagraphver,
                          );
                    }));
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: Text(
                      "Chart Ver.",
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                  )),
            ],
          )
        ],
      ),
      body: Center(
        child: Container(
          height: 800,
          child: ListView(
            children: [
              Container(
                height: 1000,
                child: FutureBuilder<List<ChartInfo>>(
                  future: _chartHelper.getChart(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      // _currentAlarms = snapshot.data;
                      return ListView(
                        physics: new NeverScrollableScrollPhysics(),
                        children: snapshot.data.map<Widget>((chart) {
                        

                          return Container(
                            margin: const EdgeInsets.only(
                                bottom: 10, right: 10, left: 10, top: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black,
                                  blurRadius: 3,
                                  spreadRadius: 1,
                                  offset: Offset(0, 0),
                                ),
                              ],
                              borderRadius:
                                  BorderRadius.all(Radius.circular(24)),
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
                                          " ${chart.id}", //chart.time,
                                          style: textstylist.TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'avenir'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      chart.time +
                                          " selama " +
                                          chart.diff.toString() +
                                          " detik",
                                      style: textstylist.TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'avenir',
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    // IconButton(
                                    //     icon: Icon(Icons.delete),
                                    //     color: Colors.white,
                                    //     onPressed: () {
                                    //       //deleteAlarm(alarm.id);
                                    //     }),
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
                        style: textstylist.TextStyle(color: Colors.white),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

