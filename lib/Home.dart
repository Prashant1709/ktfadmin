import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ktfadmin/logIn.dart';
import 'package:ktfadmin/scanner.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}
class Eve {
  final String? name;
  final String? desct;
  final String? date;
  final int? eid;
  final int? price;
  final String? imgurl;
  const Eve({
    required this.name,
    required this.date,
    required this.desct,
    required this.eid,
    required this.imgurl,
    required this.price,
  });
  factory Eve.fromJson(Map<String, dynamic> json) {
    return Eve(
      name: json['name'],
      date: json['eventDate'],
      eid: json['eventID'],
      price: json['price'],
      imgurl: json['imageURL'],
      desct: json['description'],
    );
  }
}
class _HomeState extends State<Home> {
  final firestoreInstance = FirebaseFirestore.instance;
  @override
  void initState() {
    // this is called when the class is initialized or called for the first time
    super.initState();
    Future.delayed(const Duration(seconds: 0)).then((e) async {
      eventd = await fetchDat();
    });
    getdat();
    getloc();
  }
  String code="";
  double discount=0.8;
  String type="";
  int count=0;
  String desc="";
  List<Map<String, dynamic>> user=[];
  late List<Map<String, dynamic>> eventd;
  Future<List<Map<String, dynamic>>> fetchDat() async {
    List<Map<String, dynamic>> events = [];

    final response = await http.get(
      Uri.parse('https://ktf-backend.herokuapp.com/data/events'),
      headers: <String, String>{"content-type": "application/json"},
    );
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      for (var i in jsonDecode(response.body)) {
        events.add({
          "name": Eve.fromJson(i).name,
          "date": Eve.fromJson(i).date,
          "desc": Eve.fromJson(i).desct,
          "imgurl": Eve.fromJson(i).imgurl,
          "price": Eve.fromJson(i).price,
          "eid": Eve.fromJson(i).eid,
        });
      }
      return events;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load data json');
    }
  }
  Future addcoup(String cd,double dis,String type,String desc)async{
    final String id =
    await FirebaseAuth.instance.currentUser!.getIdToken(false);
    final http.Response response = await http.post(
      Uri.parse('https://ktf-backend.herokuapp.com/admin/add-coupons'),
      headers: <String, String>{
        "Authorization": "Bearer $id",
        "content-type": "application/json"
      },
      body: jsonEncode(<String,dynamic>{
        "code": cd,
        "discount": dis,
        "type": type,
        "description": desc
      }),
    );
    if (response.statusCode == 200) {
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
      throw Exception('Failed to add coupon.');
    }
  }
  Future<void> getdat() async {
    firestoreInstance.collection('Users').snapshots().listen((event) {
      for (var i in event.docs) {
        if (i.id != FirebaseAuth.instance.currentUser?.uid) {
          user.add({
            "Name":i.get('Name'),
            "lat":i.get('lat'),
            "lon":i.get('lon'),
            "speed":i.get('speed'),
            "count":i.get('count')
          });
        }
      }
    });
  }
  Future<void> getloc() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    //location.enableBackgroundMode(enable: true);
    locationData = await location.getLocation();
    double? lat=locationData.latitude;
    double? lon=locationData.longitude;
    double? speed=locationData.speed;
    firestoreInstance.collection("Users").doc(FirebaseAuth.instance.currentUser!.uid).update({
      "lat":lat,
      "lon":lon,
      "speed":speed,
    });
  }
  launchURL(String homeLat,String homeLng) async {
    final String googleMapslocationUrl = "https://www.google.com/maps/search/?api=1&query=$homeLat,$homeLng";
    final String encodedURl = Uri.encodeFull(googleMapslocationUrl);
    if (await canLaunch(encodedURl)) {
      await launch(encodedURl);
    } else {
      throw 'Could not launch $encodedURl';
    }
  }
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
  @override
  Widget build(BuildContext context) {
    double h(double height) {
      return MediaQuery.of(context).size.height * height;
    }

    double w(double width) {
      return MediaQuery.of(context).size.width * width;
    }
    return WillPopScope(onWillPop: _onWillPop, child: DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(
                child: Text("Events"),
              ),
              Tab(
                child: Text("Coupon"),
              ),
              Tab(
                child: Text("My Counter"),
              ),
            ],
            indicatorColor: Colors.white,
          ),
          backgroundColor: Colors.black,
          title: Text("Home",style: GoogleFonts.sora(color: Colors.white),),
          centerTitle: true,
          actions: [
            IconButton(onPressed: (){
              FirebaseAuth.instance.signOut().whenComplete(() => Navigator.push(context, MaterialPageRoute(builder: (BuildContext bs)=>const LogIn())));
            }, icon:const Icon(Icons.logout,color: Colors.white,))
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(onPressed: (){
          showModalBottomSheet(isScrollControlled: true,isDismissible: true,backgroundColor: Colors.black,context: context, builder: (BuildContext bs)=>SingleChildScrollView(child: StreamBuilder<QuerySnapshot>(
            stream: firestoreInstance.collection("Users").snapshots(),
            builder: (context, snapshot) {
              return SizedBox(height: h(0.9),
                child: ListView.builder(itemBuilder: (context,index)=>
                ListTile(
                  leading:const Icon(Icons.person,color: Colors.teal,),
                  title: Text(user[index]['Name']),
                  tileColor: Colors.white,
                  subtitle: Text(user[index]['speed'].toString()),
                  trailing: IconButton(onPressed: (){
                    launchURL(user[index]['lat'].toString(), user[index]['lon'].toString());
                  },icon:const Icon(Icons.location_on,color: Colors.teal,),),
                )
                ),
              );
            }
          )));
        },
        backgroundColor: Colors.grey,child: const Icon(
          Icons.location_on,
          color: Colors.white,
        ),
        ),
        bottomNavigationBar: BottomAppBar(
            color: Colors.black,
            shape:const CircularNotchedRectangle(), //shape of notch
            notchMargin:
            5, //notch margin between floating button and bottom appbar
            child: SizedBox(
              height: h(0.078),
              child: Row(
                //children inside bottom appbar
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                    icon:const Icon(
                      Icons.home,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext bs) =>const Home()));
                    },
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  IconButton(
                    icon:const Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                    onPressed: () {
                    },
                  ),
                ],
              ),
            )),
        body: SafeArea(child: TabBarView(
          children: [
            SingleChildScrollView(
              child:SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: FutureBuilder(
                    future: fetchDat(),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.black,),
                        );
                      } else {
                        if (snap.hasError) {
                          return Text(snap.error.toString());
                        } else {
                          final events = snap.data as List<Map<String, dynamic>>;

                          return ListView.builder(
                            itemBuilder: (context, position) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  onTap:(){
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                        builder: (context) => Scanner(eid: events[position]['eid'],
                                          ename: events[position]['name'],
                                          date: events[position]['date'],
                                          desc: events[position]['desc'],
                                          price:events[position]['price'],
                                        ),
                                    ));
                                  },
                                  tileColor: Colors.black,
                                  title: Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: AutoSizeText(
                                      "${events[position]['name']}",
                                      style: GoogleFonts.sora(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 21),
                                    ),
                                  ),
                                  subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: AutoSizeText(
                                          "${events[position]['desc']}",
                                          style: GoogleFonts.sora(
                                              color: Colors.white, fontSize: 14),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: AutoSizeText(
                                          "${events[position]['date']}",
                                          style: GoogleFonts.sora(
                                              color: Colors.white, fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            itemCount: events.length,
                          );
                        }
                      }
                    }),
              ),
            ),
            SingleChildScrollView(
              child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(padding: const EdgeInsets.all(10.0),child:
                  Text("Add new coupon",style: GoogleFonts.sora(color: Colors.black,fontSize: 23),),),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(5)),
                    height: MediaQuery.of(context).size.height * 0.06,
                    width: MediaQuery.of(context).size.width * 0.7,
                    padding:const EdgeInsets.only(left: 4),
                    child: TextFormField(
                      style: const TextStyle(fontSize: 18, color: Colors.black),
                      cursorColor: Colors.black,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                          icon: Icon(Icons.code,color: Colors.black,),
                          border: InputBorder.none,
                          hintText: "Coupon code",
                          hintStyle: TextStyle(color: Colors.grey)),
                      onChanged: (value)=>code=value,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(5)),
                    height: MediaQuery.of(context).size.height * 0.06,
                    width: MediaQuery.of(context).size.width * 0.7,
                    padding:const EdgeInsets.only(left: 4),
                    child: TextFormField(
                      style: const TextStyle(fontSize: 18, color: Colors.black),
                      cursorColor: Colors.black,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                          icon: Icon(Icons.description,color: Colors.black,),
                          border: InputBorder.none,
                          hintText: "Description",
                          hintStyle: TextStyle(color: Colors.grey)),
                      onChanged: (value)=>desc=value,
                    ),
                  ),
                ),
                MaterialButton(onPressed: (){
                  addcoup(code, 0.8, "Campus Ambassador", desc);
                },color: Colors.black,child: Text("Add",style: GoogleFonts.sora(color: Colors.white),),),
              ],
              ),
            ),
            SingleChildScrollView(child: Column(mainAxisAlignment: MainAxisAlignment.center,
              children:  [
                StreamBuilder<QuerySnapshot>(
                  stream: firestoreInstance.collection('Users').snapshots(),
                  builder: (context, snapshot) {
                    return Center(
                      child:Text("Your Counter is  0",style: GoogleFonts.sora(fontSize: 28),),
                    );
                  }
                ),
              ],
            ),),
          ],
        )),
      ),
    ));
  }
}
