import 'dart:developer' show log;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../components/colors.dart';
import '../../shared/dialog_utils.dart';
import 'auth_manager.dart';

enum AuthMode { signup, login }

class AuthCard extends StatefulWidget {
  const AuthCard({super.key});

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.login;
  final Map<String, String> _authData = {
    'username': '',
    'email': '',
    'phone': '',
    'password': '',
  };
  final _isSubmitting = ValueNotifier<bool>(false);
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController(); 
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<bool> _validateFields() async {
    final email = _authData['email'] ?? '';
    final password = _authData['password'] ?? '';
    final username = _authData['username'] ?? '';
    final phone = _authData['phone'] ?? '';
    final confirmPassword = _confirmPasswordController.text;

    // Validate email (for both login and signup)
    if (email.isEmpty || !email.contains('@')) {
      await showErrorDialog(context, 'Invalid email!');
      return false;
    }

    // Validate password (for both login and signup)
    if (password.isEmpty) {
      await showErrorDialog(context, 'Please enter a password');
      return false;
    }
    if (password.length < 8) {
      await showErrorDialog(
          context, 'Password must be at least 8 characters long');
      return false;
    }

    // Additional validations for signup mode
    if (_authMode == AuthMode.signup) {
      // Validate username
      if (username.isEmpty) {
        await showErrorDialog(context, 'Username cannot be blank!');
        return false;
      }
      if (username.length <= 3) {
        await showErrorDialog(
            context, 'Username must be more than 3 characters long');
        return false;
      }

      // Validate phone
      if (phone.isEmpty) {
        await showErrorDialog(context, 'Phone cannot be blank!');
        return false;
      }
      final phoneRegex = RegExp(r'^0\d{9}$');
      if (!phoneRegex.hasMatch(phone)) {
        await showErrorDialog(context,
            'Phone number must be exactly 10 digits and start with 0 (e.g., 0123456789)');
        return false;
      }

      // Validate confirm password
      if (confirmPassword.isEmpty) {
        await showErrorDialog(context, 'Please confirm your password');
        return false;
      }
      if (confirmPassword != password) {
        await showErrorDialog(context, 'Passwords do not match');
        return false;
      }
    }

    return true; // All validations passed
  }

  Future<void> _submit() async {
    _formKey.currentState!.save();
    _isSubmitting.value = true;

    print('✅ Auth data after save: $_authData');

    // Validate fields and show errors in popup if validation fails
    final isValid = await _validateFields();
    if (!isValid) {
      _isSubmitting.value = false;
      return;
    }

    try {
      final authManager = context.read<AuthManager>();
      if (_authMode == AuthMode.login) {
        await authManager.login(
          _authData['email']!,
          _authData['password']!,
        );
      } else {
        await authManager.signup(
          _authData['username']!,
          _authData['email']!,
          _authData['phone']!,
          _authData['password']!,
        );
        await authManager.logout();
        if (mounted) {
          await showSuccessDialog(
              context, 'Account created successfully! Please log in.');
        }
        final email = _authData['email'];
        final password = _authData['password'];
        _authData['username'] = '';
        _authData['phone'] = '';
        _confirmPasswordController.clear();
        _switchAuthMode();
        setState(() {
          _authData['email'] = email!;
          _authData['password'] = password!;
          _emailController.text = email;
          _passwordController.text = password;
        });
      }
    } catch (error) {
      log('$error');
      if (mounted) {
        String errorMessage = error.toString();
        while (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.substring('Exception: '.length);
        }
        showErrorDialog(context, errorMessage);
      }
    }
    _isSubmitting.value = false;
  }

  void _switchAuthMode() {
    setState(() {
      _authMode =
          _authMode == AuthMode.login ? AuthMode.signup : AuthMode.login;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 0.0),
          child: Container(
            width: double.infinity,
            height: size.height * 0.9,
            decoration: const BoxDecoration(
              color: color17,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Text(
                    _authMode == AuthMode.signup
                        ? "Register new account!"
                        : "Login to your account!",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 25,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                      color: color4,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildEmailField(),
                        if (_authMode == AuthMode.signup) ...[
                          _buildUsernameField(),
                          _buildPhoneField(),
                        ],
                        _buildPasswordField(),
                        if (_authMode == AuthMode.signup) ...[
                          _buildPasswordConfirmField(),
                        ],
                        ValueListenableBuilder<bool>(
                          valueListenable: _isSubmitting,
                          builder: (context, isSubmitting, child) {
                            return isSubmitting
                                ? const CircularProgressIndicator()
                                : _buildSubmitButton();
                          },
                        ),
                        _buildAuthModeSwitchButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUsernameField() {
    return _buildTextField(
      hintText: "Username",
      icon: Icons.person,
      onSaved: (value) => _authData['username'] = value!,
    );
  }

  Widget _buildPhoneField() {
    return _buildTextField(
      hintText: "Phone",
      icon: Icons.phone,
      onSaved: (value) => _authData['phone'] = value!,
    );
  }

  Widget _buildEmailField() {
    return _buildTextField(
      hintText: "Email",
      icon: Icons.email,
      controller: _emailController, 
      onSaved: (value) => _authData['email'] = value!,
    );
  }

  Widget _buildPasswordField() {
    return _buildTextField(
      hintText: "Password",
      icon: Icons.lock,
      obscureText: _obscurePassword,
      controller: _passwordController,
      onSaved: (value) => _authData['password'] = value!,
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePassword ? Icons.visibility_off : Icons.visibility,
          color: color1,
        ),
        onPressed: () {
          setState(() {
            _obscurePassword = !_obscurePassword;
          });
        },
      ),
    );
  }

  Widget _buildPasswordConfirmField() {
    return _buildTextField(
      hintText: "Confirm Password",
      icon: Icons.lock_reset,
      obscureText: _obscureConfirmPassword,
      controller: _confirmPasswordController,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
          color: color1,
        ),
        onPressed: () {
          setState(() {
            _obscureConfirmPassword = !_obscureConfirmPassword;
          });
        },
      ),
    );
  }

  Widget _buildAuthModeSwitchButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _authMode == AuthMode.login
              ? "Does not have any account?"
              : "Already have an account?",
          style: TextStyle(
            color: color4,
            fontSize: 15,
          ),
        ),
        TextButton(
          onPressed: _switchAuthMode,
          child: Text(
            _authMode == AuthMode.login ? 'Register here' : 'Login here',
            style: TextStyle(
              color: color4,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    Size size = MediaQuery.of(context).size;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      width: size.width * 0.8,
      height: 55,
      decoration: BoxDecoration(
        color: color4,
        borderRadius: BorderRadius.circular(50),
      ),
      child: TextButton(
        onPressed: _submit,
        child: Text(
          _authMode == AuthMode.login ? 'LOGIN' : 'SIGN UP',
          style: TextStyle(color: color13, fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextEditingController? controller,
    void Function(String?)? onSaved,
    Widget? suffixIcon,
  }) {
    return TextFieldContainer(
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        cursorColor: color1,
        style: const TextStyle(height: 1, fontSize: 16),
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          icon: Icon(
            icon,
            color: color1,
          ),
          hintText: hintText,
          hintStyle: const TextStyle(color: color1),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
          suffixIcon: suffixIcon,
        ),
        onSaved: onSaved,
      ),
    );
  }
}

class TextFieldContainer extends StatelessWidget {
  final Widget child;
  const TextFieldContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      width: size.width * 0.8,
      decoration: BoxDecoration(
        color: color13,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color4, width: 1.5),
      ),
      child: child,
    );
  }
}