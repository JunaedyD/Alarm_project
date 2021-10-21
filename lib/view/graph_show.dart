import '../class/graph_info.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class GraphShow extends StatelessWidget {
  final List<Graph> data;

  GraphShow({this.data});

  @override
  Widget build(BuildContext context) {
    List<charts.Series<Graph, String>> series = [
      charts.Series(
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(Colors.blue),
        id: "Alarm History",
        data: data,
        domainFn: (Graph series, _) => series.waktu,
        measureFn: (Graph series, _) => series.lama,
      )
    ];

    return Scaffold(
      appBar: AppBar(title: Text("Graph Version"),),
      body: Container(
        height: 400,
        padding: EdgeInsets.all(18),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[ 
                Text("Alarm History"),
                Expanded(child: charts.BarChart(series, animate: true))
              ],
            ),
          ),
        ),
      ),
    );

    //return charts.BarChart(series, animate: true);
  }
}
