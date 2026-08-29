import 'package:flutter/material.dart';

import '../../app/widgets/common.dart';
import '../../app/widgets/manager_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../data/country_catalog.dart';
import '../../domain/career/manager_appearance.dart';
import '../../domain/career/manager_profile.dart';
import 'manager_appearance_editor.dart';

class ManagerProfileStep extends StatefulWidget {
  const ManagerProfileStep({
    super.key,
    required this.managerController,
    required this.nicknameController,
    required this.ageController,
    required this.nationalityController,
    required this.careerNameController,
    required this.appearance,
    required this.onAppearanceChanged,
  });

  final TextEditingController managerController;
  final TextEditingController nicknameController;
  final TextEditingController ageController;
  final TextEditingController nationalityController;
  final TextEditingController careerNameController;
  final ManagerAppearance appearance;
  final ValueChanged<ManagerAppearance> onAppearanceChanged;

  @override
  State<ManagerProfileStep> createState() => _ManagerProfileStepState();
}

class _ManagerProfileStepState extends State<ManagerProfileStep> {
  @override
  Widget build(BuildContext context) {
    final previewManager = ManagerProfile(
      displayName: widget.managerController.text.trim().isEmpty
          ? 'Seu técnico'
          : widget.managerController.text.trim(),
      nickname: widget.nicknameController.text.trim(),
      nationality: widget.nationalityController.text.trim().isEmpty
          ? 'Brasil'
          : widget.nationalityController.text.trim(),
      ageAtStart: int.tryParse(widget.ageController.text.trim()) ?? 35,
      appearance: widget.appearance,
      userCreated: true,
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
      children: [
        Text(
          'Criar meu técnico',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        const Text(
          'Preencha só o essencial. Aparência e perfil profissional podem ser ajustados depois.',
          style: TextStyle(color: AppColors.muted, height: 1.4),
        ),
        const SizedBox(height: 12),
        SectionCard(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ManagerAvatar(manager: previewManager, size: 72),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      previewManager.preferredName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${CountryCatalog.flagOf(previewManager.nationality)} ${previewManager.nationality}',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                    const SizedBox(height: 7),
                    OutlinedButton.icon(
                      onPressed: () => _editAppearance(previewManager),
                      icon: const Icon(Icons.face_retouching_natural_rounded, size: 18),
                      label: const Text('Editar aparência'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(40, 40),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              TextField(
                controller: widget.managerController,
                textCapitalization: TextCapitalization.words,
                maxLength: 50,
                decoration: const InputDecoration(
                  labelText: 'Nome do técnico',
                  prefixIcon: Icon(Icons.person_rounded),
                ),
                onChanged: (_) => setState(() {}),
              ),
              TextField(
                controller: widget.nicknameController,
                textCapitalization: TextCapitalization.words,
                maxLength: 24,
                decoration: const InputDecoration(
                  labelText: 'Apelido (opcional)',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                onChanged: (_) => setState(() {}),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: widget.ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Idade',
                        prefixIcon: Icon(Icons.cake_outlined),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: CountryCatalog.all.any(
                        (item) => item.name == widget.nationalityController.text,
                      )
                          ? widget.nationalityController.text
                          : 'Brasil',
                      decoration: const InputDecoration(
                        labelText: 'País',
                        prefixIcon: Icon(Icons.public_rounded),
                      ),
                      items: CountryCatalog.all
                          .map(
                            (item) => DropdownMenuItem(
                              value: item.name,
                              child: Text(item.label),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) {
                        widget.nationalityController.text = value ?? 'Brasil';
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: widget.careerNameController,
            maxLength: 50,
            decoration: const InputDecoration(
              labelText: 'Nome da carreira',
              prefixIcon: Icon(Icons.save_outlined),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _editAppearance(ManagerProfile previewManager) async {
    final result = await showManagerAppearanceEditor(
      context,
      previewManager: previewManager,
    );
    if (result != null) widget.onAppearanceChanged(result);
  }
}
