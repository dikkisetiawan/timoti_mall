import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:timoti_project/Screen-Size/Get-Device-Details.dart';
import 'package:timoti_project/Screen-Size/WidgetSizeCalculation.dart';

class GoogleMapPage extends StatefulWidget {
  static const routeName = '/Map-Page';
  final LatLng? initLatLong;

  const GoogleMapPage({Key? key, this.initLatLong}) : super(key: key);

  @override
  State<GoogleMapPage> createState() => GoogleMapPageState();
}

class GoogleMapPageState extends State<GoogleMapPage> {
  late GoogleMapController _googleMapController;
  LatLng defaultLatLng = LatLng(37.42796133580664, -122.085749655962);

  /// Address
  String addressString = '';
  String targetAddressString = '';
  late Position userPosition;
  bool loading = false;

  @override
  void initState() {
    /// Todo Get User Position
    /// Get User Location
    // getUserPosition(false);
    super.initState();
  }

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  // region Function
  // Todo Get User Position without Geocoder
  // /// Get Current User Position
  // Future<void> getUserPosition(bool goCurrent) async {
  //   if (!mounted) {
  //     return;
  //   }
  //
  //   userPosition = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.best);
  //
  //   print("Latitude: " + userPosition.latitude.toString());
  //   print("Longitude: " + userPosition.longitude.toString());
  //
  //   final coordinates =
  //       Coordinates(userPosition.latitude, userPosition.longitude);
  //   var addresses =
  //       await Geocoder.local.findAddressesFromCoordinates(coordinates);
  //   Address targetAddress;
  //   targetAddress = addresses.first;
  //
  //   addressString = targetAddress.addressLine;
  //
  //   if (goCurrent == false) {
  //     /// If has predefine Lat & Long
  //     if (widget.initLatLong != null) {
  //       targetAddressString = addressString;
  //     }
  //   } else{
  //     goToCurrent();
  //   }
  //
  //   if (this.mounted) {
  //     if (addressString != '') {
  //       setState(() {});
  //     }
  //   }
  // }

  /// Go To Current Location
  Future<void> goToCurrent() async {
    _googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(userPosition.latitude, userPosition.longitude),
          zoom: 20.151926040649414,
        ),
      ),
    );
  }
  // endregion

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);
    double mapWidth = MediaQuery.of(context).size.width;
    double mapHeight = MediaQuery.of(context).size.height - 55;
    double iconSize = _widgetSize.getResponsiveWidth(0.12, 0.12, 0.12);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55),
        child: Material(
          elevation: 4,
          shadowColor: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    color: Theme.of(context).highlightColor,
                  ),
                  SafeArea(
                    minimum: EdgeInsets.fromLTRB(
                      _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                      0,
                      _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                      0,
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          /// Back Button
                          SizedBox(
                            width: _widgetSize.getResponsiveWidth(
                                0.06, 0.04, 0.06),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Icon(
                                      Icons.arrow_back_ios,
                                      color: Theme.of(context).backgroundColor,
                                    ),
                                  )),
                            ),
                          ),

                          /// Title Text
                          SizedBox(
                            width:
                                _widgetSize.getResponsiveWidth(0.7, 0.7, 0.7),
                            child: Text(
                              targetAddressString,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: _deviceDetails.getNormalFontSize(),
                                color: Theme.of(context).backgroundColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          /// Spacing
                          SizedBox(
                            width: _widgetSize.getResponsiveWidth(
                                0.05, 0.05, 0.05),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Stack(
            children: [
              /// Google Map and Marker
              Stack(
                children: [
                  /// Google Map
                  Container(
                    width: mapWidth,
                    height: mapHeight,
                    child: GoogleMap(
                      myLocationEnabled: true,
                      onCameraMove: (pos) {
                        if (!loading) {
                          targetAddressString = "Loading";
                          loading = true;
                          setState(() {});
                        }
                      },
                      onCameraIdle: () {
                        _googleMapController
                            .getLatLng(ScreenCoordinate(
                                x: MediaQuery.of(context).size.width.toInt(),
                                y: MediaQuery.of(context).size.height.toInt()))
                            .then((pos) async {
                          /// Todo Translate Coordinate to Address
                          // final coordinates =
                          //     Coordinates(pos.latitude, pos.longitude);
                          // var addresses = await Geocoder.local
                          //     .findAddressesFromCoordinates(coordinates);
                          // Address targetAddress;
                          // targetAddress = addresses.first;
                          //
                          // addressString = targetAddress.addressLine;
                          // targetAddressString = addressString;
                          // loading = false;
                          // setState(() {});
                        });
                      },
                      mapType: MapType.normal,
                      initialCameraPosition: CameraPosition(
                        target: widget.initLatLong != null
                            ? widget.initLatLong as LatLng
                            : defaultLatLng,
                        zoom: 14.4746,
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        _googleMapController = controller;
                      },
                    ),
                  ),

                  /// Marker
                  Positioned(
                    top: (mapHeight - 120) / 2,
                    right: (mapWidth - iconSize) / 2,
                    child: Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: iconSize,
                    ),
                  ),
                ],
              ),

              /// Current Location button
              Positioned(
                top: _widgetSize.getResponsiveHeight(0.03, 0.03, 0.03),
                right: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                child: Container(
                  width: _widgetSize.getResponsiveWidth(0.12, 0.12, 0.12),
                  height: _widgetSize.getResponsiveWidth(0.12, 0.12, 0.12),
                  child: InkWell(
                    onTap: () {
                      if (userPosition != null) {
                        goToCurrent();
                      } else {
                        /// Todo Get User Position
                        // getUserPosition(true);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(1, 2),
                          ),
                        ],
                        color: Theme.of(context).primaryColor,
                        // shape: BoxShape.circle,
                        borderRadius: BorderRadius.all(Radius.circular(40)),
                      ),
                      child: Icon(
                        Icons.my_location,
                        color: Theme.of(context).backgroundColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          /// Confirm Button
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Center(
              child: Container(
                width: _widgetSize.getResponsiveWidth(0.5, 0.5, 0.5),
                height: _widgetSize.getResponsiveHeight(0.07, 0.07, 0.07),
                decoration: BoxDecoration(
                  color: Theme.of(context).highlightColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Theme.of(context).highlightColor,
                          content: Text(
                            'Click Confirmed',
                            style: TextStyle(
                                color: Theme.of(context).backgroundColor,
                                fontWeight: FontWeight.bold),
                          ),
                          actions: [
                            TextButton(
                              child: Text("Ok",
                                  style: TextStyle(
                                    color: Theme.of(context).backgroundColor,
                                  )),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Center(
                    child: Text(
                      "Confirm",
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).backgroundColor,
                          fontSize: _deviceDetails.getNormalFontSize()),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
