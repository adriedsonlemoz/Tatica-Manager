import 'dart:ui';

class MatchPlayerLabelCandidate {
  const MatchPlayerLabelCandidate({
    required this.center,
    required this.playerId,
    required this.name,
    required this.teamColor,
    required this.scale,
    required this.active,
    required this.involved,
    required this.goalkeeper,
  });

  final Offset center;
  final String playerId;
  final String name;
  final Color teamColor;
  final double scale;
  final bool active;
  final bool involved;
  final bool goalkeeper;
}

class MatchPlayerLabelPlacement {
  int? anchorIndex;
}

abstract final class MatchPlayerLabels {
  static final Map<String, Paragraph> _paragraphCache = {};

  static void draw(
    Canvas canvas, {
    required Rect field,
    required List<MatchPlayerLabelCandidate> candidates,
    required double interfaceScale,
    required Map<String, MatchPlayerLabelPlacement> placementStates,
  }) {
    if (candidates.isEmpty) return;
    final accepted = <Rect>[];
    final ordered = [...candidates]
      ..sort((first, second) {
        final byActive = (second.active ? 1 : 0) - (first.active ? 1 : 0);
        if (byActive != 0) return byActive;
        final byInvolvement =
            (second.involved ? 1 : 0) - (first.involved ? 1 : 0);
        if (byInvolvement != 0) return byInvolvement;
        final byGoalkeeper =
            (second.goalkeeper ? 1 : 0) - (first.goalkeeper ? 1 : 0);
        if (byGoalkeeper != 0) return byGoalkeeper;
        return first.playerId.compareTo(second.playerId);
      });

    for (final candidate in ordered) {
      final label = compactName(candidate.name, active: candidate.active);
      if (label.isEmpty) continue;
      final emphasized = candidate.active || candidate.involved;
      final fontSize = (candidate.active
              ? 7.8
              : candidate.involved
                  ? 7.2
                  : 6.25) *
          interfaceScale;
      final maxWidth = (candidate.active
              ? 68.0
              : candidate.involved
                  ? 58.0
                  : 45.0) *
          interfaceScale;
      final paragraph = _paragraph(
        label,
        fontSize: fontSize,
        maxWidth: maxWidth,
        emphasized: emphasized,
      );
      final horizontalPadding = emphasized ? 8.0 : 5.5;
      final width = (paragraph.longestLine + horizontalPadding * interfaceScale)
          .clamp(20.0 * interfaceScale, maxWidth + 6 * interfaceScale)
          .toDouble();
      final height =
          paragraph.height + (emphasized ? 4.4 : 3.2) * interfaceScale;
      final placement = placementStates.putIfAbsent(
        candidate.playerId,
        MatchPlayerLabelPlacement.new,
      );
      final result = _place(
        field: field,
        center: candidate.center,
        width: width,
        height: height,
        playerScale: candidate.scale,
        interfaceScale: interfaceScale,
        occupied: accepted,
        preferredAnchor: placement.anchorIndex,
      );
      if (result == null) continue;
      final rect = result.$1;
      placement.anchorIndex = result.$2;
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

  static (Rect, int)? _place({
    required Rect field,
    required Offset center,
    required double width,
    required double height,
    required double playerScale,
    required double interfaceScale,
    required List<Rect> occupied,
    required int? preferredAnchor,
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
    final anchorOrder = <int>[
      if (preferredAnchor != null &&
          preferredAnchor >= 0 &&
          preferredAnchor < positions.length)
        preferredAnchor,
      for (var index = 0; index < positions.length; index++)
        if (index != preferredAnchor) index,
    ];
    for (final anchor in anchorOrder) {
      final position = positions[anchor];
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
      if (collisions.isEmpty) return (rect, anchor);
    }
    return null;
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
    final emphasized = candidate.active || candidate.involved;
    final radius = Radius.circular(4.8 * interfaceScale);
    final rrect = RRect.fromRectAndRadius(rect, radius);
    if (emphasized) {
      canvas.drawRRect(
        rrect.shift(Offset(0, 1.2 * interfaceScale)),
        Paint()
          ..color = const Color(0x85000000)
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            1.4 * interfaceScale,
          ),
      );
    }
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = Gradient.linear(
          rect.topLeft,
          rect.bottomRight,
          emphasized
              ? const [Color(0xE60A1115), Color(0xD917252B)]
              : const [Color(0xA60A1115), Color(0x9A17252B)],
        ),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = border.withValues(
          alpha: candidate.active
              ? .90
              : candidate.involved
                  ? .62
                  : .24,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = (emphasized ? .90 : .52) * interfaceScale,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        rect.left,
        rect.top + 2 * interfaceScale,
        (emphasized ? 2.0 : 1.3) * interfaceScale,
        rect.height - 4 * interfaceScale,
      ),
      Paint()..color = candidate.teamColor.withValues(alpha: .88),
    );
    canvas.drawParagraph(
      paragraph,
      Offset(
        rect.center.dx - paragraph.width / 2,
        rect.top + (emphasized ? 2.0 : 1.4) * interfaceScale,
      ),
    );
  }

  static Paragraph _paragraph(
    String text, {
    required double fontSize,
    required double maxWidth,
    required bool emphasized,
  }) {
    final bucket = (fontSize * 10).round();
    final widthBucket = maxWidth.round();
    final key = '$text|$bucket|$widthBucket|$emphasized';
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
          fontWeight: emphasized ? FontWeight.w800 : FontWeight.w600,
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
