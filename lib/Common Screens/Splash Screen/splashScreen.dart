import 'package:cretex/Admin%20Screens/Home%20Screen%20Admin/homeScreenAdmin.dart';
import 'package:cretex/Common%20Screens/Login%20Screen/loginScreen.dart';
import 'package:cretex/Customer%20Screens/Home%20Screen%20Customer/homeScreenCustomer.dart';
import 'package:cretex/Distributers%20Screen/Distributer%20Home%20Screen/distributerHomeScreen.dart';
import 'package:cretex/Manufacturer%20Screens/Manufacturer%20Home%20Screen/manufacturerHomeScreen.dart';
import 'package:cretex/Merchant%20Screens/Home%20Screen%20Merchant/homeScreenMerchant.dart';
import 'package:cretex/UI%20Helper/Colors/colors.dart';
import 'package:cretex/UI%20Helper/Gradients/gradients.dart';
import 'package:cretex/Warehousing%20Screens/Warehousing%20Home%20Screen/wareHousingHomeScreen.dart';
import 'package:cretex/WholeSalers%20Screen/WholeSalers%20Home%20Screen/wholeSalersHomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _pulseController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _pulseAnimation;

  bool _isLoading = true;
  String? _error;

  // ── Responsive helpers ───────────────────────────────────────────────────────
  // Reference device: 390 x 844 (iPhone 14)

  double _sw(BuildContext ctx) => MediaQuery.of(ctx).size.width;
  double _sh(BuildContext ctx) => MediaQuery.of(ctx).size.height;

  double _ws(BuildContext ctx, double size) => size * _sw(ctx) / 390;
  double _hs(BuildContext ctx, double size) => size * _sh(ctx) / 844;
  double _fs(BuildContext ctx, double size) =>
      _ws(ctx, size).clamp(size * 0.82, size * 1.18);

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSplashSequence();
  }

  void _setupAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _logoRotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
      ),
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
      ),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Subtle pulse on the logo container after it appears
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _startSplashSequence() {
    _logoController.forward();

    Timer(const Duration(milliseconds: 500), () {
      if (mounted) _textController.forward();
    });

    Timer(const Duration(milliseconds: 3500), () {
      _checkAuthState();
    });
  }

  Future<void> _checkAuthState() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        _navigateToLogin();
        return;
      }

      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) {
        await FirebaseAuth.instance.signOut();
        _navigateToLogin();
        return;
      }

      final Map<String, dynamic>? userData =
      userDoc.data() as Map<String, dynamic>?;
      final String? role = userData?['role'] as String?;

      if (role == null) {
        await FirebaseAuth.instance.signOut();
        _navigateToLogin();
        return;
      }

      _navigateBasedOnRole(role.toLowerCase());
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Authentication error. Redirecting to login...';
          _isLoading = false;
        });
      }
      await Future.delayed(const Duration(seconds: 2));
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }

  void _navigateBasedOnRole(String role) {
    if (!mounted) return;
    switch (role) {
      case 'admin':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdminHomeScreen()),
        );
        break;
      case 'customer':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => CustomerHomeScreen()),
        );
        break;
      case 'merchant':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MerchantHomeScreen()),
        );
        break;
      case 'manufacturer':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ManufacturerHomeScreen()),
        );
        break;
      case 'warehousing':
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => WareHousingHomeScreen()),
              (route) => false,
        );
        break;
      case 'wholesaler':
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => WholesalerHomeScreen()),
              (route) => false,
        );
        break;
      case 'distributer':
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => Distributerhomescreen()),
              (route) => false,
        );
        break;
      default:
        _navigateToLogin();
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // ── BUILD ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF0F4FF), Color(0xFFFFFFFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Decorative circle — top right
            Positioned(
              top: -_hs(context, 80),
              right: -_ws(context, 80),
              child: Container(
                width: _ws(context, 260),
                height: _ws(context, 260),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: MyColors.blueColor.withOpacity(0.06),
                ),
              ),
            ),
            // Decorative circle — bottom left
            Positioned(
              bottom: -_hs(context, 60),
              left: -_ws(context, 60),
              child: Container(
                width: _ws(context, 200),
                height: _ws(context, 200),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: MyColors.blueColor.withOpacity(0.04),
                ),
              ),
            ),

            // ── Main content ──
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScaleAnimation.value,
                        child: Transform.rotate(
                          angle: _logoRotationAnimation.value * 0.5,
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _logoScaleAnimation.value >= 1.0
                                    ? _pulseAnimation.value
                                    : 1.0,
                                child: child,
                              );
                            },
                            child: Container(
                              width: _ws(context, 120),
                              height: _ws(context, 120),
                              decoration: BoxDecoration(
                                gradient: MyGradients.blueGradient,
                                borderRadius:
                                BorderRadius.circular(_ws(context, 30)),
                                boxShadow: [
                                  BoxShadow(
                                    color: MyColors.blueColor.withOpacity(0.35),
                                    blurRadius: _ws(context, 30),
                                    spreadRadius: _ws(context, 4),
                                  ),
                                  BoxShadow(
                                    color: const Color(0xFF764BA2)
                                        .withOpacity(0.15),
                                    blurRadius: _ws(context, 50),
                                    spreadRadius: _ws(context, 8),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(_ws(context, 24)),
                                child: Image.asset(
                                  'Assets/Images/bakaya-logo.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: _hs(context, 40)),

                  // App name + tagline
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _textFadeAnimation,
                        child: SlideTransition(
                          position: _textSlideAnimation,
                          child: Column(
                            children: [
                              Text(
                                'CRETEX',
                                style: TextStyle(
                                  fontSize: _fs(context, 42),
                                  fontWeight: FontWeight.w200,
                                  color: MyColors.blueColor,
                                  letterSpacing: _ws(context, 8),
                                ),
                              ),
                              SizedBox(height: _hs(context, 10)),
                              // Divider line
                              Container(
                                width: _ws(context, 50),
                                height: 1.5,
                                decoration: BoxDecoration(
                                  gradient: MyGradients.blueGradient,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              SizedBox(height: _hs(context, 12)),
                              Text(
                                'Manage your business with ease',
                                style: TextStyle(
                                  fontSize: _fs(context, 14),
                                  color: MyColors.blueColor.withOpacity(0.65),
                                  letterSpacing: _ws(context, 0.8),
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: _hs(context, 70)),

                  // Loading / Error indicator
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _textFadeAnimation,
                        child: _error != null
                            ? _buildErrorState(context)
                            : _buildLoadingState(context),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Bottom branding
            Positioned(
              bottom: _hs(context, 48),
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _textFadeAnimation,
                    child: Column(
                      children: [
                        // Small dots decoration
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (i) {
                            return Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: _ws(context, 3)),
                              width: _ws(context, i == 1 ? 16 : 6),
                              height: _ws(context, 6),
                              decoration: BoxDecoration(
                                color: MyColors.blueColor
                                    .withOpacity(i == 1 ? 0.5 : 0.2),
                                borderRadius:
                                BorderRadius.circular(_ws(context, 3)),
                              ),
                            );
                          }),
                        ),
                        SizedBox(height: _hs(context, 12)),
                        Text(
                          'Powered by Clusters',
                          style: TextStyle(
                            fontSize: _fs(context, 13),
                            color: MyColors.blueColor.withOpacity(0.45),
                            letterSpacing: _ws(context, 0.8),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Loading state ────────────────────────────────────────────────────────────

  Widget _buildLoadingState(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: _ws(context, 28),
          height: _ws(context, 28),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              MyColors.blueColor.withOpacity(0.6),
            ),
          ),
        ),
        SizedBox(height: _hs(context, 16)),
        Text(
          'Loading...',
          style: TextStyle(
            fontSize: _fs(context, 13),
            color: MyColors.blueColor.withOpacity(0.5),
            letterSpacing: _ws(context, 1),
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  // ── Error state ──────────────────────────────────────────────────────────────

  Widget _buildErrorState(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(_ws(context, 12)),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.error_outline_rounded,
            size: _ws(context, 28),
            color: Colors.red.shade400,
          ),
        ),
        SizedBox(height: _hs(context, 14)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: _ws(context, 40)),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.red.shade400,
              fontSize: _fs(context, 13),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        SizedBox(height: _hs(context, 16)),
        SizedBox(
          width: _ws(context, 22),
          height: _ws(context, 22),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor:
            AlwaysStoppedAnimation<Color>(MyColors.blueColor.withOpacity(0.5)),
          ),
        ),
      ],
    );
  }
}