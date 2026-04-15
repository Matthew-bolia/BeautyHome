import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Modèles de données ────────────────────────────────────────────────────

class SalonService {
  final String id, name, description, icon;
  final int durationMinutes;
  final double price;
  SalonService({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.durationMinutes,
    required this.price,
  });
}

class SalonSpecialist {
  final String id, name, role, imageUrl;
  SalonSpecialist({
    required this.id,
    required this.name,
    required this.role,
    required this.imageUrl,
  });
}

// ─── Données statiques ─────────────────────────────────────────────────────

final List<SalonService> _services = [
  SalonService(
    id: 's1',
    name: 'Coupe femme',
    description: 'Coupe + brushing inclus',
    icon: '✂️',
    durationMinutes: 60,
    price: 45,
  ),
  SalonService(
    id: 's2',
    name: 'Coupe homme',
    description: 'Coupe classique ou dégradé',
    icon: '💈',
    durationMinutes: 30,
    price: 22,
  ),
  SalonService(
    id: 's3',
    name: 'Coloration',
    description: 'Couleur complète ou mèches',
    icon: '🎨',
    durationMinutes: 90,
    price: 75,
  ),
  SalonService(
    id: 's4',
    name: 'Balayage',
    description: 'Balayage naturel ou californien',
    icon: '🌟',
    durationMinutes: 120,
    price: 95,
  ),
  SalonService(
    id: 's5',
    name: 'Lissage brésilien',
    description: 'Lissage longue durée',
    icon: '💆',
    durationMinutes: 150,
    price: 120,
  ),
  SalonService(
    id: 's6',
    name: 'Soin capillaire',
    description: 'Masque + traitement profond',
    icon: '🧴',
    durationMinutes: 45,
    price: 35,
  ),
  SalonService(
    id: 's7',
    name: 'Coiffure de mariage',
    description: 'Mise en beauté & chignon',
    icon: '👰',
    durationMinutes: 180,
    price: 150,
  ),
  SalonService(
    id: 's8',
    name: 'Permanente',
    description: 'Boucles ou ondulations',
    icon: '🌀',
    durationMinutes: 120,
    price: 85,
  ),
];

final List<SalonSpecialist> _specialists = [
  SalonSpecialist(
    id: 'sp1',
    name: 'Isabelle Fontaine',
    role: 'Directrice artistique',
    imageUrl:
        'https://images.pexels.com/photos/1181690/pexels-photo-1181690.jpeg?auto=compress&cs=tinysrgb&w=400',
  ),
  SalonSpecialist(
    id: 'sp2',
    name: 'Marcus Dupont',
    role: 'Coloriste expert',
    imageUrl:
        'https://images.pexels.com/photos/91227/pexels-photo-91227.jpeg?auto=compress&cs=tinysrgb&w=400',
  ),
  SalonSpecialist(
    id: 'sp3',
    name: 'Sophie Leblanc',
    role: 'Styliste',
    imageUrl:
        'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=400',
  ),
  SalonSpecialist(
    id: 'sp4',
    name: 'Théo Bernard',
    role: 'Barbier & coiffeur',
    imageUrl:
        'https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg?auto=compress&cs=tinysrgb&w=400',
  ),
];

final List<String> _timeSlots = [
  '09:00',
  '09:30',
  '10:00',
  '10:30',
  '11:00',
  '11:30',
  '14:00',
  '14:30',
  '15:00',
  '15:30',
  '16:00',
  '16:30',
  '17:00',
  '17:30',
];

// ─── Écran principal de réservation ────────────────────────────────────────

class BookingScreen extends StatefulWidget {
  final String? preselectedSpecialistName;
  const BookingScreen({super.key, this.preselectedSpecialistName, required String preselectedService});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _currentStep = 0;

  SalonService? _selectedService;
  SalonSpecialist? _selectedSpecialist;
  DateTime? _selectedDate;
  String? _selectedTime;
  final _noteController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isConfirmed = false;

  @override
  void initState() {
    super.initState();
    if (widget.preselectedSpecialistName != null) {
      _selectedSpecialist = _specialists.firstWhere(
        (s) => s.name == widget.preselectedSpecialistName,
        orElse: () => _specialists.first,
      );
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool get _canProceed {
    switch (_currentStep) {
      case 0:
        return _selectedService != null;
      case 1:
        return _selectedSpecialist != null;
      case 2:
        return _selectedDate != null && _selectedTime != null;
      case 3:
        return _nameController.text.trim().isNotEmpty &&
            _phoneController.text.trim().length >= 8;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_currentStep < 3 && _canProceed) {
      setState(() => _currentStep++);
    } else if (_currentStep == 3 && _canProceed) {
      _confirmBooking();
    }
  }

  void _confirmBooking() {
    setState(() => _isConfirmed = true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_isConfirmed) return _buildConfirmationScreen(theme);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: const Color(0xFF1A1A2E)),
        title: Text(
          'Réservation',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: _buildStepIndicator(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, animation) => SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0.08, 0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: KeyedSubtree(
                key: ValueKey(_currentStep),
                child: _buildCurrentStep(),
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Service', 'Spécialiste', 'Date & Heure', 'Coordonnées'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isActive = i == _currentStep;
          final isDone = i < _currentStep;
          return Expanded(
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone
                            ? const Color(0xFFB8860B)
                            : isActive
                            ? const Color(0xFF1A1A2E)
                            : Colors.grey[200],
                      ),
                      child: Center(
                        child: isDone
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 14,
                              )
                            : Text(
                                '${i + 1}',
                                style: TextStyle(
                                  color: isActive
                                      ? Colors.white
                                      : Colors.grey[500],
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      steps[i],
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        color: isActive
                            ? const Color(0xFF1A1A2E)
                            : Colors.grey[400],
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                if (i < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 1.5,
                      margin: const EdgeInsets.only(bottom: 20),
                      color: isDone
                          ? const Color(0xFFB8860B)
                          : Colors.grey[200],
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildServiceStep();
      case 1:
        return _buildSpecialistStep();
      case 2:
        return _buildDateTimeStep();
      case 3:
        return _buildContactStep();
      default:
        return const SizedBox();
    }
  }

  // ── Step 1 : Choix du service ──────────────────────────────────────────

  Widget _buildServiceStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Quel service souhaitez-vous ?'),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: _services.length,
            itemBuilder: (context, i) => _buildServiceCard(_services[i]),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(SalonService service) {
    final isSelected = _selectedService?.id == service.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedService = service),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A1A2E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFB8860B) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(service.icon, style: const TextStyle(fontSize: 28)),
            const Spacer(),
            Text(
              service.name,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              service.description,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: isSelected ? Colors.white60 : Colors.grey[500],
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${service.durationMinutes} min',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: isSelected
                        ? const Color(0xFFB8860B)
                        : Colors.grey[400],
                  ),
                ),
                Text(
                  '${service.price.toStringAsFixed(0)}€',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? const Color(0xFFB8860B)
                        : const Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 2 : Choix du spécialiste ─────────────────────────────────────

  Widget _buildSpecialistStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Choisissez votre spécialiste'),
          const SizedBox(height: 16),
          ..._specialists.map(
            (sp) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildSpecialistCard(sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialistCard(SalonSpecialist sp) {
    final isSelected = _selectedSpecialist?.id == sp.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedSpecialist = sp),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFB8860B) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(sp.imageUrl),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sp.name,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  Text(
                    sp.role,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFFB8860B),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  // ── Step 3 : Date & Heure ─────────────────────────────────────────────

  Widget _buildDateTimeStep() {
    final now = DateTime.now();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Choisissez une date'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CalendarDatePicker(
              initialDate: _selectedDate ?? now,
              firstDate: now,
              lastDate: now.add(const Duration(days: 60)),
              onDateChanged: (date) => setState(() => _selectedDate = date),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Choisissez un créneau'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _timeSlots.map((slot) {
              final isSelected = _selectedTime == slot;
              return GestureDetector(
                onTap: () => setState(() => _selectedTime = slot),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1A1A2E) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFB8860B)
                          : Colors.grey[200]!,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    slot,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF1A1A2E),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Step 4 : Coordonnées ──────────────────────────────────────────────

  Widget _buildContactStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Vos coordonnées'),
          const SizedBox(height: 16),
          _buildSummaryCard(),
          const SizedBox(height: 24),
          _buildInputField(
            controller: _nameController,
            label: 'Nom complet',
            icon: Icons.person_outline,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),
          _buildInputField(
            controller: _phoneController,
            label: 'Numéro de téléphone',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),
          _buildInputField(
            controller: _noteController,
            label: 'Note pour le coiffeur (optionnel)',
            icon: Icons.notes_outlined,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final dateStr = _selectedDate != null
        ? '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}'
        : '';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF2D2D44)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Récapitulatif',
            style: GoogleFonts.cormorantGaramond(
              color: const Color(0xFFB8860B),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          _summaryRow(
            Icons.content_cut,
            _selectedService?.name ?? '-',
            '${_selectedService?.price.toStringAsFixed(0) ?? '-'}€',
          ),
          const SizedBox(height: 8),
          _summaryRow(
            Icons.person_outline,
            _selectedSpecialist?.name ?? '-',
            _selectedSpecialist?.role ?? '',
          ),
          const SizedBox(height: 8),
          _summaryRow(
            Icons.calendar_today_outlined,
            '$dateStr  $_selectedTime',
            '${_selectedService?.durationMinutes ?? 0} min',
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFB8860B), size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF1A1A2E)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey[500]),
        prefixIcon: Icon(icon, size: 18, color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB8860B), width: 1.5),
        ),
      ),
    );
  }

  // ── Barre du bas ──────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      color: Colors.white,
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1A1A2E),
                  side: const BorderSide(color: Color(0xFF1A1A2E)),
                  minimumSize: const Size(0, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Retour',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _canProceed ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A2E),
                disabledBackgroundColor: Colors.grey[200],
                minimumSize: const Size(0, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _currentStep == 3 ? 'Confirmer la réservation' : 'Continuer',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Écran de confirmation ─────────────────────────────────────────────

  Widget _buildConfirmationScreen(ThemeData theme) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFFB8860B).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFFB8860B),
                  size: 50,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Réservation confirmée !',
                style: GoogleFonts.cormorantGaramond(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Votre rendez-vous avec ${_selectedSpecialist?.name} pour ${_selectedService?.name} est confirmé.',
                style: GoogleFonts.inter(
                  color: Colors.white60,
                  fontSize: 14,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _confirmRow(
                      '📅',
                      'Date',
                      '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}',
                    ),
                    const SizedBox(height: 10),
                    _confirmRow('🕐', 'Heure', _selectedTime ?? ''),
                    const SizedBox(height: 10),
                    _confirmRow(
                      '💰',
                      'Total',
                      '${_selectedService?.price.toStringAsFixed(0) ?? ''}€',
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB8860B),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Retour à l'accueil",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _confirmRow(String emoji, String label, String value) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.inter(color: Colors.white60, fontSize: 13),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.cormorantGaramond(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1A1A2E),
      ),
    );
  }
}
