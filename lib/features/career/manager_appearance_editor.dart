import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';

import '../../app/widgets/common.dart';
import '../../app/widgets/manager_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/media/player_photo_store.dart';
import '../../domain/career/manager_appearance.dart';
import '../../domain/career/manager_profile.dart';
import 'manager_appearance_components.dart';

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
      height: MediaQuery.sizeOf(context).height * .90,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
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
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
            child: SectionCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ManagerAvatar(manager: preview, size: 68),
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
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              children: [
                AppearanceGroupCard(
                  title: 'ROSTO E PELE',
                  subtitle: 'Base do rosto e tom de pele do treinador.',
                  children: [
                    AppearanceChoiceRow(
                      label: 'Formato do rosto',
                      options: const ['Oval', 'Redondo', 'Longo', 'Quadrado'],
                      selected: local.faceShape,
                      onSelected: (value) =>
                          _update((a) => a.copyWith(faceShape: value)),
                    ),
                    AppearanceChoiceRow(
                      label: 'Tom de pele',
                      options: const ['1', '2', '3', '4', '5', '6'],
                      selected: local.skinTone,
                      onSelected: (value) =>
                          _update((a) => a.copyWith(skinTone: value)),
                    ),
                  ],
                ),
                AppearanceGroupCard(
                  title: 'CABELO',
                  subtitle: 'Estilo e cor usados no avatar.',
                  children: [
                    AppearanceChoiceRow(
                      label: 'Estilo',
                      compactLabels: true,
                      options: const [
                        'Curto',
                        'Lateral',
                        'Ondulado',
                        'Cacheado',
                        'Faixa',
                        'Picos',
                        'Careca',
                        'Longo',
                      ],
                      selected: local.hairStyle,
                      onSelected: (value) =>
                          _update((a) => a.copyWith(hairStyle: value)),
                    ),
                    AppearanceChoiceRow(
                      label: 'Cor do cabelo e barba',
                      options: const [
                        'Preto',
                        'Castanho',
                        'Marrom',
                        'Loiro',
                        'Grisalho',
                      ],
                      selected: local.hairColor,
                      onSelected: (value) =>
                          _update((a) => a.copyWith(hairColor: value)),
                    ),
                  ],
                ),
                AppearanceGroupCard(
                  title: 'TRAÇOS DO ROSTO',
                  subtitle: 'Olhos, sobrancelhas, nariz e boca.',
                  children: [
                    AppearanceChoiceRow(
                      label: 'Olhos',
                      options: const ['1', '2', '3', '4'],
                      selected: local.eyeStyle,
                      onSelected: (value) =>
                          _update((a) => a.copyWith(eyeStyle: value)),
                    ),
                    AppearanceChoiceRow(
                      label: 'Cor dos olhos',
                      options: const ['1', '2', '3', '4', '5'],
                      selected: local.eyeColor,
                      onSelected: (value) =>
                          _update((a) => a.copyWith(eyeColor: value)),
                    ),
                    AppearanceChoiceRow(
                      label: 'Sobrancelhas',
                      options: const ['1', '2', '3', '4'],
                      selected: local.eyebrowStyle,
                      onSelected: (value) =>
                          _update((a) => a.copyWith(eyebrowStyle: value)),
                    ),
                    AppearanceChoiceRow(
                      label: 'Nariz',
                      options: const ['1', '2', '3', '4'],
                      selected: local.noseStyle,
                      onSelected: (value) =>
                          _update((a) => a.copyWith(noseStyle: value)),
                    ),
                    AppearanceChoiceRow(
                      label: 'Boca',
                      options: const ['1', '2', '3', '4'],
                      selected: local.mouthStyle,
                      onSelected: (value) =>
                          _update((a) => a.copyWith(mouthStyle: value)),
                    ),
                  ],
                ),
                AppearanceGroupCard(
                  title: 'BARBA E BIGODE',
                  subtitle: 'Pelos faciais usam a mesma cor do cabelo.',
                  children: [
                    AppearanceChoiceRow(
                      label: 'Barba',
                      options: const [
                        'Nenhuma',
                        'Leve',
                        'Cavanhaque',
                        'Marcada',
                        'Cheia',
                      ],
                      selected: local.beardStyle,
                      onSelected: (value) =>
                          _update((a) => a.copyWith(beardStyle: value)),
                    ),
                    AppearanceChoiceRow(
                      label: 'Bigode',
                      options: const ['Nenhum', 'Fino', 'Marcado', 'Cheio'],
                      selected: local.moustacheStyle,
                      onSelected: (value) =>
                          _update((a) => a.copyWith(moustacheStyle: value)),
                    ),
                  ],
                ),
                AppearanceGroupCard(
                  title: 'EXPRESSÃO',
                  subtitle: 'Detalhe visual final do avatar.',
                  children: [
                    AppearanceChoiceRow(
                      label: 'Estilo',
                      options: const [
                        'Suave',
                        'Firme',
                        'Focado',
                        'Expressivo',
                        'Detalhado',
                      ],
                      selected: local.detailStyle,
                      onSelected: (value) =>
                          _update((a) => a.copyWith(detailStyle: value)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
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
