import 'package:cretex/Admin%20Screens/Distributers%20Registration%20Page/distributersRegistrationPage.dart';
import 'package:cretex/Admin%20Screens/Manufacturer%20Registration%20Page/registerManufacturer.dart';
import 'package:cretex/Admin%20Screens/Warehousing%20Registration%20Page/wareHousingRegistrationPage.dart';
import 'package:cretex/Admin%20Screens/WholeSalers%20Registration%20Page/wholeSalersRegistrationPage.dart';
import 'package:cretex/Common%20Screens/Login%20Screen/loginScreen.dart';
import 'package:cretex/UI%20Helper/Colors/colors.dart';
import 'package:cretex/UI%20Helper/Gradients/gradients.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class AdminHomeScreen extends StatefulWidget {
  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen>
    with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _floatController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _floatAnimation;

  // ── Responsive helpers ───────────────────────────────────────────────────────
  double _sw(BuildContext ctx) => MediaQuery.of(ctx).size.width;
  double _sh(BuildContext ctx) => MediaQuery.of(ctx).size.height;
  double _ws(BuildContext ctx, double size) => size * _sw(ctx) / 390;
  double _hs(BuildContext ctx, double size) => size * _sh(ctx) / 844;
  double _fs(BuildContext ctx, double size) =>
      _ws(ctx, size).clamp(size * 0.82, size * 1.18);

  final List<Map<String, dynamic>> _registrationOptions = [
    {
      'title': 'Register Manufacturer',
      'subtitle': 'Add new manufacturers to the system',
      'icon': Icons.factory_outlined,
      'tag': 'MFG',
    },
    {
      'title': 'Register Warehousing',
      'subtitle': 'Register warehouse facilities',
      'icon': Icons.warehouse_outlined,
      'tag': 'WHS',
    },
    {
      'title': 'Register Wholesalers',
      'subtitle': 'Add wholesale partners',
      'icon': Icons.storefront_outlined,
      'tag': 'WSL',
    },
    {
      'title': 'Register Distributers',
      'subtitle': 'Register distribution channels',
      'icon': Icons.local_shipping_outlined,
      'tag': 'DST',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _floatAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => LoginScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  // ── Sign Out Dialog ──────────────────────────────────────────────────────────

  void _showSignOutDialog() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_ws(context, 24))),
        elevation: 0,
        backgroundColor: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(_ws(context, 28)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon circle
              Container(
                width: _ws(context, 72),
                height: _ws(context, 72),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.red.shade400,
                  size: _ws(context, 34),
                ),
              ),
              SizedBox(height: _hs(context, 20)),

              // Title
              Text(
                'Sign Out',
                style: TextStyle(
                  fontSize: _fs(context, 20),
                  fontWeight: FontWeight.bold,
                  color: MyColors.blueColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: _hs(context, 10)),

              // Subtitle
              Text(
                'Are you sure you want to\nsign out of your session?',
                style: TextStyle(
                  fontSize: _fs(context, 14),
                  color: Colors.grey.shade500,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: _hs(context, 28)),

              // Sign Out button — gradient
              Container(
                width: double.infinity,
                height: _hs(context, 50),
                decoration: BoxDecoration(
                  gradient: MyGradients.blueGradient,
                  borderRadius: BorderRadius.circular(_ws(context, 14)),
                  boxShadow: [
                    BoxShadow(
                      color: MyColors.blueColor.withOpacity(0.28),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _signOut();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(_ws(context, 14)),
                    ),
                  ),
                  child: Text(
                    'Yes, Sign Out',
                    style: TextStyle(
                      fontSize: _fs(context, 15),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: _hs(context, 12)),

              // Cancel button — outlined
              SizedBox(
                width: double.infinity,
                height: _hs(context, 50),
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: MyColors.blueColor.withOpacity(0.3),
                        width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(_ws(context, 14)),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: _fs(context, 15),
                      fontWeight: FontWeight.w600,
                      color: MyColors.blueColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToRegistration(String title) {
    HapticFeedback.lightImpact();
    Widget? targetPage;
    switch (title) {
      case 'Register Manufacturer':
        targetPage = ManufacturerRegisterPage();
        break;
      case 'Register Warehousing':
        targetPage = WarehousingRegistrationPage();
        break;
      case 'Register Wholesalers':
        targetPage = WholeSalersRegistrationPage();
        break;
      case 'Register Distributers':
        targetPage = DistributersRegistrationPage();
        break;
    }
    if (targetPage != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => targetPage!));
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  // ── BUILD ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: _ws(context, 20),
              vertical: _hs(context, 10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: _hs(context, 12)),
                _buildHeader(context),
                SizedBox(height: _hs(context, 24)),
                SlideTransition(
                  position: _slideAnimation,
                  child: _buildAdminCard(context),
                ),
                SizedBox(height: _hs(context, 28)),
                SlideTransition(
                  position: _slideAnimation,
                  child: _buildSectionHeader(context),
                ),
                SizedBox(height: _hs(context, 14)),
                SlideTransition(
                  position: _slideAnimation,
                  child: _buildRegistrationGrid(context),
                ),
                SizedBox(height: _hs(context, 24)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── HEADER ───────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Admin Panel',
              style: TextStyle(
                fontSize: _fs(context, 13),
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade500,
                letterSpacing: 0.2,
                height: 1.0,
              ),
            ),
            SizedBox(height: _hs(context, 3)),
            ShaderMask(
              shaderCallback: (bounds) =>
                  MyGradients.blueGradient.createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: Text(
                'CRETEX',
                style: TextStyle(
                  fontSize: _fs(context, 30),
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 2.0,
                  height: 1.0,
                ),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: _showSignOutDialog,
          child: Container(
            width: _ws(context, 46),
            height: _ws(context, 46),
            decoration: BoxDecoration(
              gradient: MyGradients.blueGradient,
              borderRadius: BorderRadius.circular(_ws(context, 14)),
              boxShadow: [
                BoxShadow(
                  color: MyColors.blueColor.withOpacity(0.28),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              Icons.logout_rounded,
              color: Colors.white,
              size: _ws(context, 20),
            ),
          ),
        ),
      ],
    );
  }

  // ── ADMIN CARD ───────────────────────────────────────────────────────────────

  Widget _buildAdminCard(BuildContext context) {
    final cardHeight = _hs(context, 210);
    final pad = _ws(context, 22);

    return Container(
      height: cardHeight,
      decoration: BoxDecoration(
        gradient: MyGradients.blueGradient,
        borderRadius: BorderRadius.circular(_ws(context, 28)),
        boxShadow: [
          BoxShadow(
            color: MyColors.blueColor.withOpacity(0.32),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            top: -cardHeight * 0.25,
            right: -cardHeight * 0.2,
            child: Container(
              width: cardHeight * 0.9,
              height: cardHeight * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -cardHeight * 0.2,
            left: -_ws(context, 30),
            child: Container(
              width: cardHeight * 0.7,
              height: cardHeight * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_ws(context, 28)),
              child: CustomPaint(painter: _GridPainter()),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: _ws(context, 10),
                            vertical: _hs(context, 5),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius:
                            BorderRadius.circular(_ws(context, 20)),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: _ws(context, 6),
                                height: _ws(context, 6),
                                decoration: const BoxDecoration(
                                  color: Colors.greenAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: _ws(context, 6)),
                              Text(
                                'Active Session',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: _fs(context, 11),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: _hs(context, 14)),
                        Text(
                          'Welcome back,',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: _fs(context, 13),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: _hs(context, 3)),
                        Text(
                          'Admin Dashboard',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _fs(context, 24),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                    AnimatedBuilder(
                      animation: _floatController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                              0,
                              -6 * math.sin(
                                  _floatAnimation.value * math.pi)),
                          child: child,
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(_ws(context, 16)),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius:
                          BorderRadius.circular(_ws(context, 18)),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.3), width: 1),
                        ),
                        child: Icon(
                          Icons.admin_panel_settings_outlined,
                          color: Colors.white,
                          size: _ws(context, 32),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildStatChip(context, Icons.people_outline, 'Users'),
                    SizedBox(width: _ws(context, 10)),
                    _buildStatChip(
                        context, Icons.bar_chart_rounded, 'Analytics'),
                    SizedBox(width: _ws(context, 10)),
                    _buildStatChip(context, Icons.tune_rounded, 'Controls'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _ws(context, 12),
        vertical: _hs(context, 8),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(_ws(context, 12)),
        border: Border.all(color: Colors.white.withOpacity(0.28), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: _ws(context, 14)),
          SizedBox(width: _ws(context, 6)),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: _fs(context, 11),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── SECTION HEADER ───────────────────────────────────────────────────────────

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Registration',
              style: TextStyle(
                fontSize: _fs(context, 22),
                fontWeight: FontWeight.bold,
                color: MyColors.blueColor,
              ),
            ),
            SizedBox(height: _hs(context, 2)),
            Text(
              'Select an option to register',
              style: TextStyle(
                fontSize: _fs(context, 13),
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: _ws(context, 12),
            vertical: _hs(context, 6),
          ),
          decoration: BoxDecoration(
            color: MyColors.blueColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(_ws(context, 20)),
          ),
          child: Text(
            '${_registrationOptions.length} Options',
            style: TextStyle(
              fontSize: _fs(context, 12),
              color: MyColors.blueColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ── REGISTRATION GRID ────────────────────────────────────────────────────────

  Widget _buildRegistrationGrid(BuildContext context) {
    return Column(
      children: List.generate(_registrationOptions.length, (index) {
        final option = _registrationOptions[index];
        return Padding(
          padding: EdgeInsets.only(bottom: _hs(context, 14)),
          child: _buildRegistrationCard(context, option),
        );
      }),
    );
  }

  Widget _buildRegistrationCard(
      BuildContext context, Map<String, dynamic> option) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(_ws(context, 20)),
        onTap: () => _navigateToRegistration(option['title']),
        child: Container(
          padding: EdgeInsets.all(_ws(context, 18)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_ws(context, 20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon box
              Container(
                width: _ws(context, 56),
                height: _ws(context, 56),
                decoration: BoxDecoration(
                  gradient: MyGradients.blueGradient,
                  borderRadius: BorderRadius.circular(_ws(context, 16)),
                  boxShadow: [
                    BoxShadow(
                      color: MyColors.blueColor.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  option['icon'] as IconData,
                  color: Colors.white,
                  size: _ws(context, 26),
                ),
              ),
              SizedBox(width: _ws(context, 16)),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option['title'] as String,
                      style: TextStyle(
                        fontSize: _fs(context, 15),
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: _hs(context, 4)),
                    Text(
                      option['subtitle'] as String,
                      style: TextStyle(
                        fontSize: _fs(context, 12),
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: _ws(context, 8)),
              // Tag + arrow
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: _ws(context, 8),
                      vertical: _hs(context, 3),
                    ),
                    decoration: BoxDecoration(
                      color: MyColors.blueColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(_ws(context, 6)),
                    ),
                    child: Text(
                      option['tag'] as String,
                      style: TextStyle(
                        fontSize: _fs(context, 10),
                        fontWeight: FontWeight.w700,
                        color: MyColors.blueColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  SizedBox(height: _hs(context, 8)),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: MyColors.blueColor.withOpacity(0.5),
                    size: _ws(context, 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Grid painter ──────────────────────────────────────────────────────────────

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const cols = 7;
    const rows = 5;

    for (int i = 0; i <= cols; i++) {
      final x = i * size.width / cols;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (int i = 0; i <= rows; i++) {
      final y = i * size.height / rows;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}