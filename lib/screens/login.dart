import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers for input fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // State variables
  bool showPassword = false;
  bool _isLoading = false;
  String _errorCode = "";

  // Navigation methods
  void navigateRegister() {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, 'register');
  }

  void navigateHome() {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, 'home');
  }

  void navigateForgotPassword() {
    if (!context.mounted) return;
    Navigator.pushNamed(context, 'forgot_password');
  }

  // Authentication methods
  void signIn() async {
    setState(() {
      _isLoading = true;
      _errorCode = "";
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      navigateHome();
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorCode = e.code;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  // UI state toggle
  void toggleShowPassword() {
    setState(() {
      showPassword = !showPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ListView(
            children: [
              const SizedBox(height: 200),
              _buildHeader(),
              const SizedBox(height: 60),
              _buildEmailField(),
              const SizedBox(height: 24),
              _buildPasswordField(),
              const SizedBox(height: 24),
              if (_errorCode.isNotEmpty) _buildErrorMessage(),
              _buildLoginButton(),
              _buildForgotPasswordButton(),
              _buildRegisterRow(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget builders for better structure
  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Welcome to Ikling!',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Start your journey with us',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16.0,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      decoration: const InputDecoration(
        label: Text('Email'),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
        ),
        contentPadding: EdgeInsets.all(18.0),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: !showPassword,
      decoration: InputDecoration(
        label: const Text('Password'),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
        ),
        contentPadding: const EdgeInsets.all(18.0),
        suffixIcon: IconButton(
          icon: Icon(
            showPassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: toggleShowPassword,
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Column(
      children: [
        Text(
          _errorCode,
          style: const TextStyle(color: Colors.red),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildLoginButton() {
    return OutlinedButton(
      onPressed: signIn,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        side: const BorderSide(color: Colors.blue, width: 2.0),
      ),
      child: _isLoading
          ? const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
          : const Text(
              'LOGIN',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return TextButton(
      onPressed: navigateForgotPassword,
      child: const Text('Forgot Password?'),
    );
  }

  Widget _buildRegisterRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Don\'t have an account?'),
        TextButton(
          onPressed: navigateRegister,
          child: const Text('Register'),
        ),
      ],
    );
  }
}