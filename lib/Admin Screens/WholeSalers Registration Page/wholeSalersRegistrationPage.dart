import 'package:cretex/UI%20Helper/Colors/colors.dart';
import 'package:cretex/UI%20Helper/Gradients/gradients.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WholeSalersRegistrationPage extends StatefulWidget {
  @override
  _WholeSalersRegistrationPageState createState() =>
      _WholeSalersRegistrationPageState();
}

class _WholeSalersRegistrationPageState
    extends State<WholeSalersRegistrationPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _nameController     = TextEditingController();
  final _phoneController    = TextEditingController();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController  = TextEditingController();

  final FocusNode _nameFocus     = FocusNode();
  final FocusNode _phoneFocus    = FocusNode();
  final FocusNode _emailFocus    = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _addressFocus  = FocusNode();

  bool _isPasswordVisible = false;
  bool _isLoading         = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _floatController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _floatAnimation;

  // ── Responsive helpers ───────────────────────────────────────────────────────
  double _sw(BuildContext ctx) => MediaQuery.of(ctx).size.width;
  double _sh(BuildContext ctx) => MediaQuery.of(ctx).size.height;
  double _ws(BuildContext ctx, double v) => v * _sw(ctx) / 390;
  double _hs(BuildContext ctx, double v) => v * _sh(ctx) / 844;
  double _fs(BuildContext ctx, double v) =>
      _ws(ctx, v).clamp(v * 0.82, v * 1.18);

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2800),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _floatAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  // ── Firebase registration ────────────────────────────────────────────────────

  Future<void> _registerWholesaler() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.vibrate();
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      final result = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(result.user!.uid)
          .set({
        'manufacturer_name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'address': _addressController.text.trim(),
        'role': 'wholesaler',
        'createdAt': FieldValue.serverTimestamp(),
      });

      HapticFeedback.heavyImpact();
      _showResultDialog(success: true);
    } on FirebaseAuthException catch (e) {
      HapticFeedback.vibrate();
      String msg;
      switch (e.code) {
        case 'email-already-in-use':
          msg = 'This email is already registered.';
          break;
        case 'invalid-email':
          msg = 'The email address is not valid.';
          break;
        case 'weak-password':
          msg = 'Password is too weak. Use at least 6 characters.';
          break;
        default:
          msg = 'Registration failed. Please try again.';
      }
      _showResultDialog(success: false, errorMessage: msg);
    } catch (_) {
      HapticFeedback.vibrate();
      _showResultDialog(
          success: false,
          errorMessage: 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Dialog ───────────────────────────────────────────────────────────────────

  void _showResultDialog({required bool success, String? errorMessage}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: EdgeInsets.all(_ws(context, 28)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: _ws(context, 72),
                height: _ws(context, 72),
                decoration: BoxDecoration(
                  color: success
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  success
                      ? Icons.check_circle_outline_rounded
                      : Icons.error_outline_rounded,
                  color: success
                      ? Colors.green.shade500
                      : Colors.red.shade400,
                  size: _ws(context, 36),
                ),
              ),
              SizedBox(height: _hs(context, 20)),
              Text(
                success ? 'Registered Successfully!' : 'Registration Failed',
                style: TextStyle(
                  fontSize: _fs(context, 20),
                  fontWeight: FontWeight.bold,
                  color: MyColors.blueColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: _hs(context, 10)),
              Text(
                success
                    ? 'Wholesaler has been added to the system.'
                    : errorMessage ?? 'An error occurred.',
                style: TextStyle(
                  fontSize: _fs(context, 14),
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: _hs(context, 24)),
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
                    if (success) Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(_ws(context, 14)),
                    ),
                  ),
                  child: Text(
                    success ? 'Done' : 'Try Again',
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
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _floatController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _addressFocus.dispose();
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
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding:
                  EdgeInsets.symmetric(horizontal: _ws(context, 20)),
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        SizedBox(height: _hs(context, 16)),
                        _buildHeroSection(context),
                        SizedBox(height: _hs(context, 24)),
                        _buildRegistrationForm(context),
                        SizedBox(height: _hs(context, 30)),
                      ],
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

  // ── HEADER ───────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _ws(context, 20),
        vertical: _hs(context, 14),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Container(
              width: _ws(context, 44),
              height: _ws(context, 44),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_ws(context, 12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: MyColors.blueColor,
                size: _ws(context, 18),
              ),
            ),
          ),
          SizedBox(width: _ws(context, 14)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Register',
                style: TextStyle(
                  fontSize: _fs(context, 14),
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade500,
                ),
              ),
              Text(
                'Wholesaler',
                style: TextStyle(
                  fontSize: _fs(context, 24),
                  fontWeight: FontWeight.bold,
                  color: MyColors.blueColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── HERO SECTION ─────────────────────────────────────────────────────────────

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(_ws(context, 22)),
      decoration: BoxDecoration(
        gradient: MyGradients.blueGradient,
        borderRadius: BorderRadius.circular(_ws(context, 24)),
        boxShadow: [
          BoxShadow(
            color: MyColors.blueColor.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Decorative circles
          Positioned(
            top: -_ws(context, 30),
            right: -_ws(context, 30),
            child: Container(
              width: _ws(context, 110),
              height: _ws(context, 110),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -_ws(context, 20),
            left: -_ws(context, 20),
            child: Container(
              width: _ws(context, 80),
              height: _ws(context, 80),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Row(
            children: [
              // Floating icon box
              AnimatedBuilder(
                animation: _floatController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                        0,
                        -5 *
                            (0.5 +
                                0.5 *
                                    (_floatAnimation.value * 2 - 1)
                                        .clamp(-1.0, 1.0))),
                    child: child,
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(_ws(context, 16)),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(_ws(context, 18)),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.3), width: 1),
                  ),
                  child: Icon(
                    Icons.store_outlined,
                    color: Colors.white,
                    size: _ws(context, 32),
                  ),
                ),
              ),
              SizedBox(width: _ws(context, 16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add New Wholesaler',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _fs(context, 18),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: _hs(context, 5)),
                    Text(
                      'Fill in the details below to register\na new wholesaling partner.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: _fs(context, 13),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── REGISTRATION FORM ────────────────────────────────────────────────────────

  Widget _buildRegistrationForm(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(_ws(context, 22)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_ws(context, 24)),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title
            Row(
              children: [
                Container(
                  width: _ws(context, 4),
                  height: _ws(context, 22),
                  decoration: BoxDecoration(
                    gradient: MyGradients.blueGradient,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(width: _ws(context, 10)),
                Text(
                  'Registration Details',
                  style: TextStyle(
                    fontSize: _fs(context, 18),
                    fontWeight: FontWeight.bold,
                    color: MyColors.blueColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: _hs(context, 22)),

            _buildField(
              context,
              label: 'Wholesaler Name',
              hint: 'Enter wholesaler name',
              icon: Icons.store_outlined,
              controller: _nameController,
              focusNode: _nameFocus,
              nextFocus: _phoneFocus,
              validator: (v) =>
              v!.trim().isEmpty ? 'Enter wholesaler name' : null,
            ),
            SizedBox(height: _hs(context, 16)),

            _buildField(
              context,
              label: 'Phone Number',
              hint: 'Enter phone number',
              icon: Icons.phone_outlined,
              controller: _phoneController,
              focusNode: _phoneFocus,
              nextFocus: _emailFocus,
              keyboardType: TextInputType.phone,
              validator: (v) =>
              v!.trim().isEmpty ? 'Enter phone number' : null,
            ),
            SizedBox(height: _hs(context, 16)),

            _buildField(
              context,
              label: 'Email Address',
              hint: 'Enter email address',
              icon: Icons.email_outlined,
              controller: _emailController,
              focusNode: _emailFocus,
              nextFocus: _passwordFocus,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v!.trim().isEmpty) return 'Enter email address';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(v)) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            SizedBox(height: _hs(context, 16)),

            _buildField(
              context,
              label: 'Password',
              hint: 'Minimum 6 characters',
              icon: Icons.lock_outline,
              controller: _passwordController,
              focusNode: _passwordFocus,
              nextFocus: _addressFocus,
              obscureText: !_isPasswordVisible,
              validator: (v) => v!.length < 6
                  ? 'Password must be at least 6 characters'
                  : null,
              suffix: IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: MyColors.pinkColor,
                  size: _ws(context, 20),
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() => _isPasswordVisible = !_isPasswordVisible);
                },
              ),
            ),
            SizedBox(height: _hs(context, 16)),

            _buildField(
              context,
              label: 'Address',
              hint: 'Enter full address',
              icon: Icons.location_on_outlined,
              controller: _addressController,
              focusNode: _addressFocus,
              maxLines: 3,
              textInputAction: TextInputAction.done,
              validator: (v) =>
              v!.trim().isEmpty ? 'Enter address' : null,
            ),

            SizedBox(height: _hs(context, 28)),
            _buildRegisterButton(context),
          ],
        ),
      ),
    );
  }

  // ── FIELD ────────────────────────────────────────────────────────────────────

  Widget _buildField(
      BuildContext context, {
        required String label,
        required String hint,
        required IconData icon,
        required TextEditingController controller,
        required FocusNode focusNode,
        FocusNode? nextFocus,
        TextInputType? keyboardType,
        bool obscureText = false,
        int maxLines = 1,
        TextInputAction? textInputAction,
        required String? Function(String?) validator,
        Widget? suffix,
      }) {
    final radius = _ws(context, 14);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
              left: _ws(context, 2), bottom: _hs(context, 6)),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: _fs(context, 10.5),
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
              letterSpacing: 0.8,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          textInputAction: textInputAction ??
              (nextFocus != null
                  ? TextInputAction.next
                  : TextInputAction.done),
          onFieldSubmitted: (_) {
            if (nextFocus != null) {
              FocusScope.of(context).requestFocus(nextFocus);
            }
          },
          validator: validator,
          style: TextStyle(
            fontSize: _fs(context, 15),
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: _fs(context, 14),
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.all(_ws(context, 12)),
              child: Icon(
                icon,
                color: MyColors.pinkColor,
                size: _ws(context, 20),
              ),
            ),
            suffixIcon: suffix,
            filled: true,
            fillColor: const Color(0xFFF7F8FA),
            contentPadding: EdgeInsets.symmetric(
              horizontal: _ws(context, 16),
              vertical: _hs(context, 16),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide:
              BorderSide(color: MyColors.blueColor, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide(color: Colors.red.shade300),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide:
              BorderSide(color: Colors.red.shade400, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // ── REGISTER BUTTON ──────────────────────────────────────────────────────────

  Widget _buildRegisterButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: _hs(context, 54),
      decoration: BoxDecoration(
        gradient: MyGradients.blueGradient,
        borderRadius: BorderRadius.circular(_ws(context, 14)),
        boxShadow: [
          BoxShadow(
            color: MyColors.blueColor.withOpacity(0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(_ws(context, 14)),
          onTap: _isLoading ? null : _registerWholesaler,
          child: Center(
            child: _isLoading
                ? SizedBox(
              width: _ws(context, 22),
              height: _ws(context, 22),
              child: const CircularProgressIndicator(
                valueColor:
                AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2.5,
              ),
            )
                : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person_add_outlined,
                  color: Colors.white,
                  size: _ws(context, 20),
                ),
                SizedBox(width: _ws(context, 10)),
                Text(
                  'Register Wholesaler',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _fs(context, 16),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}