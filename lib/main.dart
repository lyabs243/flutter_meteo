import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:geocoder/geocoder.dart';
import 'package:http/http.dart' as http;
import 'temperature.dart';
import 'dart:convert';
import 'my_flutter_app_icons.dart';

void main(){
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Meteo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String town;
  List<String> towns = [];
  String keyList = 'towns';

  Location location;
  LocationData locationData;
  Stream stream;

  Coordinates townCoordinates;

  Temperature temperature;
  String currentCity = 'Current Town';

  AssetImage night = new AssetImage('assets/n.jpg');
  AssetImage sun = new AssetImage('assets/d1.jpg');
  AssetImage rain = new AssetImage('assets/d2.jpg');

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    getSharedPref();
    location = new Location();
    initLocation();
    listenToStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: new Drawer(
        child: Container(
          color: Colors.blue,
          child: new ListView.builder(
            itemBuilder: (context,i){
              if(i == 0){
                return DrawerHeader(
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      textWithStyle(
                        'My Towns',
                        fontSize: 22.0,
                      ),
                      new RaisedButton(
                        onPressed: (){
                          addTown();
                        },
                        elevation: 8.0,
                        color: Colors.white,
                        child: textWithStyle(
                            'Add Town',
                            color: Colors.blue,
                        ),
                      )
                    ],
                  ),
                );
              }
              else if(i == 1){
                return new ListTile(
                  title: textWithStyle(currentCity),
                  onTap: (){
                    setState(() {
                      town = null;
                      townCoordinates = null;
                    });
                    Navigator.pop(context);
                  },
                );
              }
              else {
                return new ListTile(
                  title: textWithStyle(towns[i-2]),
                  trailing: new IconButton(
                    icon: new Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                    onPressed: (){
                      deleteTown(towns[i-2]);
                    }
                  ),
                  onTap: () {
                    setState(() {
                      town = towns[i-2];
                      coordinatesFromCity();
                    });
                    Navigator.pop(context);
                  },
                );
              }
            },
            itemCount: towns.length+2,
          ),
        ),
      ),
      body: (temperature == null)?
        Center(
          child: new Text(
            (town!= null)? town : currentCity,
            textScaleFactor: 3.0,
          ),
        )
      :
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: new BoxDecoration(
            image: new DecorationImage
            (
              image: getBackground(),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              textWithStyle((town == null)? currentCity : town,fontSize: 40.0),
              textWithStyle(temperature.description, fontSize: 30.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Image.asset('assets/weather/${temperature.icon.substring(0,2)}.png'),
                  textWithStyle('${temperature.temp.toInt()} C', fontSize: 70.0),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  extra('${temperature.temp_min} C', MyFlutterApp.up),
                  extra('${temperature.temp_max} C', MyFlutterApp.down),
                  extra('${temperature.pressure}', MyFlutterApp.temperatire),
                  extra('${temperature.humidity}%', MyFlutterApp.drizzle),
                ],
              ),
            ],
          ),
        ),
    );
  }

  listenToStream(){
    stream = location.onLocationChanged();
    stream.listen((newLocation){
      if(locationData != null && (locationData.latitude != newLocation.latitude
          && locationData.longitude != newLocation.longitude)) {
        print('New Location: ${newLocation.latitude} / ${newLocation.longitude}');
        setState(() {
          locationData = newLocation;
          locationToString();
        });
      }
    });
  }

  initLocation() async{
    try{
      locationData = await location.getLocation();
      print('Localization: ${locationData.latitude} / ${locationData.longitude}');
      locationToString();
    }
    catch(e){
      print('Location error: $e');
    }
  }

  locationToString() async{
    if(locationData != null){
      try {
        Coordinates coordinates = new Coordinates(
            locationData.latitude, locationData.longitude);
        final cityName = await Geocoder.local.findAddressesFromCoordinates(
            coordinates);
        setState(() {
          currentCity = cityName.first.locality;
          api();
        });
      }
      catch(e){
        print('Error $e');
      }
    }
  }

  coordinatesFromCity() async{
    if(town != null){
      List<Address> addresses = await Geocoder.local.findAddressesFromQuery(town);
      if(addresses.length > 0){
        Address first = addresses.first;
        Coordinates coordinates = first.coordinates;
        setState(() {
          townCoordinates = coordinates;
          api();
        });
      }
    }
  }

  AssetImage getBackground(){
    print(temperature.icon);
    if(temperature.icon.contains('n')){
      return night;
    }
    else if(temperature.icon.contains('01') || temperature.icon.contains('02') || temperature.icon.contains('03')){
      return sun;
    }
    else{
      return rain;
    }
  }

  api() async{
    double lat;
    double lon;

    if(townCoordinates != null){
      lat = townCoordinates.latitude;
      lon = townCoordinates.longitude;
    }
    else if(locationData != null){
      lat = locationData.latitude;
      lon = locationData.longitude;
    }

    if(lat != null && lon != null){
      try {
        final key = '&APPID=bd4b66af5e769c820604a654a7b3dadf';
        String lang = '&lang=${Localizations
            .localeOf(context)
            .languageCode}';
        String baseApi = 'http://api.openweathermap.org/data/2.5/weather?';
        String coordString = 'lat=$lat&lon=$lon';
        String units = '&units=metric';
        String totalString = baseApi + coordString + lang + units + key;
        final response = await http.get(totalString);
        if (response.statusCode == 200) {
          Map map = json.decode(response.body);
          setState(() {
            temperature = new Temperature(map);
            print(temperature.description);
          });
        }
      }
      catch(e){
        print('Erreur: $e');
    }
    }
  }

  Column extra(String data,IconData iconData){
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Icon(
          iconData,
          color: Colors.white,
          size: 32.0,
        ),
        textWithStyle(data),
      ],
    );
  }

  Text textWithStyle(String title,{color: Colors.white,fontSize: 18.0,fontStyle: FontStyle.italic,textAlign: TextAlign.center,textScaleFactor: 1.0}){
    return new Text(
      title,
      textScaleFactor: textScaleFactor,
      textAlign: textAlign,
      style: new TextStyle(
        fontStyle: fontStyle,
        fontSize: fontSize,
        color: color,
      ),
    );
  }

  Future addTown() async{
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext buildContext){
        return new SimpleDialog(
          contentPadding: EdgeInsets.all(20.0),
          title: textWithStyle(
            'Add Town',
            fontSize: 22.0,
            color: Colors.blue,
          ),
          children: <Widget>[
            new TextField(
              decoration: new InputDecoration(
                labelText: 'Town: ',
              ),
              onSubmitted: (String text){
                addNewTown(text);
                Navigator.pop(buildContext);
              },
            ),
          ],
        );
      },
    );
  }

  void getSharedPref() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<String> list = sharedPreferences.getStringList(keyList);
    if(list != null){
      setState(() {
        towns = list;
      });
    }
  }

  void addNewTown(String own) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    towns.add(own);
    await sharedPreferences.setStringList(keyList, towns);
    getSharedPref();
  }

  void deleteTown(String t) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    towns.remove(t);
    await sharedPreferences.setStringList(keyList, towns);
    getSharedPref();
  }
}
