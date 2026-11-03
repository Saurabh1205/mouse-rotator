import 'package:flutter/material.dart';
import '../services/idle_monitor_service.dart';

class ControlsCard extends StatelessWidget {
  final IdleMonitorService monitor;

  const ControlsCard({super.key, required this.monitor});

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
            Text(
              'Actions & Controls',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Main Buttons Row
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: monitor.isMonitoring
                          ? Colors.redAccent.withValues(alpha: 0.15)
                          : Colors.greenAccent.withValues(alpha: 0.15),
                      foregroundColor: monitor.isMonitoring
                          ? Colors.redAccent
                          : Colors.greenAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: monitor.isMonitoring
                              ? Colors.redAccent.withValues(alpha: 0.5)
                              : Colors.greenAccent.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    icon: Icon(
                      monitor.isMonitoring
                          ? Icons.pause_circle_outline
                          : Icons.play_circle_outline,
                      size: 22,
                    ),
                    label: Text(
                      monitor.isMonitoring ? 'Pause Monitor' : 'Resume Monitor',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => monitor.toggleMonitoring(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                      foregroundColor: const Color(0xFF00E5FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    icon: monitor.isRotating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF00E5FF),
                            ),
                          )
                        : const Icon(Icons.rotate_right_rounded, size: 22),
                    label: Text(
                      monitor.isRotating ? 'Rotating...' : 'Test Rotate Now',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: monitor.isRotating ? null : () => monitor.testRotateNow(),
                  ),
                ),
              ],
            ),
            const Divider(height: 36),

            // Inactivity Preset Chips
            Text(
              'Inactivity Threshold',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildIntervalChip(
                  context,
                  label: '4m 30s (Default)',
                  duration: const Duration(minutes: 4, seconds: 30),
                  isDefault: true,
                ),
                _buildIntervalChip(
                  context,
                  label: '1 min',
                  duration: const Duration(minutes: 1),
                ),
                _buildIntervalChip(
                  context,
                  label: '2 min',
                  duration: const Duration(minutes: 2),
                ),
                _buildIntervalChip(
                  context,
                  label: '5 min',
                  duration: const Duration(minutes: 5),
                ),
                _buildIntervalChip(
                  context,
                  label: '10 min',
                  duration: const Duration(minutes: 10),
                ),
              ],
            ),
            const Divider(height: 36),

            // Mouse Circle Radius Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rotation Radius',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${monitor.circleRadius} px',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00E5FF),
                  ),
                ),
              ],
            ),
            Slider(
              value: monitor.circleRadius.toDouble(),
              min: 20,
              max: 120,
              divisions: 20,
              activeColor: const Color(0xFF00E5FF),
              onChanged: (val) => monitor.setCircleRadius(val.round()),
            ),

            // Speed Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rotation Speed',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${monitor.rotationSpeedMs} ms',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00E5FF),
                  ),
                ),
              ],
            ),
            Slider(
              value: monitor.rotationSpeedMs.toDouble(),
              min: 300,
              max: 1500,
              divisions: 12,
              activeColor: const Color(0xFF00E5FF),
              onChanged: (val) => monitor.setRotationSpeedMs(val.round()),
            ),
            const SizedBox(height: 8),

            // Prevent Windows Sleep / Lock switch
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Prevent Windows Sleep & Lock Screen'),
              subtitle: const Text(
                'Sends system signals so the display stays active during idle periods',
              ),
              value: monitor.preventSleep,
              activeThumbColor: const Color(0xFF00E5FF),
              onChanged: (val) => monitor.setPreventSleep(val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntervalChip(
    BuildContext context, {
    required String label,
    required Duration duration,
    bool isDefault = false,
  }) {
    final isSelected = monitor.threshold == duration;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      showCheckmark: false,
      selectedColor: const Color(0xFF00E5FF).withValues(alpha: 0.2),
      side: BorderSide(
        color: isSelected
            ? const Color(0xFF00E5FF)
            : Colors.white.withValues(alpha: 0.15),
      ),
      labelStyle: TextStyle(
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? const Color(0xFF00E5FF) : Colors.white70,
      ),
      onSelected: (_) => monitor.setThreshold(duration),
    );
  }
}
