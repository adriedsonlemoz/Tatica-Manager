import 'dart:ui';

class MatchPlayerLabelCandidate {
  const MatchPlayerLabelCandidate({
    required this.center,
    required this.playerId,
    required this.name,
    required this.teamColor,
    required this.scale,
    required this.active,
    required this.goalkeeper,
  });

  final Offset center;
  final String playerId;
  final String name;
  final Color teamColor;
  final double scale;
  final bool active;
  final bool goalkeeper;
}

abstract final class MatchPlayerLabels {
  static final Map<String, Paragraph> _paragraphCache = {};

  static void draw(
    Canvas canvas, {
    required Rect field,
    required List<MatchPlayerLabelCandidate> candidates,
    required double interfaceScale,
  }) {
    if (candidates.isEmpty) return;
    final accepted = <Rect>[];
    final ordered = [...candidates]
      ..sort((first, second) {
        final byActive = (second.active ? 1 : 0) - (first.active ? 1 : 0);
        if (byActive != 0) return byActive;
        final byGoalkeeper =
            (second.goalkeeper ? 1 : 0) - (first.goalkeeper ? 1 : 0);
        if (byGoalkeeper != 0) return byGoalkeeper;
        return first.center.dy.compareTo(second.center.dy);
      });

    for (final candidate in ordered) {
      final label = compactName(candidate.name, active: candidate.active);
      if (label.isEmpty) continue;
      final fontSize = (candidate.active ? 7.8 : 7.0) * interfaceScale;
      final maxWidth = (candidate.active ? 70.0 : 55.0) * interfaceScale;
      final paragraph = _paragraph(
        label,
        fontSize: fontSize,
        maxWidth: maxWidth,
        active: candidate.active,
      );
      final width = (paragraph.longestLine + 9 * interfaceScale)
          .clamp(24.0 * interfaceScale, maxWidth + 8 * interfaceScale)
          .toDouble();
      final height = paragraph.height + 4.6 * interfaceScale;
      final rect = _place(
        field: field,
        center: candidate.center,
        width: width,
        height: height,
        playerScale: candidate.scale,
        interfaceScale: interfaceScale,
        occupied: accepted,
        force: candidate.active,
      );
      if (rect == null) continue;
      accepted.add(rect.inflate(1.2 * interfaceScale));
      _drawLabel(
        canvas,
        rect: rect,
        paragraph: paragraph,
        candidate: candidate,
        interfaceScale: interfaceScale,
      );
    }
  }

  static String compactName(String source, {bool active = false}) {
    final normalized = source.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.isEmpty) return '';
    final limit = active ? 16 : 12;
    if (normalized.runes.length <= limit) return normalized;
    final parts = normalized.split(' ');
    if (parts.length > 1) {
      final last = parts.last;
      if (last.runes.length >= 3 && last.runes.length <= limit) return last;
      final firstWithInitial =
          '${parts.first} ${String.fromCharCode(last.runes.first)}.';
      if (firstWithInitial.runes.length <= limit) return firstWithInitial;
    }
    final runes = normalized.runes.toList();
    return '${String.fromCharCodes(runes.take(limit - 1))}…';
  }

  static Rect? _place({
    required Rect field,
    required Offset center,
    required double width,
    required double height,
    required double playerScale,
    required double interfaceScale,
    required List<Rect> occupied,
    required bool force,
  }) {
    final above = 18.0 * playerScale + height / 2;
    final below = 12.0 * playerScale + height / 2;
    final horizontal = 13.0 * playerScale + width / 2;
    final positions = <Offset>[
      center.translate(0, -above),
      center.translate(0, below),
      center.translate(-horizontal, -4 * interfaceScale),
      center.translate(horizontal, -4 * interfaceScale),
      center.translate(-width * .36, -above),
      center.translate(width * .36, -above),
    ];
    final safeField = field.deflate(1.5 * interfaceScale);
    Rect? bestEffort;
    var lowestOverlap = double.infinity;
    for (final position in positions) {
      final rect = Rect.fromCenter(
        center: position,
        width: width,
        height: height,
      );
      if (!safeField.contains(rect.topLeft) ||
          !safeField.contains(rect.bottomRight)) {
        continue;
      }
      final collisions = occupied.where(rect.overlaps).toList();
      if (collisions.isEmpty) return rect;
      if (force) {
        final overlap = collisions.fold<double>(0, (sum, item) {
          final intersection = rect.intersect(item);
          return sum + intersection.width * intersection.height;
        });
        if (overlap < lowestOverlap) {
          lowestOverlap = overlap;
          bestEffort = rect;
        }
      }
    }
    return force ? bestEffort : null;
  }

  static void _drawLabel(
    Canvas canvas, {
    required Rect rect,
    required Paragraph paragraph,
    required MatchPlayerLabelCandidate candidate,
    required double interfaceScale,
  }) {
    final border = Color.lerp(
      candidate.teamColor,
      const Color(0xFFFFFFFF),
      candidate.active ? .34 : .20,
    )!;
    final radius = Radius.circular(4.8 * interfaceScale);
    final rrect = RRect.fromRectAndRadius(rect, radius);
    canvas.drawRRect(
      rrect.shift(Offset(0, 1.2 * interfaceScale)),
      Paint()
        ..color = const Color(0x85000000)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          1.4 * interfaceScale,
        ),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = Gradient.linear(
          rect.topLeft,
          rect.bottomRight,
          const [Color(0xE60A1115), Color(0xD917252B)],
        ),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = border.withValues(alpha: candidate.active ? .90 : .52)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (candidate.active ? 1.05 : .70) * interfaceScale,
    );
    canvas.drawParagraph(
      paragraph,
      Offset(
        rect.center.dx - paragraph.width / 2,
        rect.top + 2.0 * interfaceScale,
      ),
    );
  }

  static Paragraph _paragraph(
    String text, {
    required double fontSize,
    required double maxWidth,
    required bool active,
  }) {
    final bucket = (fontSize * 10).round();
    final widthBucket = maxWidth.round();
    final key = '$text|$bucket|$widthBucket|$active';
    final cached = _paragraphCache[key];
    if (cached != null) return cached;
    final builder = ParagraphBuilder(
      ParagraphStyle(
        maxLines: 1,
        ellipsis: '…',
        textAlign: TextAlign.center,
      ),
    )..pushStyle(
        TextStyle(
          color: const Color(0xFFFFFFFF),
          fontSize: fontSize,
          fontWeight: active ? FontWeight.w800 : FontWeight.w700,
          letterSpacing: .05,
        ),
      );
    builder.addText(text);
    final paragraph = builder.build()
      ..layout(ParagraphConstraints(width: maxWidth));
    if (_paragraphCache.length >= 512) {
      _paragraphCache.remove(_paragraphCache.keys.first);
    }
    _paragraphCache[key] = paragraph;
    return paragraph;
  }
}
