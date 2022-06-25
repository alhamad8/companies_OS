import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:work_os/services/global_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../constants/constant.dart';
import 'login.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late final TextEditingController _emailController =
      TextEditingController(text: '');
  late final TextEditingController _passController =
      TextEditingController(text: '');
  late final TextEditingController _nameController =
      TextEditingController(text: '');
  late final TextEditingController _positionController =
      TextEditingController(text: '');
  late final TextEditingController _phoneNumberController =
      TextEditingController(text: '');
  bool _obscureText = true;
  final _signupKey = GlobalKey<FormState>();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passFocusNode = FocusNode();
  final FocusNode _positionFocusNode = FocusNode();
  final FocusNode _phoneNumberFocusNode = FocusNode();
  File? imageFile;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;
  String? url;

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _nameController.dispose();
    _positionController.dispose();
    _phoneNumberController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passFocusNode.dispose();
    _positionFocusNode.dispose();
    _phoneNumberFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 20));
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.linear)
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((animationStatus) {
            if (animationStatus == AnimationStatus.completed) {
              _animationController.reset();
              _animationController.forward();
            }
          });
    _animationController.forward();

    super.initState();
  }

  void sumbitSignup() async {
    final isValid = _signupKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      if (imageFile == null) {
        GlobalMethods.showError(
            error: 'please pick up an image', context: context);
        return;
      }
      setState(() {
        isLoading = true;
      });
      try {
        await _auth.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passController.text.trim());
        Navigator.canPop(context) ? Navigator.pop(context) : null;
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ));
        final User? user = _auth.currentUser;
        final uid = user!.uid;
        final storageRef = FirebaseStorage.instance
            .ref()
            .child("usersImages")
            .child("$uid.jpg");
        await storageRef.putFile(imageFile!);
        url = await storageRef.getDownloadURL();

        CollectionReference users =
            FirebaseFirestore.instance.collection('users');
        users.doc(uid).set({
          "id": uid,
          "name": _nameController.text,
          "email": _emailController.text,
          "userImageUrl": url,
          "phoneNumber": _phoneNumberController.text,
          "positionInCompany": _positionController.text,
          "createdAt": Timestamp.now()
        });
      } catch (error) {
        print("Error = $error");
        GlobalMethods.showError(context: context, error: error.toString());
        setState(() {
          isLoading = false;
        });
      }
    } else {}
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(children: [
        CachedNetworkImage(
          imageUrl:
              "https://media.istockphoto.com/photos/businesswoman-using-computer-in-dark-office-picture-id557608443?k=6&m=557608443&s=612x612&w=0&h=fWWESl6nk7T6ufo4sRjRBSeSiaiVYAzVrY-CLlfMptM=",
          placeholder: (context, url) => Image.asset(
            'assests/images/wallpaper.jpg',
            fit: BoxFit.fill,
          ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          alignment: FractionalOffset(_animation.value, 0),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            children: [
              SizedBox(
                height: size.height * 0.1,
              ),
              const Text(
                "Register",
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              RichText(
                  text: TextSpan(children: [
                const TextSpan(
                    text: "Already have an account?",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const TextSpan(text: '  '),
                TextSpan(
                    text: "Login",
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ));
                      },
                    style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline)),
              ])),
              SizedBox(
                height: size.height * 0.05,
              ),
              Form(
                key: _signupKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Flexible(
                          flex: 2,
                          child: TextFormField(
                            textInputAction: TextInputAction.next,
                            onEditingComplete: () => FocusScope.of(context)
                                .requestFocus(_emailFocusNode),
                            focusNode: _nameFocusNode,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Field can't be missing";
                              }
                              return null;
                            },
                            controller: _nameController,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.name,
                            decoration: const InputDecoration(
                              hintText: "Enter your Full Name",
                              hintStyle: TextStyle(color: Colors.white),
                              labelText: "Full Name",
                              labelStyle: TextStyle(color: Colors.white),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.deepPurple)),
                              errorBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red)),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: size.width * 0.24,
                                  height: size.width * 0.24,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1, color: Colors.white),
                                      borderRadius: BorderRadius.circular(16)),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: imageFile == null
                                        ? Image.network(
                                            'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_1280.png',
                                            fit: BoxFit.fill,
                                          )
                                        : Image.file(
                                          
                                            imageFile!,
                                            fit: BoxFit.fill,
                                          ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: _showImageDialog,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.pink,
                                        border: Border.all(
                                            width: 2, color: Colors.white),
                                        shape: BoxShape.circle),
                                    child: Icon(
                                      imageFile == null
                                          ? Icons.add_a_photo
                                          : Icons.edit_outlined,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      focusNode: _emailFocusNode,
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () =>
                          FocusScope.of(context).requestFocus(_passFocusNode),
                      validator: (value) {
                        if (value!.isEmpty || !value.contains("@")) {
                          return "Please enter a valid Email address";
                        }
                        return null;
                      },
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: "Enter your email",
                        hintStyle: TextStyle(color: Colors.white),
                        labelText: "Email",
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepPurple)),
                        errorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red)),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      focusNode: _passFocusNode,
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () => FocusScope.of(context)
                          .requestFocus(_phoneNumberFocusNode),
                      obscureText: _obscureText,
                      validator: (value) {
                        if (value!.isEmpty || value.length < 5) {
                          return "Please enter a valid Password";
                        }
                        return null;
                      },
                      controller: _passController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                          child: Icon(
                            _obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white,
                          ),
                        ),
                        hintText: "Enter your password",
                        hintStyle: const TextStyle(color: Colors.white),
                        labelText: "Password",
                        labelStyle: const TextStyle(color: Colors.white),
                        enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepPurple)),
                        errorBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red)),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () => FocusScope.of(context)
                          .requestFocus(_positionFocusNode),
                      focusNode: _phoneNumberFocusNode,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Field can't be missing";
                        }
                        return null;
                      },
                      controller: _phoneNumberController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: "Enter your phone number",
                        hintStyle: TextStyle(color: Colors.white),
                        labelText: "Phone number",
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepPurple)),
                        errorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red)),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    GestureDetector(
                      onTap: () => showJobsDialog(size),
                      child: TextFormField(
                        enabled: false,
                        focusNode: _positionFocusNode,
                        textInputAction: TextInputAction.done,
                        onEditingComplete: sumbitSignup,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Field can't be missing";
                          }
                          return null;
                        },
                        controller: _positionController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: "Enter your position",
                          hintStyle: TextStyle(color: Colors.white),
                          labelText: "Position in the company",
                          labelStyle: TextStyle(color: Colors.white),
                          disabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.deepPurple)),
                          errorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.red)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              const SizedBox(
                height: 35,
              ),
              isLoading
                  ? Center(
                      child: Container(
                          width: 80,
                          height: 80,
                          child: const CircularProgressIndicator()),
                    )
                  : MaterialButton(
                      onPressed: sumbitSignup,
                      color: Colors.amberAccent,
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide.none),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              "Register",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(
                            Icons.app_registration,
                            color: Colors.white,
                          )
                        ],
                      ),
                    )
            ],
          ),
        )
      ]),
    );
  }

  void _pickedImageCamera() async {
    XFile? pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.camera, maxHeight: 1080, maxWidth: 1080);
    setState(() {
    imageFile = File(pickedFile!.path);
    });
    _cropImage(filePath: pickedFile!.path);

    Navigator.pop(context);
  }

  void _pickedImageGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery, maxHeight: 1080, maxWidth: 1080);
   setState(() {
       imageFile = File(pickedFile!.path);
     });
    _cropImage(filePath: pickedFile!.path);
    Navigator.pop(context);
  }

  void _cropImage({required filePath}) async {
    CroppedFile? cropImage = await ImageCropper()
        .cropImage(sourcePath: filePath, maxHeight: 1080, maxWidth: 1080);
    if (cropImage != null) {
      setState(() {
        imageFile = cropImage as File ;
      });
    }
  }

  void _showImageDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text(
                'please chose an option',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: _pickedImageCamera,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.camera,
                            color: Colors.purple,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            'Camera',
                            style: TextStyle(color: Colors.purple),
                          )
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _pickedImageGallery,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.image,
                            color: Colors.purple,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            'Gallry',
                            style: TextStyle(color: Colors.purple),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ));
  }

  showJobsDialog(Size size) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                "Jobs",
                style: TextStyle(color: Constant.red, fontSize: 20),
              ),
              content: Container(
                width: size.width * 0.9,
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: Constant.jobsList.length,
                    itemBuilder: ((context, index) => InkWell(
                          onTap: () {
                            setState(() {
                              _positionController.text =
                                  Constant.jobsList[index];
                            });
                            Navigator.pop(context);
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: Constant.red,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  Constant.jobsList[index],
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        ))),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.canPop(context) ? Navigator.pop(context) : null;
                    },
                    child: const Text("close")),
                TextButton(onPressed: () {}, child: const Text("Cancel")),
              ],
            ));
  }
}
