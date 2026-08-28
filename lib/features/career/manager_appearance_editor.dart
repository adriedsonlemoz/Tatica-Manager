import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';

import '../../app/widgets/common.dart';
import '../../app/widgets/manager_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/media/player_photo_store.dart';
import '../../domain/career/manager_appearance.dart';
import '../../domain/career/manager_profile.dart';

Future<ManagerAppearance?> showManagerAppearanceEditor(
  BuildContext context, {
  required ManagerProfile previewManager,
}) => showModalBottomSheet<ManagerAppearance>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => _ManagerAppearanceSheet(
        initial: previewManager.appearance,
        previewManager: previewManager,
      ),
    );

class _ManagerAppearanceSheet extends StatefulWidget {
  const _ManagerAppearanceSheet({
    required this.initial,
    required this.previewManager,
  });

  final ManagerAppearance initial;
  final ManagerProfile previewManager;

  @override
  State<_ManagerAppearanceSheet> createState() => _ManagerAppearanceSheetState();
}

class _ManagerAppearanceSheetState extends State<_ManagerAppearanceSheet> {
  late ManagerAppearance local;
  final PlayerPhotoStore _photoStore = const PlayerPhotoStore();

  @override
  void initState() {
    super.initState();
    local = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    final preview = widget.previewManager.copyWith(appearance: local);
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * .86,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Editar aparência',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Defina rosto, tom de pele, cabelo, barba e detalhes visuais do treinador.',
                        style: TextStyle(color: AppColors.muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: SectionCard(
              child: Row(
                children: [
                  ManagerAvatar(manager: preview, size: 76),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          preview.preferredName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _importPhoto,
                              icon: const Icon(Icons.add_a_photo_outlined, size: 17),
                              label: Text(
                                local.customPhotoPath == null
                                    ? 'Importar foto'
                                    : 'Trocar foto',
                              ),
                            ),
                            if (local.customPhotoPath != null)
                              IconButton.outlined(
                                tooltip: 'Remover foto',
                                onPressed: _removePhoto,
                                icon: const Icon(Icons.delete_outline_rounded),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
              children: [
                _ChoiceSection(
                  title: 'ROSTO',
                  subtitle: 'Formato base do rosto do treinador.',
                  options: const ['Oval', 'Redondo', 'Longo', 'Quadrado'],
                  selected: local.faceShape,
                  onSelected: (value) => _update((a) => a.copyWith(faceShape: value)),
                ),
                _ChoiceSection(
                  title: 'TOM DE PELE',
                  subtitle: 'Paleta usada no avatar.',
                  options: const ['1', '2', '3', '4', '5', '6'],
                  selected: local.skinTone,
                  onSelected: (value) => _update((a) => a.copyWith(skinTone: value)),
                ),
                _ChoiceSection(
                  title: 'CABELO',
                  subtitle: 'Escolha o estilo de cabelo.',
                  options: const ['Curto', 'Lateral', 'Ondulado', 'Cacheado', 'Faixa', 'Picos', 'Careca', 'Longo'],
                  selected: local.hairStyle,
                  onSelected: (value) => _update((a) => a.copyWith(hairStyle: value)),
                ),
                _ChoiceSection(
                  title: 'COR DO CABELO E BARBA',
                  subtitle: 'O avatar atual compartilha o mesmo tom entre cabelo, barba e bigode.',
                  options: const ['Preto', 'Castanho', 'Marrom', 'Loiro', 'Grisalho'],
                  selected: local.hairColor,
                  onSelected: (value) => _update((a) => a.copyWith(hairColor: value)),
                ),
                _ChoiceSection(
                  title: 'OLHOS',
                  subtitle: 'Formato dos olhos.',
                  options: const ['1', '2', '3', '4'],
                  selected: local.eyeStyle,
                  onSelected: (value) => _update((a) => a.copyWith(eyeStyle: value)),
                ),
                _ChoiceSection(
                  title: 'COR DOS OLHOS',
                  subtitle: 'Cor usada no avatar.',
                  options: const ['1', '2', '3', '4', '5'],
                  selected: local.eyeColor,
                  onSelected: (value) => _update((a) => a.copyWith(eyeColor: value)),
                ),
                _ChoiceSection(
                  title: 'SOBRANCELHAS',
                  subtitle: 'Formato das sobrancelhas.',
                  options: const ['1', '2', '3', '4'],
                  selected: local.eyebrowStyle,
                  onSelected: (value) => _update((a) => a.copyWith(eyebrowStyle: value)),
                ),
                _ChoiceSection(
                  title: 'NARIZ',
                  subtitle: 'Formato do nariz.',
                  options: const ['1', '2', '3', '4'],
                  selected: local.noseStyle,
                  onSelected: (value) => _update((a) => a.copyWith(noseStyle: value)),
                ),
                _ChoiceSection(
                  title: 'BOCA',
                  subtitle: 'Formato da boca.',
                  options: const ['1', '2', '3', '4'],
                  selected: local.mouthStyle,
                  onSelected: (value) => _update((a) => a.copyWith(mouthStyle: value)),
                ),
                _ChoiceSection(
                  title: 'BARBA',
                  subtitle: 'Defina o estilo de barba.',
                  options: const ['Nenhuma', 'Leve', 'Cavanhaque', 'Marcada', 'Cheia'],
                  selected: local.beardStyle,
                  onSelected: (value) => _update((a) => a.copyWith(beardStyle: value)),
                ),
                _ChoiceSection(
                  title: 'BIGODE',
                  subtitle: 'Ajuste o bigode separadamente.',
                  options: const ['Nenhum', 'Fino', 'Marcado', 'Cheio'],
                  selected: local.moustacheStyle,
                  onSelected: (value) => _update((a) => a.copyWith(moustacheStyle: value)),
                ),
                _ChoiceSection(
                  title: 'OUTROS DETALHES VISUAIS',
                  subtitle: 'Olhos, expressão e detalhes finais.',
                  options: const ['Suave', 'Firme', 'Focado', 'Expressivo', 'Detalhado'],
                  selected: local.detailStyle,
                  onSelected: (value) => _update((a) => a.copyWith(detailStyle: value)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(local),
                icon: const Icon(Icons.check_circle_rounded),
                label: const Text('Salvar aparência'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _update(ManagerAppearance Function(ManagerAppearance current) update) {
    setState(() => local = update(local));
  }

  Future<void> _importPhoto() async {
    try {
      final source = await openFile(
        acceptedTypeGroups: const [PlayerPhotoStore.acceptedImages],
      );
      if (source == null) return;
      final previewBytes = await source.readAsBytes();
      if (!mounted) return;
      final crop = await _showPhotoCropDialog(previewBytes);
      if (crop == null) return;
      final imported = await _photoStore.importPhoto(
        playerId: 'manager-${widget.previewManager.avatarSeedSource}',
        source: source,
        cropAlignmentX: crop.x,
        cropAlignmentY: crop.y,
        cropZoom: crop.zoom,
      );
      if (!mounted) return;
      setState(() => local = local.copyWith(customPhotoPath: imported));
    } on PlayerPhotoException catch (error) {
      if (!mounted) return;
      await _showPhotoError(error.message);
    } catch (_) {
      if (!mounted) return;
      await _showPhotoError('Não foi possível importar essa foto.');
    }
  }

  void _removePhoto() {
    setState(() => local = local.copyWith(clearCustomPhoto: true));
  }

  Future<_PhotoCropSettings?> _showPhotoCropDialog(Uint8List bytes) {
    var x = 0.0;
    var y = 0.0;
    var zoom = 1.0;
    return showDialog<_PhotoCropSettings>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Ajustar foto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: SizedBox.square(
                    dimension: 220,
                    child: ClipRect(
                      child: Transform.scale(
                        scale: zoom,
                        child: Image.memory(
                          bytes,
                          fit: BoxFit.cover,
                          alignment: Alignment(x, y),
                          gaplessPlayback: true,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Reposicione e aproxime a foto antes de aplicar.',
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                _CropSlider(
                  label: 'Horizontal',
                  value: x,
                  min: -1,
                  max: 1,
                  onChanged: (value) => setDialogState(() => x = value),
                ),
                _CropSlider(
                  label: 'Vertical',
                  value: y,
                  min: -1,
                  max: 1,
                  onChanged: (value) => setDialogState(() => y = value),
                ),
                _CropSlider(
                  label: 'Zoom',
                  value: zoom,
                  min: 1,
                  max: 2.5,
                  onChanged: (value) => setDialogState(() => zoom = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(
                _PhotoCropSettings(x: x, y: y, zoom: zoom),
              ),
              child: const Text('Aplicar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPhotoError(String message) => showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.image_not_supported_outlined),
          title: const Text('Foto não importada'),
          content: Text(message, textAlign: TextAlign.center),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendi'),
            ),
          ],
        ),
      );
}

class _PhotoCropSettings {
  const _PhotoCropSettings({
    required this.x,
    required this.y,
    required this.zoom,
  });

  final double x;
  final double y;
  final double zoom;
}

class _CropSlider extends StatelessWidget {
  const _CropSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      );
}

class _ChoiceSection extends StatelessWidget {
  const _ChoiceSection({
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String title;
  final String subtitle;
  final List<String> options;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: .4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (var index = 0; index < options.length; index++)
                    ChoiceChip(
                      label: Text(options[index]),
                      selected: selected == index,
                      onSelected: (_) => onSelected(index),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
}
