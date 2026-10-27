import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:interactive_radar_chart/interactive_radar_chart.dart';

void main() {
  runApp(const InteractiveRadarDemoApp());
}

class InteractiveRadarDemoApp extends StatefulWidget {
  const InteractiveRadarDemoApp({super.key});

  @override
  State<InteractiveRadarDemoApp> createState() =>
      _InteractiveRadarDemoAppState();
}

enum DemoThemeType { dark, light, cyberpunk }

class _InteractiveRadarDemoAppState extends State<InteractiveRadarDemoApp> {
  DemoThemeType _selectedTheme = DemoThemeType.dark;

  InteractiveRadarTheme get _radarTheme {
    switch (_selectedTheme) {
      case DemoThemeType.dark:
        return InteractiveRadarTheme.dark();
      case DemoThemeType.light:
        return InteractiveRadarTheme.light();
      case DemoThemeType.cyberpunk:
        return InteractiveRadarTheme.cyberpunk();
    }
  }

  Color get _scaffoldColor {
    switch (_selectedTheme) {
      case DemoThemeType.dark:
        return const Color(0xFF0F172A);
      case DemoThemeType.light:
        return const Color(0xFFF8FAFC);
      case DemoThemeType.cyberpunk:
        return const Color(0xFF090514);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'interactive_radar_chart — Interactive Showcase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: _selectedTheme == DemoThemeType.light
            ? Brightness.light
            : Brightness.dark,
        scaffoldBackgroundColor: _scaffoldColor,
        useMaterial3: true,
      ),
      home: RadarDemoScreen(
        radarTheme: _radarTheme,
        themeType: _selectedTheme,
        onThemeChanged: (t) => setState(() => _selectedTheme = t),
      ),
    );
  }
}

class RadarDemoScreen extends StatefulWidget {
  const RadarDemoScreen({
    super.key,
    required this.radarTheme,
    required this.themeType,
    required this.onThemeChanged,
  });

  final InteractiveRadarTheme radarTheme;
  final DemoThemeType themeType;
  final ValueChanged<DemoThemeType> onThemeChanged;

  @override
  State<RadarDemoScreen> createState() => _RadarDemoScreenState();
}

class _RadarDemoScreenState extends State<RadarDemoScreen> {
  bool _copiedCommand = false;
  bool _snapToFive = true;
  RadarGridShape _shape = RadarGridShape.polygon;

  List<RadarEntry> _playerEntries = const [
    RadarEntry(label: 'Attack', value: 75),
    RadarEntry(label: 'Defense', value: 60),
    RadarEntry(label: 'Agility', value: 85),
    RadarEntry(label: 'Magic', value: 50),
    RadarEntry(label: 'Vitality', value: 70),
  ];

  final List<RadarEntry> _bossEntries = const [
    RadarEntry(label: 'Attack', value: 90),
    RadarEntry(label: 'Defense', value: 80),
    RadarEntry(label: 'Agility', value: 65),
    RadarEntry(label: 'Magic', value: 85),
    RadarEntry(label: 'Vitality', value: 95),
  ];

  Future<void> _copyPubCommand() async {
    await Clipboard.setData(
      const ClipboardData(text: 'flutter pub add interactive_radar_chart'),
    );
    HapticFeedback.lightImpact();
    setState(() => _copiedCommand = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copiedCommand = false);
    });
  }

  void _applyBuildPreset(String name) {
    setState(() {
      switch (name) {
        case 'Tank':
          _playerEntries = const [
            RadarEntry(label: 'Attack', value: 55),
            RadarEntry(label: 'Defense', value: 95),
            RadarEntry(label: 'Agility', value: 40),
            RadarEntry(label: 'Magic', value: 30),
            RadarEntry(label: 'Vitality', value: 100),
          ];
        case 'Assassin':
          _playerEntries = const [
            RadarEntry(label: 'Attack', value: 95),
            RadarEntry(label: 'Defense', value: 40),
            RadarEntry(label: 'Agility', value: 100),
            RadarEntry(label: 'Magic', value: 45),
            RadarEntry(label: 'Vitality', value: 50),
          ];
        case 'Archmage':
          _playerEntries = const [
            RadarEntry(label: 'Attack', value: 40),
            RadarEntry(label: 'Defense', value: 50),
            RadarEntry(label: 'Agility', value: 60),
            RadarEntry(label: 'Magic', value: 100),
            RadarEntry(label: 'Vitality', value: 65),
          ];
        case 'Balanced':
          _playerEntries = const [
            RadarEntry(label: 'Attack', value: 75),
            RadarEntry(label: 'Defense', value: 75),
            RadarEntry(label: 'Agility', value: 75),
            RadarEntry(label: 'Magic', value: 75),
            RadarEntry(label: 'Vitality', value: 75),
          ];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeTheme = widget.radarTheme.gridShape == _shape
        ? widget.radarTheme
        : InteractiveRadarTheme(
            gridColor: widget.radarTheme.gridColor,
            axisColor: widget.radarTheme.axisColor,
            labelColor: widget.radarTheme.labelColor,
            handleColor: widget.radarTheme.handleColor,
            activeHandleColor: widget.radarTheme.activeHandleColor,
            divisions: widget.radarTheme.divisions,
            gridShape: _shape,
          );

    final dataSets = [
      // 1. Benchmark Silhouette (Boss)
      RadarDataSet(
        entries: _bossEntries,
        fillColor: const Color(0x228B5CF6),
        borderColor: const Color(0x668B5CF6),
        borderWidth: 1.5,
        isInteractive: false,
      ),
      // 2. Interactive Player Build
      RadarDataSet(
        entries: _playerEntries,
        fillColor: const Color(0x3310B981),
        borderColor: const Color(0xFF10B981),
        borderWidth: 2.5,
        entryRadius: 6.0,
        isInteractive: true,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.radar_rounded, color: Color(0xFF10B981), size: 20),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'interactive_radar_chart',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6.0,
                vertical: 2.0,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: const Text(
                'v1.0.0',
                style: TextStyle(
                  fontSize: 11.0,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF10B981),
                ),
              ),
            ),
          ],
        ),
        actions: [
          // 1-Tap Copy Install Button
          InkWell(
            onTap: _copyPubCommand,
            borderRadius: BorderRadius.circular(6.0),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: _copiedCommand
                    ? const Color(0xFF10B981).withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6.0),
                border: Border.all(
                  color: _copiedCommand
                      ? const Color(0xFF10B981)
                      : Colors.white.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _copiedCommand ? Icons.check : Icons.terminal_rounded,
                    size: 14,
                    color: _copiedCommand
                        ? const Color(0xFF10B981)
                        : Colors.white70,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _copiedCommand ? 'Copied pub add!' : 'pub add',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _copiedCommand
                          ? const Color(0xFF10B981)
                          : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<DemoThemeType>(
              value: widget.themeType,
              icon: const Icon(Icons.palette_outlined, size: 18),
              onChanged: (t) {
                if (t != null) widget.onThemeChanged(t);
              },
              items: const [
                DropdownMenuItem(
                  value: DemoThemeType.dark,
                  child: Text('Dark Slate'),
                ),
                DropdownMenuItem(
                  value: DemoThemeType.light,
                  child: Text('Light Clean'),
                ),
                DropdownMenuItem(
                  value: DemoThemeType.cyberpunk,
                  child: Text('Cyberpunk'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'RPG Skill Tree & Polygon Evaluator',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6.0),
                const Text(
                  'Grab any green handle and drag radially along its axis. Features magnetic step snapping and benchmark overlay comparison.',
                  style: TextStyle(fontSize: 14.0, color: Colors.grey),
                ),
                const SizedBox(height: 20.0),

                // Radar Chart Canvas
                Container(
                  height: 340,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: InteractiveRadarChart(
                    dataSets: dataSets,
                    minValue: 0,
                    maxValue: 100,
                    step: _snapToFive ? 5.0 : null,
                    theme: activeTheme,
                    onValuesChanged: (vals) {
                      setState(() {
                        _playerEntries = List.generate(_playerEntries.length, (
                          i,
                        ) {
                          return _playerEntries[i].copyWith(value: vals[i]);
                        });
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20.0),

                // Live Attribute Chips
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _playerEntries.map((entry) {
                    return Chip(
                      avatar: CircleAvatar(
                        backgroundColor: const Color(0xFF10B981),
                        child: Text(
                          '${entry.value.round()}',
                          style: const TextStyle(
                            fontSize: 10.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      label: Text('${entry.label}: ${entry.value.round()}/100'),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24.0),

                // Class Presets & Controls
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6.0,
                  runSpacing: 6.0,
                  children: [
                    const Text(
                      'Build Presets: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    ActionChip(
                      label: const Text('Tank'),
                      onPressed: () => _applyBuildPreset('Tank'),
                    ),
                    ActionChip(
                      label: const Text('Assassin'),
                      onPressed: () => _applyBuildPreset('Assassin'),
                    ),
                    ActionChip(
                      label: const Text('Archmage'),
                      onPressed: () => _applyBuildPreset('Archmage'),
                    ),
                    ActionChip(
                      label: const Text('Balanced'),
                      onPressed: () => _applyBuildPreset('Balanced'),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),

                // Options Row
                Wrap(
                  spacing: 12.0,
                  runSpacing: 8.0,
                  children: [
                    FilterChip(
                      label: const Text('Magnetic Snap (Step: 5)'),
                      selected: _snapToFive,
                      onSelected: (val) => setState(() => _snapToFive = val),
                    ),
                    FilterChip(
                      label: Text(
                        _shape == RadarGridShape.polygon
                            ? 'Polygon Web'
                            : 'Circular Web',
                      ),
                      selected: _shape == RadarGridShape.circle,
                      onSelected: (val) => setState(() {
                        _shape = val
                            ? RadarGridShape.circle
                            : RadarGridShape.polygon;
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
