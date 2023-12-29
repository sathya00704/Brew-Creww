import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:brew_creww/models/user.dart';
import 'package:brew_creww/models/brew.dart';

class DatabaseService {
  final String uid;

  DatabaseService({required this.uid});

  final CollectionReference<Map<String, dynamic>> brewCollection =
    FirebaseFirestore.instance.collection('brews');

  Future<void> updateUserData(String sugars, String name, int strength) async {
    try {
      if (uid.isNotEmpty) {
        // Creating a document reference using the uid
        DocumentReference docRef = FirebaseFirestore.instance.collection('brews').doc(uid);

        // Using the docRef to update document data
        await docRef.set({
          'sugars': sugars,
          'name': name,
          'strength': strength,
        });
      } else {
        print('Error: Empty uid provided');
      }
    } catch (e) {
      print('Error updating user data: $e');
    }
  }


  List<Brew> _brewListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Brew(
          name: doc.get('name') ?? '',
          sugars: doc.get('sugars') ?? '0',
          strength: doc.get('strength') ?? 0,
      );
    }).toList();
  }

  // get brews stream
  Stream<List<Brew>> get brews {
    return brewCollection.snapshots()
        .map(_brewListFromSnapshot);
  }

  //userData from snapshot
  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
    print('data=$data');

    if (data == null) {
      // Handle null case or return a default value
      return UserData(uid: uid, name: '', sugars: '', strength: 0);
    }

    return UserData(
      uid: uid,
      name: data['name'] ?? '',
      sugars: data['sugars'] ?? '',
      strength: data['strength'] ?? 0,
    );
  }


  //get user doc stream
  Stream<UserData> get userData {
    return brewCollection.doc(uid).snapshots()
        .map(_userDataFromSnapshot);
  }

}