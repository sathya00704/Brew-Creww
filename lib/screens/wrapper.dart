import 'package:provider/provider.dart';
import 'authenticate/authenticate.dart';
import 'package:flutter/material.dart';
import 'home/home.dart';
import '/models/user.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<AppUser?>(context);
    print(user);


    //return either home or authenticate widget
    //return Authenticate();

    if(user == null){
      return Authenticate();
    }
    else{
      return Home();
    }
  }
}
