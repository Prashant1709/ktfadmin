import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ktfadmin/Home.dart';
class LogIn extends StatefulWidget {
  const LogIn({Key? key}) : super(key: key);

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final _auth = FirebaseAuth.instance;
  final firestoreInstance = FirebaseFirestore.instance;
  String email="";
  String pass="";
  bool _passwordVisible = false;
  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.black54,
      content: Row(
        children: [
          const CircularProgressIndicator(
            color: Colors.white,
          ),
          Container(
              margin: const EdgeInsets.only(left: 17),
              child: Text(
                "Loading...",
                style: GoogleFonts.sora(
                  color: Colors.white,
                ),
              )),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  var now=DateTime.now();
/*void checkroute(){
  firestoreInstance.collection('Users').snapshots().listen((event) {
    for (var i in event.docs) {
      if (i.id != _auth.currentUser?.uid){
        firestoreInstance.collection('Users').doc('${_auth.currentUser?.uid}').set(
            {
              'created':now,
              'counter':0,
              'lat':0,
              'long':0,
            }).whenComplete(() => Navigator.push(context, MaterialPageRoute(builder: (BuildContext bs)=>const Home())));
      }
      else{
        Navigator.push(context, MaterialPageRoute(builder: (BuildContext bs)=>const Home()));
      }
    }
  });

}*/
  Future<bool> _onWillPop() async {
    return (await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Do you want to exit an App'),
        actions: <Widget>[
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(false), //<-- SEE HERE
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(), // <-- SEE HERE
            child: const Text('Yes'),
          ),
        ],
      ),
    )) ??
        false;
  }
  double h(double height) {
    return MediaQuery.of(context).size.height * height;
  }

  double w(double width) {
    return MediaQuery.of(context).size.width * width;
  }
  @override
    Widget build(BuildContext context) {
      return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          body: Stack(
            children: [
              Container(
                height: h(1),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/background.png"),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  child: GlassContainer.frostedGlass(
                    height: h(0.7),
                    width: w(0.79),
                    borderRadius: BorderRadius.circular(50),
                    borderColor: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Container(
                            height: h(0.2),
                            width: w(0.48),
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage("assets/msc logo.png"),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(5)),
                          height: MediaQuery.of(context).size.height * 0.06,
                          width: MediaQuery.of(context).size.width * 0.7,
                          padding:const EdgeInsets.only(left: 4),
                          child: TextFormField(
                            style: const TextStyle(fontSize: 18, color: Colors.white),
                            cursorColor: Colors.white,
                            keyboardType: TextInputType.name,
                            decoration: const InputDecoration(
                                icon: Icon(Icons.mail,color: Colors.white,),
                                border: InputBorder.none,
                                hintText: "Email ID",
                                hintStyle: TextStyle(color: Colors.white)),
                            onChanged: (value)=>email=value,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(5)),
                          height: MediaQuery.of(context).size.height * 0.06,
                          width: MediaQuery.of(context).size.width * 0.7,
                          padding:const EdgeInsets.only(left: 4),
                          child: TextFormField(
                            style: const TextStyle(fontSize: 18, color: Colors.white),
                            cursorColor: Colors.white,
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                                icon: Icon(Icons.password,color: Colors.white,),
                                border: InputBorder.none,
                                hintText: "Password",
                                hintStyle: TextStyle(color: Colors.white),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _passwordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                              ),
                            ),
                            onChanged: (value)=>pass=value,
                            obscureText: !_passwordVisible,
                            obscuringCharacter: '*',
                          ),
                        ),
                        MaterialButton(onPressed: ()async{
                          try {
                            await FirebaseAuth.instance.signInWithEmailAndPassword(
                                email: email,
                                password: pass
                            ).then((value) => {
                              showLoaderDialog(context),
                            }).whenComplete(() => {
                              Navigator.push(context, MaterialPageRoute(builder: (BuildContext bs)=>const Home()))
                            });
                          } on FirebaseAuthException catch (e) {
                            showDialog(
                                context: context,
                                builder: (BuildContext b) {
                                  return AlertDialog(
                                    title: Text(
                                        "Login Failed due to ${e.message}"),
                                  );
                                });
                            //print(e.message);
                          }
                        },color: Colors.white,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),child: Text("Login",style: GoogleFonts.sora(color: Colors.black,fontSize: 16),),),
                        TextButton(onPressed: (){
                          showDialog(context: context, builder: (BuildContext bs)=>AlertDialog(backgroundColor: Colors.black54,
                            title: Text("Reset Password",style: GoogleFonts.sora(color: Colors.white,fontSize: 16),),
                            content: SizedBox(
                              height: h(0.15),
                              child: Column(children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text("Enter email to proceed!",style: GoogleFonts.sora(color: Colors.white,fontSize: 15),),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.white),
                                        borderRadius: BorderRadius.circular(5)),
                                    height: MediaQuery.of(context).size.height * 0.06,
                                    width: MediaQuery.of(context).size.width * 0.7,
                                    padding:const EdgeInsets.only(left: 4),
                                    child: TextFormField(
                                      style: const TextStyle(fontSize: 18, color: Colors.white),
                                      cursorColor: Colors.white,
                                      keyboardType: TextInputType.name,
                                      decoration: const InputDecoration(
                                          icon: Icon(Icons.mail,color: Colors.white,),
                                          border: InputBorder.none,
                                          hintText: "Email ID",
                                          hintStyle: TextStyle(color: Colors.white)),
                                      onChanged: (value)=>email=value,
                                    ),
                                  ),
                                ),
                              ],),
                            ),
                            actions: [
                              TextButton(onPressed: (){
                                try {FirebaseAuth.instance.sendPasswordResetEmail(email: email)
                                  .then((value) => {
                                    showLoaderDialog(context),
                                Navigator.pop(context),
                                  }).whenComplete(() => Fluttertoast.showToast(msg: "Reset mail sent"));
                                } on FirebaseAuthException catch (e) {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext b) {
                                        return AlertDialog(
                                          title: Text(
                                              "Reset Failed due to ${e.message}"),
                                        );
                                      });
                                  //print(e.message);
                                }
                              }, child: Text("Reset",style: GoogleFonts.sora(color: Colors.white,fontSize: 15),)),
                              TextButton(onPressed: (){
                                Navigator.pop(context);
                              }, child: Text("Cancel",style: GoogleFonts.sora(color: Colors.white,fontSize: 15),))
                            ],
                          ));
                        }, child:Text("Forgot Password!",style: GoogleFonts.sora(color: Colors.white,fontSize: 14),))
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
}