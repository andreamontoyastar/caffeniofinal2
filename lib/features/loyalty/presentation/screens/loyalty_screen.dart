import 'package:caffenio/core/services/service_locator.dart';
import 'package:caffenio/core/theme/app_border_radius.dart';
import 'package:caffenio/core/theme/app_spacing.dart';
import 'package:caffenio/features/auth/presentation/providers/auth_provider.dart';
import 'package:caffenio/features/loyalty/data/models/loyalty_card_model.dart';
import 'package:caffenio/features/loyalty/domain/usecases/get_loyalty_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LoyaltyScreen extends StatelessWidget {
  const LoyaltyScreen({super.key});

  String _levelLabel(String level) {
    switch (level) {
      case 'platinum':
      case 'platino':
        return 'Platino';
      case 'gold':
      case 'oro':
        return 'Oro';
      case 'silver':
      case 'plata':
        return 'Plata';
      default:
        return 'Bronce';
    }
  }

  String _nextLevelLabel(int points) {
    if (points >= 3000) return 'Máximo';
    if (points >= 1500) return 'Platino';
    if (points >= 500) return 'Oro';
    return 'Plata';
  }

  double _progress(int points) {
    if (points >= 3000) return 1;
    if (points >= 1500) return (points - 1500) / 1500;
    if (points >= 500) return (points - 500) / 1000;
    return points / 500;
  }

  int _pointsToNext(int points) {
    if (points >= 3000) return 0;
    if (points >= 1500) return 3000 - points;
    if (points >= 500) return 1500 - points;
    return 500 - points;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final uid = auth.currentUser?.uid;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mi Tarjeta Lealtad')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Inicia sesión para ver tus puntos de lealtad.',
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  onPressed: () => context.go('/auth/login'),
                  child: const Text('Iniciar sesión'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Tarjeta Lealtad',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: StreamBuilder<LoyaltyCardModel?>(
        stream: sl<GetLoyaltyCard>().call(uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'No se pudo cargar tu tarjeta de lealtad.',
                style: theme.textTheme.bodyLarge,
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final points = snapshot.data?.points ?? 0;
          final level = snapshot.data?.level ?? 'bronze';
          final progress = _progress(points);
          final missing = _pointsToNext(points);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 4,
                  shape: const RoundedRectangleBorder(
                      borderRadius: AppBorderRadius.lgAll),
                  color: colorScheme.primary,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.coffee,
                                color: colorScheme.onPrimary, size: 36),
                            Text(
                              _levelLabel(level).toUpperCase(),
                              style: TextStyle(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          'PUNTOS DISPONIBLES',
                          style: TextStyle(
                            color: colorScheme.onPrimary.withValues(alpha: 0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$points pts',
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          auth.currentUser?.displayNameOrEmail ??
                              'Cliente Caffenio',
                          style: TextStyle(
                            color: colorScheme.onPrimary.withValues(alpha: 0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tu progreso hacia el siguiente nivel',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 10,
                            backgroundColor:
                                colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.secondary),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          missing > 0
                              ? 'Te faltan $missing puntos para ${_nextLevelLabel(points)}.'
                              : '¡Felicidades! Has alcanzado el nivel máximo.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Cómo ganar puntos',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.sm),
                const ListTile(
                  leading: Icon(Icons.shopping_bag_outlined),
                  title: Text('1 punto por cada \$1 MXN en pedidos'),
                  subtitle: Text(
                      'Los puntos se suman al confirmar tu compra en la app.'),
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Cuenta nueva'),
                  subtitle: Text(
                    points == 0
                        ? 'Empiezas con 0 puntos hasta tu primer pedido.'
                        : 'Total ganado en pedidos: ${snapshot.data?.totalEarned ?? 0} pts.',
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
