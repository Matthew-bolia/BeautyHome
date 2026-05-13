
import 'dart:developer' as developer;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:beauty_home/home_screen.dart';
import 'auth_storage.dart';
import 'verify_code_screen.dart'; 
 

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
  bool _rememberMe = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final creds = await AuthStorageService.loadCredentials();
    if (creds['email'] != null) {
      setState(() {
        _emailController.text = creds['email']!;
        _passwordController.text = creds['password'] ?? '';
        _rememberMe = true;
      });
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
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://plus.unsplash.com/premium_photo-1661964222478-6cb034dbc294?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
              width: 250,
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: _buildAuthCard(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleForm() {
    setState(() {
      _isLogin = !_isLogin;
      _formKey.currentState?.reset();
    });
  }

  // ÉTAPE 3: MODIFICATION DE LA LOGIQUE DE SOUMISSION
  Future<void> _submitAuthForm() async {
    final isValid = _formKey.currentState?.validate();
    if (isValid != true || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        // LOGIQUE DE CONNEXION
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        User? user = userCredential.user;
        if (user != null) {
          await user.reload();
          user = _auth.currentUser; // Recharger pour le statut de vérification

          if (user!.emailVerified) {
            if (_rememberMe) {
              await AuthStorageService.saveCredentials(
                _emailController.text.trim(),
                _passwordController.text.trim(),
              );
            } else {
              await AuthStorageService.clearCredentials();
            }
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            }
          } else {
            // Si l'email n'est pas vérifié, aller à l'écran de code
             developer.log('Email non vérifié. Redirection vers la vérification par code.', name: 'AuthScreen');
             if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez vérifier votre compte avec le code envoyé par e-mail.')),
                );
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => VerifyCodeScreen(email: user!.email!)),
                );
             }
          }
        }

      } else {
        // LOGIQUE D'INSCRIPTION
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        
        User? user = userCredential.user;
        if (user != null) {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'displayName': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'role': 'client',
            'createdAt': Timestamp.now(),
          });

          // TODO: Déclencher l'envoi de l'email avec le code via une Cloud Function
          developer.log('Utilisateur créé. Redirection vers la vérification par code.', name: 'AuthScreen');
          if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Compte créé ! Veuillez vérifier votre e-mail pour obtenir le code.')),
            );
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => VerifyCodeScreen(email: user.email!)),
            );
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? "Une erreur est survenue."),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e, s) {
      developer.log('Erreur inattendue', name: 'AuthScreen', error: e, stackTrace: s);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Une erreur inattendue est survenue.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez d'abord entrer votre email."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Un email de réinitialisation a été envoyé."),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? "Impossible d'envoyer l'email."),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Widget _buildAuthCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isLogin ? 'Bienvenue' : 'Créer un compte',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin
                      ? 'Connectez-vous pour continuer'
                      : 'Remplissez les champs pour vous inscrire',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),
                if (!_isLogin) ...[
                  _buildTextField(
                    controller: _nameController,
                    icon: Icons.person_outline,
                    hint: 'Nom complet',
                    validator: (v) => v!.isEmpty ? 'Nom requis' : null,
                  ),
                  const SizedBox(height: 16),
                ],
                _buildTextField(
                  controller: _emailController,
                  icon: Icons.email_outlined,
                  hint: 'Email',
                  validator: (v) =>
                      v == null || !v.contains('@') ? 'Email invalide' : null,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _passwordController,
                  icon: Icons.lock_outline,
                  hint: 'Mot de passe',
                  isPassword: !_isPasswordVisible,
                  validator: (v) =>
                      v == null || v.length < 6 ? '6 caractères min.' : null,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.white70,
                    ),
                    onPressed: () => setState(
                      () => _isPasswordVisible = !_isPasswordVisible,
                    ),
                  ),
                ),
                if (!_isLogin) ...[
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _confirmPasswordController,
                    icon: Icons.lock_outline,
                    hint: 'Confirmer le mot de passe',
                    isPassword: true,
                    validator: (v) => v != _passwordController.text
                        ? 'Mots de passe non identiques'
                        : null,
                  ),
                ],
                if (_isLogin) ...[
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _resetPassword,
                      child: const Text(
                        'Mot de passe oublié ?',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (v) =>
                            setState(() => _rememberMe = v ?? false),
                        activeColor: Colors.white,
                        checkColor: Colors.black,
                        side: const BorderSide(color: Colors.white70),
                      ),
                      const Text(
                        'Se souvenir de moi',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 12),
                if (_isLoading)
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                if (!_isLoading) ...[
                  ElevatedButton(
                    onPressed: _submitAuthForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _isLogin ? 'Se connecter' : 'S\'inscrire',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                _buildToggleSwitch(),
                // ÉTAPE 2: Suppression du bouton et du séparateur Google
                // const SizedBox(height: 16),
                // buildSocialDivider(),
                // const SizedBox(height: 16),
                // if (!_isLoading)
                //   buildGoogleSignInButton(context, () async {
                //     if (_isLoading) return;
                //     setState(() => _isLoading = true);
                //     await handleGoogleSignIn(context);
                //     if (mounted) setState(() => _isLoading = false);
                //   }),
              ],
            ),
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
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: Colors.white70, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.black.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorStyle: const TextStyle(color: Colors.yellowAccent),
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return TextButton(
      onPressed: _toggleForm,
      child: RichText(
        text: TextSpan(
          text: _isLogin ? 'Pas encore de compte ? ' : 'Déjà un compte ? ',
          style: const TextStyle(color: Colors.white, fontSize: 14),
          children: [
            TextSpan(
              text: _isLogin ? 'S\'inscrire' : 'Se connecter',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 15, 15, 15),
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
