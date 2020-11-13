import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future<void> addUserInfo(userData, uid) async {
    Firestore.instance
        .collection("users")
        .document(uid)
        .setData(userData)
        .catchError((e) {
      print(
        e.toString(),
      );
    });
  }

  Future<void> sendMessage(message, uid) async {
    Firestore.instance
        .collection('messaging')
        .document(uid)
        .setData(message, merge: true)
        .catchError((e) {
      print(
        e.toString(),
      );
    });
  }

  Future<void> addDriverInfo(userData, uid) async {
    Firestore.instance
        .collection("drivers")
        .document(uid)
        .setData(userData)
        .catchError((e) {
      print(
        e.toString(),
      );
    });
  }

  deleteDocument(documentTodelete, uid) async {
    Firestore.instance
        .collection(documentTodelete)
        .document(uid)
        .delete()
        .catchError((e) {
      print(e.toString());
    });
  }

  Future<void> addSetAndOrders(userData, uid) async {
    Firestore.instance
        .collection('pickUpRequest')
        .document(uid)
        .setData(userData)
        .catchError((e) {
      print(
        e.toString(),
      );
    });
  }

  Future<void> addStudentInfo(userData, uid) async {
    Firestore.instance
        .collection("students")
        .document(uid)
        .setData(userData)
        .catchError((e) {
      print(
        e.toString(),
      );
    });
  }

  Future<void> addPickUpStatusInfo(userData, uid) async {
    Firestore.instance
        .collection("pickUpRequest")
        .document(uid)
        .setData(userData, merge: true)
        .catchError((e) {
      print(
        e.toString(),
      );
    });
  }

  Future<void> addStaffandFacultyInfo(userData, uid) async {
    Firestore.instance
        .collection("staff and faculty")
        .document(uid)
        .setData(userData)
        .catchError((e) {
      print(
        e.toString(),
      );
    });
  }

  deleteRequest(path, uid) async {
    Firestore.instance.collection(path).document(uid).delete().catchError((e) {
      print(e.toString());
    });
  }

  Future<void> addAdminInfo(userData, uid) async {
    Firestore.instance
        .collection("Administrator")
        .document(uid)
        .setData(userData)
        .catchError((e) {
      print(
        e.toString(),
      );
    });
  }


  getUsersById(path, id) async {
    return Firestore.instance
        .collection(path)
        .document(id)
        .get()
        .catchError((e) {
      print(e.toString());
    });
  }

  getUserInfo(String path, String username) async {
    return Firestore.instance
        .collection("users")
        .where(path, isEqualTo: username)
        .getDocuments()
        .catchError((e) {
      print(e.toString());
    });
  }

  updateEstimatedTime(locationdata, uid) async {
    await Firestore.instance
        .collection("timing")
        .document(uid)
        .setData(locationdata)
        .catchError((e) {
      print(e.toString());
    });
  }

  Future <void> updateUserLocation(locationdata, uid) async {
    await Firestore.instance
        .collection("trackData")
        .document(uid)
        .setData(locationdata)
        .catchError((e) {
      print(e.toString());
    });
  }
}
