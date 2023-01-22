import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';


void main() {
  runApp(GeolocatorWidget());
}

/// Example [Widget] showing the functionalities of the geolocator plugin
class GeolocatorWidget extends StatefulWidget {

  @override
  _GeolocatorWidgetState createState() => _GeolocatorWidgetState();
}

class _GeolocatorWidgetState extends State<GeolocatorWidget> {
  final List<_PositionItem> _positionItems = <_PositionItem>[];
  late StreamSubscription<Position> _positionStreamSubscription;

  bool _isListening() => !(_positionStreamSubscription == null ||
      _positionStreamSubscription.isPaused);

  Color _determineButtonColor() {
    return _isListening() ? Colors.green : Colors.red;
  }

  void _toggleListening() {
    if (_positionStreamSubscription == null) {
      final positionStream = Geolocator.getPositionStream();
      _positionStreamSubscription = positionStream.handleError((error) {
        _positionStreamSubscription.cancel();
        // _positionStreamSubscription = null;
      }).listen((position) => setState(() => _positionItems.add(
          _PositionItem(_PositionItemType.position, position.toString()))));
      _positionStreamSubscription.pause();
    }

    setState(() {
      if (_positionStreamSubscription.isPaused) {
        _positionStreamSubscription.resume();
      } else {
        _positionStreamSubscription.pause();
      }
    });
  }

  @override
  void dispose() {
    if (_positionStreamSubscription != null) {
      _positionStreamSubscription.cancel();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              Text("Hi"),
              
              Expanded(
                child: ListView.builder(
                  itemCount: _positionItems.length,
                  itemBuilder: (context, index) {
                    final positionItem = _positionItems[index];

                    if (positionItem.type == _PositionItemType.permission) {
                      return ListTile(
                        title: Text(positionItem.displayValue,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            )),
                      );
                    } else {
                      return Card(
                        child: ListTile(
                          tileColor: Colors.grey,
                          title: Text(
                            positionItem.displayValue,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Stack(
          children: <Widget>[
            /// Get Last Known Position
            Positioned(
              bottom: 80.0,
              right: 10.0,
              child: FloatingActionButton.extended(
                onPressed: () async {
                  await Geolocator.getLastKnownPosition().then((value) => {
                    _positionItems.add(_PositionItem(
                        _PositionItemType.position, value.toString()))
                  });

                  setState(
                        () {},
                  );
                },
                label: Text("getLastKnownPosition"),
              ),
            ),

            /// Get Position Stream
            Positioned(
              bottom: 150.0,
              right: 10.0,
              child: FloatingActionButton.extended(
                onPressed: _toggleListening,
                label: Text(() {
                  if (_positionStreamSubscription == null) {
                    return "getPositionStream = null";
                  } else {
                    return "getPositionStream ="
                        " ${_positionStreamSubscription.isPaused ? "off" : "on"}";
                  }
                }()),
                backgroundColor: _determineButtonColor(),
              ),
            ),

            /// Clear position
            Positioned(
              bottom: 220.0,
              right: 10.0,
              child: FloatingActionButton.extended(
                onPressed: () => setState(_positionItems.clear),
                label: Text("clear positions"),
              ),
            ),

            /// Check Permission Status
            Positioned(
              bottom: 290.0,
              right: 10.0,
              child: FloatingActionButton.extended(
                onPressed: () async {
                  await Geolocator.checkPermission().then((value) => {
                    _positionItems.add(_PositionItem(
                        _PositionItemType.permission, value.toString()))
                  });
                  setState(() {});
                },
                label: Text("getPermissionStatus"),
              ),
            ),

            /// Get Current position
            Positioned(
              bottom: 10.0,
              right: 10.0,
              child: FloatingActionButton.extended(
                  onPressed: () async {
                    await Geolocator.getCurrentPosition().then((value) => {
                      _positionItems.add(_PositionItem(
                          _PositionItemType.position, value.toString()))
                    });

                    setState(
                          () {},
                    );
                  },
                  label: Text("getCurrentPosition")),
            ),
          ],
        ),
      ),
    );
  }
}

enum _PositionItemType {
  permission,
  position,
}

class _PositionItem {
  _PositionItem(this.type, this.displayValue);

  final _PositionItemType type;
  final String displayValue;
}