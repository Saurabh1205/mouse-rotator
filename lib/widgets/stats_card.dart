import 'package:flutter/material.dart';
import '../services/idle_monitor_service.dart';

class StatsCard extends StatelessWidget {
  final IdleMonitorService monitor;

  const StatsCard({super.key, required this.monitor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Text(
                  'Activity & Statistics',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${monitor.totalRotations} Rotations',
                    style: const TextStyle(
                      color: Color(0xFF00E5FF),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Metrics row
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 300) {
                  return Column(
                    children: [
                      _buildMetricTile(
                        context,
                        title: 'Total Auto-Rotations',
                        value: '${monitor.totalRotations}',
                        icon: Icons.replay_circle_filled_rounded,
                        accentColor: const Color(0xFF00E5FF),
                      ),
                      const SizedBox(height: 12),
                      _buildMetricTile(
                        context,
                        title: 'Last Rotated',
                        value: monitor.lastRotatedAt == null
                            ? 'None yet'
                            : _formatTimestamp(monitor.lastRotatedAt!),
                        icon: Icons.schedule_rounded,
                        accentColor: Colors.purpleAccent,
                      ),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        context,
                        title: 'Total Auto-Rotations',
                        value: '${monitor.totalRotations}',
                        icon: Icons.replay_circle_filled_rounded,
                        accentColor: const Color(0xFF00E5FF),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricTile(
                        context,
                        title: 'Last Rotated',
                        value: monitor.lastRotatedAt == null
                            ? 'None yet'
                            : _formatTimestamp(monitor.lastRotatedAt!),
                        icon: Icons.schedule_rounded,
                        accentColor: Colors.purpleAccent,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // Recent activity log list
            Text(
              'Recent Activity Log',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            if (monitor.recentLogs.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    'No mouse rotations recorded yet.\nThe mouse will rotate once idle for ${monitor.threshold.inMinutes}m ${monitor.threshold.inSeconds % 60}s.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: monitor.recentLogs.length > 5 ? 5 : monitor.recentLogs.length,
                separatorBuilder: (context, index) => const Divider(height: 12),
                itemBuilder: (context, index) {
                  final log = monitor.recentLogs[index];
                  return Row(
                    children: [
                      Icon(
                        log.isManualTest
                            ? Icons.play_arrow_rounded
                            : Icons.auto_awesome_rounded,
                        size: 18,
                        color: log.isManualTest ? Colors.amberAccent : const Color(0xFF00E5FF),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          log.isManualTest
                              ? 'Manual Test Rotation'
                              : 'Auto Rotation (Idle: ${log.idleDuration.inSeconds}s)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        _formatTimestamp(log.timestamp),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final second = dt.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }
}
