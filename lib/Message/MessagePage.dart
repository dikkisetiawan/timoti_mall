import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:timoti_project/Custom-UI/Custom-Ex-ListTile.dart';
import 'package:timoti_project/Custom-UI/Custom-LoadingUI.dart';
import 'package:timoti_project/Screen-Size/Get-Device-Details.dart';
import 'package:timoti_project/Screen-Size/WidgetSizeCalculation.dart';
import 'package:timoti_project/Screen-Size/ui-utils.dart';
import 'package:timoti_project/enums/device-screen-type.dart';

class MessagePage extends StatefulWidget {
  static const routeName = '/Message-Page';
  @override
  State<StatefulWidget> createState() {
    return _MessagePageState();
  }
}

class _MessagePageState extends State<MessagePage> {
  bool _loading = false;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<DocumentSnapshot> message = [];

  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 15;
  DocumentSnapshot? lastDocument;

  @override
  void initState() {
    getMessageData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // region Function
  getMessageData() async {
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
          .collection('Message')
          .where("type", isEqualTo: 'notice')
          .where("visible", isEqualTo: true)
          .orderBy('date')
          .limit(documentLimit)
          .get();
    }

    /// Load more data
    else {
      querySnapshot = await firestore
          .collection('Message')
          .where("type", isEqualTo: 'notice')
          .where("visible", isEqualTo: true)
          .orderBy('date')
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
        title: Center(
          child: Text(
            "Message",
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
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
                  getMessageData();
                }
                return false;
              },
              child: SingleChildScrollView(
                // physics: BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children:
                      getPageContent(context, _deviceDetails, _widgetSize),
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
      bgColor: Theme.of(context).shadowColor,
    );

    if (message.length > 0) {
      for (int i = 0; i < message.length; ++i) {
        /// Assign Data
        Map<String, dynamic> messageMapData = message[i].data() as Map<String, dynamic>;

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
                      title: Text(
                        messageMapData["title"],
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      content: Text(
                        messageMapData["subtitle"],
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: Text(
                            "Ok",
                            style: TextStyle(
                              color: Colors.black,
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
                  title: messageMapData["title"],
                  subTitle: messageMapData["subtitle"],
                  titleColor: Theme.of(context).primaryColor,
                  subTitleColor: Theme.of(context).primaryColor,
                  bgColor: Theme.of(context).shadowColor,
                ),
              ),
            ),
          ),
        );
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
                color: Theme.of(context).dividerColor,
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
