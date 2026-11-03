import 'package:flutter/material.dart';
import '../services/idle_monitor_service.dart';

class CountdownCard extends StatelessWidget {
  final IdleMonitorService monitor;

  const CountdownCard({super.key, required this.monitor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRotating = monitor.isRotating;
    final isMonitoring = monitor.isMonitoring;

    final primaryColor = isRotating
        ? Colors.amberAccent
        : isMonitoring
            ? const Color(0xFF00E5FF)
            : Colors.grey;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: theme.colorScheme.surface,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            ],
          ),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            // Status Header Badge
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isRotating
                        ? Colors.amberAccent
                        : isMonitoring
                            ? Colors.greenAccent
                            : Colors.orangeAccent,
                    boxShadow: [
                      BoxShadow(
                        color: (isRotating
                                ? Colors.amberAccent
                                : isMonitoring
                                    ? Colors.greenAccent
                                    : Colors.orangeAccent)
                            .withValues(alpha: 0.6),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                Text(
                  isRotating
                      ? 'ROTATING MOUSE NOW...'
                      : isMonitoring
                          ? 'IDLE MONITOR ACTIVE'
                          : 'MONITORING PAUSED',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: isRotating
                        ? Colors.amberAccent
                        : isMonitoring
                            ? Colors.greenAccent
                            : Colors.orangeAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Circular Countdown Timer
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: isMonitoring ? monitor.progress : 0.0,
                    strokeWidth: 10,
                    backgroundColor: Colors.white.withValues(alpha: 0.06),
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isRotating
                          ? Icons.sync
                          : Icons.mouse_rounded,
                      size: 32,
                      color: primaryColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      monitor.formattedRemainingTime,
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'until auto-rotate',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // User Physical Inactivity Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.center,
                spacing: 6,
                runSpacing: 4,
                children: [
                  Icon(
                    Icons.touch_app_outlined,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  Text(
                    'User idle duration: ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    monitor.formattedIdleTime,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isMonitoring
                          ? (monitor.currentSystemIdle.inSeconds >= 270
                              ? Colors.amberAccent
                              : theme.colorScheme.primary)
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
