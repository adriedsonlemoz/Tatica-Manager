part of 'club_editor_screen.dart';


class _EditorQuickAction extends StatelessWidget {
  const _EditorQuickAction({
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 52),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20),
              const SizedBox(height: 3),
              Text(label, maxLines: 1, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      );
}

class _EditorMenuTile extends StatelessWidget {
  const _EditorMenuTile({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: SectionCard(
          padding: EdgeInsets.zero,
          child: ListTile(
            onTap: onTap,
            leading: Icon(icon, color: AppColors.green),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            subtitle: Text(subtitle),
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
        ),
      );
}

class _ClubIdentityTile extends StatelessWidget {
  const _ClubIdentityTile({required this.identity, required this.onTap});

  final ClubIdentity identity;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => SectionCard(
        padding: EdgeInsets.zero,
        child: ListTile(
          enabled: onTap != null,
          onTap: onTap,
          contentPadding: const EdgeInsets.fromLTRB(12, 7, 10, 7),
          leading: _ClubIdentityBadge(identity: identity, size: 48),
          title: Text(
            identity.name,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${identity.nickname} • ${identity.stadium?.name ?? 'Estádio'} '
              '• ${_visibleId(identity.clubId)}',
            ),
          ),
          trailing: const Icon(Icons.chevron_right_rounded, size: 20),
        ),
      );
}

class _ClubIdentityBadge extends StatelessWidget {
  const _ClubIdentityBadge({required this.identity, required this.size});
  final ClubIdentity identity;
  final double size;

  @override
  Widget build(BuildContext context) {
    final kit = identity.homeKit;
    final primary = kit?.primaryHex ?? identity.colors?.primaryHex ?? 0xFF1E7A2B;
    final secondary = kit?.secondaryHex ?? identity.colors?.secondaryHex ?? 0xFFFFFFFF;
    Widget fallback() => Text(
          identity.shortName.length <= 3
              ? identity.shortName
              : identity.shortName.substring(0, 3),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * .23,
            fontWeight: FontWeight.w900,
          ),
        );
    final hasCustomIcon = identity.iconBase64?.isNotEmpty == true;
    Widget child = fallback();
    if (hasCustomIcon) {
      try {
        child = Padding(
          padding: EdgeInsets.all(size * .08),
          child: Image.memory(
            base64Decode(identity.iconBase64!),
            width: size * .84,
            height: size * .84,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, _, _) => Center(child: fallback()),
          ),
        );
      } catch (_) {
        child = fallback();
      }
    }
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: hasCustomIcon ? const Color(0xFFF4F4F4) : null,
        gradient: hasCustomIcon
            ? null
            : LinearGradient(colors: [Color(primary), Color(secondary)]),
        borderRadius: BorderRadius.circular(size * .28),
        border: Border.all(
          color: hasCustomIcon
              ? Colors.white.withValues(alpha: .55)
              : Colors.white.withValues(alpha: .20),
        ),
      ),
      child: child,
    );
  }
}

class _ClubIdentityDialog extends StatefulWidget {
  const _ClubIdentityDialog({required this.identity});
  final ClubIdentity identity;

  @override
  State<_ClubIdentityDialog> createState() => _ClubIdentityDialogState();
}

class _ClubIdentityDialogState extends State<_ClubIdentityDialog> {
  late final TextEditingController _name;
  late final TextEditingController _nickname;
  late final TextEditingController _shortName;
  String? _error;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.identity.name);
    _nickname = TextEditingController(text: widget.identity.nickname);
    _shortName = TextEditingController(text: widget.identity.shortName);
  }

  @override
  void dispose() {
    _name.dispose();
    _nickname.dispose();
    _shortName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Nome e apelido'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'ID permanente: ${widget.identity.clubId}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                maxLength: 42,
                decoration: const InputDecoration(labelText: 'Nome completo'),
              ),
              TextField(
                controller: _nickname,
                textCapitalization: TextCapitalization.words,
                maxLength: 24,
                decoration: const InputDecoration(labelText: 'Apelido'),
              ),
              TextField(
                controller: _shortName,
                textCapitalization: TextCapitalization.characters,
                maxLength: 4,
                decoration: const InputDecoration(labelText: 'Sigla', hintText: 'Ex.: CPT'),
              ),
              if (_error != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(onPressed: _submit, child: const Text('Aplicar')),
        ],
      );

  void _submit() {
    final name = _name.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    final nickname = _nickname.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    final shortName = _shortName.text.trim().toUpperCase();
    if (name.length < 3 || name.length > 42) {
      setState(() => _error = 'O nome deve ter entre 3 e 42 caracteres.');
      return;
    }
    if (nickname.length < 2 || nickname.length > 24) {
      setState(() => _error = 'O apelido deve ter entre 2 e 24 caracteres.');
      return;
    }
    if (!RegExp(r'^[A-Z0-9]{2,4}$').hasMatch(shortName)) {
      setState(() => _error = 'A sigla deve ter de 2 a 4 letras ou números.');
      return;
    }
    Navigator.pop(
      context,
      widget.identity.copyWith(name: name, nickname: nickname, shortName: shortName),
    );
  }
}

class _StadiumDialog extends StatefulWidget {
  const _StadiumDialog({required this.stadium});
  final Stadium stadium;

  @override
  State<_StadiumDialog> createState() => _StadiumDialogState();
}

class _StadiumDialogState extends State<_StadiumDialog> {
  late final TextEditingController _name;
  late final TextEditingController _capacity;
  late final TextEditingController _ticketPrice;
  String? _error;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.stadium.name);
    _capacity = TextEditingController(text: '${widget.stadium.capacity}');
    _ticketPrice = TextEditingController(text: '${widget.stadium.ticketPrice}');
  }

  @override
  void dispose() {
    _name.dispose();
    _capacity.dispose();
    _ticketPrice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Editar estádio'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                maxLength: 50,
                decoration: const InputDecoration(labelText: 'Nome do estádio'),
              ),
              TextField(
                controller: _capacity,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Capacidade'),
              ),
              TextField(
                controller: _ticketPrice,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Preço-base do ingresso'),
              ),
              const SizedBox(height: 8),
              Text(
                'Capacidade e preço do ingresso influenciam as receitas de partidas.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted),
              ),
              if (_error != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(onPressed: _submit, child: const Text('Aplicar')),
        ],
      );

  void _submit() {
    final name = _name.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    final capacity = int.tryParse(_capacity.text.trim());
    final price = int.tryParse(_ticketPrice.text.trim());
    if (name.length < 3 || name.length > 50) {
      setState(() => _error = 'O nome do estádio deve ter entre 3 e 50 caracteres.');
      return;
    }
    if (capacity == null || capacity < 1000 || capacity > 200000) {
      setState(() => _error = 'A capacidade deve ficar entre 1.000 e 200.000.');
      return;
    }
    if (price == null || price < 0 || price > 5000) {
      setState(() => _error = 'O ingresso deve ficar entre 0 e 5.000.');
      return;
    }
    Navigator.pop(context, widget.stadium.copyWith(name: name, capacity: capacity, ticketPrice: price));
  }
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({required this.text, required this.error});

  final String text;
  final bool error;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: (error ? AppColors.danger : AppColors.green).withValues(alpha: .10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: (error ? AppColors.danger : AppColors.green).withValues(alpha: .35),
          ),
        ),
        child: Text(text),
      );
}

String _visibleId(String clubId) {
  final match = RegExp(r'^br-club-(\d{3})$').firstMatch(clubId);
  return match == null ? clubId.toUpperCase() : 'BR-${match.group(1)}';
}
