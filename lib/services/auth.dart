import 'package:brew_creww/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:brew_creww/models/user.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  //create a user object based on FirebaseUser
  AppUser? _userFromFirebaseUser(User? user){
    return  user != null ? AppUser(uid: user.uid): null;
  }

  //auth change user stream
  Stream <AppUser?> get user{
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  // sign in anon
  Future signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // sign in with email and password
  Future signInWithEmailAndPassword(String email, String password) async{
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }


  // register with email and password
  Future registerWithEmailAndPassword(String email, String password) async{
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      //create a new document for the user with the uid
      if (user != null) {
        // Printing the email only if the user object is not null
        print('User email: ${user.email}');
        await DatabaseService(uid: user.uid).updateUserData('0', 'new crew member', 100);
        print('User data updated successfully!');
      } else {
        print('User is null');
      }
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // sign out
  Future <void>signOut() async{
    try{
      return await _auth.signOut();
    }catch(e){
      print(e.toString());
      //return null;
    }
  }
}