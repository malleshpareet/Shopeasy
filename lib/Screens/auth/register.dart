import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Const/my_validators.dart';
import 'package:flutter_application_1/Screens/auth/login.dart';
import 'package:flutter_application_1/Screens/loading_manager.dart';
import 'package:flutter_application_1/Widgets/app_name_text.dart';
import 'package:flutter_application_1/Widgets/auth/image_picker_widget.dart';
import 'package:flutter_application_1/Widgets/subtitle_text.dart';
import 'package:flutter_application_1/services/my_app_methods.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class RegisterScreen extends StatefulWidget {
  static const String routeName = '/register';

  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final TextEditingController _nameController,
      _emailController,
      _passwordController,
      _confirmPasswordController;
  late final FocusNode _nameFocusNode,
      _emailFocusNode,
      _passwordFocusNode,
      _confirmPasswordFocusNode;
  late final _formKey = GlobalKey<FormState>();
  bool obscureText = true;
  bool isLoading = false;
  XFile? _pickedImage;
  final auth = FirebaseAuth.instance;
  String? UserImageUrl;

  @override
  void initState() {
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _nameFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _confirmPasswordFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _registerFct() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (_pickedImage == null) {
      await MyAppMethods.showErrorWarningDialog(
        context: context,
        subtitle: "Please pick an image",
        fct: () {},
      );
      return;
    }
    if (isValid) {
      try {
        setState(() => isLoading = true);
        final ref = FirebaseStorage.instance
            .ref()
            .child("user_image")
            .child("${_emailController.text.trim()}.jpg");
        await ref.putFile(File(_pickedImage!.path));
        UserImageUrl = await ref.getDownloadURL();

        await auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text.trim(),
        );

        User? user = auth.currentUser;
        final uid = user!.uid;
        await FirebaseFirestore.instance.collection("users").doc(uid).set({
          "userId": uid,
          "userName": _nameController.text.trim(),
          "userEmail": _emailController.text.toLowerCase(),
          "userImage": UserImageUrl,
          "createdAt": Timestamp.now(),
          "userCart": [],
          "userWish": [],
        });

        Fluttertoast.showToast(
          msg: "Account has been created",
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } on FirebaseAuthException catch (error) {
        if (!mounted) return;
        await MyAppMethods.showErrorWarningDialog(
          context: context,
          subtitle: "An error has been occured ${error.message}",
          fct: () {},
        );
      } catch (error) {
        if (!mounted) return;
        await MyAppMethods.showErrorWarningDialog(
          context: context,
          subtitle: "An Error has been occured $error",
          fct: () {},
        );
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> localImagePicker() async {
    final ImagePicker picker = ImagePicker();
    await MyAppMethods.imagePickerDialog(
      context: context,
      cameraFCT: () async {
        _pickedImage = await picker.pickImage(source: ImageSource.camera);
        setState(() {});
      },
      galleryFCT: () async {
        _pickedImage = await picker.pickImage(source: ImageSource.gallery);
        setState(() {});
      },
      removeFCT: () {
        setState(() => _pickedImage = null);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: LoadingManager(
          isLoading: isLoading,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 60.0),
                  const AppNameTextWidget(fontsize: 30),
                  const SizedBox(height: 16.0),
                  Text("Welcome to ShopEasy!",
                      style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E3A8A))),
                  Text("Happy shopping! 🛍️",
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800])),
                  const SizedBox(height: 20.0),
                  SizedBox(
                    height: size.width * 0.3,
                    width: size.width * 0.3,
                    child: ImagePickerWidget(
                      pickedimage: _pickedImage,
                      function: () async => await localImagePicker(),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(_nameController, _nameFocusNode, "Full Name", IconlyLight.profile, _emailFocusNode, MyValidators.displayNamevalidator),
                        const SizedBox(height: 16.0),
                        _buildTextField(_emailController, _emailFocusNode, "Email Address", IconlyLight.message, _passwordFocusNode, MyValidators.emailValidator),
                        const SizedBox(height: 16.0),
                        _buildPasswordField(_passwordController, _passwordFocusNode, "Password", _confirmPasswordFocusNode, MyValidators.passwordValidator),
                        const SizedBox(height: 16.0),
                        _buildPasswordField(_confirmPasswordController, _confirmPasswordFocusNode, "Confirm Password", null, (value) => MyValidators.repeatPasswordValidator(value: value, password: _passwordController.text)),
                        const SizedBox(height: 24.0),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3A8A),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(IconlyLight.addUser, color: Colors.white),
                            label: Text("Sign Up",
                                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                            onPressed: _registerFct,
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SubtitleTextWidgets(label: "Already have an account? ", color: Colors.black),
                            TextButton(
                              onPressed: () => Navigator.pushNamed(context, LoginScreen.routeName),
                              child: const SubtitleTextWidgets(label: "Login", color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, FocusNode focusNode, String hintText, IconData icon, FocusNode? nextFocus, String? Function(String?) validator) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      textInputAction: nextFocus != null ? TextInputAction.next : TextInputAction.done,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.grey[700]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator,
      onFieldSubmitted: (_) {
        if (nextFocus != null) FocusScope.of(context).requestFocus(nextFocus);
      },
    );
  }

  Widget _buildPasswordField(TextEditingController controller, FocusNode focusNode, String hintText, FocusNode? nextFocus, String? Function(String?) validator) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      textInputAction: nextFocus != null ? TextInputAction.next : TextInputAction.done,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        hintText: hintText,
        prefixIcon: Icon(IconlyLight.lock, color: Colors.grey[700]),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off, color: Colors.grey[600]),
          onPressed: () => setState(() => obscureText = !obscureText),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator,
      onFieldSubmitted: (_) {
        if (nextFocus != null) {
          FocusScope.of(context).requestFocus(nextFocus);
        } else {
          _registerFct();
        }
      },
    );
  }
}
