import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:page_admin/DoctorCard.dart';
import 'package:page_admin/pages/Feedbacks.dart';
import 'package:page_admin/pages/Widgets/Doctors.dart';

import 'MyClipper.dart';

class AdminPage extends StatefulWidget {
  AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  Uint8List webImage = Uint8List(8);
  bool imageAvailable = false;
  TextEditingController catController = TextEditingController();
  Future<void> pickImage() async {
    /*final image = await ImagePickerWeb.getImageAsBytes();
    setState(() {
      imageFile= image!;
      imageAvailable=true;
    });*/
    if (kIsWeb) {
      setState(() async {
        final ImagePicker _picker = ImagePicker();
        XFile? image = await _picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          var f = await image.readAsBytes();
          webImage = f;
          imageAvailable = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var doctorsRef = FirebaseFirestore.instance
        .collection("Docuser")
        .where("isAccepted", isEqualTo: false)
        .snapshots();

    final double h = MediaQuery.of(context).size.height;
    final double w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        /*leading: Transform.translate(offset: Offset(h*1.112,0),
        child: Image.asset('assets/img/LogoWhite.png', height:h*0.8 ,width: w*0.8,)),*/
        toolbarHeight: h * 0.15,
        titleSpacing: w * 0.2,
        backgroundColor: Colors.indigoAccent,
        title: Row(
          children: [
            Text(
              'Admin',
              style: TextStyle(fontSize: h * 0.036, fontFamily: 'Montserrat'),
            ),
            Image.asset(
              'assets/img/LogoWhite.png',
              height: h * 0.08,
              width: w * 0.08,
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Row(
                          children: [
                            Image.asset(
                              'assets/img/stethoscope.png',
                              height: h * 0.05,
                              width: w * 0.05,
                            ),
                            Text(
                              'Add category',
                              style: TextStyle(fontFamily: 'Montserrat'),
                            ),
                          ],
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        actions: [
                          TextField(controller: catController,
                              decoration: InputDecoration(
                                  labelText: "Name of category",
                                  //labelStyle: TextStyle(color: Colors.black54),

                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        width: 1, color: Colors.black26),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        width: 1, color: Colors.black45),
                                    borderRadius: BorderRadius.circular(30),
                                  ))),
                          SizedBox(
                            height: h * 0.04,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: w * 0.01,
                              ),
                              Text(
                                'Add an image',
                                style: TextStyle(fontFamily: 'Montserrat'),
                              ),
                              SizedBox(
                                width: w * 0.05,
                              ),
                              IconButton(
                                onPressed: () {
                                  pickImage();
                                  print(webImage);
                                  print(
                                      '-------------------------------------------------------------------');
                                },
                                icon: Icon(Icons.add_photo_alternate_outlined),
                                color: Colors.indigoAccent,
                              ),
                              SizedBox(
                                width: w * 0.05,
                              ),
                              ClipOval(
                                child: imageAvailable == false
                                    ? null
                                    : Image.memory(
                                        webImage!,
                                        height: h * 0.1,
                                      ),
                                clipper: MyClipper(),
                              )
                            ],
                          ),
                          SizedBox(
                            height: h * 0.04,
                          ),
                          Center(
                              child: ElevatedButton(
                            onPressed: () {uploadNewCate();},
                            child: Text(
                              'Confirm',
                              style: TextStyle(fontFamily: 'Montserrat'),
                            ),
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ))),
                          ))
                        ],
                      ));
            },
            icon: Icon(Icons.add_circle),
            color: Colors.white,
            iconSize: h * 0.07,
          ),
          SizedBox(width: w * 0.13),
          IconButton(
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => Feedbacks())),
            icon: Icon(Icons.feedback_rounded),
            color: Colors.white,
            iconSize: h * 0.07,
          ),
          SizedBox(width: w * 0.135),
        ],
      ),
      body: ListView(
        children: [
          Container(
            height: h * 0.33,
            color: Colors.black12,
            child: Row(
              children: [
                SizedBox(width: w * 0.15),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Find your doctor',
                      style: TextStyle(
                          fontFamily: 'Montserrat', fontSize: h * 0.055),
                    ),
                    Text(
                      'With one click',
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: h * 0.03,
                          color: Colors.indigoAccent),
                    ),
                  ],
                ),
                SizedBox(width: w * 0.3),
                Image.asset('assets/img/pngwing.com.png')
              ],
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: doctorsRef,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent:
                        MediaQuery.of(context).size.width * 0.33,
                    childAspectRatio: 3 / 2,
                    //mainAxisSpacing: MediaQuery.of(context).size.height*0.5,
                  ),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemCount:
                      snapshot.data!.docs.length, //how many doctors in the list
                  itemBuilder: (context, index) {
                    //the input list of doctors
                    return DoctorCard(
                        doc: Doctor(
                      "Dr. " +
                          "${snapshot.data!.docs[index]['firstname']}" +
                          " " +
                          "${snapshot.data!.docs[index]['lastname']}",
                      "${snapshot.data!.docs[index]['phone']}",
                      "${snapshot.data!.docs[index]['specialité']}",
                      "${snapshot.data!.docs[index]['wilaya']}",
                      snapshot.data!.docs[index]['picture'],
                      snapshot.data!.docs[index]['owner'],
                      snapshot.data!.docs[index]['email'],
                    ));
                  },
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          )
        ],
      ),
    );
  }
  PlatformFile? pickedFile;
  UploadTask? uploadTask;
  uploadNewCate() async {
    try {
      var path = 'admin/${webImage}';
      var file = File('$webImage');
      final ref = FirebaseStorage.instance.ref().child(path);
      uploadTask = ref.putFile(file);
      final snapshot = await uploadTask!.whenComplete(() {});
      // The link to the profil image ///////////////////////////////////////////////
      final urldownload = await snapshot.ref.getDownloadURL();
      //////////////////////////////////////---------------------URL --------------------------////////////////////////////////////
      print('Download Link of the profil image: $urldownload');

      await FirebaseFirestore.instance
          .collection('Specialities')
          .add({'spec': catController.text, 'specpicture': urldownload});
    } catch (e) {
      print(e);
      print('/*/*/*/*/*/*/*/');
    }
  }
}
