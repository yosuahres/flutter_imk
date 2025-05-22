import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controllers for input fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String _errorCode = "";

  final Color _backgroundColor = const Color(0xFF2E7D6E);
  final Color _logoColor = const Color(0xFFBDECB6);
  final Color _buttonColor = const Color(0xFF1E6052);
  final Color _whiteTextColor = Colors.white;
  final Color _inputFillColor = Colors.white;
  final Color _inputHintColor = Colors.grey.shade500;
  final Color _inputIconColor = Colors.grey.shade500;
  final Color _inputTextColor = Colors.black87;

  void navigateLogin() {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, 'login');
  }

  void navigateHome() { 
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, 'home');
  }

  void register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorCode = "Passwords do not match.";
      });
      return;
    }

    if (!_isLoading) {
      setState(() {
        _isLoading = true;
        _errorCode = "";
      });

      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (mounted) navigateLogin();
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          setState(() {
            _errorCode = e.message ?? "Registration failed. Please try again.";
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorCode = "An unexpected error occurred. Please try again.";
          });
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                _buildLogo(),
                const SizedBox(height: 25),
                _buildHeader(),
                const SizedBox(height: 40),
                _buildEmailField(),
                const SizedBox(height: 16),
                _buildPasswordField(),

                const SizedBox(height: 16),
                _buildConfirmPasswordField(),
                const SizedBox(height: 24),
                if (_errorCode.isNotEmpty) _buildErrorMessage(),
                _buildRegisterButton(),
                const SizedBox(height: 30),
                _buildLoginRow(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    // Image.asset('assets/images/app_logo.png', height: 80)
    return Icon(
      Icons.spa_outlined, 
      size: 90,
      color: _logoColor,
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Create Account',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 34.0,
            fontWeight: FontWeight.bold,
            color: _whiteTextColor,
          ),
        ),
        // Optional subtitle:
        const SizedBox(height: 8),
        Text(
          'Join us and start your journey!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.0,
            color: _whiteTextColor.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(color: _inputTextColor),
      decoration: InputDecoration(
        hintText: 'Enter your Email address',
        hintStyle: TextStyle(color: _inputHintColor),
        prefixIcon: Icon(Icons.email_outlined, color: _inputIconColor),
        filled: true,
        fillColor: _inputFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: true,
      style: TextStyle(color: _inputTextColor),
      decoration: InputDecoration(
        hintText: 'Create a password',
        hintStyle: TextStyle(color: _inputHintColor),
        prefixIcon: Icon(Icons.lock_outline, color: _inputIconColor),
        filled: true,
        fillColor: _inputFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextField(
      controller: _confirmPasswordController,
      obscureText: true,
      style: TextStyle(color: _inputTextColor),
      decoration: InputDecoration(
        hintText: 'Confirm your password',
        hintStyle: TextStyle(color: _inputHintColor),
        prefixIcon: Icon(Icons.lock_outline, color: _inputIconColor),
        filled: true,
        fillColor: _inputFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, top: 5.0),
      child: Text(
        _errorCode,
        style: TextStyle(color: Colors.red.shade300, fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : register,
      style: ElevatedButton.styleFrom(
        backgroundColor: _buttonColor,
        foregroundColor: _whiteTextColor,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        minimumSize: const Size(double.infinity, 50),
      ),
      child: _isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_whiteTextColor),
                strokeWidth: 2.5,
              ),
            )
          : const Text(
              'Register', 
              style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w600),
            ),
    );
  }

  Widget _buildLoginRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: TextStyle(color: _whiteTextColor, fontSize: 14.5),
        ),
        GestureDetector(
          onTap: navigateLogin,
          child: Text(
            'Login here', 
            style: TextStyle(
              color: _whiteTextColor, // Or _logoColor for accent
              fontWeight: FontWeight.bold,
              fontSize: 14.5,
              decoration: TextDecoration.underline,
              decorationColor: _whiteTextColor.withOpacity(0.8),
              decorationThickness: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}