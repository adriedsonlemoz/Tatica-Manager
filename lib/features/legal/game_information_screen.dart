import 'package:flutter/material.dart';

import '../../app/widgets/common.dart';
import '../../core/config/app_info.dart';
import '../../core/theme/app_colors.dart';

enum GameInformationPage { about, howItWorks, terms, privacy }

class GameInformationScreen extends StatelessWidget {
  const GameInformationScreen({
    super.key,
    required this.page,
  });

  final GameInformationPage page;

  @override
  Widget build(BuildContext context) {
    final content = _contentFor(page);
    return PremiumScaffold(
      appBar: GameTopBar(
        title: content.title,
        subtitle: content.subtitle,
      ),
      safeBottom: true,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
        children: [
          SectionCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: .11),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(content.icon, color: AppColors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        content.lead,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tática Manager ${AppInfo.version}',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          for (final section in content.sections) ...[
            SectionCard(
              padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    section.text,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.5,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

_InfoContent _contentFor(GameInformationPage page) => switch (page) {
      GameInformationPage.about => const _InfoContent(
          title: 'Sobre o jogo',
          subtitle: 'A proposta do Tática Manager',
          icon: Icons.sports_soccer_rounded,
          lead:
              'Um jogo de gestão de futebol focado em decisões de carreira, clube e partida.',
          sections: [
            _InfoSection(
              'O que é',
              'Tática Manager é um jogo de gerenciamento de futebol para celular. Você assume o papel de treinador, escolhe um clube, organiza elenco e tática, acompanha calendário, mercado, contratos, finanças e conduz a equipe ao longo de várias temporadas.',
            ),
            _InfoSection(
              'Partidas',
              'O resultado das partidas é calculado pelo Match Engine do jogo. A apresentação em campo, animações e replays representam visualmente os acontecimentos já definidos pelo motor da partida.',
            ),
            _InfoSection(
              'Carreiras e edição',
              'As carreiras são salvas no aparelho. A Central de Edição permite personalizar dados do banco e importar pacotes compatíveis sem mudar a lógica principal do jogo.',
            ),
          ],
        ),
      GameInformationPage.howItWorks => const _InfoContent(
          title: 'Como funciona',
          subtitle: 'Do início da carreira às partidas',
          icon: Icons.route_rounded,
          lead:
              'A carreira avança por dias, decisões de gestão e partidas do calendário.',
          sections: [
            _InfoSection(
              '1. Criação da carreira',
              'Escolha ou crie um técnico, selecione o clube, defina a formação, o estilo inicial e a duração visual das partidas.',
            ),
            _InfoSection(
              '2. Gestão diária',
              'Avance os dias para receber notícias, acompanhar recuperação de jogadores, contratos, propostas, finanças e o próximo compromisso do calendário.',
            ),
            _InfoSection(
              '3. Dia de jogo',
              'Revise escalação e tática antes da partida. Durante a transmissão, você pode acompanhar os eventos e fazer alterações permitidas pelo sistema de jogo.',
            ),
            _InfoSection(
              '4. Evolução da carreira',
              'Resultados afetam classificação e histórico. A carreira continua por temporadas, mantendo o estado salvo no aparelho.',
            ),
          ],
        ),
      GameInformationPage.terms => const _InfoContent(
          title: 'Termos de Uso',
          subtitle: 'Condições básicas de utilização',
          icon: Icons.gavel_rounded,
          lead:
              'Ao utilizar o Tática Manager, você concorda com estas condições básicas de uso.',
          sections: [
            _InfoSection(
              'Uso do aplicativo',
              'O Tática Manager é disponibilizado para entretenimento. Você é responsável por manter cópias de arquivos externos que importar e por utilizar apenas conteúdos que tenha direito de usar.',
            ),
            _InfoSection(
              'Edição e conteúdo importado',
              'A Central de Edição permite alterar e importar dados. Conteúdos criados ou importados pelo usuário não passam a fazer parte do conteúdo oficial do jogo, e a responsabilidade pelo uso desses arquivos é de quem os adiciona.',
            ),
            _InfoSection(
              'Saves e disponibilidade',
              'Os dados de carreira são mantidos localmente no aparelho. Atualizações procuram preservar saves compatíveis, mas é recomendável manter cópia de segurança antes de alterações importantes no dispositivo.',
            ),
            _InfoSection(
              'Mudanças no jogo',
              'Recursos, balanceamento e interface podem ser atualizados ao longo do desenvolvimento. Mudanças relevantes devem ser registradas nas notas de versão do aplicativo.',
            ),
          ],
        ),
      GameInformationPage.privacy => const _InfoContent(
          title: 'Privacidade',
          subtitle: 'Como os dados do jogo são tratados',
          icon: Icons.privacy_tip_outlined,
          lead:
              'O Tática Manager foi projetado para funcionar com os principais dados de carreira armazenados localmente.',
          sections: [
            _InfoSection(
              'Dados de carreira',
              'Saves, preferências, edições do banco e informações do técnico são armazenados no aparelho pelo próprio aplicativo. O jogo não exige conta online para criar uma carreira.',
            ),
            _InfoSection(
              'Fotos e arquivos escolhidos',
              'Quando você escolhe uma foto, música ou pacote de edição, o aplicativo acessa somente o arquivo selecionado por meio das ferramentas do sistema. Cópias necessárias ao funcionamento ficam na área do aplicativo no aparelho.',
            ),
            _InfoSection(
              'Envio de dados',
              'A versão atual não possui backend próprio para enviar saves ou perfis de carreira. Recursos do sistema, como síntese de voz, reprodução de áudio e seleção de arquivos, podem depender dos serviços disponíveis no próprio dispositivo.',
            ),
            _InfoSection(
              'Controle do usuário',
              'Você pode apagar uma carreira dentro do jogo. A remoção completa do aplicativo pelo sistema também remove os dados locais que pertencem ao aplicativo, conforme o comportamento da plataforma.',
            ),
          ],
        ),
    };

class _InfoContent {
  const _InfoContent({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.lead,
    required this.sections,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String lead;
  final List<_InfoSection> sections;
}

class _InfoSection {
  const _InfoSection(this.title, this.text);

  final String title;
  final String text;
}
