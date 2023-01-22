import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/Custom-UI/Custom-Ex-ListTile.dart';
import '/Custom-UI/Custom-LoadingUI.dart';
import '/Screen-Size/Get-Device-Details.dart';
import '/Screen-Size/WidgetSizeCalculation.dart';
import '/Screen-Size/ui-utils.dart';
import '/enums/device-screen-type.dart';
import '/main.dart';

class AppVersionPage extends StatefulWidget {
  static const routeName = '/AppVersion-Page';
  @override
  State<StatefulWidget> createState() {
    return _AppVersionPageState();
  }
}

class _AppVersionPageState extends State<AppVersionPage> {
  bool _loading = false;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<DocumentSnapshot> message = [];
  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 15;
  DocumentSnapshot? lastDocument;

  @override
  void initState() {
    getAppVersionData();
    super.initState();
  }

  @override
  void dispose() {
    lastDocument = null;
    super.dispose();
  }

  // region Function
  getAppVersionData() async {
    if (!hasMore) {
      print('No More Data');
      if (this.mounted) {
        setState(() {
          isLoading = false;
        });
      }
      return;
    }
    if (isLoading) {
      return;
    }

    /// Begin Here
    if (this.mounted) {
      setState(() {
        isLoading = true;
      });
    }

    QuerySnapshot querySnapshot;

    /// First Time Load
    if (lastDocument == null) {
      querySnapshot = await firestore
          .collection('AppVersion')
          .orderBy('Updated_Date', descending: true)
          .limit(documentLimit)
          .get();
    }

    /// Load more data
    else {
      querySnapshot = await firestore
          .collection('AppVersion')
          .orderBy('Updated_Date', descending: true)
          .startAfterDocument(lastDocument as DocumentSnapshot)
          .limit(documentLimit)
          .get();
      // print(1);
    }

    print('Length:' + querySnapshot.docs.length.toString());
    if (querySnapshot.docs.length == 0) {
      if (this.mounted) {
        setState(() {
          isLoading = false;
        });
      }
      return;
    }
    if (querySnapshot.docs.length < documentLimit) {
      hasMore = false;
    }

    /// Get last document
    lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
    message.addAll(querySnapshot.docs);
    if (this.mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
  // endregion

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);

    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          highlightColor: Colors.transparent,
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).primaryColor,
            size: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          ),
        ),
        title: Text(
          "App Version",
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        shadowColor: Colors.grey,
        elevation: 3,
      ),
      body: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
          ),
          child: Scrollbar(
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent) {
                  getAppVersionData();
                }
                return false;
              },
              child: SingleChildScrollView(
                // physics: BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: getPageContent(
                    context,
                    _deviceDetails,
                    _widgetSize,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }

  List<Widget> getPageContent(
    BuildContext context,
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    var mediaQuery = MediaQuery.of(context);

    List<Widget> pageContent = [];
    SizedBox _spacing = SizedBox(
      height: _widgetSize.getResponsiveHeight(0.01, 0.01, 0.01),
    );

    pageContent.add(_spacing);

    /// Define no event
    CustomExListTile noMessageListTile = new CustomExListTile(
      title: "No message",
      subTitle: "Your new message will appear here.",
      titleColor: Theme.of(context).primaryColor,
      subTitleColor: Theme.of(context).primaryColor,
      bgColor: Colors.transparent,
    );

    if (message.length > 0) {
      for (int i = 0; i < message.length; ++i) {
        Map<String, dynamic> data = message[i].data() as Map<String, dynamic>;

        if (data["Version"] != null) {
          pageContent.add(
            Ink(
              color: Colors.transparent,
              child: InkWell(
                // splashColor: Colors.grey,
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: Theme.of(context).backgroundColor,
                        elevation: 10,
                        scrollable: true,
                        title: data["Version"] == App.appVersion
                            ? Text(
                                "${data["Version"]} (Current Version)",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                ),
                              )
                            : Text(
                                data["Version"] != null
                                    ? data["Version"]
                                    : "Error",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                        content: Text(
                          data["Description"] != null
                              ? data["Description"]
                                  .toString()
                                  .replaceAll("\\n", "\n")
                              : "Error",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: Text(
                              "Ok",
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width:
                            getDeviceType(mediaQuery) == DeviceScreenType.Mobile
                                ? 0.6
                                : 3.0,
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                  ),
                  child: CustomExListTile(
                    maxLine: 1,
                    title: data["Version"] == App.appVersion
                        ? "${data["Version"]} (Current Version)"
                        : data["Version"] != null
                            ? data["Version"]
                            : "Error",
                    subTitle: data["Description"] != null
                        ? data["Description"].replaceAll("\\n", "\n")
                        : "Error",
                    titleColor: Theme.of(context).primaryColor,
                    subTitleColor: Theme.of(context).primaryColor,
                    bgColor: Theme.of(context).shadowColor,
                  ),
                ),
              ),
            ),
          );
        }
      }
    } else {
      pageContent.add(
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: getDeviceType(mediaQuery) == DeviceScreenType.Mobile
                    ? 0.6
                    : 3.0,
                color: Theme.of(context).shadowColor,
              ),
            ),
          ),
          child: noMessageListTile,
        ),
      );
    }

    if (_loading == true) {
      pageContent.add(CustomLoading());
    }
    return pageContent;
  }
}
