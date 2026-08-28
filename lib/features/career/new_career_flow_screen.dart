import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/career_controller.dart';
import '../../app/state/providers.dart';
import '../../app/widgets/common.dart';
import '../../app/widgets/game_notice_dialog.dart';
import '../../core/config/app_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/career/manager_appearance.dart';
import '../../domain/career/manager_profile.dart';
import '../../domain/career/new_career_config.dart';
import '../../domain/club/club_identity.dart';
import '../../domain/formation/formation.dart';
import '../../domain/season/league_loading.dart';
import '../../domain/settings/match_presentation_settings.dart';
import '../../domain/tactic/tactic.dart';
import '../../game/career/career_league_planner.dart';
import 'career_setup_step.dart';
import 'career_style_step.dart';
import 'career_signing_screen.dart';
import 'club_selection_screen.dart';
import 'league_selection_step.dart';
import 'manager_profile_step.dart';
import 'manager_selection_step.dart';

class NewCareerFlowScreen extends ConsumerStatefulWidget {
  const NewCareerFlowScreen({super.key});

  @override
  ConsumerState<NewCareerFlowScreen> createState() => _NewCareerFlowScreenState();
}

class _NewCareerFlowScreenState extends ConsumerState<NewCareerFlowScreen> {
  static const int _initialSeason = 2026;

  final _managerController = TextEditingController();
  final _managerNicknameController = TextEditingController();
  final _managerAgeController = TextEditingController(text: '35');
  final _nationalityController = TextEditingController(text: 'Brasil');
  late final TextEditingController _careerNameController;

  int _step = 0;
  bool? _useExistingManager;
  String? _clubId;
  ManagerProfile? _managerProfile;
  FormationType _formation = FormationType.f433;
  CareerLeagueSetup _leagueSetup = const CareerLeagueSetup();
  String? _leagueSetupClubId;
  Mentality _mentality = Mentality.balanced;
  Pressing _pressing = Pressing.medium;
  MatchTempo _tempo = MatchTempo.normal;
  MatchDurationPreset _matchDuration = MatchDurationPreset.normal;
  ClubIdentityPack? _clubIdentityPack;
  String? _clubIdentityError;
  ManagerAppearance _managerAppearance = const ManagerAppearance();

  @override
  void initState() {
    super.initState();
    final count = ref.read(careerControllerProvider).saves.length;
    _careerNameController = TextEditingController(text: 'Carreira ${count + 1}');
    Future.microtask(() async {
      await Future.wait([_loadClubIdentityPack(), _loadDefaultSettings()]);
    });
  }

  @override
  void dispose() {
    _managerController.dispose();
    _managerNicknameController.dispose();
    _managerAgeController.dispose();
    _nationalityController.dispose();
    _careerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hub = ref.watch(careerControllerProvider);
    return PremiumScaffold(
      appBar: GameTopBar(
        title: 'Nova carreira',
        subtitle: 'Etapa ${_step + 1} de 6',
      ),
      bottomNavigationBar: _step == 0
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(14, 8, 14, 12),
              child: Row(
          children: [
            if (_step > 0) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: hub.loading ? null : () => setState(() => _step--),
                  child: const Text('Voltar'),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              flex: _step == 0 ? 1 : 2,
              child: FilledButton.icon(
                onPressed: hub.loading ? null : _next,
                icon: Icon(
                  _step == 5
                      ? Icons.sports_soccer_rounded
                      : Icons.arrow_forward_rounded,
                ),
                label: Text(_step == 5 ? 'Começar carreira' : 'Continuar'),
              ),
            ),
          ],
              ),
            ),
      body: Column(
        children: [
          _Progress(step: _step),
          Expanded(child: _body()),
          if (hub.loading) const LinearProgressIndicator(minHeight: 2),
        ],
      ),
    );
  }

  Widget _body() {
    if (_step > 0 && _clubIdentityPack == null) {
      if (_clubIdentityError != null) {
        return EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Não foi possível carregar os clubes',
          text: _clubIdentityError!,
        );
      }
      return const Center(child: CircularProgressIndicator());
    }

    return switch (_step) {
      0 => ManagerChoiceStep(
          onExisting: () => setState(() {
            _useExistingManager = true;
            _step = 1;
          }),
          onCreate: () => setState(() {
            _useExistingManager = false;
            _step = 1;
          }),
        ),
      1 => _useExistingManager == true
          ? ExistingManagerSelectionStep(
              pack: _clubIdentityPack!,
              selected: _managerProfile,
              onSelected: (manager) => setState(() => _managerProfile = manager),
            )
          : ManagerProfileStep(
              managerController: _managerController,
              nicknameController: _managerNicknameController,
              ageController: _managerAgeController,
              nationalityController: _nationalityController,
              careerNameController: _careerNameController,
              appearance: _managerAppearance,
              onAppearanceChanged: (value) =>
                  setState(() => _managerAppearance = value),
            ),
      2 => ClubSelectionStep(
          selectedId: _clubId,
          identityPack: _clubIdentityPack,
          onSelected: (value) => setState(() => _clubId = value),
        ),
      3 => LeagueSelectionStep(
          userClubId: _clubId!,
          setup: _leagueSetup,
          onChanged: (value) => setState(() => _leagueSetup = value),
        ),
      4 => CareerSetupStep(
          formation: _formation,
          onFormation: (value) => setState(() => _formation = value),
        ),
      _ => CareerStyleStep(
          mentality: _mentality,
          pressing: _pressing,
          tempo: _tempo,
          onMentality: (value) => setState(() => _mentality = value),
          onPressing: (value) => setState(() => _pressing = value),
          onTempo: (value) => setState(() => _tempo = value),
          matchDuration: _matchDuration,
          onMatchDuration: (value) => setState(() => _matchDuration = value),
        ),
    };
  }

  Future<void> _loadDefaultSettings() async {
    final repository = ref.read(careerRepositoryProvider);
    final stored = await repository.loadAppValue(
      AppPreferences.defaultGameSettingsKey,
    );
    if (!mounted) return;
    final defaults = AppPreferences.decodeGameSettings(stored);
    setState(() {
      _matchDuration = MatchDurationPreset.fromMinutes(
        defaults.matchDurationMinutes,
      );
    });
  }

  Future<void> _loadClubIdentityPack() async {
    try {
      final pack = await ref
          .read(careerControllerProvider.notifier)
          .loadClubIdentityPack();
      if (!mounted) return;
      setState(() {
        _clubIdentityPack = pack;
        _clubIdentityError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _clubIdentityError = error.toString());
    }
  }

  Future<void> _next() async {
    if (_step == 0) {
      _show('Escolha se deseja usar um técnico existente ou criar o seu.');
      return;
    }

    if (_step == 1) {
      final careerName = _careerNameController.text.trim();
      if (careerName.length < 2 || careerName.length > 50) {
        _show('O nome da carreira deve ter entre 2 e 50 caracteres.');
        return;
      }
      if (_useExistingManager == true) {
        if (_managerProfile == null) {
          _show('Escolha um técnico para continuar.');
          return;
        }
      } else {
        try {
          final age = int.tryParse(_managerAgeController.text.trim());
          if (age == null) {
            throw const FormatException('Digite uma idade válida para o técnico.');
          }
          _managerProfile = ManagerProfile.normalized(
            id: 'manager-user-${DateTime.now().microsecondsSinceEpoch}',
            displayName: _managerController.text,
            nickname: _managerNicknameController.text,
            nationality: _nationalityController.text,
            ageAtStart: age,
            careerStartSeason: _initialSeason,
            appearance: _managerAppearance,
            userCreated: true,
          );
        } on FormatException catch (error) {
          _show(error.message.toString());
          return;
        }
      }
      setState(() => _step = 2);
      return;
    }

    if (_step == 2) {
      if (_clubId == null) {
        _show('Escolha um clube para continuar.');
        return;
      }
      final clubId = _clubId!;
      final clubChanged = _leagueSetupClubId != clubId;
      final nextSetup = _leagueSetup.competitions.isEmpty ||
              (clubChanged && _leagueSetup.preset != CareerWorldPreset.custom)
          ? CareerLeaguePlanner.forPreset(
              userClubId: clubId,
              preset: _leagueSetup.preset,
            )
          : CareerLeaguePlanner.normalize(
              setup: _leagueSetup,
              userClubId: clubId,
            );
      setState(() {
        _leagueSetup = nextSetup;
        _leagueSetupClubId = clubId;
        _step = 3;
      });
      return;
    }

    if (_step == 3) {
      setState(() => _step = 4);
      return;
    }

    if (_step == 4) {
      setState(() => _step = 5);
      return;
    }

    final manager = _managerProfile;
    if (manager == null) {
      _show('Revise o perfil do técnico antes de criar a carreira.');
      setState(() => _step = 0);
      return;
    }

    final config = NewCareerConfig(
      careerName: _careerNameController.text.trim(),
      manager: manager,
      clubId: _clubId!,
      formation: _formation,
      tactic: Tactic(
        mentality: _mentality,
        pressing: _pressing,
        tempo: _tempo,
      ),
      matchDuration: _matchDuration,
      leagueSetup: CareerLeaguePlanner.normalize(
        setup: _leagueSetup,
        userClubId: _clubId!,
      ),
      clubIdentityPack: _clubIdentityPack,
    );
    final created =
        await ref.read(careerControllerProvider.notifier).createCareer(config);
    if (!mounted) return;
    if (created) {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CareerSigningScreen(
            managerName: config.manager.displayName,
            clubId: config.clubId,
          ),
        ),
      );
    }
  }

  void _show(String text) {
    showGameNotice(
      context,
      message: text,
      title: 'Revise esta etapa',
      icon: Icons.sports_soccer_rounded,
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Row(
          children: List.generate(6, (index) {
            final active = index <= step;
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: index == 5 ? 0 : 6),
                decoration: BoxDecoration(
                  color: active ? AppColors.green : AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
      );
}
