# interactive_radar_chart

<p align="center">
  <a href="https://pub.dev/packages/interactive_radar_chart"><img src="https://img.shields.io/pub/v/interactive_radar_chart.svg?style=flat-square&color=blue" alt="Pub Version"></a>
  <a href="https://pub.dev/packages/interactive_radar_chart/score"><img src="https://img.shields.io/pub/points/interactive_radar_chart?style=flat-square&color=2E8B57&label=pub%20points" alt="Pub Points"></a>
  <a href="https://govindtank.github.io/interactive_radar_chart/"><img src="https://img.shields.io/badge/Live%20Demo-Try%20In%20Browser-00ff88?style=flat-square&logo=flutter" alt="Live Demo"></a>
  <a href="https://pub.dev/packages/interactive_radar_chart"><img src="https://img.shields.io/pub/likes/interactive_radar_chart?style=flat-square" alt="Pub Likes"></a>
  <a href="https://github.com/govindtank/interactive_radar_chart/actions"><img src="https://github.com/govindtank/interactive_radar_chart/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-Apache%202.0-blue.svg?style=flat-square" alt="License"></a>
</p>

An interactive polygon radar / spider chart for Flutter. Built for RPG skill builders, assessment diagnostics, and product comparisons with **draggable vertices, magnetic step snapping, multi-layer benchmark overlays, and smooth custom painting**.

---

## ⚡ Why `interactive_radar_chart`?

Existing Flutter chart libraries treat radar/spider charts as strictly static read-only graphics. When developers need to build interactive attribute editors (such as RPG character stat customizers, personality tests, or performance evaluations), they are forced to rebuild geometry from scratch:

* 🎯 **Draggable Vertex Handles**: Grab and drag polygon corners along radial rays with direct touch feedback.
* 🧲 **Magnetic Step Snapping**: Automatically snaps to integer or fractional increments (e.g., steps of 5, 10, or 1–5 stars) with tactile haptic clicks.
* 📊 **Multi-Layer Comparison**: Overlay a read-only benchmark silhouette (e.g. boss/target baseline) behind the editable user polygon.
* 🕸️ **Polygon & Circular Webs**: Switch between classic faceted spider web polygons and smooth concentric circular grid lines.

---

## 🚀 Features

| Feature | Description |
|---|---|
| **🎯 Draggable Vertices** | Touch and drag vertex handles radially along their axis to adjust values in real-time. |
| **🧲 Magnetic Snapping** | Optional step intervals (`step: 5.0`) with subtle haptic ticks on snap thresholds. |
| **📊 Multi-Layer Overlays** | Render multiple polygon layers with custom fill colors, borders, and interaction toggles. |
| **🕸️ Flexible Web Geometries** | Concentric `RadarGridShape.polygon` (spider web) or `RadarGridShape.circle`. |
| **🎨 3 Design Presets** | `dark()` (Slate), `light()` (Clean), and `cyberpunk()` (Neon purple and cyan). |
| **🌐 Multi-Platform** | 100% pure Dart & Flutter with zero native dependencies. Works on iOS, Android, Web, macOS, Windows, and Linux. |

---

## 📦 Installation

Add `interactive_radar_chart` to your `pubspec.yaml`:

```bash
flutter pub add interactive_radar_chart
```

---

## 💡 Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:interactive_radar_chart/interactive_radar_chart.dart';

class MyRadarScreen extends StatefulWidget {
  const MyRadarScreen({super.key});

  @override
  State<MyRadarScreen> createState() => _MyRadarScreenState();
}

class _MyRadarScreenState extends State<MyRadarScreen> {
  List<RadarEntry> _entries = const [
    RadarEntry(label: 'Attack', value: 80),
    RadarEntry(label: 'Defense', value: 65),
    RadarEntry(label: 'Speed', value: 90),
    RadarEntry(label: 'Magic', value: 50),
    RadarEntry(label: 'Vitality', value: 75),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: SizedBox(
          width: 320,
          height: 320,
          child: InteractiveRadarChart(
            dataSets: [
              RadarDataSet(
                entries: _entries,
                fillColor: const Color(0x3310B981),
                borderColor: const Color(0xFF10B981),
                isInteractive: true,
              ),
            ],
            minValue: 0,
            maxValue: 100,
            step: 5.0, // Magnetic snap to steps of 5
            onValuesChanged: (newValues) {
              setState(() {
                _entries = List.generate(_entries.length, (i) {
                  return _entries[i].copyWith(value: newValues[i]);
                });
              });
            },
          ),
        ),
      ),
    );
  }
}
```

---

## 📊 Multi-Layer Comparison (Baseline vs User)

```dart
InteractiveRadarChart(
  dataSets: [
    // 1. Read-only Baseline Silhouette
    RadarDataSet(
      entries: bossBaseline,
      fillColor: const Color(0x228B5CF6),
      borderColor: const Color(0x668B5CF6),
      isInteractive: false,
    ),
    // 2. Interactive User Polygon
    RadarDataSet(
      entries: userStats,
      fillColor: const Color(0x3310B981),
      borderColor: const Color(0xFF10B981),
      isInteractive: true,
    ),
  ],
)
```

---

## 🔗 Related Packages by Author

* **[tactile_fluid_slider](https://pub.dev/packages/tactile_fluid_slider)** — iOS 18 fluid slider with rubber-band squash physics & haptics.
* **[smooth_signature_pad](https://pub.dev/packages/smooth_signature_pad)** — Fountain pen velocity pressure simulation and vector SVG export.
* **[flutter_privacy_vault](https://pub.dev/packages/flutter_privacy_vault)** — App-switcher privacy shield, inactivity auto-lock, and balance masking.
* **[ai_stream_bubble](https://pub.dev/packages/ai_stream_bubble)** — High-performance streaming AI message bubble with DeepSeek reasoning accordions.

---

## 💖 Support the Project

If you find this project useful, consider supporting its active maintenance and future development:

<p align="left">
  <a href="https://buymeacoffee.com/govindtanko"><img src="https://img.shields.io/badge/Buy%20Me%20A%20Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black" alt="Buy Me A Coffee" /></a>
  <a href="https://github.com/sponsors/govindtank"><img src="https://img.shields.io/badge/GitHub%20Sponsors-EA4AAA?style=for-the-badge&logo=github&logoColor=white" alt="GitHub Sponsors" /></a>
  <a href="https://www.patreon.com/govindtank"><img src="https://img.shields.io/badge/Patreon-F96854?style=for-the-badge&logo=patreon&logoColor=white" alt="Patreon" /></a>
</p>

---

## 📄 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

*Maintained with ❤️ by [Govind Tank](https://github.com/govindtank).*
