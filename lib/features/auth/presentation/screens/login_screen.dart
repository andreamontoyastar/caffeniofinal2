import 'package:animate_do/animate_do.dart';
import 'package:caffenio/core/constants/route_constants.dart';
import 'package:caffenio/core/theme/app_border_radius.dart';
import 'package:caffenio/core/theme/app_colors.dart';
import 'package:caffenio/core/theme/app_spacing.dart';
import 'package:caffenio/core/theme/app_typography.dart';
import 'package:caffenio/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Pantalla de inicio de sesión.
///
/// Diseño: gradiente rojo en la parte superior (40%) +
/// tarjeta blanca con formulario en la parte inferior (60%).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Acciones ──────────────────────────────────────────────────────────────

  Future<void> _signIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthProvider>();
    final success = await auth.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!success && mounted && auth.errorMessage != null) {
      _showErrorSnackBar(auth.errorMessage!);
    }
  }

  Future<void> _signInWithGoogle() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.signInWithGoogle();
    if (!success && mounted && auth.errorMessage != null) {
      _showErrorSnackBar(auth.errorMessage!);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: AppBorderRadius.mdAll,
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Stack(
        children: [
          // ── Fondo gradiente ─────────────────────────────────────────────
          Container(
            height: size.height * 0.45,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF7F0000), AppColors.primaryDark, AppColors.primary],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),

          // ── Contenido principal ─────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Logo area
                SizedBox(
                  height: size.height * 0.38,
                  child: _buildLogoSection(),
                ),

                // Form card — ocupa el resto de la pantalla
                Expanded(
                  child: _buildFormCard(size),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Sección logo ──────────────────────────────────────────────────────────

  Widget _buildLogoSection() {
    return FadeInDown(
      duration: const Duration(milliseconds: 700),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 2,
                ),
              ),
              child: const Center(
                child: Text('☕', style: TextStyle(fontSize: 38)),
              ),
            ),
            const Gap(16),
            Text(
              'Caffenio',
              style: AppTypography.headlineLarge.copyWith(
                color: Colors.white,
                letterSpacing: 1.0,
              ),
            ),
            const Gap(6),
            Text(
              'Bienvenido de vuelta',
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.white.withValues(alpha: 0.80),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tarjeta del formulario ────────────────────────────────────────────────

  Widget _buildFormCard(Size size) {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: AppBorderRadius.topXl,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Campos ────────────────────────────────────────────────
                _buildEmailField(),
                const Gap(AppSpacing.md),
                _buildPasswordField(),
                const Gap(AppSpacing.sm),

                // Olvidé contraseña
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () =>
                        context.push(RouteConstants.forgotPassword),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                    ),
                    child: Text(
                      '¿Olvidaste tu contraseña?',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),

                const Gap(AppSpacing.md),

                // ── Botón principal ───────────────────────────────────────
                _buildSignInButton(),

                const Gap(AppSpacing.lg),
                _buildDivider(),
                const Gap(AppSpacing.lg),

                // ── Google ────────────────────────────────────────────────
                _buildGoogleButton(),
                const Gap(AppSpacing.sm),
                _buildRegisterButton(),
                const Gap(AppSpacing.xl),
                _buildDemoSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDemoSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(13),
        borderRadius: AppBorderRadius.mdAll,
        border: Border.all(
          color: AppColors.primary.withAlpha(38),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.flash_on, color: AppColors.primary, size: 18),
              const Gap(6),
              Text(
                'Acceso Rápido (Modo Demo)',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Gap(4),
          Text(
            'Entra al instante omitiendo Firebase Auth para probar los distintos roles:',
            textAlign: TextAlign.center,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const Gap(AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.read<AuthProvider>().signInDemo(role: 'customer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Cliente', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ),
              const Gap(8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.read<AuthProvider>().signInDemo(role: 'barista'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Barista', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ),
              const Gap(8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.read<AuthProvider>().signInDemo(role: 'admin'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Admin', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Widgets del formulario ────────────────────────────────────────────────

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autocorrect: false,
      decoration: const InputDecoration(
        labelText: 'Correo electrónico',
        hintText: 'tu@correo.com',
        prefixIcon: Icon(Icons.email_outlined),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Ingresa tu correo';
        }
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(value.trim())) {
          return 'Correo no válido';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _signIn(),
      decoration: InputDecoration(
        labelText: 'Contraseña',
        hintText: '••••••••',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: () =>
              setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ingresa tu contraseña';
        }
        if (value.length < 6) {
          return 'Mínimo 6 caracteres';
        }
        return null;
      },
    );
  }

  Widget _buildSignInButton() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return ElevatedButton(
          onPressed: auth.isActionLoading ? null : _signIn,
          child: auth.isActionLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  'Iniciar sesión',
                  style: AppTypography.button.copyWith(color: Colors.white),
                ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text(
            'o continúa con',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return OutlinedButton(
          onPressed: auth.isActionLoading ? null : _signInWithGoogle,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.onBackground,
            side: const BorderSide(color: AppColors.outline),
            minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
            shape: const RoundedRectangleBorder(
              borderRadius: AppBorderRadius.button,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: const Color(0xFF4285F4),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: Text(
                    'G',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const Gap(AppSpacing.sm),
              Text(
                'Continuar con Google',
                style: AppTypography.button.copyWith(
                  color: AppColors.onBackground,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRegisterButton() {
    return OutlinedButton(
      onPressed: () => context.push(RouteConstants.register),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
        shape: const RoundedRectangleBorder(
          borderRadius: AppBorderRadius.button,
        ),
      ),
      child: Text(
        'Registrarse',
        style: AppTypography.button.copyWith(
          color: AppColors.primary,
        ),
      ),
    );
  }


}
