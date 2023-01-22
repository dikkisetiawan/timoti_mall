import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:timoti_project/Custom-UI/Custom-RoundedInputField.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'package:timoti_project/Functions/Messager.dart';
import 'package:timoti_project/Screen-Size/Get-Device-Details.dart';
import 'package:timoti_project/Screen-Size/WidgetSizeCalculation.dart';
import 'package:timoti_project/Screen-Size/ui-utils.dart';
import 'package:timoti_project/enums/device-screen-type.dart';

class UpdateProfilePage extends StatefulWidget {
  static const routeName = '/UpdateProfile';
  @override
  State<StatefulWidget> createState() {
    return _UpdateProfilePageState();
  }
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  bool _loading = false;
  TextEditingController _fullNameController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String messageString = "";
  Color colorValue = Colors.black;

  bool _fullNameError = false;

  String usernameString = '';

  /// For image
  var _picker = ImagePicker();
  var imageBase64;
  var finalImage;
  var previousImage;

  String previousName = '';

  String emailErrorMessageString = '';
  String profilePicURL = '';

  User firebaseUser = FirebaseAuth.instance.currentUser as User;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    imageCache?.clear();

    if (this.mounted) {
      _loading = true;
      setState(() {});
    }

    print(firebaseUser.displayName);
    print(firebaseUser.uid);

    if (this.mounted) {
      _loading = false;
      setState(() {});
    }
    getUserData();

    super.initState();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    imageBase64 = null;
    finalImage = null;
    previousImage = null;
    super.dispose();
  }

  // region UI
  /// Background Image
  Widget getBGUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    return Container(
      height: _widgetSize.getResponsiveHeight(0.25, 0.25, 0.25),
      width: _widgetSize.getResponsiveWidth(1, 1, 1),
      color: Theme.of(context).highlightColor,
      // image: AssetImage('assets/icon/walletbg.jpg'),
      // fit: BoxFit.cover,
    );
    // return Image(
    //   height: _widgetSize.getResponsiveHeight(0.25, 0.25, 0.25),
    //   width: _widgetSize.getResponsiveWidth(1, 1, 1),
    //   image: AssetImage('assets/icon/walletbg.jpg'),
    //   fit: BoxFit.cover,
    // );
  }

  Widget customBorder(
    TextEditingController controller,
    String labelText,
    bool verification,
    String errorText,
    bool hiddenInput,
    DeviceDetails _deviceDetails,
    bool pinpoint,
    String hintText,
    bool isNumeric,
  ) {
    return TextField(
      controller: controller,
      keyboardType: isNumeric == true ? TextInputType.number : null,
      inputFormatters: isNumeric == true
          ? <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(18),
            ]
          : <TextInputFormatter>[
              LengthLimitingTextInputFormatter(20),
            ],
      style: TextStyle(
          fontSize: _deviceDetails.getNormalFontSize(),
          height: 2.0,
          color: Colors.white),
      cursorColor: Theme.of(context).primaryColor,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        labelText: verification ? null : labelText,
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey,
          fontSize: _deviceDetails.getNormalFontSize(),
        ),
        labelStyle: TextStyle(
          color: Colors.white,
          fontSize: _deviceDetails.getNormalFontSize(),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: new BorderSide(color: Colors.white),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: new BorderSide(color: Colors.white),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: new BorderSide(color: Colors.white),
        ),
        errorText: verification ? errorText : null,
        errorStyle: TextStyle(
            color: Colors.red,
            fontSize: _deviceDetails.getNormalFontSize(),
            fontWeight: FontWeight.w800),
      ),
      obscureText: hiddenInput,
    );
  }

  /// Show UI
  Widget showUpdateProfileUI(
    BuildContext context,
  ) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);

    var mediaQuery = MediaQuery.of(context);

    return SizedBox(
      width: _widgetSize.getResponsiveWidth(0.8, 0.8, 0.8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Full Name
          customRoundedBorder(
            _fullNameController,
            "Your Name",
            _fullNameError,
            messageString,
            false,
            _deviceDetails,
            _widgetSize,
            'Full Name',
            null,
          ),

          /// Spacing
          SizedBox(
            height: getDeviceType(mediaQuery) == DeviceScreenType.Mobile
                ? _widgetSize.getResponsiveHeight(0.02, 0.02, 0.02)
                : _widgetSize.getResponsiveHeight(0.05, 0.05, 0.05),
          ),

          /// Submit Button
          Center(
            child: SizedBox(
              width: _widgetSize.getResponsiveWidth(0.35, 0.35, 0.35),
              height: _widgetSize.getResponsiveHeight(0.07, 0.07, 0.07),
              child: TextButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.all(
                      Theme.of(context).highlightColor),
                  elevation: MaterialStateProperty.all(5),
                  shadowColor: MaterialStateProperty.all(
                      Theme.of(context).highlightColor),
                ),
                onPressed: () {
                  setState(() {
                    if (validate() == true) {
                      updateProfile(_deviceDetails);
                    }
                  });
                },
                child: Text(
                  "Save Profile",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: _deviceDetails.getNormalFontSize(),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getProfilePictureUI(
    WidgetSizeCalculation _widgetSize,
    DeviceDetails _deviceDetails,
  ) {
    return Column(
      children: [
        /// Profile picture
        SizedBox(
          width: _widgetSize.getResponsiveWidth(0.3, 0.3, 0.3),
          height: _widgetSize.getResponsiveWidth(0.3, 0.3, 0.3),
          child: Stack(
            children: [
              /// White background
              ClipOval(
                child: Container(
                  width: _widgetSize.getResponsiveWidth(0.3, 0.3, 0.3),
                  height: _widgetSize.getResponsiveWidth(0.3, 0.3, 0.3),
                  color: Colors.white,
                ),
              ),

              /// Default Picture
              if (profilePicURL == '')
                Center(
                  child: Container(
                    width: _widgetSize.getResponsiveWidth(0.27, 0.27, 0.27),
                    height: _widgetSize.getResponsiveWidth(0.27, 0.27, 0.27),
                    child: ClipOval(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: finalImage != null
                            ? Image.memory(finalImage)
                            : Image.asset('assets/icon/defaultPic.png'),
                      ),
                    ),
                  ),
                ),

              /// Actual
              if (profilePicURL != '')
                Center(
                  child: Container(
                    width: _widgetSize.getResponsiveWidth(0.27, 0.27, 0.27),
                    height: _widgetSize.getResponsiveWidth(0.27, 0.27, 0.27),
                    child: ClipOval(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: CachedNetworkImage(
                          imageUrl: profilePicURL,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),

              // /// Camera icon
              // Align(
              //   alignment: Alignment.bottomRight,
              //   child: InkWell(
              //     onTap: () {
              //       getProfileImage();
              //     },
              //     child: Container(
              //       width: _widgetSize.getResponsiveWidth(0.1),
              //       height: _widgetSize.getResponsiveWidth(0.1),
              //       decoration: BoxDecoration(
              //           color: Theme.of(context).accentColor,
              //           borderRadius: BorderRadius.circular(50)),
              //       child: Center(
              //         child: Icon(
              //           Icons.camera_alt,
              //           color: Colors.white,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ],
    );
  }
  // endregion

  // region Function
  /// Get User Data
  Future<void> getUserData() async {
    if (this.mounted) {
      _loading = true;
      setState(() {});
    }

    if (firebaseUser == null) {
      if (this.mounted) {
        _loading = false;
        setState(() {});
      }
      return;
    }
    DocumentSnapshot data =
        await firestore.collection('Customers').doc(firebaseUser.uid).get();

    if (this.mounted) {
      /// Define Map Data
      Map<String, dynamic> cusData = Map<String, dynamic>();

      /// Assign Data
      cusData = data.data() as Map<String, dynamic>;

      _fullNameController.text = cusData["Full_Name"];
      previousName = cusData["Full_Name"];
      profilePicURL = cusData["Profile_Pic"];
      _loading = false;
      setState(() {});
    }
  }

  Future<void> updateProfile(DeviceDetails _deviceDetails) async {
    if (this.mounted) {
      _loading = true;
      setState(() {});
    }
    await firestore.collection('Customers').doc(firebaseUser.uid).update({
      "Full_Name": _fullNameController.text,
    }).then((value) {
      if (this.mounted) {
        firebaseUser.updateDisplayName(_fullNameController.text);
        previousName = _fullNameController.text;
        _loading = false;
        setState(() {});

        showMessage(
          '',
          "Updated Full Name",
          _deviceDetails,
          context,
        );
      }
    });
  }

  /// Validate the form
  bool validate() {
    bool temp = false;
    if (_fullNameController.text.isEmpty) {
      _fullNameError = true;
      messageString = 'Full Name Cannot Be Empty';
    } else if (_fullNameController.text == previousName) {
      _fullNameError = true;
      messageString = "Your current name is the same as previous name";
    } else {
      _fullNameError = false;
      temp = true;
    }
    return temp;
  }

  /// Get profile image
  Future<void> getProfileImage() async {
    PickedFile? image = await _picker.getImage(source: ImageSource.gallery);
    final imageBytes = await image?.readAsBytes();
    if (imageBytes != null) {
      setState(() {
        imageBase64 = base64Encode(imageBytes);
        print(imageBase64);
        finalImage = imageBytes;
      });
    }
  }

  String convertToImage(
    String imgExtension,
    String base64Data,
  ) {
    String finalImageData =
        "data:image/" + imgExtension + ";base64," + base64Data;
    return finalImageData.split(',').last;
  }
// endregion

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);

    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios_sharp,
            color: Theme.of(context).primaryColor,
            size: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          ),
        ),
        title: Text(
          "Edit Profile",
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        shadowColor: Colors.grey,
        elevation: 3,
      ),
      body: ModalProgressHUD(
        opacity: 0.5,
        color: Theme.of(context).highlightColor,
        inAsyncCall: _loading,
        progressIndicator: SpinKitFoldingCube(color: Colors.white),
        child: SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
              maxWidth: MediaQuery.of(context).size.width,
            ),
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Stack(
                children: [
                  Column(
                    children: getPageContent(
                      context,
                      _deviceDetails,
                      _widgetSize,
                    ),
                  ),

                  /// Profile Image
                  Positioned(
                    child: getProfilePictureUI(_widgetSize, _deviceDetails),
                    top: _widgetSize.getResponsiveHeight(0.12, 0.12, 0.12),
                    left: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                    right: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                  ),
                ],
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
    List<Widget> pageContent = [];

    /// Background image
    pageContent.add(getBGUI(_deviceDetails, _widgetSize));

    /// Spacing
    pageContent.add(
      SizedBox(
        height: _widgetSize.getResponsiveHeight(0.1, 0.1, 0.1),
      ),
    );

    /// Profile Details UI
    pageContent.add(showUpdateProfileUI(context));

    /// Spacing
    pageContent.add(
      SizedBox(
        height: _widgetSize.getResponsiveHeight(0.05, 0.05, 0.05),
      ),
    );

    return pageContent;
  }
}
