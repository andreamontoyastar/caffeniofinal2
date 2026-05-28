import 'package:caffenio/core/constants/route_constants.dart';
import 'package:caffenio/core/theme/app_border_radius.dart';
import 'package:caffenio/core/theme/app_spacing.dart';
import 'package:caffenio/features/auth/domain/entities/user_entity.dart';
import 'package:caffenio/features/auth/presentation/providers/auth_provider.dart';
import 'package:caffenio/features/settings/presentation/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final settingsProvider = context.watch<SettingsProvider>();

    final user = authProvider.currentUser;
    final String avatarLetter =
        user != null && user.displayNameOrEmail.isNotEmpty
            ? user.displayNameOrEmail.substring(0, 1).toUpperCase()
            : 'C';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Cuenta',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Cabecera de usuario
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    avatarLetter,
                    style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  user?.displayName ?? 'Cliente Caffenio',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  user?.email ?? 'correo@caffenio.com',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          Card(
            shape: const RoundedRectangleBorder(
                borderRadius: AppBorderRadius.mdAll),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text('Nombre',
                      style: Theme.of(context).textTheme.bodyMedium),
                  subtitle:
                      Text(user?.displayNameOrEmail ?? 'Cliente Caffenio'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: Text('Correo electrónico',
                      style: Theme.of(context).textTheme.bodyMedium),
                  subtitle: Text(user?.email ?? 'correo@caffenio.com'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: Text('Teléfono',
                      style: Theme.of(context).textTheme.bodyMedium),
                  subtitle: Text(user?.phone ?? 'No registrado'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text('Dirección de entrega',
                      style: Theme.of(context).textTheme.bodyMedium),
                  subtitle: Text(user?.address ?? 'No registrada'),
                ),
                const Divider(height: 1),
                if (authProvider.canAddPassword) ...[
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: Text(
                      'Agregar contraseña',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    subtitle: Text(
                      'Activa inicio con correo y contraseña además de Google',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showAddPasswordDialog(
                      context,
                      authProvider,
                      user?.email ?? '',
                    ),
                  ),
                  const Divider(height: 1),
                ],
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _showEditProfileDialog(context, authProvider, user),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar perfil'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Sección de Ajustes de la App
          Text('PREFERENCIAS Y CONFIGURACIÓN',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  letterSpacing: 1.1)),
          const SizedBox(height: AppSpacing.sm),

          Card(
            shape: const RoundedRectangleBorder(
                borderRadius: AppBorderRadius.mdAll),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(Icons.dark_mode,
                      color: Theme.of(context).colorScheme.onSurface),
                  title: Text('Modo Oscuro',
                      style: Theme.of(context).textTheme.bodyMedium),
                  subtitle: Text('Cambiar la paleta visual de la aplicación',
                      style: Theme.of(context).textTheme.bodySmall),
                  value: settingsProvider.themeMode == ThemeMode.dark,
                  onChanged: (bool value) async {
                    await settingsProvider.toggleTheme(value);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.notifications_active,
                      color: Theme.of(context).colorScheme.onSurface),
                  title: Text('Notificaciones Push',
                      style: Theme.of(context).textTheme.bodyMedium),
                  subtitle: Text('Alertas sobre tus pedidos en preparación',
                      style: Theme.of(context).textTheme.bodySmall),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(RouteConstants.notifications),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Acciones de Cuenta
          Card(
            shape: const RoundedRectangleBorder(
                borderRadius: AppBorderRadius.mdAll),
            child: ListTile(
              leading: Icon(Icons.logout,
                  color: Theme.of(context).colorScheme.error),
              title: Text('Cerrar Sesión',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.bold)),
              onTap: () async {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                await authProvider.signOut();
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('Sesión finalizada con éxito.')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddPasswordDialog(
    BuildContext context,
    AuthProvider authProvider,
    String email,
  ) async {
    final formKey = GlobalKey<FormState>();
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    bool obscure = true;
    bool isSubmitting = false;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Agregar contraseña'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Cuenta: $email',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscure,
                      decoration: InputDecoration(
                        labelText: 'Nueva contraseña',
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () =>
                              setState(() => obscure = !obscure),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Mínimo 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: confirmController,
                      obscureText: obscure,
                      decoration: const InputDecoration(
                        labelText: 'Confirmar contraseña',
                      ),
                      validator: (value) {
                        if (value != passwordController.text) {
                          return 'Las contraseñas no coinciden';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      isSubmitting ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (!(formKey.currentState?.validate() ?? false)) {
                            return;
                          }
                          setState(() => isSubmitting = true);
                          final success = await authProvider.linkEmailPassword(
                            email: email,
                            password: passwordController.text,
                          );
                          setState(() => isSubmitting = false);
                          if (!context.mounted) return;
                          if (success) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Contraseña agregada. Ya puedes entrar con correo o Google.',
                                ),
                              ),
                            );
                          } else if (authProvider.errorMessage != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(authProvider.errorMessage!),
                                backgroundColor:
                                    Theme.of(context).colorScheme.error,
                              ),
                            );
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2.2),
                        )
                      : const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    passwordController.dispose();
    confirmController.dispose();
  }

  Future<void> _showEditProfileDialog(
    BuildContext context,
    AuthProvider authProvider,
    UserEntity? user,
  ) async {
    final formKey = GlobalKey<FormState>();
    final TextEditingController nameController =
        TextEditingController(text: (user?.displayName ?? ''));
    final TextEditingController phoneController =
        TextEditingController(text: (user?.phone ?? ''));
    final TextEditingController addressController =
        TextEditingController(text: (user?.address ?? ''));
    bool isSubmitting = false;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Editar perfil'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Nombre'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa tu nombre';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'Teléfono'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa tu teléfono';
                          }
                          final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
                          if (digits.length < 10) {
                            return 'Teléfono no válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: addressController,
                        decoration: const InputDecoration(
                          labelText: 'Dirección de entrega',
                          hintText: 'Calle, Número, Colonia, Ciudad',
                        ),
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa tu dirección de entrega';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      isSubmitting ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (!(formKey.currentState?.validate() ?? false)) {
                            return;
                          }
                          final newName = nameController.text.trim();
                          final newPhone = phoneController.text.trim();
                          final newAddress = addressController.text.trim();

                          if (newName == (user?.displayName ?? '') &&
                              newPhone == (user?.phone ?? '') &&
                              newAddress == (user?.address ?? '')) {
                            Navigator.of(context).pop();
                            return;
                          }

                          setState(() => isSubmitting = true);
                          final success = await authProvider.updateProfile(
                            displayName: newName,
                            phone: newPhone,
                            address: newAddress,
                          );
                          setState(() => isSubmitting = false);
                          if (success) {
                            if (!context.mounted) return;
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Perfil actualizado correctamente.'),
                              ),
                            );
                          } else if (context.mounted &&
                              authProvider.errorMessage != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(authProvider.errorMessage!),
                                backgroundColor:
                                    Theme.of(context).colorScheme.error,
                              ),
                            );
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2.2),
                        )
                      : const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
