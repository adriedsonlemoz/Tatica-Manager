import 'package:flutter/material.dart';

import '../../app/widgets/common.dart';
import '../../core/theme/app_colors.dart';

class GameDataEditorTutorialScreen extends StatelessWidget {
  const GameDataEditorTutorialScreen({super.key});

  @override
  Widget build(BuildContext context) => PremiumScaffold(
        appBar: const GameTopBar(
          title: 'Como editar os dados',
          subtitle: 'Guia da Central de Edição',
        ),
        safeBottom: true,
        body: ListView(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
          children: const [
            _TutorialIntro(),
            SizedBox(height: 10),
            _TutorialSection(
              number: '1',
              title: 'Escolha o que deseja editar',
              text: 'Abra País > Campeonato > Série > Clubes. Toque em um clube para abrir a edição em uma tela própria. Também é possível editar técnicos e jogadores livres pelos atalhos da tela principal.',
            ),
            _TutorialSection(
              number: '2',
              title: 'Edite sem trocar os IDs',
              text: 'Nome, apelido, estádio, uniformes, escudo, jogadores e técnicos podem ser personalizados. Os IDs internos são permanentes e não são editáveis porque mantêm calendário, elencos, saves e importações consistentes.',
            ),
            _TutorialSection(
              number: '3',
              title: 'Pacote completo',
              text: 'Use Pacote para importar clubes, jogadores, técnicos e escudos de uma vez. O arquivo é validado antes de ser carregado e a tela mostra um resumo com as quantidades encontradas antes da confirmação.',
            ),
            _TutorialSection(
              number: '4',
              title: 'Somente escudos',
              text: 'Use Escudos quando quiser alterar apenas as imagens dos clubes. A associação é feita pelo ID permanente, sem mudar nomes, elencos, estádio, uniformes ou técnicos.',
            ),
            _TutorialSection(
              number: '5',
              title: 'Técnicos',
              text: 'Na área Técnicos você pode criar, editar, importar e exportar perfis. Aparência, foto, idade, clube, reputação, estilo e preferências táticas continuam vinculados ao perfil do técnico.',
            ),
            _TutorialSection(
              number: '6',
              title: 'Padrão e confirmação',
              text: 'Padrão restaura o banco original do jogo. A ação sempre pede confirmação antes de substituir as alterações que ainda não foram salvas.',
            ),
            _TutorialSection(
              number: '7',
              title: 'Salve somente quando terminar',
              text: 'Importar ou editar apenas prepara as mudanças. Revise os dados e toque em Salvar alterações para gravar o banco que será usado nas próximas carreiras.',
            ),
          ],
        ),
      );
}

class _TutorialIntro extends StatelessWidget {
  const _TutorialIntro();

  @override
  Widget build(BuildContext context) => SectionCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.school_outlined, color: AppColors.green),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'A Central de Edição altera os dados que o jogo usa para criar novas carreiras. Faça as mudanças, revise o resultado e salve somente no final.',
                style: TextStyle(height: 1.45, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
}

class _TutorialSection extends StatelessWidget {
  const _TutorialSection({
    required this.number,
    required this.title,
    required this.text,
  });

  final String number;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: SectionCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
                child: Text(number, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(text, style:  TextStyle(color: AppColors.muted, height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
