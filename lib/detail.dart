import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
class Detail extends StatefulWidget {
  final String data;
  final int eid;
  const Detail({Key? key, required this.eid,required this.data}) : super(key: key);

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  @override
  void initState() {
    // this is called when the class is initialized or called for the first time
    super.initState();
    checkuser(widget.data);
  }
  Future checkuser(String uid)async{
    final String id =
    await FirebaseAuth.instance.currentUser!.getIdToken(false);
    final http.Response response = await http.post(
      Uri.parse('https://ktf-backend.herokuapp.com/admin/check-in'),
      headers: <String, String>{
        "Authorization": "Bearer $id",
        "content-type": "application/json"
      },
      body: jsonEncode(<String,dynamic>{
        "uid": uid,
        "eventID": widget.eid,
      }),
    );
    if (response.statusCode == 200) {
      print(response.statusCode);
      print(response.body);
      Fluttertoast.showToast(msg: response.body.substring(12,response.body.length-2),toastLength: Toast
          .LENGTH_LONG,
          gravity:
          ToastGravity.SNACKBAR,
          fontSize: 17,
          backgroundColor: Colors.black,
          textColor: Colors.white);
      throw Exception("Added successfully");
    } else {
      // If the server did not return a "200 OK response",
      // then throw an exception.
      print(response.statusCode);
      print(response.body);
      throw Exception('Failed to check');
    }
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        title: Text("Check-in",style: GoogleFonts.sora(color: Colors.white,fontSize: 16),),
        centerTitle: true,
        backgroundColor: Colors.black,
        actions: [],
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: [
        Text("${widget.eid}",style: GoogleFonts.sora(fontSize: 16),),
        Text(widget.data,style: GoogleFonts.sora(fontSize: 16),),
      ],),
    ));
  }
}
