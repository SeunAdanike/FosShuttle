import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:fluttershuttle/widgets/main_drawer.dart';

import 'package:linked_scroll_controller/linked_scroll_controller.dart';

class ScheduleTable extends StatefulWidget {
  String userName;
  ScheduleTable({@required this.userName});
  static const routeName = '/EstimationTable';
  @override
  _ScheduleTableState createState() => _ScheduleTableState(userName);
}

class _ScheduleTableState extends State<ScheduleTable> {
  int switcher;
  String _userName;
  _ScheduleTableState(this._userName);

  LinkedScrollControllerGroup _scrollControllerGroup;
  ScrollController _shuttleScrollController;
  ScrollController _busStopScrollController;

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return Container(
      height: 43,
      width: MediaQuery.of(context).size.width * 0.3,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        semanticContainer: true,
        elevation: 5.0,
        color: Colors.deepPurple,
        child: FittedBox(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                document['busStop'],
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Map driverDetails = Map();
  String shuttleType;

  getDriverID() async {
    Firestore.instance
        .collection('drivers')
        .where('ShuttleType', isEqualTo: '$shuttleType')
        .snapshots()
        .listen((event) {
      for (int i = 0; i < event.documents.length; i++) {
        driverDetails.update(event.documents[i].documentID,
            (value) => event.documents[i].data['Name'],
            ifAbsent: () => event.documents[i].data['Name']);
      }
    });
  }

  @override
  void initState() {
    shuttleType = 'SpaceWagon';
    _scrollControllerGroup = LinkedScrollControllerGroup();
    _shuttleScrollController = _scrollControllerGroup.addAndGet();
    _busStopScrollController = _scrollControllerGroup.addAndGet();
    getDriverID();
    switcher = 0;
    super.initState();
  }

  @override
  void dispose() {
    _shuttleScrollController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map keyArrays = Map();
    return Scaffold(
      drawer: MainDrawer(
        userName: _userName,
      ),
      appBar: AppBar(
        title: Text('Estimated Time in minutes'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.83,
            child: Row(
              children: <Widget>[
                Expanded(
                    child: Card(
                  child: StreamBuilder(
                    stream:
                        Firestore.instance.collection('busStops').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return Container(
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            height: 40,
                            width: MediaQuery.of(context).size.width * 0.45,
                            child: Center(
                              child: FittedBox(
                                child: Text(
                                  'Shuttles',
                                  style: TextStyle(fontSize: 28),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 40,
                            width: MediaQuery.of(context).size.width * 0.45,
                            child: Card(
                              color: Colors.grey,
                              child: Container(
                                child: FittedBox(
                                  child: Center(
                                    child: Text(
                                      'BusStops',
                                      style: TextStyle(
                                        fontSize: 23,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                              child: Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: ListView.builder(
                              controller: _busStopScrollController,
                              itemCount: snapshot.data.documents.length,
                              itemBuilder: (context, index) => _buildListItem(
                                  context, snapshot.data.documents[index]),
                            ),
                          ))
                        ],
                      );
                    },
                  ),
                )),
                Expanded(
                  child: Card(
                    child: StreamBuilder<Object>(
                      stream:
                          Firestore.instance.collection('timing').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return Container(
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        QuerySnapshot event = snapshot.data;
                        for (int i = 0; i < event.documents.length; i++) {
                          if (driverDetails.isNotEmpty &&
                              driverDetails
                                  .containsKey(event.documents[i].documentID)) {
                            var driverName =
                                driverDetails[event.documents[i].documentID];
                            keyArrays.update(driverName,
                                (value) => event.documents[i].data.values,
                                ifAbsent: () => event.documents[i].data.values);
                          }
                        }
                        List itValues = keyArrays.values.toList();
                        List itkeys = keyArrays.keys.toList();

                        var mapping = Map.fromIterables(itkeys, itValues);

                        return mapping.isEmpty
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Container(
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  Container(
                                    child: Center(
                                      child: Text(
                                        'There is current no driver',
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.45,
                                    height: 40,
                                    child: FittedBox(
                                      child: Center(
                                        child: Text(
                                          '$shuttleType Drivers',
                                          style: TextStyle(fontSize: 28),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                      physics: ClampingScrollPhysics(),
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: mapping.length,
                                      itemBuilder: (context, index) {
                                        List firebaseTime = [];
                                        var key = mapping.keys.elementAt(index);
                                        return Column(children: <Widget>[
                                          Container(
                                            height: 40,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.45,
                                            child: Card(
                                              color: Colors.grey,
                                              child: FittedBox(
                                                child: Center(
                                                  child: Text(
                                                    '$key',
                                                    style: TextStyle(
                                                        fontSize: 23,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: ListView.builder(
                                                shrinkWrap: true,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: 1,
                                                itemBuilder: (ctx, counter) {
                                                  return Container(
                                                    height: 300,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.4,
                                                    child: ListView.builder(
                                                        itemCount:
                                                            mapping[key].length,
                                                        shrinkWrap: true,
                                                        controller:
                                                            _shuttleScrollController,
                                                        itemBuilder:
                                                            (context, count) {
                                                          if (!firebaseTime
                                                                  .contains(mapping[
                                                                          key]
                                                                      .toList()) &&
                                                              (firebaseTime
                                                                      .length <
                                                                  2)) {
                                                            firebaseTime =
                                                                mapping[key]
                                                                    .toList();
                                                          }

                                                          return Container(
                                                            width: 0.3,
                                                            child: Card(
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            30.0),
                                                              ),
                                                              semanticContainer:
                                                                  true,
                                                              elevation: 5.0,
                                                              color: Colors
                                                                  .deepPurple,
                                                              child: Center(
                                                                child: Text(
                                                                  (firebaseTime[
                                                                          count])
                                                                      .toStringAsFixed(
                                                                          2),
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        30,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        }),
                                                  );
                                                }),
                                          ),
                                        ]);
                                      },
                                    ),
                                  )
                                ],
                              );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FloatingActionButton(
                  heroTag: null,
                  onPressed: () {
                    setState(() {
                      shuttleType = 'Car';
                      driverDetails.clear();
                      getDriverID();
                    });
                  },
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  backgroundColor: Colors.blueGrey,
                  child: const Icon(
                    Icons.directions_car,
                    size: 35,
                  ),
                ),
                FloatingActionButton(
                  heroTag: null,
                  onPressed: () {
                    setState(() {
                      shuttleType = 'Bus(Coaster)';
                      driverDetails.clear();
                      getDriverID();
                    });
                  },
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  backgroundColor: Colors.blueGrey,
                  child: const Icon(
                    Icons.directions_bus,
                    size: 35,
                  ),
                ),
                FloatingActionButton(
                  heroTag: null,
                  onPressed: () {
                    setState(() {
                      shuttleType = 'Bus(Hiace)';
                      getDriverID();
                      driverDetails.clear();
                    });
                  },
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  backgroundColor: Colors.blueGrey,
                  child: const Icon(
                    Icons.directions_transit,
                    size: 35,
                  ),
                ),
                FloatingActionButton(
                  heroTag: null,
                  onPressed: () {
                    setState(() {
                      shuttleType = 'SpaceWagon';
                      getDriverID();
                      driverDetails.clear();
                    });
                  },
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  backgroundColor: Colors.blueGrey,
                  child: const Icon(
                    Icons.airport_shuttle,
                    size: 35,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
