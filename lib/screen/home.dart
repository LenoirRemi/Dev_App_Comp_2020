import 'package:flutter/material.dart';
import 'package:client/utils/utils.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<String> _uuid;
  Future<String> _i;
  Future<String> _tempID;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await deleteAll();
    await manageUUID();
    setState(() {
      _uuid = getUUID();
      _i = getI();
      _tempID = getLastTempID();
    });
  }

  updateTempID() async {
    await nextTempID();
    setState(() {
      _i = getI();
      _tempID = getLastTempID();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("CovidAPP"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FutureBuilder(
                future: _uuid,
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      "UUID : " + snapshot.data.toString(),
                      style: TextStyle(fontSize: 20.0),
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
              Divider(),
              FutureBuilder(
                future: _i,
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.hasData) {
                    return Text("I : " + snapshot.data.toString(),
                        style: TextStyle(fontSize: 20.0));
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
              FutureBuilder(
                future: _tempID,
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.hasData) {
                    return Text("ID temporaire : " + snapshot.data,
                        style: TextStyle(fontSize: 20.0));
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
              Divider(),
              RaisedButton(
                onPressed: () => updateTempID(),
                child: Text("Generer ID temporaire"),
              ),
            ],
          ),
        ));
  }
}
