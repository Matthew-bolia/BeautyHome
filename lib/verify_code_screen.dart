
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;
import 'home_screen.dart'; // Assurez-vous que le chemin est correct

class VerifyCodeScreen extends StatefulWidget {
  final String email;

  const VerifyCodeScreen({super.key, required this.email});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  Future<void> _verifyCode(String code) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // TODO: Remplacer ceci par la logique de vérification du backend
    // Pour l'instant, nous allons simuler une vérification et recharger l'utilisateur
    // pour voir si son e-mail a été vérifié manuellement via la console Firebase.
    try {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;

      if (user != null && user.emailVerified) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        // La simulation échoue car la vérification réelle n'est pas implémentée.
        // Dans une implémentation réelle, vous appelleriez une Cloud Function ici.
        // Exemple: final result = await FirebaseFunctions.instance.httpsCallable('verifyEmailCode').call({'code': code});
        // if (result.data['success']) { ... } else { ... }
        
        developer.log('Vérification simulée échouée. Implémentez la logique backend.', name: 'VerifyCodeScreen');
        setState(() {
          _errorMessage = "Le code est incorrect ou a expiré. La logique réelle doit être implémentée.";
        });
      }
    } catch (e) {
      developer.log('Erreur lors de la vérification du code: $e', name: 'VerifyCodeScreen', error: e);
      setState(() {
        _errorMessage = "Une erreur s'est produite. Veuillez réessayer.";
      });
    }


    setState(() {
      _isLoading = false;
    });
  }
  
  // TODO: Implémenter la logique pour renvoyer le code
  Future<void> _resendCode() async {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Logique de renvoi du code à implémenter.")),
      );
  }


  @override
  Widget build(BuildContext context) {
    const focusedBorderColor = Color.fromRGBO(23, 171, 144, 1);
    const fillColor = Color.fromRGBO(243, 246, 249, 0);
    const borderColor = Color.fromRGBO(23, 171, 144, 0.4);

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Color.fromRGBO(30, 60, 87, 1),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Vérification du compte"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.mark_email_read_outlined, size: 100, color: Colors.deepPurple),
                const SizedBox(height: 24),
                Text(
                  "Code de Vérification",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Text(
                  "Un code à 6 chiffres a été envoyé à \n${widget.email}",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Pinput(
                    length: 6,
                    controller: pinController,
                    focusNode: focusNode,
                    defaultPinTheme: defaultPinTheme,
                    separatorBuilder: (index) => const SizedBox(width: 8),
                    validator: (value) {
                      return value?.length == 6 ? null : 'Veuillez entrer le code complet';
                    },
                    hapticFeedbackType: HapticFeedbackType.lightImpact,
                    onCompleted: (pin) {
                      _verifyCode(pin);
                    },
                    cursor: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 9),
                          width: 22,
                          height: 1,
                          color: focusedBorderColor,
                        ),
                      ],
                    ),
                    focusedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: focusedBorderColor),
                      ),
                    ),
                    submittedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        color: fillColor,
                        borderRadius: BorderRadius.circular(19),
                        border: Border.all(color: focusedBorderColor),
                      ),
                    ),
                    errorPinTheme: defaultPinTheme.copyBorderWith(
                      border: Border.all(color: Colors.redAccent),
                    ),
                  ),
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 32),
                _isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                               _verifyCode(pinController.text);
                            }
                          },
                          child: const Text('Vérifier'),
                        ),
                      ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _resendCode,
                  child: const Text("Renvoyer le code"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
