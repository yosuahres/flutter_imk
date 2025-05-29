import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String _errorCode = "";
  bool _rememberMe = false; 

  final Color _backgroundColor = const Color(0xFF2E7D6E); 
  final Color _logoColor = const Color(0xFFBDECB6);    
  final Color _buttonColor = const Color(0xFF1E6052);   
  final Color _whiteTextColor = Colors.white;
  final Color _inputFillColor = Colors.white;
  final Color _inputHintColor = Colors.grey.shade500;
  final Color _inputIconColor = Colors.grey.shade500;
  final Color _inputTextColor = Colors.black87;

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

  void signIn() async {
    if (!_isLoading) { 
      setState(() {
        _isLoading = true;
        _errorCode = "";
      });

      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (mounted) navigateHome();
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          setState(() {
            _errorCode = e.message ?? "Login failed. Please try again.";
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: _buildLoginForm(),
    );
  }

  Widget _buildLoginForm() {
    return SafeArea(
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
              _buildRememberForgotRow(),
              const SizedBox(height: 24),
              if (_errorCode.isNotEmpty) _buildErrorMessage(),
              _buildLoginButton(),
              const SizedBox(height: 30), 
              _buildRegisterRow(),
              const SizedBox(height: 20), 
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Icon(
      Icons.spa_outlined, 
      size: 90,
      color: _logoColor,
    );
  }

  Widget _buildHeader() {
    return Text(
      'Login',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 34.0,
        fontWeight: FontWeight.bold,
        color: _whiteTextColor,
      ),
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
        hintText: 'Enter your password',
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

  Widget _buildRememberForgotRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell( 
          onTap: () {
            setState(() {
              _rememberMe = !_rememberMe;
            });
          },
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: _rememberMe,
                    onChanged: (bool? value) {
                      if (value != null) {
                        setState(() {
                          _rememberMe = value;
                        });
                      }
                    },
                    activeColor: _logoColor,
                    checkColor: _buttonColor,
                    side: BorderSide(color: _whiteTextColor.withOpacity(0.7)),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Remember me',
                  style: TextStyle(color: _whiteTextColor, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        TextButton(
          onPressed: navigateForgotPassword,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
            minimumSize: const Size(50, 30),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            alignment: Alignment.centerRight,
            foregroundColor: _whiteTextColor,
          ),
          child: const Text(
            'Forgot password?',
            style: TextStyle(fontSize: 14),
          ),
        ),
      ],
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

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : signIn,
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
              'Login',
              style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w600),
            ),
    );
  }

  Widget _buildSocialLoginButton({
    required String text,
    required Widget iconWidget,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _inputFillColor,
        padding: const EdgeInsets.symmetric(vertical: 13.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        minimumSize: const Size(double.infinity, 50),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconWidget,
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: _inputTextColor,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Don\'t have an account? ',
          style: TextStyle(color: _whiteTextColor, fontSize: 14.5),
        ),
        GestureDetector(
          onTap: navigateRegister,
          child: Text(
            'Sign up here',
            style: TextStyle(
              color: _whiteTextColor,
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