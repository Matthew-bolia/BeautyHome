import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  bool _isLogin = true;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _toggleForm() {
    setState(() {
      _isLogin = !_isLogin;
      _formKey.currentState?.reset();
      _isPasswordVisible = false;
      _isConfirmPasswordVisible = false;
    });
  }

  Future<void> _submitAuthForm() async {
    final isValid = _formKey.currentState?.validate();
    if (isValid != true) {
      return;
    }

    // sauvegarde les champs du formulaire
    _formKey.currentState?.save();

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        // Logique de connexion
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        // Créer l'utilisateur dans Firebase Auth
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Enregistrer les informatiions de l'utilisateur dans Firebase avec le rôle 'client'
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
              'displayName': _nameController.text.trim(),
              'email': _emailController.text.trim(),
              'role': 'client', // rôle assigné automatiquement
              'createAt': Timestamp.now(), // l'ajout de la date de creation
            });
      }

      // la navigation se fera automatiquement par l'AuthWrapper, pas besoin de setState
    } on FirebaseAuthException catch (e) {
      String message = 'Une erreur est survenue.';
      if (e.message != null) {
        message = e.message!;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Une erreur inattendue est survenue.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Colors.white;

    return Scaffold(
      body: Stack(
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://images.pexels.com/photos/2081199/pexels-photo-2081199.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(),
                  Colors.black.withValues(),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildToggle(primaryColor),
                          const SizedBox(height: 30),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                            child: _isLogin
                                ? _buildLoginForm(primaryColor)
                                : _buildSignupForm(primaryColor),
                          ),
                          const SizedBox(height: 25),
                          _buildDivider(primaryColor),
                          const SizedBox(height: 25),
                          _buildSocialButtons(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(Color primaryColor) {
    return Column(
      key: const ValueKey('login'),
      children: [
        _buildTextField(
          controller: _emailController,
          icon: Icons.email_outlined,
          hint: 'Email',
          validator: (value) {
            if (value == null || !value.contains('@')) {
              return 'Veuillez entrer une adresse email valide.';
            }
            return null;
          },
        ),
        const SizedBox(height: 15),
        _buildTextField(
          controller: _passwordController,
          icon: Icons.lock_outline,
          hint: 'Mot de passe',
          isPassword: true,
          isVisible: _isPasswordVisible,
          onToggleVisibility: () =>
              setState(() => _isPasswordVisible = !_isPasswordVisible),
          validator: (value) {
            if (value == null || value.length < 6) {
              return 'Le mot de passe doit contenir au moins 6 caractères.';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: Text(
              'Mot de passe oublié ?',
              style: TextStyle(color: primaryColor.withOpacity(0.8)),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildAuthButton(primaryColor),
      ],
    );
  }

  Widget _buildSignupForm(Color primaryColor) {
    return Column(
      key: const ValueKey('signup'),
      children: [
        _buildTextField(
          controller: _nameController,
          icon: Icons.person_outline,
          hint: 'Nom complet',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer votre nom.';
            }
            return null;
          },
        ),
        const SizedBox(height: 15),
        _buildTextField(
          controller: _emailController,
          icon: Icons.email_outlined,
          hint: 'Email',
          validator: (value) {
            if (value == null || !value.contains('@')) {
              return 'Veuillez entrer une adresse email valide.';
            }
            return null;
          },
        ),
        const SizedBox(height: 15),
        _buildTextField(
          controller: _passwordController,
          icon: Icons.lock_outline,
          hint: 'Mot de passe',
          isPassword: true,
          isVisible: _isPasswordVisible,
          onToggleVisibility: () =>
              setState(() => _isPasswordVisible = !_isPasswordVisible),
          validator: (value) {
            if (value == null || value.length < 6) {
              return 'Le mot de passe doit contenir au moins 6 caractères.';
            }
            return null;
          },
        ),
        const SizedBox(height: 15),
        _buildTextField(
          controller: _confirmPasswordController,
          icon: Icons.lock_outline,
          hint: 'Confirmer le mot de passe',
          isPassword: true,
          isVisible: _isConfirmPasswordVisible,
          onToggleVisibility: () => setState(
            () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
          ),
          validator: (value) {
            if (value != _passwordController.text) {
              return 'Les mots de passe ne correspondent pas.';
            }
            return null;
          },
        ),
        const SizedBox(height: 40),
        _buildAuthButton(primaryColor),
      ],
    );
  }

  Widget _buildToggle(Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton('CONNEXION', _isLogin, primaryColor),
          _buildToggleButton('S\'INSCRIRE', _isLogin, primaryColor),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isSelected, Color primaryColor) {
    return GestureDetector(
      onTap: _isLoading ? null : _toggleForm,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool isPassword = false,
    bool? isVisible,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !(isVisible ?? false),
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: Colors.white70, size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isVisible ?? false ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white70,
                ),
                onPressed: onToggleVisibility,
              )
            : null,
        filled: true,
        fillColor: Colors.black.withValues(),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }

  Widget _buildAuthButton(Color primaryColor) {
    return _isLoading
        ? const CircularProgressIndicator(color: Colors.white)
        : ElevatedButton(
            onPressed: _submitAuthForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: Text(
              _isLogin ? 'Se connecter' : 'Créer un compte',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          );
  }

  Widget _buildDivider(Color primaryColor) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: primaryColor.withOpacity(0.5), thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'OU',
            style: TextStyle(color: primaryColor.withOpacity(0.8)),
          ),
        ),
        Expanded(
          child: Divider(color: primaryColor.withOpacity(0.5), thickness: 1),
        ),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Google Button
        GestureDetector(
          onTap: _isLoading
              ? null
              : () {
                  /* Handle Google Sign-in */
                },
          child: const CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white,
            child: FaIcon(
              FontAwesomeIcons.google,
              color: Color(0xFFDB4437), // Google Red
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 25),
        // Facebook Button
        GestureDetector(
          onTap: _isLoading
              ? null
              : () {
                  /* Handle Facebook Sign-in */
                },
          child: const CircleAvatar(
            radius: 25,
            backgroundColor: Color(0xFF1877F2), // Official Facebook Blue
            child: FaIcon(
              FontAwesomeIcons.facebookF,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ],
    );
  }
}
