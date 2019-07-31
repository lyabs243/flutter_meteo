
class Temperature{

  String main;
  String description;
  String icon;
  var temp;
  var pressure;
  var humidity;
  var temp_min;
  var temp_max;

  Temperature(Map map){
    List weather = map['weather'];
    Map weatherMap = weather.first;
    main = weatherMap['main'];
    description = weatherMap['description'];
    icon = weatherMap['icon'];
    Map mainMap = weatherMap['main'];
    temp = mainMap['temp'];
    pressure = mainMap['pressure'];
    humidity = mainMap['humidity'];
    temp_min = mainMap['temp_min'];
    temp_max = mainMap['temp_max'];
  }

}