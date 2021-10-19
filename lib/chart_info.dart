import 'package:charts_flutter/flutter.dart' as charts;

class ChartInfo {
  int id;
  String time;
  int diff;
  

  ChartInfo(
      {this.id,
      this.time,
      this.diff,
      });

  factory ChartInfo.fromMap(Map<String, dynamic> json) => ChartInfo(
        id: json["id"],
        time: json["time"],
        diff: json["diff"],
        
      );
  Map<String, dynamic> toMap() => {
        "id": id,
        "time": time,
        "diff": diff,
        
      };
}
