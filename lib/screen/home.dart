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
  bool _emulate = false;
  bool _risk = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    // await deleteAll();
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

  emulateReception() {
    setState(() {
      _emulate = true;
      _risk = compareAllHash();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("CovidAPP"),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
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
              Divider(),
              RaisedButton(
                onPressed: () => emulateReception(),
                child: Text("Emuler la reception de clés"),
              ),
              Divider(),
              Center(child: _emulate ? TableCle() : Container()),
              _emulate ? Divider() : Container(),
              Center(child: _emulate ? TableCompare() : Container()),
              _emulate ? Divider() : Container(),
              _emulate
                  ? Center(
                      child: _risk
                          ? Text(
                              "Le téléphone a été en contacte avec une/des personne contaminée.",
                              style: TextStyle(fontSize: 20.0))
                          : Text(
                              "Le téléphone n'a pas été en contacte avec une/des personne contaminée.",
                              style: TextStyle(fontSize: 20.0)))
                  : Container(),
              SizedBox(
                height: 50.0,
              )
            ],
          ),
        ));
  }
}

class TableCle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<TableRow> rows = <TableRow>[
      new TableRow(children: <Widget>[
        Text(
          "Clés reçues du serveur",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.0,
          ),
        )
      ])
    ];

    for (String cle in EMULATED_BACKEND_LIST) {
      rows.add(new TableRow(
        children: [
          Text(
            cle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.0),
          )
        ],
      ));
    }

    return Table(border: TableBorder.all(color: Colors.black), children: rows);
  }
}

class TableCompare extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<TableRow> rows = <TableRow>[
      new TableRow(children: <Widget>[
        Text(
          "i reçus",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.0),
        ),
        Text(
          "ID reçus",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.0),
        ),
        Text(
          "ID calculés",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.0),
        )
      ])
    ];

    var meet = false;
    var res = "";
    for (final y in EMULATED_BACKEND_LIST) {
      for (final z in EMULATED_BLUETOOTH_MEETINGS) {
        meet = false;
        res = generateTempID(z["i"].toString(), y);
        if (z["hash"] == res) {
          meet = true;
        }
        rows.add(new TableRow(
          children: [
            Text(
              z["i"].toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: meet ? FontWeight.bold : FontWeight.normal),
            ),
            Text(
              z["hash"].toString().substring(0, 12) + "...",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: meet ? FontWeight.bold : FontWeight.normal),
            ),
            Text(
              res.toString().substring(0, 12) + "...",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: meet ? FontWeight.bold : FontWeight.normal),
            ),
          ],
        ));
      }
      rows.add(new TableRow(
        children: [Text(""), Container(), Container()],
      ));
    }
    rows.removeLast();
    return Table(border: TableBorder.all(color: Colors.black), children: rows);
  }
}
