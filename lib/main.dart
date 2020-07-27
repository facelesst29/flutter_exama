import 'dart:async';
import 'dart:convert';
import 'dart:js';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';


void main() {
  ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
  connectionStatus.initialize();
  runApp(new MaterialApp(
    home: new HomePage(),
  ));
}

class ConnectionStatusSingleton {
  //This creates the single instance by calling the `_internal` constructor specified below
  static final ConnectionStatusSingleton _singleton = new ConnectionStatusSingleton._internal();
  ConnectionStatusSingleton._internal();

  //This is what's used to retrieve the instance through the app
  static ConnectionStatusSingleton getInstance() => _singleton;

  //This tracks the current connection status
  bool hasConnection = false;

  //This is how we'll allow subscribing to connection changes
  StreamController connectionChangeController = new StreamController.broadcast();

  //flutter_connectivity
  final ConnectionStatusSingleton _connectivity = ConnectionStatusSingleton._internal();

  //Hook into flutter_connectivity's Stream to listen for changes
  //And check the connection status out of the gate
  void initialize() {
    _connectivity.checkConnection();
    checkConnection();
  }

  Stream get connectionChange => connectionChangeController.stream;

  //A clean up method to close our StreamController
  //   Because this is meant to exist through the entire application life cycle this isn't
  //   really an issue
  void dispose() {
    connectionChangeController.close();
  }

  //flutter_connectivity's listener
  void _connectionChange(ConnectionStatusSingleton result) {
    checkConnection();
  }

  //The test to actually see if there is a connection
  Future<bool> checkConnection() async {
    bool previousConnection = hasConnection;

    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        hasConnection = true;
      } else {
        hasConnection = false;
      }
    } on SocketException catch(_) {
      hasConnection = false;
    }

    //The connection status changed send out an update to all listeners
    if (previousConnection != hasConnection) {
      connectionChangeController.add(hasConnection);
    }

    return hasConnection;
  }
}

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => new HomePageState();


}

class HomePageState extends State<HomePage> {

  List data;



  Future<String> getData() async {
    var response = await http.get(
        Uri.encodeFull("https://api.musixmatch.com/ws/1.1/chart.tracks.get?apikey=2d782bc7a52a41ba2fc1ef05b9cf40d7"),
        headers: {
          "Accept": "application/json"
        }
    );

    this.setState(() {
      data = json.decode(response.body);
    });
    print(data[1]["Track_ID"]);

    return "Success!";
  }

  @override
  void initState() {
    super.initState();
    this.getData();
    {
      // ignore: unnecessary_statements
      Navigator.push( context, MaterialPageRoute(builder: (context) => SecondRoute()),
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
  }
class SecondRoute extends StatefulWidget {
  @override
  SecondRouteState createState() => new SecondRouteState();


}


  class SecondRouteState extends State<SecondRoute> {
    List data;

    @override
    Future<String> getDat() async {
      var response = await http.get(
          Uri.encodeFull(
              "https://api.musixmatch.com/ws/1.1/track.get?track_id=TRACK_ID&apikey=2d782bc7a52a41ba2fc1ef05b9cf40d7"),
          headers: {
            "Accept": "application/json"
          }
      );

      this.setState(() {
        data = json.decode(response.body);
      });

      @override
      Widget build(BuildContext context) {
        return new Scaffold(
          appBar: new AppBar(
            title: new Text("Trending"),
          ),
          body: new ListView.builder(
            itemCount: data == null ? 0 : data.length,
            itemBuilder: (BuildContext context, int Track_ID) {
              return new Card(
                child: new Text(data[Track_ID]["Trending"]),
              );
            },
          ),
        );
      };
    }

    Future<String> getDt() async {
      var response = await http.get(
          Uri.encodeFull(
              "https://api.musixmatch.com/ws/1.1/track.lyrics.get?track_id=TRACK_ID&apikey=2d782bc7a52a41ba2fc1ef05b9cf40d7"),
          headers: {
            "Accept": "application/json"
          }
      );

      this.setState(() {
        data = json.decode(response.body);
      });


      Widget build(BuildContext context) {
        return new Scaffold(
            appBar: new AppBar(
              title: new Text("Trending"),
            ),
            body: new ListView.builder(
              itemCount: data == null ? 0 : data.length,
              itemBuilder: (BuildContext context, int Track_ID) {
                return new Card(
                  child: new Text(data[Track_ID]["Trending"]),

                );
              },
            )
        );
      };
      onPressed() {
        Navigator.pop(context);
      }
    }


    @override
    State<StatefulWidget> createState() {
      // TODO: implement createState
      throw UnimplementedError();
    }

    noSuchMethod(Invocation i) => super.noSuchMethod(i);
  }

