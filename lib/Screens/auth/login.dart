import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_1/Const/my_validators.dart';
import 'package:flutter_application_1/Screens/auth/forgot_password.dart';
import 'package:flutter_application_1/Screens/auth/register.dart';
import 'package:flutter_application_1/Screens/loading_manager.dart';
import 'package:flutter_application_1/Widgets/app_name_text.dart';
import 'package:flutter_application_1/Widgets/auth/google_button.dart';
import 'package:flutter_application_1/root_screen.dart';
import 'package:flutter_application_1/services/my_app_methods.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final FocusNode _emailFocusNode;
  late final FocusNode _passwordFocusNode;
  late final _formKey = GlobalKey<FormState>();
  bool obscureText = true;
  bool isLoading = false;
  final auth = FirebaseAuth.instance;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loginFct() async {
    FocusScope.of(context).unfocus();
    try {
      setState(() => isLoading = true);
      await auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text.trim(),
      );
      Fluttertoast.showToast(
          msg: "Login Successful", backgroundColor: Colors.green);
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const RootScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 700),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      await MyAppMethods.showErrorWarningDialog(
          context: context, subtitle: "Error: $error", fct: () {});
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: LoadingManager(
          isLoading: isLoading,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Text(
                        "Welcome Back",
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E3A8A), // Deep Blue
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextField(
                              _emailController,
                              _emailFocusNode,
                              "Email Address",
                              IconlyLight.message,
                              false),
                          const SizedBox(height: 20),
                          _buildTextField(
                              _passwordController,
                              _passwordFocusNode,
                              "Password",
                              IconlyLight.lock,
                              true),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => Navigator.pushNamed(
                                  context, ForgotPasswordScreen.routeName),
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: Color(0xFF1E3A8A),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildLoginButton(),
                          const SizedBox(height: 24),
                          _buildSocialButtons(),
                          const SizedBox(height: 16),
                          _buildSignUpOption(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, FocusNode focusNode,
      String hintText, IconData icon, bool isPassword) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: isPassword ? obscureText : false,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF1F5F9), // Light grey
        prefixIcon: Icon(icon, color: Colors.grey[700]),
        suffixIcon: isPassword
            ? IconButton(
            icon: Icon(
                obscureText ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey[600]),
            onPressed: () =>
                setState(() => obscureText = !obscureText))
            : null,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) => isPassword
          ? MyValidators.passwordValidator(value)
          : MyValidators.emailValidator(value),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E3A8A), // Deep Blue
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: _loginFct,
        child: const Text(
          "Login",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const GoogleButton(),
      ],
    );
  }

  Widget _buildSignUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account? ",
            style: TextStyle(color: Colors.black)),
        TextButton(
          onPressed: () =>
              Navigator.pushNamed(context, RegisterScreen.routeName),
          child: const Text("Sign Up",
              style: TextStyle(
                  color: Colors.black,
                  decoration: TextDecoration.underline)),
        ),
      ],
    );
  }
}
