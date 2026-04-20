import 'package:cretex/Admin%20Screens/Home%20Screen%20Admin/homeScreenAdmin.dart';
import 'package:cretex/Common%20Screens/Account%20Signup%20Selection%20Page/accountSignupSelectionPage.dart';
import 'package:cretex/Customer%20Screens/Home%20Screen%20Customer/homeScreenCustomer.dart';
import 'package:cretex/Distributers%20Screen/Distributer%20Home%20Screen/distributerHomeScreen.dart';
import 'package:cretex/Manufacturer%20Screens/Manufacturer%20Home%20Screen/manufacturerHomeScreen.dart';
import 'package:cretex/Merchant%20Screens/Home%20Screen%20Merchant/homeScreenMerchant.dart';
import 'package:cretex/UI%20Helper/Colors/colors.dart';
import 'package:cretex/UI%20Helper/Gradients/gradients.dart';
import 'package:cretex/Warehousing%20Screens/Warehousing%20Home%20Screen/wareHousingHomeScreen.dart';
import 'package:cretex/WholeSalers%20Screen/WholeSalers%20Home%20Screen/wholeSalersHomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  String? _successMessage;

  // ── Responsive helpers ───────────────────────────────────────────────────────
  // Reference device: 390 x 844 (iPhone 14)

  double _sw(BuildContext ctx) => MediaQuery.of(ctx).size.width;
  double _sh(BuildContext ctx) => MediaQuery.of(ctx).size.height;

  /// Scale relative to screen WIDTH (padding, font sizes, radii, icon sizes)
  double _ws(BuildContext ctx, double size) => size * _sw(ctx) / 390;

  /// Scale relative to screen HEIGHT (hero height, vertical gaps, button heights)
  double _hs(BuildContext ctx, double size) => size * _sh(ctx) / 844;

  /// Font size — width-scaled but clamped so text stays readable on all screens
  double _fs(BuildContext ctx, double size) =>
      _ws(ctx, size).clamp(size * 0.82, size * 1.18);

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.elasticOut));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  void _clearMessages() => setState(() {
    _errorMessage = null;
    _successMessage = null;
  });

  void _showError(String message) => setState(() {
    _errorMessage = message;
    _successMessage = null;
  });

  void _showSuccess(String message) => setState(() {
    _successMessage = message;
    _errorMessage = null;
  });

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    _clearMessages();
    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    try {
      final credential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (credential.user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .get();

        if (!userDoc.exists) {
          _showError('User profile not found. Please contact support.');
          await FirebaseAuth.instance.signOut();
          return;
        }

        final userData = userDoc.data();
        final role = userData?['role'] as String?;

        if (role == null) {
          _showError('User role not assigned. Please contact support.');
          await FirebaseAuth.instance.signOut();
          return;
        }

        _showSuccess('Login successful! Redirecting...');
        await Future.delayed(const Duration(milliseconds: 1500));

        if (mounted) {
          switch (role.toLowerCase()) {
            case 'admin':
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => AdminHomeScreen()),
                    (route) => false,
              );
              break;
            case 'customer':
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => CustomerHomeScreen()),
                    (route) => false,
              );
              break;
            case 'merchant':
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => MerchantHomeScreen()),
                    (route) => false,
              );
              break;
            case 'manufacturer':
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => ManufacturerHomeScreen()),
                    (route) => false,
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
              _showError('Invalid user role. Please contact support.');
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No account found with this email address.';
          break;
        case 'wrong-password':
          message = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled. Contact support.';
          break;
        case 'too-many-requests':
          message = 'Too many failed attempts. Please try again later.';
          break;
        case 'network-request-failed':
          message = 'Network error. Please check your connection.';
          break;
        case 'invalid-credential':
          message =
          'Invalid credentials. Please check your email and password.';
          break;
        default:
          message = e.message ?? 'Login failed. Please try again.';
      }
      _showError(message);
    } catch (e) {
      _showError('An unexpected error occurred. Please try again.');
      print(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      _showError('Please enter your email address first.');
      return;
    }
    _clearMessages();
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      _showSuccess('Password reset link sent to your email.');
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No account found with this email address.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'network-request-failed':
          message = 'Network error. Please check your connection.';
          break;
        default:
          message = e.message ?? 'Failed to send reset email.';
      }
      _showError(message);
    } catch (e) {
      _showError('An unexpected error occurred. Please try again.');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── BUILD ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: _ws(context, 20),
            vertical: _hs(context, 10),
          ),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: _hs(context, 20)),
                _buildHeader(context),
                SizedBox(height: _hs(context, 24)),
                SlideTransition(
                  position: _slideAnimation,
                  child: _buildHeroSection(context),
                ),
                SizedBox(height: _hs(context, 20)),
                if (_errorMessage != null) _buildErrorBanner(context),
                if (_successMessage != null) _buildSuccessBanner(context),
                if (_errorMessage != null || _successMessage != null)
                  SizedBox(height: _hs(context, 14)),
                SlideTransition(
                  position: _slideAnimation,
                  child: _buildLoginForm(context),
                ),
                SizedBox(height: _hs(context, 16)),
                SlideTransition(
                  position: _slideAnimation,
                  child: _buildCreateAccountSection(context),
                ),
                SizedBox(height: _hs(context, 20)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── HEADER ───────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    final logoSize = _ws(context, 54);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back',
              style: TextStyle(
                fontSize: _fs(context, 22),
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: _hs(context, 4)),
            Text(
              'Sign In',
              style: TextStyle(
                fontSize: _fs(context, 30),
                fontWeight: FontWeight.bold,
                color: MyColors.blueColor,
              ),
            ),
          ],
        ),
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            gradient: MyGradients.blueGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: MyColors.blueColor.withOpacity(0.35),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Image.asset(
              'Assets/Images/bakaya-logo.png',
              width: _ws(context, 26),
              height: _ws(context, 26),
            ),
          ),
        ),
      ],
    );
  }

  // ── HERO ─────────────────────────────────────────────────────────────────────

  Widget _buildHeroSection(BuildContext context) {
    final heroHeight = _hs(context, 190);
    final pad = _ws(context, 24);

    return Container(
      height: heroHeight,
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
        children: [
          // Decorative circle — top right
          Positioned(
            top: -heroHeight * 0.21,
            right: -heroHeight * 0.21,
            child: Container(
              width: heroHeight * 0.84,
              height: heroHeight * 0.84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          // Decorative circle — bottom left
          Positioned(
            bottom: -heroHeight * 0.16,
            left: -_ws(context, 20),
            child: Container(
              width: heroHeight * 0.63,
              height: heroHeight * 0.63,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.all(pad),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'CRETEX',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: _fs(context, 34),
                          fontWeight: FontWeight.w200,
                          letterSpacing: _ws(context, 5),
                        ),
                      ),
                      SizedBox(height: _hs(context, 6)),
                      Text(
                        'Manage your business with ease',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: _fs(context, 13),
                        ),
                      ),
                      SizedBox(height: _hs(context, 16)),
                      Row(
                        children: [
                          _buildFeatureChip(
                              context, Icons.shield_outlined, 'Secure'),
                          SizedBox(width: _ws(context, 8)),
                          _buildFeatureChip(
                              context, Icons.flash_on_outlined, 'Fast'),
                          SizedBox(width: _ws(context, 8)),
                          _buildFeatureChip(
                              context, Icons.verified_outlined, 'Trusted'),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: _ws(context, 16)),
                Container(
                  padding: EdgeInsets.all(_ws(context, 14)),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(_ws(context, 18)),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.3), width: 1),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Colors.white,
                    size: _ws(context, 38),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _ws(context, 9),
        vertical: _hs(context, 5),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(_ws(context, 20)),
        border:
        Border.all(color: Colors.white.withOpacity(0.28), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: _ws(context, 11)),
          SizedBox(width: _ws(context, 4)),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: _fs(context, 10),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── BANNERS ──────────────────────────────────────────────────────────────────

  Widget _buildErrorBanner(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(_ws(context, 14)),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(_ws(context, 12)),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline,
              color: Colors.red.shade700, size: _ws(context, 22)),
          SizedBox(width: _ws(context, 12)),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.red.shade900,
                fontSize: _fs(context, 13),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close,
                color: Colors.red.shade700, size: _ws(context, 18)),
            onPressed: _clearMessages,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessBanner(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(_ws(context, 14)),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(_ws(context, 12)),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline,
              color: Colors.green.shade700, size: _ws(context, 22)),
          SizedBox(width: _ws(context, 12)),
          Expanded(
            child: Text(
              _successMessage!,
              style: TextStyle(
                color: Colors.green.shade900,
                fontSize: _fs(context, 13),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close,
                color: Colors.green.shade700, size: _ws(context, 18)),
            onPressed: _clearMessages,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  // ── LOGIN FORM ────────────────────────────────────────────────────────────────

  Widget _buildLoginForm(BuildContext context) {
    final pad = _ws(context, 24);
    final radius = _ws(context, 12);

    InputDecoration inputDec({
      required String hint,
      required IconData prefix,
      Widget? suffix,
    }) =>
        InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              color: Colors.grey.shade400, fontSize: _fs(context, 14)),
          prefixIcon: Icon(prefix,
              color: MyColors.pinkColor, size: _ws(context, 20)),
          suffixIcon: suffix,
          filled: true,
          fillColor: const Color(0xFFF7F8FA),
          contentPadding: EdgeInsets.symmetric(
            vertical: _hs(context, 16),
            horizontal: _ws(context, 16),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide(color: MyColors.blueColor, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide(color: Colors.red.shade300),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
          ),
        );

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: EdgeInsets.all(pad),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_ws(context, 20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Login to your account',
                style: TextStyle(
                  fontSize: _fs(context, 22),
                  fontWeight: FontWeight.bold,
                  color: MyColors.blueColor,
                ),
              ),
              SizedBox(height: _hs(context, 22)),

              // ── Email ──
              _buildFieldLabel(context, 'Email Address'),
              SizedBox(height: _hs(context, 8)),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(fontSize: _fs(context, 15)),
                decoration: inputDec(
                  hint: 'you@example.com',
                  prefix: Icons.email_outlined,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please enter your email';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(v)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),

              SizedBox(height: _hs(context, 18)),

              // ── Password ──
              _buildFieldLabel(context, 'Password'),
              SizedBox(height: _hs(context, 8)),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: TextStyle(fontSize: _fs(context, 15)),
                decoration: inputDec(
                  hint: 'Enter your password',
                  prefix: Icons.lock_outline,
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: MyColors.pinkColor,
                      size: _ws(context, 20),
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (v.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),

              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _forgotPassword,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        vertical: _hs(context, 8), horizontal: 4),
                  ),
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: MyColors.blueColor,
                      fontWeight: FontWeight.w600,
                      fontSize: _fs(context, 13),
                    ),
                  ),
                ),
              ),

              SizedBox(height: _hs(context, 6)),

              // ── Sign In button ──
              Container(
                height: _hs(context, 54),
                decoration: BoxDecoration(
                  gradient: MyGradients.blueGradient,
                  borderRadius: BorderRadius.circular(radius),
                  boxShadow: [
                    BoxShadow(
                      color: MyColors.blueColor.withOpacity(0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(radius),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                    height: _ws(context, 20),
                    width: _ws(context, 20),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: _fs(context, 16),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.3,
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

  Widget _buildFieldLabel(BuildContext context, String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: _fs(context, 11),
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade500,
        letterSpacing: 0.9,
      ),
    );
  }

  // ── REGISTER SECTION ──────────────────────────────────────────────────────────

  Widget _buildCreateAccountSection(BuildContext context) {
    final radius = _ws(context, 12);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _ws(context, 20),
        vertical: _hs(context, 18),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_ws(context, 20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Don't have an account?",
                  style: TextStyle(
                    fontSize: _fs(context, 15),
                    fontWeight: FontWeight.w600,
                    color: MyColors.pinkColor,
                  ),
                ),
                SizedBox(height: _hs(context, 3)),
                Text(
                  'Join thousands of users',
                  style: TextStyle(
                    fontSize: _fs(context, 12),
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: _ws(context, 12)),
          Container(
            height: _hs(context, 48),
            decoration: BoxDecoration(
              gradient: MyGradients.blueGradient,
              borderRadius: BorderRadius.circular(radius),
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
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AccountTypeScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(horizontal: _ws(context, 22)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius),
                ),
              ),
              child: Text(
                'Register',
                style: TextStyle(
                  fontSize: _fs(context, 15),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}