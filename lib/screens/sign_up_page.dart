import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'dart:math' as Math;


class SignUpPage extends StatefulWidget {
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final dateController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    nomController.dispose();
    prenomController.dispose();
    emailController.dispose();
    passwordController.dispose();
    dateController.dispose();
    super.dispose();
  }

  Widget _buildBioPattern() {
    return Positioned.fill(
      child: CustomPaint(
        painter: BioPatternPainter(),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 40),
      child: Column(
        children: [
          // Logo/Icon avec animation
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF4CAF50), Color(0xFF81C784)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF4CAF50).withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.eco,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          
          // Titre principal
          Text(
            'Créer un compte',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2E7D32),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          
          // Sous-titre
          Text(
            'Rejoignez notre communauté bio',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    bool obscureText = false,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E7D32),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            validator: validator,
            obscureText: obscureText,
            readOnly: readOnly,
            onTap: onTap,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF212121),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Color(0xFF4CAF50), size: 20),
              ),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Color(0xFF4CAF50), width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.red.shade300),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.red.shade400, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpButton() {
    return Container(
      width: double.infinity,
      height: 56,
      margin: const EdgeInsets.only(top: 16, bottom: 24),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSignUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: Color(0xFF4CAF50).withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Création en cours...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_add, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Créer mon compte',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.registerUser(
        nom: nomController.text.trim(),
        prenom: prenomController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        dateNaissance: dateController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Compte créé avec succès ! 🎉',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Erreur: $e',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FFFE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: Color(0xFF2E7D32)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Stack(
        children: [
          _buildBioPattern(),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _buildHeader(),
                      
                      // Formulaire dans un container avec design moderne
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 30,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Nom & Prénom en ligne
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildCustomTextField(
                                      controller: nomController,
                                      label: 'Nom',
                                      hint: 'Votre nom',
                                      icon: Icons.person_outline,
                                      validator: (value) => value?.trim().isEmpty == true 
                                          ? 'Nom requis' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildCustomTextField(
                                      controller: prenomController,
                                      label: 'Prénom',
                                      hint: 'Votre prénom',
                                      icon: Icons.badge_outlined,
                                      validator: (value) => value?.trim().isEmpty == true 
                                          ? 'Prénom requis' : null,
                                    ),
                                  ),
                                ],
                              ),
                              
                              _buildCustomTextField(
                                controller: emailController,
                                label: 'Adresse email',
                                hint: 'votre.email@exemple.com',
                                icon: Icons.email_outlined,
                                validator: (value) {
                                  if (value?.trim().isEmpty == true) return 'Email requis';
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                                    return 'Format email invalide';
                                  }
                                  return null;
                                },
                              ),
                              
                              _buildCustomTextField(
                                controller: passwordController,
                                label: 'Mot de passe',
                                hint: 'Minimum 6 caractères',
                                icon: Icons.lock_outline,
                                obscureText: _obscurePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.grey.shade600,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                validator: (value) {
                                  if (value?.isEmpty == true) return 'Mot de passe requis';
                                  if (value!.length < 6) return '6 caractères minimum';
                                  return null;
                                },
                              ),
                              
                              _buildCustomTextField(
                                controller: dateController,
                                label: 'Date de naissance',
                                hint: 'Sélectionnez votre date',
                                icon: Icons.calendar_today_outlined,
                                readOnly: true,
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime(2000),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: ColorScheme.light(
                                            primary: Color(0xFF4CAF50),
                                            surface: Colors.white,
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (picked != null) {
                                    dateController.text = picked.toIso8601String().split('T').first;
                                  }
                                },
                                validator: (value) => value?.isEmpty == true 
                                    ? 'Date de naissance requise' : null,
                              ),
                              
                              _buildSignUpButton(),
                              
                              // Lien vers connexion
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Déjà un compte ? ',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(
                                      'Se connecter',
                                      style: TextStyle(
                                        color: Color(0xFF4CAF50),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter pour les motifs biologiques
class BioPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF4CAF50).withOpacity(0.03)
      ..style = PaintingStyle.fill;

    // Dessiner des feuilles stylisées
    for (int i = 0; i < 8; i++) {
      final x = (size.width / 8) * i + (size.width / 16);
      final y = size.height * 0.1 + (i % 2) * 20;
      
      _drawLeaf(canvas, paint, Offset(x, y), i * 45.0);
    }
    
    // Dessiner des cercles organiques
    for (int i = 0; i < 15; i++) {
      final x = (i * size.width / 15) + (i % 3) * 30;
      final y = size.height * 0.7 + (i % 2) * 50;
      final radius = 8 + (i % 3) * 4;
      
      canvas.drawCircle(Offset(x, y), radius.toDouble(), paint);
    }
    
    // Dessiner des spirales ADN stylisées
    _drawDNASpiral(canvas, paint, size);
  }
  
  void _drawLeaf(Canvas canvas, Paint paint, Offset center, double rotation) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation * 3.14159 / 180);
    
    final path = Path();
    path.moveTo(0, -15);
    path.quadraticBezierTo(8, -8, 12, 0);
    path.quadraticBezierTo(8, 8, 0, 15);
    path.quadraticBezierTo(-8, 8, -12, 0);
    path.quadraticBezierTo(-8, -8, 0, -15);
    
    canvas.drawPath(path, paint);
    canvas.restore();
  }
  
  void _drawDNASpiral(Canvas canvas, Paint paint, Size size) {
    final path = Path();
    final spiralPaint = Paint()
      ..color = Color(0xFF81C784).withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    for (double i = 0; i < size.width; i += 10) {
      final y1 = size.height * 0.3 + 30 * Math.sin(i * 0.02);
      final y2 = size.height * 0.3 + 30 * Math.sin(i * 0.02 + 3.14159);
      
      canvas.drawCircle(Offset(i, y1), 2, spiralPaint..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(i, y2), 2, spiralPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}