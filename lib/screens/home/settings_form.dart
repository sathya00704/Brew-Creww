import 'package:brew_creww/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:brew_creww/services/database.dart';
import 'package:brew_creww/shared/constants.dart';
import 'package:brew_creww/models/user.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsForm extends StatefulWidget {
  const SettingsForm({Key? key}) : super(key: key);

  @override
  State<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  final _formKey = GlobalKey<FormState>();
  final List<String> sugars = ['0', '1', '2', '3', '4'];

  String? _currentName;
  String? _currentSugars;
  int? _currentStrength;

  @override
  Widget build(BuildContext context) {
    final User? user = Provider.of<User?>(context);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('brews').doc(user?.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          Map<String, dynamic>? userData = snapshot.data?.data();

          _currentName ??= userData?['name'];
          _currentSugars ??= userData?['sugars'];
          _currentStrength ??= userData?['strength'];

          return Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Text(
                  'Update your brew settings',
                  style: TextStyle(fontSize: 18.0),
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  initialValue: _currentName ?? '',
                  decoration: textInputDecoration.copyWith(hintText: 'Enter a name'),
                  validator: (val) => val?.isEmpty ?? true ? 'Please enter a name' : null,
                  onChanged: (val) => setState(() => _currentName = val),
                ),
                SizedBox(height: 20.0),
                DropdownButtonFormField(
                  decoration: textInputDecoration,
                  value: _currentSugars ?? sugars.first,
                  items: sugars.map((sugar) {
                    return DropdownMenuItem(
                      value: sugar,
                      child: Text('$sugar sugars'),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _currentSugars = val as String),
                ),
                SizedBox(height: 20.0),
                Slider(
                  value: _currentStrength?.toDouble() ?? 100.0, // Set a default value of 100.0
                  min: 100.0,
                  max: 900.0,
                  divisions: 8,
                  activeColor: Colors.brown[_currentStrength ?? 100],
                  inactiveColor: Colors.brown[100],
                  label: _currentStrength?.round().toString() ?? '100',
                  onChanged: (val) => setState(() => _currentStrength = val.round()),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink[400],
                  ),
                  child: Text(
                    'Update',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      final CollectionReference brewCollection = FirebaseFirestore.instance.collection('brews');

                      // Check if the user is logged in and get the user's uid
                      final User? currentUser = FirebaseAuth.instance.currentUser;
                      if (currentUser != null) {
                        final String uid = currentUser.uid;

                        // Update the Firestore document directly
                        try {
                          await brewCollection.doc(uid).update({
                            'sugars': _currentSugars!,
                            'name': _currentName!,
                            'strength': _currentStrength!,
                          });
                          Navigator.pop(context); // Close the form after successful update
                        } catch (e) {
                          print('Error updating user data: $e');
                          // Handle error accordingly
                        }
                      }
                    }
                  },
                ),
              ],
            ),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}



/*import 'package:brew_creww/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:brew_creww/services/database.dart';
import 'package:brew_creww/shared/constants.dart';
import 'package:brew_creww/models/user.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsForm extends StatefulWidget {
  const SettingsForm({Key? key}) : super(key: key);

  @override
  State<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  final _formKey = GlobalKey<FormState>();
  final List<String> sugars = ['0', '1', '2', '3', '4'];

  String? _currentName;
  String? _currentSugars;
  int? _currentStrength;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    return StreamBuilder<UserData?>(
      stream: user != null ? DatabaseService(uid: user.uid).userData : null,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData && snapshot.data != null) {
          UserData userData = snapshot.data!;

          _currentName ??= userData.name ?? '';
          _currentSugars ??= userData.sugars ?? '';
          _currentStrength ??= userData.strength ?? 0;
          return Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Text(
                  'Update your brew settings',
                  style: TextStyle(fontSize: 18.0),
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  initialValue: _currentName ?? '',
                  decoration: textInputDecoration,
                  validator: (val) => val?.isEmpty ?? true ? 'Please enter a name' : null,
                  onChanged: (val) => setState(() => _currentName = val),
                ),
                SizedBox(height: 20.0),
                DropdownButtonFormField(
                  decoration: textInputDecoration,
                  value: _currentSugars ?? '',
                  items: sugars.map((sugar) {
                    return DropdownMenuItem(
                      value: sugar,
                      child: Text('$sugar sugars'),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _currentSugars = val),
                ),
                Slider(
                  value: _currentStrength?.toDouble() ?? 100.0,
                  activeColor: Colors.brown[_currentStrength ?? 100],
                  inactiveColor: Colors.brown[_currentStrength ?? 100],
                  min: 100.0,
                  max: 900.0,
                  divisions: 8,
                  onChanged: (val) => setState(() => _currentStrength = val.round()),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink[400],
                  ),
                  child: Text(
                    'Update',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      await DatabaseService(uid: user!.uid).updateUserData(
                        _currentSugars ?? '',
                        _currentName ?? '',
                        _currentStrength ?? 0,
                      );
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          );
        } else {
          return Loading(); // or some other placeholder/widget
        }
      },
    );
  }
}*/

/*class SettingsForm extends StatefulWidget {
  const SettingsForm({Key? key}) : super(key: key);

  @override
  State<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  final _formKey = GlobalKey<FormState>();
  final List<String> sugars = ['0', '1', '2', '3', '4'];

  String _currentName = '';
  String _currentSugars = '';
  int _currentStrength = 0;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    return StreamBuilder<UserData?>(
      stream: user != null ? DatabaseService(uid: user.uid).userData : null,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData && snapshot.data != null) {
          UserData userData = snapshot.data!;

          _currentName ??= userData.name ?? '';
          _currentSugars ??= userData.sugars ?? '';
          _currentStrength ??= userData.strength ?? 0;

          return Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Text(
                  'Update your brew settings',
                  style: TextStyle(fontSize: 18.0),
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  initialValue: userData.name ?? '',
                  validator: (val) =>
                  val?.isEmpty ?? true ? 'Please enter a name' : null,
                  onChanged: (val) => setState(() => _currentName = val ?? ''),
                ),
                SizedBox(height: 20.0),
                DropdownButtonFormField(
                  value: _currentSugars.isNotEmpty
                      ? _currentSugars
                      : userData.sugars ?? '',
                  items: sugars.map((sugar) {
                    return DropdownMenuItem(
                      value: sugar,
                      child: Text('$sugar sugars'),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _currentSugars = val ?? ''),
                ),
                Slider(
                  value: _currentStrength.toDouble().clamp(100.0, 900.0),
                  onChanged: (val) =>
                      setState(() => _currentStrength = val.round()),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      await DatabaseService(uid: user!.uid).updateUserData(
                        _currentSugars,
                        _currentName,
                        _currentStrength,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Update'),
                ),
              ],
            ),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}*/


/*
import 'package:flutter/material.dart';
import 'package:brew_creww/shared/constants.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:brew_creww/models/user.dart';
import 'package:brew_creww/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsForm extends StatelessWidget {
  const SettingsForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    return StreamBuilder<UserData>(
      stream: user != null ? DatabaseService(uid: user.uid).userData : null,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Or any loading widget
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData && snapshot.data != null) {
          UserData userData = snapshot.data!;

          return _BuildForm(userData: userData);
        } else {
          return Text('No data available');
        }
      },
    );
  }
}

class _BuildForm extends StatefulWidget {
  final UserData userData;

  const _BuildForm({Key? key, required this.userData}) : super(key: key);

  @override
  __BuildFormState createState() => __BuildFormState();
}

class __BuildFormState extends State<_BuildForm> {
  final _formKey = GlobalKey<FormState>();
  final List<String> sugars = ['0', '1', '2', '3', '4'];

  late String _currentName;
  late String _currentSugars;
  late int _currentStrength;

  @override
  void initState() {
    super.initState();
    _currentName = widget.userData.name ?? ''; // Assign a default value if null
    _currentSugars = widget.userData.sugars ?? ''; // Assign a default value if null
    _currentStrength = widget.userData.strength ?? 100; // Assign a default value if null
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Text(
            'Update your brew settings',
            style: TextStyle(fontSize: 18.0),
          ),
          SizedBox(height: 20.0),
          TextFormField(
            initialValue: _currentName,
            decoration: textInputDecoration.copyWith(hintText: 'Enter your name'),
            validator: (val) => val?.isEmpty ?? true ? 'Please enter a name' : null,
            onChanged: (val) => setState(() => _currentName = val ?? ''),
          ),
          SizedBox(height: 20.0),
          DropdownButtonFormField(
            decoration: textInputDecoration,
            value: _currentSugars.isNotEmpty ? _currentSugars : null,
            items: sugars.map((sugar) {
              return DropdownMenuItem(
                value: sugar,
                child: Text('$sugar sugars'),
              );
            }).toList(),
            onChanged: (val) => setState(() => _currentSugars = val.toString()),
          ),
          SizedBox(height: 20.0),
          Slider(
            value: _currentStrength.toDouble().clamp(100.0, 900.0),
            activeColor: Colors.brown[_currentStrength],
            inactiveColor: Colors.brown[_currentStrength],
            min: 100.0,
            max: 900.0,
            divisions: 8,
            onChanged: (val) => setState(() => _currentStrength = val.round()),
          ),
          SizedBox(height: 20.0),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink[400],
            ),
            child: Text(
              'Update',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              // Implement your update logic here
              print(_currentName);
              print(_currentSugars);
              print(_currentStrength);
            },
          ),
        ],
      ),
    );
  }
}*/


/*
import 'package:flutter/material.dart';
import 'package:brew_creww/shared/constants.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsForm extends StatefulWidget {
  const SettingsForm({Key? key}) : super(key: key);

  @override
  State<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  final _formKey = GlobalKey<FormState>();
  final List<String> sugars = ['0', '1', '2', '3', '4'];

  late String _currentName;
  late String _currentSugars;
  late int _currentStrength;

  @override
  void initState() {
    super.initState();
    _currentName = '';
    _currentSugars = '';
    _currentStrength = 100; // Initializing the slider value
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = Provider.of<User?>(context, listen: false);
    if (user != null) {
      try {
        DocumentSnapshot userDataSnapshot =
        await FirebaseFirestore.instance.collection('brews').doc(user.uid).get();
        if (userDataSnapshot.exists) {
          Map<String, dynamic>? userData = userDataSnapshot.data() as Map<String, dynamic>?;

          setState(() {
            _currentName = userData?['name'] ?? 'New Crew Member';
            _currentSugars = userData?['sugars'] ?? '0';
            _currentStrength = userData?['strength'] ?? 100; // Update slider value
          });
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Text(
            'Update your brew settings',
            style: TextStyle(fontSize: 18.0),
          ),
          SizedBox(height: 20.0),
          TextFormField(
            initialValue: _currentName,
            decoration: textInputDecoration.copyWith(hintText: 'Enter your name'),
            validator: (val) => val?.isEmpty ?? true ? 'Please enter a name' : null,
            onChanged: (val) => setState(() => _currentName = val ?? ''),
          ),
          SizedBox(height: 20.0),
          DropdownButtonFormField(
            decoration: textInputDecoration,
            value: _currentSugars.isNotEmpty ? _currentSugars : null,
            items: sugars.map((sugar) {
              return DropdownMenuItem(
                value: sugar,
                child: Text('$sugar sugars'),
              );
            }).toList(),
            onChanged: (val) => setState(() => _currentSugars = val.toString()),
          ),
          SizedBox(height: 20.0),
          Slider(
            value: _currentStrength.toDouble().clamp(100.0, 900.0),
            activeColor: Colors.brown[_currentStrength],
            inactiveColor: Colors.brown[_currentStrength],
            min: 100.0,
            max: 900.0,
            divisions: 8,
            onChanged: (val) => setState(() => _currentStrength = val.round()),
          ),
          SizedBox(height: 20.0),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink[400],
            ),
            child: Text(
              'Update',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              // Implement your update logic here
              print(_currentName);
              print(_currentSugars);
              print(_currentStrength);
            },
          ),
        ],
      ),
    );
  }
}*/