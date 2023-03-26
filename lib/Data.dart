class Data {
  Data({
      required this.resultB64,
      required this.foregroundTop,
      required this.foregroundLeft,
      required this.foregroundWidth,
      required this.foregroundHeight,});

  Data.fromJson(dynamic json) {
    resultB64 = json['result_b64'];
    foregroundTop = json['foreground_top'];
    foregroundLeft = json['foreground_left'];
    foregroundWidth = json['foreground_width'];
    foregroundHeight = json['foreground_height'];
  }
  String resultB64;
  int foregroundTop;
  int foregroundLeft;
  int foregroundWidth;
  int foregroundHeight;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['result_b64'] = resultB64;
    map['foreground_top'] = foregroundTop;
    map['foreground_left'] = foregroundLeft;
    map['foreground_width'] = foregroundWidth;
    map['foreground_height'] = foregroundHeight;
    return map;
  }

}