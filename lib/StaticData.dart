import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/Data-Class/CategoriesDataClass.dart';

class StaticData {
  static List<CategoriesData> categoryList = <CategoriesData>[];
  static List<CategoriesData> iconOnlyList = <CategoriesData>[];
  static int cartQuantity = 0;

  // region Cart Function
  /// Get cart quantity
  int getCartQuantity() {
    int tempQuantity = 0;
    if (cartQuantity > 0) {
      tempQuantity = cartQuantity;
    }
    return tempQuantity;
  }

  /// Update Cart quantity
  Future<void> updateCartQuantity(
    User? firebaseUser,
    FirebaseFirestore firestore,
  ) async {
    if (firebaseUser != null) {
      /// Get User All Branch Cart
      QuerySnapshot cartSnapshot;
      cartSnapshot = await firestore
          .collection('Cart')
          .where("User_ID", isEqualTo: firebaseUser.uid)
          .get();

      if (cartSnapshot.docs.length > 0) {
        int tempQuantity = 0;

        /// Define Temp Map Data
        Map<String, dynamic>? cartSnapshotMapData = Map<String, dynamic>();

        /// Get each branch cart quantity
        for (int i = 0; i < cartSnapshot.docs.length; ++i) {
          /// Assign Data
          cartSnapshotMapData =
              cartSnapshot.docs[i].data() as Map<String, dynamic>;
          tempQuantity += cartSnapshotMapData["Qty"] as int;
        }

        cartQuantity = tempQuantity;
      } else {
        cartQuantity = 0;
      }

      /// Updated Page
      // _cartPageKey.currentState.refresh();
    } else {
      print("*** User is NULL");
    }
  }
  // endregion
}
