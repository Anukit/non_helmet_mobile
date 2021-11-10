import 'dart:io';

import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker/image_picker.dart';
import 'package:non_helmet_mobile/models/profile.dart';
import 'package:non_helmet_mobile/modules/service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfile extends StatefulWidget {
  EditProfile({Key? key}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final formKey = GlobalKey<FormState>();
  // Profile profiles = Profile();
  TextEditingController firstname = TextEditingController();
  TextEditingController lastname = TextEditingController();

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  void dispose() {
    firstname.dispose();
    lastname.dispose();
    super.dispose();
  }

  Future<void> getData() async {
    final prefs = await SharedPreferences.getInstance();
    int user_id = prefs.getInt('user_id') ?? 0;
    var result = await getDataUser(user_id);
    try {
      if (result.pass) {
        var listdata = result.data["data"][0];
        setState(() {
          firstname.text = listdata["firstname"];
          lastname.text = listdata["lastname"];
        });
      }
    } catch (e) {}
  }

  Future<void> getImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (image != null) {
        _image = File(image.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
        title: const Text(
          'แก้ไขข้อมูลส่วนตัว',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          //textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
            //physics: AlwaysScrollableScrollPhysics(),
            // padding: const EdgeInsets.symmetric(
            //   horizontal: 100.0,
            //   vertical: 24.0,
            // ),
            child: Center(
                child: Form(
                    key: formKey,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: <Widget>[
                          const SizedBox(height: 20.0),
                          buildShowPic(),
                          const SizedBox(height: 50.0),
                          buildFirstname(),
                          const SizedBox(height: 20.0),
                          buildLastname(),
                          const SizedBox(height: 50.0),
                          buildConfirm()
                        ],
                      ),
                    )))),
      ),
    );
  }

  Widget buildShowPic() {
    return SizedBox(
      height: 120,
      width: 120,
      child: Stack(
        //clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(72.0),
            // ignore: unnecessary_null_comparison
            child: _image == null
                ? const CircleAvatar()
                : Image.file(
                    _image!,
                    fit: BoxFit.cover,
                  ),
          ),
          Positioned(
              bottom: 0,
              right: -25,
              child: RawMaterialButton(
                onPressed: getImage,
                elevation: 2.0,
                fillColor: const Color(0xFFF5F6F9),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.black,
                ),
                padding: const EdgeInsets.all(1.0),
                shape: const CircleBorder(),
              )),
        ],
      ),
    );
  }

  Widget buildFirstname() {
    return TextFormField(
      controller: firstname,
      keyboardType: TextInputType.name,
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
        labelText: 'ชื่อ',
        labelStyle: TextStyle(fontSize: 18, color: Colors.grey.shade600),
        fillColor: Colors.white,
        // filled: true,
        errorStyle: const TextStyle(color: Colors.red, fontSize: 14),
        prefixIcon: const Icon(
          Icons.person,
          color: Colors.grey,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
      ),
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(context, errorText: "กรุณากรอกชื่อ"),
      ]),
      onSaved: (value) {
        firstname.text = value!;
      },
    );
  }

  Widget buildLastname() {
    return TextFormField(
      controller: lastname,
      keyboardType: TextInputType.name,
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
        labelText: 'นามสกุล',
        labelStyle: TextStyle(fontSize: 18, color: Colors.grey.shade600),
        fillColor: Colors.white,
        // filled: true,
        errorStyle: const TextStyle(color: Colors.red, fontSize: 14),
        prefixIcon: const Icon(
          Icons.person,
          color: Colors.grey,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
      ),
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(context, errorText: "กรุณากรอกนามสกุล"),
      ]),
      onSaved: (value) {
        lastname.text = value!;
      },
    );
  }

  Widget buildConfirm() {
    return Row(children: <Widget>[
      Expanded(
        child: MaterialButton(
          height: 45,
          highlightColor: Colors.red,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          color: Colors.amber,
          child: const Text(
            "บันทึกข้อมูล",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            formKey.currentState!.save();
            if (formKey.currentState!.validate()) {
              /* Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              ); */
            }
          },
        ),
      ),
    ]);
  }
}
