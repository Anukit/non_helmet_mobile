import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:non_helmet_mobile/models/profile.dart';
import 'package:non_helmet_mobile/pages/homepage.dart';
import 'package:non_helmet_mobile/pages/register_page.dart';

class Login_Page extends StatefulWidget {
  Login_Page({Key? key}) : super(key: key);

  @override
  _Login_PageState createState() => _Login_PageState();
}

class _Login_PageState extends State<Login_Page> {
  bool _isObscure = true;
  final formKey = GlobalKey<FormState>();
  Profile profiles = Profile();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: SingleChildScrollView(
            child: Form(
          key: formKey,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 80),
                Image.asset(
                  'assets/images/logo.png',
                  scale: 7,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "Helmet",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Capture",
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    //color: Colors.grey.shade300,
                  ),
                  child: Column(
                    children: <Widget>[
                      buildInputEmail(),
                      const SizedBox(
                        height: 20,
                      ),
                      buildInputPassword(),
                      // const SizedBox(
                      //   height: 10,
                      // ),
                      buildForgetPasswordBtn(),
                      const SizedBox(
                        height: 20,
                      ),
                      buildSigninBtn(),
                      const SizedBox(
                        height: 50,
                      ),
                      buildSignupBtn()
                    ],
                  ),
                ),
              ],
            ),
          ),
        )),
      ),
    );
  }

  Widget buildInputEmail() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'อีเมลผู้ใช้',
        prefixIcon: const Icon(Icons.person),
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 18),
        fillColor: Colors.white,
        filled: true,
        errorStyle: const TextStyle(
          color: Colors.red,
          fontSize: 15,
        ),
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
      ),
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(context, errorText: "กรุณากรอกอีเมล"),
        FormBuilderValidators.email(context, errorText: "รูปแบบอีเมลไม่ถูกต้อง")
      ]),
      onSaved: (value) {
        profiles.email = value!;
      },
    );
  }

  Widget buildInputPassword() {
    return TextFormField(
      obscureText: _isObscure,
      keyboardType: TextInputType.visiblePassword,
      decoration: InputDecoration(
        labelText: 'รหัสผ่าน',
        prefixIcon: const Icon(Icons.vpn_key),
        suffixIcon: IconButton(
          onPressed: () {
            setState(
              () {
                _isObscure = !_isObscure;
              },
            );
          },
          icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
        ),
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 18),
        fillColor: Colors.white,
        filled: true,
        errorStyle: const TextStyle(
          color: Colors.red,
          fontSize: 15,
        ),
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
      ),
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(context, errorText: "กรุณากรอกรหัสผ่าน"),
      ]),
      onSaved: (value) {
        profiles.password = value!;
      },
    );
  }

  Widget buildForgetPasswordBtn() {
    return Container(
      alignment: Alignment.centerRight,
      child: MaterialButton(
        height: 20,
        child: Text(
          "ลืมรหัสผ่าน?",
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
        onPressed: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => ForgetPassword()),
          // );
        },
      ),
    );
  }

  Widget buildSignupBtn() {
    // ignore: avoid_unnecessary_containers
    return Container(
      child: MaterialButton(
        height: 20,
        child: const Text(
          "ลงทะเบียนผู้ใช้",
          style: TextStyle(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RegisterPage()),
          );
        },
      ),
    );
  }

  Widget buildSigninBtn() {
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
            "เข้าสู่ระบบ",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            formKey.currentState!.save();
            if (formKey.currentState!.validate()) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            }
          },
        ),
      ),
    ]);
  }
}
