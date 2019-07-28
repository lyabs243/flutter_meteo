import 'package:flutter/material.dart';

void main() => runApp(MyApp());

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
  List<String> towns = ['Lubumbashi','Kinshasa','Kisangani'];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
                  title: textWithStyle('Current Town'),
                  onTap: (){
                    setState(() {
                      town = null;
                    });
                    Navigator.pop(context);
                  },
                );
              }
              else {
                return new ListTile(
                  title: textWithStyle(towns[i-2]),
                  onTap: () {
                    setState(() {
                      town = towns[i-2];
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
      body: Center(
        child: new Text(
          (town!= null)? town : 'Current Town',
          textScaleFactor: 3.0,
        ),
      ),
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
                Navigator.pop(buildContext);
              },
            ),
          ],
        );
      },
    );
  }
}
