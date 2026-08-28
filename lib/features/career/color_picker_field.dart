import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/color_hex.dart';
import '../../core/utils/editor_input_formatters.dart';

class ColorPickerField extends StatefulWidget {
  const ColorPickerField({
    super.key,
    required this.controller,
    required this.label,
  });

  final TextEditingController controller;
  final String label;

  @override
  State<ColorPickerField> createState() => _ColorPickerFieldState();
}

class _ColorPickerFieldState extends State<ColorPickerField> {
  @override
  Widget build(BuildContext context) {
    Color color;
    try {
      color = Color(ColorHex.parse(widget.controller.text));
    } catch (_) {
      color = AppColors.muted;
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          InkWell(
            onTap: _pick,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 2),
              ),
              child: const Icon(Icons.colorize_rounded, size: 18),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: widget.controller,
              inputFormatters: const [HexColorInputFormatter()],
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: widget.label,
                hintText: 'RRGGBB',
                counterText: '',
                suffixIcon: IconButton(
                  tooltip: 'Escolher visualmente',
                  onPressed: _pick,
                  icon: const Icon(Icons.palette_outlined),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pick() async {
    int initial;
    try {
      initial = ColorHex.parse(widget.controller.text);
    } catch (_) {
      initial = 0xFFFFFFFF;
    }
    final result = await showDialog<int>(
      context: context,
      builder: (context) => _RgbColorDialog(initial: Color(initial)),
    );
    if (result == null || !mounted) return;
    widget.controller.text = ColorHex.format(result);
    setState(() {});
  }
}

class _RgbColorDialog extends StatefulWidget {
  const _RgbColorDialog({required this.initial});
  final Color initial;

  @override
  State<_RgbColorDialog> createState() => _RgbColorDialogState();
}

class _RgbColorDialogState extends State<_RgbColorDialog> {
  late double _r;
  late double _g;
  late double _b;

  @override
  void initState() {
    super.initState();
    _r = widget.initial.r * 255;
    _g = widget.initial.g * 255;
    _b = widget.initial.b * 255;
  }

  Color get _color => Color.fromARGB(255, _r.round(), _g.round(), _b.round());

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Escolher cor'),
        content: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 72,
                decoration: BoxDecoration(
                  color: _color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                alignment: Alignment.center,
                child: Text(
                  ColorHex.format(_color.toARGB32()),
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: _color.computeLuminance() > .5 ? Colors.black : Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _channel('Vermelho', _r, (value) => setState(() => _r = value)),
              _channel('Verde', _g, (value) => setState(() => _g = value)),
              _channel('Azul', _b, (value) => setState(() => _b = value)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(context, _color.toARGB32()),
            child: const Text('Usar cor'),
          ),
        ],
      );

  Widget _channel(String label, double value, ValueChanged<double> onChanged) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ${value.round()}', style: const TextStyle(fontWeight: FontWeight.w800)),
          Slider(value: value, min: 0, max: 255, divisions: 255, onChanged: onChanged),
        ],
      );
}
