import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/auth_screen.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importer le package
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String _selectedLanguage = 'FR';

  static const Map<String, Map<String, String>> _uiStrings = {
    'FR': {'prev': 'Précédent', 'next': 'Suivant', 'start': 'Commencer'},
    'EN': {'prev': 'Previous', 'next': 'Next', 'start': 'Start'},
  };

  static final List<Map<String, dynamic>> _onboardingData = [
    {
      'imageUrl':
          'https://plus.unsplash.com/premium_photo-1661544472209-504acaa14621?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1yZWxhdGVkfDI4fHx8ZW58MHx8fHx8',
      'FR': {
        'title': 'Des coiffures qui vous ressemblent',
        'description':
            'Trouvez l\'inspiration et les meilleurs coiffeurs pour votre style unique.',
      },
      'EN': {
        'title': 'Hairstyles that look like you',
        'description':
            'Find inspiration and the best hairdressers for your unique style.',
      },
    },
    {
      'imageUrl':
          'https://media.istockphoto.com/id/2260248040/fr/photo/masque-facial.jpg?s=612x612&w=0&k=20&c=GQhOjPT14H_WmaRQhiFkrH4tMBrRXXp1E-p8TBUGUHo=',
      'FR': {
        'title': 'Beauté & soin à portée de main',
        'description':
            'Réservez des soins esthétiques et des manucures près de chez vous.',
      },
      'EN': {
        'title': 'Beauty & care at your fingertips',
        'description': 'Book beauty treatments and manicures near you.',
      },
    },
    {
      'imageUrl':
          'https://media.istockphoto.com/id/1141255401/photo/businessman-work-with-friend.webp?a=1&b=1&s=612x612&w=0&k=20&c=2g7fNFAxS_Mf46fGOcQcwRGZdeWmouTMZ5vKNZ5ScXU=',
      'FR': {
        'title': 'Gérez vos rendez-vous en un clin d\'œil',
        'description':
            'Planifiez, modifiez ou annulez vos séances beauté facilement.',
      },
      'EN': {
        'title': 'Manage your appointments in a snap',
        'description':
            'Easily schedule, change or cancel your beauty sessions.',
      },
    },
  ];

  void _onLanguageSelected(String language) {
    setState(() {
      _selectedLanguage = language;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: _onboardingData.length,
            itemBuilder: (context, index) {
              return OnboardingPage(
                data: _onboardingData[index],
                language: _selectedLanguage,
              );
            },
          ),
          Positioned(
            top: 60,
            right: 20,
            child: Row(
              children: [
                _buildLanguageButton('🇫🇷', 'FR'),
                const SizedBox(width: 10),
                _buildLanguageButton('🇬🇧', 'EN'),
              ],
            ),
          ),
          // Navigation and Indicator
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: _currentPage == _onboardingData.length - 1
                ? Center(
                    child: ElevatedButton(
                      // --- MODIFICATION CI-DESSOUS ---
                      onPressed: () async {
                        // Rendre la fonction asynchrone
                        // 1. Sauvegarder que l'accueil est terminé
                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setBool('onboarding_complete', true);

                        if (!mounted) return;

                        // 2. Conserver l'ancienne navigation
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AuthScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        _uiStrings[_selectedLanguage]!['start']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Opacity(
                        opacity: _currentPage > 0 ? 1.0 : 0.0,
                        child: TextButton(
                          onPressed: _currentPage > 0
                              ? () => _pageController.previousPage(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                )
                              : null,
                          child: Text(
                            _uiStrings[_selectedLanguage]!['prev']!,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                      SmoothPageIndicator(
                        controller: _pageController,
                        count: _onboardingData.length,
                        onDotClicked: (index) {
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        },
                        effect: const WormEffect(
                          dotHeight: 8,
                          dotWidth: 8,
                          activeDotColor: Colors.white,
                          dotColor: Colors.white54,
                        ),
                      ),
                      TextButton(
                        onPressed: () => _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        ),
                        child: Text(
                          _uiStrings[_selectedLanguage]!['next']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageButton(String flag, String language) {
    final isSelected = _selectedLanguage == language;
    return GestureDetector(
      onTap: () => _onLanguageSelected(language),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.9)
              : Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              language,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final Map<String, dynamic> data;
  final String language;
  const OnboardingPage({super.key, required this.data, required this.language});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(data['imageUrl']!),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.5),
                Colors.transparent,
                Colors.black.withOpacity(0.8),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
        ),
        Positioned(
          bottom: 150,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HighlightTitle(text: data[language]!['title']!),
              const SizedBox(height: 20),
              Text(
                data[language]!['description']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class HighlightTitle extends StatelessWidget {
  final String text;
  const HighlightTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final words = text.split(' ');
    final line1 = words.sublist(0, (words.length / 2).ceil()).join(' ');
    final line2 = words.sublist((words.length / 2).ceil()).join(' ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (line1.isNotEmpty) _buildHighlightedLine(line1, -2.0, 0),
        if (line2.isNotEmpty) const SizedBox(height: 8),
        if (line2.isNotEmpty) _buildHighlightedLine(line2, -2.0, 15),
      ],
    );
  }

  Widget _buildHighlightedLine(
    String line,
    double angleDegrees,
    double leftPadding,
  ) {
    return Transform.rotate(
      angle: angleDegrees * (math.pi / 180),
      child: Padding(
        padding: EdgeInsets.only(left: leftPadding),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            CustomPaint(
              painter: HighlightPainter(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                child: Text(
                  line,
                  style: GoogleFonts.caveat(
                    color: Colors.black,
                    fontSize: 32, // Réduction de la taille de la police
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HighlightPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          const Color(0xFFFDBF00) // Jaune
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(-5, size.height * 0.15);
    path.lineTo(size.width + 2, 0);
    path.lineTo(size.width + 5, size.height * 0.85);
    path.lineTo(-2, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
