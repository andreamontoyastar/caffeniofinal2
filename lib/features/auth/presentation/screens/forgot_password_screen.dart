import 'package:animate_do/animate_do.dart';
import 'package:caffenio/core/theme/app_border_radius.dart';
import 'package:caffenio/core/theme/app_colors.dart';
import 'package:caffenio/core/theme/app_spacing.dart';
import 'package:caffenio/core/theme/app_typography.dart';
import 'package:caffenio/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Pantalla de recuperación de contraseña.
///
/// Tiene dos estados:
/// - [_sent == false]: formulario con campo de email.
/// - [_sent == true]: confirmación con instrucciones.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _sent = false;
  String _sentEmail = '';

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // ── Acciones ──────────────────────────────────────────────────────────────

  Future<void> _sendReset() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthProvider>();
    final success = await auth.sendPasswordReset(
      email: _emailController.text.trim(),
    );

    if (success && mounted) {
      setState(() {
        _sent = true;
        _sentEmail = _emailController.text.trim();
      });
    } else if (!success && mounted && auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage!),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(
            borderRadius: AppBorderRadius.mdAll,
          ),
        ),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Recuperar contraseña'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: _sent ? _buildSuccessState() : _buildFormState(),
        ),
      ),
    );
  }

  // ── Estado: formulario ────────────────────────────────────────────────────

  Widget _buildFormState() {
    return SingleChildScrollView(
      key: const ValueKey('form'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: FadeIn(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Gap(AppSpacing.lg),

            // Ilustración
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🔐', style: TextStyle(fontSize: 44)),
                ),
              ),
            ),
            const Gap(AppSpacing.xl),

            // Título
            Text(
              '¿Olvidaste tu contraseña?',
              style: AppTypography.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const Gap(AppSpacing.sm),
            Text(
              'Ingresa tu correo y te enviaremos las instrucciones para restablecerla.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(AppSpacing.xxl),

            // Formulario
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _sendReset(),
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  hintText: 'tu@correo.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ingresa tu correo';
                  final r = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!r.hasMatch(v.trim())) return 'Correo no válido';
                  return null;
                },
              ),
            ),
            const Gap(AppSpacing.xl),

            // Botón
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                return ElevatedButton(
                  onPressed: auth.isActionLoading ? null : _sendReset,
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
                          'Enviar instrucciones',
                          style: AppTypography.button.copyWith(
                            color: Colors.white,
                          ),
                        ),
                );
              },
            ),
            const Gap(AppSpacing.lg),

            // Volver a login
            Center(
              child: TextButton(
                onPressed: () => context.pop(),
                child: Text(
                  'Volver al inicio de sesión',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Estado: éxito ─────────────────────────────────────────────────────────

  Widget _buildSuccessState() {
    return FadeIn(
      key: const ValueKey('success'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ícono de éxito
            Center(
              child: Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(
                  color: AppColors.successContainer,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('✉️', style: TextStyle(fontSize: 48)),
                ),
              ),
            ),
            const Gap(AppSpacing.xl),

            Text(
              '¡Correo enviado!',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.success,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(AppSpacing.md),

            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                children: [
                  const TextSpan(
                    text: 'Enviamos las instrucciones a\n',
                  ),
                  TextSpan(
                    text: _sentEmail,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.onBackground,
                    ),
                  ),
                  const TextSpan(
                    text: '\n\nRevisa tu bandeja de entrada\n'
                        'y sigue los pasos del correo.',
                  ),
                ],
              ),
            ),
            const Gap(AppSpacing.sm),

            Text(
              '¿No lo ves? Revisa la carpeta de spam.',
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
            const Gap(AppSpacing.xxl),

            ElevatedButton(
              onPressed: () => context.pop(),
              child: Text(
                'Volver al inicio de sesión',
                style: AppTypography.button.copyWith(color: Colors.white),
              ),
            ),
            const Gap(AppSpacing.md),

            // Reenviar
            OutlinedButton(
              onPressed: () => setState(() => _sent = false),
              child: Text(
                'Reenviar correo',
                style: AppTypography.button.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
