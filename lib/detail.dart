import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ticket_widget/ticket_widget.dart';
import 'package:google_fonts/google_fonts.dart';
class Detail extends StatefulWidget {
  final String ename;
  final String desc;
  final String date;
  final int eid;
  final int price;
  final String data;
  const Detail({Key ?key, required this.eid, required this.ename, required this.date, required this.desc,required this.price,required this.data}) : super(key: key);

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  @override
  void initState() {
    // this is called when the class is initialized or called for the first time
    super.initState();
    checkuser(widget.data);
    //checkin(widget.data);
  }
  Future checkuser(String uid)async{
    final String id =
    await FirebaseAuth.instance.currentUser!.getIdToken(false);
    final http.Response response = await http.post(
      Uri.parse('https://ktf-backend.herokuapp.com/admin/check'),
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
      Fluttertoast.showToast(msg: response.body.substring(12,response.body.length-2),
          toastLength: Toast.LENGTH_LONG,
          gravity:
          ToastGravity.SNACKBAR,
          fontSize: 17,
          backgroundColor: Colors.black,
          textColor: Colors.white);
      throw Exception('Failed to check');
    }
  }
  Future checkin()async{
    final String id =
    await FirebaseAuth.instance.currentUser!.getIdToken(false);
    final http.Response response = await http.post(
      Uri.parse('https://ktf-backend.herokuapp.com/admin/check-in'),
      headers: <String, String>{
        "Authorization": "Bearer $id",
        "content-type": "application/json"
      },
      body: jsonEncode(<String,dynamic>{
        "uid": widget.data,
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

      throw Exception("Checked in successfully");
    } else {
      print(response.statusCode);
      print(response.body);
      // If the server did not return a "200 OK response",
      // then throw an exception.
      Fluttertoast.showToast(msg: response.body.substring(12,response.body.length-2),
          toastLength: Toast.LENGTH_LONG,
          gravity:
          ToastGravity.SNACKBAR,
          fontSize: 17,
          backgroundColor: Colors.black,
          textColor: Colors.white);
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
        Center(
          child: TicketWidget(
            color:Colors.teal,
            width: 350,
            height: 500,
            isCornerRounded: true,
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 120.0,
                      height: 25.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0),
                        border: Border.all(width: 1.0, color: Colors.white),
                      ),
                      child: Center(
                        child: Text(
                          'Digital Ticket',
                          style: GoogleFonts.sora(color: Colors.white,fontSize: 14),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                            'KTF',
                            style: GoogleFonts.sora(color: Colors.white,fontSize: 17,fontWeight: FontWeight.bold)
                        ),
                      ],
                    )
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: Text(
                    widget.ename,
                    style: GoogleFonts.sora(color:Colors.white,fontSize: 32 ),
                  ),
                ),
                SizedBox(height: 20,),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text("Event ID",style: GoogleFonts.sora(color: Colors.grey.shade300,fontSize: 18),),
                        ),
                        Text("${widget.eid}",style: GoogleFonts.sora(color: Colors.white,fontSize: 18),),
                      ],
                    ),
                    SizedBox(width: 5,),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text("Price",style: GoogleFonts.sora(color: Colors.grey.shade300,fontSize: 18),),
                        ),
                        Text("₹ ${widget.price}",style: GoogleFonts.sora(color: Colors.white,fontSize: 18),),
                      ],
                    ),
                    SizedBox(width: 7,),
                  ],
                ),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text("Status",style: GoogleFonts.sora(color: Colors.grey.shade300,fontSize: 18),),
                        ),
                        Text("Paid",style: GoogleFonts.sora(color: Colors.white,fontSize: 18),),
                      ],
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text("Location",style: GoogleFonts.sora(color: Colors.grey.shade300,fontSize: 18),),
                        ),
                        Text("KSOM",style: GoogleFonts.sora(color: Colors.white,fontSize: 18),),
                      ],
                    ),
                  ],
                ),
                Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text("Date",style: GoogleFonts.sora(color: Colors.grey.shade300,fontSize: 18),),
                      ),
                      Text(widget.date,style: GoogleFonts.sora(color: Colors.white,fontSize: 18),),
                    ],
                  ),
                ),
                Divider(color: Colors.grey.shade300,thickness: 1,),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: [
                  MaterialButton(onPressed: (){
                    checkin();
                  },color: Colors.white,child: Row(
                    children: [
                      const Icon(Icons.check,color: Colors.teal,),
                      Text("Check-In",style: GoogleFonts.sora(fontSize: 20,color: Colors.teal),),
                    ],
                  ),)
                ],)
              ],
            ),
          ),
        ),
      ],),
    ));
  }
}
