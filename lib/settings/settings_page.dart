import 'package:flutter/material.dart';
import 'package:image_app1/settings/app_settings.dart';
import 'package:image_app1/widgets/control_pill.dart';
import 'package:image_app1/widgets/nav_arrow_button.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        actions: [
          TextButton.icon(
            onPressed: appSettings.reset,
            icon: const Icon(Icons.restart_alt_rounded),
            label: const Text('Reset to defaults'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: ListenableBuilder(
            listenable: appSettings,
            builder: (context, _) => ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              children: [
                _preview(context),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _toolbarColumn(context)),
                    const SizedBox(width: 32),
                    Expanded(child: _otherColumn(context)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Left column: toolbar ──
  Widget _toolbarColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _section(context, 'Toolbar'),
        _SizeSlider(
          label: 'Text size',
          value: appSettings.pillTextSize,
          min: 10,
          max: 28,
          onChanged: (v) => appSettings.pillTextSize = v,
        ),
        _SizeSlider(
          label: 'Icon size',
          value: appSettings.pillIconSize,
          min: 16,
          max: 48,
          onChanged: (v) => appSettings.pillIconSize = v,
        ),
        _SizeSlider(
          label: 'Opacity',
          value: appSettings.pillOpacity,
          min: 0,
          max: 1,
          divisions: 100,
          display: (v) => '${(v * 100).round()}%',
          onChanged: (v) => appSettings.pillOpacity = v,
        ),
        _BlurSwitch(
          value: appSettings.pillBlur,
          opacity: appSettings.pillOpacity,
          onChanged: (v) => appSettings.pillBlur = v,
        ),
      ],
    );
  }

  // ── Right column: arrows, tooltips, info panel ──
  Widget _otherColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _section(context, 'Arrow buttons'),
        _SizeSlider(
          label: 'Arrow icon size',
          value: appSettings.arrowIconSize,
          min: 16,
          max: 64,
          onChanged: (v) => appSettings.arrowIconSize = v,
        ),
        const SizedBox(height: 16),
        _section(context, 'Tooltips'),
        _SizeSlider(
          label: 'Tooltip text size',
          value: appSettings.tooltipTextSize,
          min: 10,
          max: 24,
          onChanged: (v) => appSettings.tooltipTextSize = v,
        ),
        const SizedBox(height: 16),
        _section(context, 'Details panel'),
        _SizeSlider(
          label: 'Opacity',
          value: appSettings.infoOpacity,
          min: 0,
          max: 1,
          divisions: 100,
          display: (v) => '${(v * 100).round()}%',
          onChanged: (v) => appSettings.infoOpacity = v,
        ),
        _BlurSwitch(
          value: appSettings.infoBlur,
          opacity: appSettings.infoOpacity,
          onChanged: (v) => appSettings.infoBlur = v,
        ),
      ],
    );
  }

  Widget _section(BuildContext context, String title) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      );

  // Preview sits on a bright background on purpose, so you can check
  // readability in the worst case.
  Widget _preview(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        
        // gradient: const LinearGradient(
        //   colors: [Color(0xFFF4F4F4), Color(0xFFCFE3FF)],
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        // ),

        // Added image because this help in seeing the
        // blur effect of the pill
        image: DecorationImage(
          image: AssetImage("assets/strip.png"),
          fit: BoxFit.cover
        )
        
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: ControlPill(
              label: '3 / 24',
              fileName: 'holiday_photo.jpg',
              isFullScreen: false,
              isInfoOpen: false,
              onOpen: () {},
              onZoomOut: () {},
              onZoomIn: () {},
              onRotate: () {},
              onFullscreen: () {},
              onInfo: () {},
              onSettings: () {},
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NavArrowButton(
                  onPressed: () {}, icon: Icons.chevron_left_rounded),
              const SizedBox(width: 12),
              NavArrowButton(
                  onPressed: () {}, icon: Icons.chevron_right_rounded),
              const SizedBox(width: 32),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Tooltip sample',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: appSettings.tooltipTextSize,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BlurSwitch extends StatelessWidget {
  final bool value;
  final double opacity;
  final ValueChanged<bool> onChanged;

  const _BlurSwitch({
    required this.value,
    required this.opacity,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final inactive = opacity <= 0 || opacity >= 1;
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: const Text('Frosted glass blur'),
      subtitle: Text(
        inactive
            ? 'No effect at ${(opacity * 100).round()}% opacity. '
                'Set opacity between 1% and 99% to see it.'
            : 'Blurs the image behind it. Uses more GPU.',
      ),
      value: value,
      onChanged: (v) {
        onChanged(v);
        appSettings.save();
      },
    );
  }
}

class _SizeSlider extends StatelessWidget {
  final String label;
  final double value, min, max;
  final ValueChanged<double> onChanged;
  final int? divisions;
  final String Function(double)? display;

  const _SizeSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
    this.display,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 120, child: Text(label)),
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions ?? (max - min).round(),
            onChanged: onChanged,
            onChangeEnd: (_) => appSettings.save(),
          ),
        ),
        SizedBox(
          width: 48,
          child: Text(
            display?.call(value) ?? '${value.round()} px',
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
