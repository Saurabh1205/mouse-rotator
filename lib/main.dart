import 'package:flutter/material.dart';
import 'services/idle_monitor_service.dart';
import 'widgets/countdown_card.dart';
import 'widgets/controls_card.dart';
import 'widgets/stats_card.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MouseRotatorApp());
}

class MouseRotatorApp extends StatelessWidget {
  const MouseRotatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auto Mouse Rotator',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E5FF),
          onPrimary: Colors.black,
          surface: Color(0xFF1E222D),
          surfaceContainerHigh: Color(0xFF262C3A),
          surfaceContainerHighest: Color(0xFF2E3445),
          onSurface: Color(0xFFF0F4F8),
          onSurfaceVariant: Color(0xFF9EAAB7),
        ),
        scaffoldBackgroundColor: const Color(0xFF13161F),
        fontFamily: 'Segoe UI',
        cardTheme: const CardThemeData(
          color: Color(0xFF1E222D),
          elevation: 0,
        ),
      ),
      home: const MouseRotatorHomePage(),
    );
  }
}

class MouseRotatorHomePage extends StatefulWidget {
  const MouseRotatorHomePage({super.key});

  @override
  State<MouseRotatorHomePage> createState() => _MouseRotatorHomePageState();
}

class _MouseRotatorHomePageState extends State<MouseRotatorHomePage> {
  late final IdleMonitorService _monitorService;

  @override
  void initState() {
    super.initState();
    _monitorService = IdleMonitorService();
  }

  @override
  void dispose() {
    _monitorService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.mouse_rounded,
                color: Color(0xFF00E5FF),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Auto Mouse Rotator',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  'Idle rotation after 4 min 30 sec',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          ListenableBuilder(
            listenable: _monitorService,
            builder: (context, _) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Chip(
                  avatar: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _monitorService.isMonitoring
                          ? Colors.greenAccent
                          : Colors.orangeAccent,
                    ),
                  ),
                  label: Text(
                    _monitorService.isMonitoring ? 'Active' : 'Paused',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _monitorService.isMonitoring
                          ? Colors.greenAccent
                          : Colors.orangeAccent,
                    ),
                  ),
                  backgroundColor: theme.colorScheme.surfaceContainerHigh,
                  side: BorderSide.none,
                ),
              );
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _monitorService,
        builder: (context, _) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 720) {
                      // Two-column layout for desktop
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: CountdownCard(monitor: _monitorService),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 6,
                            child: Column(
                              children: [
                                ControlsCard(monitor: _monitorService),
                                const SizedBox(height: 20),
                                StatsCard(monitor: _monitorService),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      // Single-column layout for smaller windows
                      return Column(
                        children: [
                          CountdownCard(monitor: _monitorService),
                          const SizedBox(height: 20),
                          ControlsCard(monitor: _monitorService),
                          const SizedBox(height: 20),
                          StatsCard(monitor: _monitorService),
                        ],
                      );
                    }
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
