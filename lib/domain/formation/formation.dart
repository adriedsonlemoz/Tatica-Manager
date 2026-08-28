import '../player/player.dart';

enum FormationType { f442, f433, f4231, f4141, f451, f352, f343, f532 }

extension FormationTypeX on FormationType {
  String get label => switch (this) {
        FormationType.f442 => '4-4-2',
        FormationType.f433 => '4-3-3',
        FormationType.f4231 => '4-2-3-1',
        FormationType.f4141 => '4-1-4-1',
        FormationType.f451 => '4-5-1',
        FormationType.f352 => '3-5-2',
        FormationType.f343 => '3-4-3',
        FormationType.f532 => '5-3-2',
      };
}

class FormationSlot {
  const FormationSlot({required this.id, required this.role, required this.x, required this.y});
  final String id;
  final PlayerPosition role;
  final double x;
  final double y;
}

abstract final class FormationCatalog {
  static const Map<FormationType, List<FormationSlot>> slots = {
    FormationType.f442: [
      FormationSlot(id: 'gk', role: PlayerPosition.gol, x: .50, y: .91),
      FormationSlot(id: 'lb', role: PlayerPosition.le, x: .16, y: .72),
      FormationSlot(id: 'cb1', role: PlayerPosition.zag, x: .38, y: .76),
      FormationSlot(id: 'cb2', role: PlayerPosition.zag, x: .62, y: .76),
      FormationSlot(id: 'rb', role: PlayerPosition.ld, x: .84, y: .72),
      FormationSlot(id: 'lm', role: PlayerPosition.pe, x: .15, y: .48),
      FormationSlot(id: 'cm1', role: PlayerPosition.vol, x: .39, y: .52),
      FormationSlot(id: 'cm2', role: PlayerPosition.vol, x: .61, y: .52),
      FormationSlot(id: 'rm', role: PlayerPosition.pd, x: .85, y: .48),
      FormationSlot(id: 'st1', role: PlayerPosition.ca, x: .38, y: .24),
      FormationSlot(id: 'st2', role: PlayerPosition.ca, x: .62, y: .24),
    ],
    FormationType.f433: [
      FormationSlot(id: 'gk', role: PlayerPosition.gol, x: .50, y: .91),
      FormationSlot(id: 'lb', role: PlayerPosition.le, x: .16, y: .72),
      FormationSlot(id: 'cb1', role: PlayerPosition.zag, x: .38, y: .76),
      FormationSlot(id: 'cb2', role: PlayerPosition.zag, x: .62, y: .76),
      FormationSlot(id: 'rb', role: PlayerPosition.ld, x: .84, y: .72),
      FormationSlot(id: 'dm', role: PlayerPosition.vol, x: .50, y: .58),
      FormationSlot(id: 'cm1', role: PlayerPosition.mc, x: .32, y: .46),
      FormationSlot(id: 'am', role: PlayerPosition.mei, x: .68, y: .46),
      FormationSlot(id: 'lw', role: PlayerPosition.pe, x: .18, y: .23),
      FormationSlot(id: 'st', role: PlayerPosition.ca, x: .50, y: .19),
      FormationSlot(id: 'rw', role: PlayerPosition.pd, x: .82, y: .23),
    ],
    FormationType.f4231: [
      FormationSlot(id: 'gk', role: PlayerPosition.gol, x: .50, y: .91),
      FormationSlot(id: 'lb', role: PlayerPosition.le, x: .16, y: .72),
      FormationSlot(id: 'cb1', role: PlayerPosition.zag, x: .38, y: .76),
      FormationSlot(id: 'cb2', role: PlayerPosition.zag, x: .62, y: .76),
      FormationSlot(id: 'rb', role: PlayerPosition.ld, x: .84, y: .72),
      FormationSlot(id: 'dm1', role: PlayerPosition.vol, x: .38, y: .57),
      FormationSlot(id: 'dm2', role: PlayerPosition.vol, x: .62, y: .57),
      FormationSlot(id: 'lw', role: PlayerPosition.pe, x: .18, y: .37),
      FormationSlot(id: 'am', role: PlayerPosition.mei, x: .50, y: .35),
      FormationSlot(id: 'rw', role: PlayerPosition.pd, x: .82, y: .37),
      FormationSlot(id: 'st', role: PlayerPosition.ca, x: .50, y: .18),
    ],
    FormationType.f4141: [
      FormationSlot(id: 'gk', role: PlayerPosition.gol, x: .50, y: .91),
      FormationSlot(id: 'lb', role: PlayerPosition.le, x: .16, y: .72),
      FormationSlot(id: 'cb1', role: PlayerPosition.zag, x: .38, y: .76),
      FormationSlot(id: 'cb2', role: PlayerPosition.zag, x: .62, y: .76),
      FormationSlot(id: 'rb', role: PlayerPosition.ld, x: .84, y: .72),
      FormationSlot(id: 'dm', role: PlayerPosition.vol, x: .50, y: .58),
      FormationSlot(id: 'lm', role: PlayerPosition.pe, x: .17, y: .41),
      FormationSlot(id: 'cm1', role: PlayerPosition.mc, x: .39, y: .44),
      FormationSlot(id: 'cm2', role: PlayerPosition.mc, x: .61, y: .44),
      FormationSlot(id: 'rm', role: PlayerPosition.pd, x: .83, y: .41),
      FormationSlot(id: 'st', role: PlayerPosition.ca, x: .50, y: .18),
    ],
    FormationType.f451: [
      FormationSlot(id: 'gk', role: PlayerPosition.gol, x: .50, y: .91),
      FormationSlot(id: 'lb', role: PlayerPosition.le, x: .16, y: .72),
      FormationSlot(id: 'cb1', role: PlayerPosition.zag, x: .38, y: .76),
      FormationSlot(id: 'cb2', role: PlayerPosition.zag, x: .62, y: .76),
      FormationSlot(id: 'rb', role: PlayerPosition.ld, x: .84, y: .72),
      FormationSlot(id: 'dm1', role: PlayerPosition.vol, x: .36, y: .56),
      FormationSlot(id: 'dm2', role: PlayerPosition.vol, x: .64, y: .56),
      FormationSlot(id: 'lm', role: PlayerPosition.pe, x: .17, y: .40),
      FormationSlot(id: 'cm', role: PlayerPosition.mc, x: .50, y: .42),
      FormationSlot(id: 'rm', role: PlayerPosition.pd, x: .83, y: .40),
      FormationSlot(id: 'st', role: PlayerPosition.ca, x: .50, y: .18),
    ],
    FormationType.f352: [
      FormationSlot(id: 'gk', role: PlayerPosition.gol, x: .50, y: .91),
      FormationSlot(id: 'cb1', role: PlayerPosition.zag, x: .27, y: .73),
      FormationSlot(id: 'cb2', role: PlayerPosition.zag, x: .50, y: .77),
      FormationSlot(id: 'cb3', role: PlayerPosition.zag, x: .73, y: .73),
      FormationSlot(id: 'lwb', role: PlayerPosition.le, x: .12, y: .49),
      FormationSlot(id: 'dm1', role: PlayerPosition.vol, x: .37, y: .54),
      FormationSlot(id: 'cm', role: PlayerPosition.mc, x: .50, y: .42),
      FormationSlot(id: 'dm2', role: PlayerPosition.vol, x: .63, y: .54),
      FormationSlot(id: 'rwb', role: PlayerPosition.ld, x: .88, y: .49),
      FormationSlot(id: 'st1', role: PlayerPosition.ca, x: .38, y: .22),
      FormationSlot(id: 'st2', role: PlayerPosition.ca, x: .62, y: .22),
    ],
    FormationType.f343: [
      FormationSlot(id: 'gk', role: PlayerPosition.gol, x: .50, y: .91),
      FormationSlot(id: 'cb1', role: PlayerPosition.zag, x: .27, y: .73),
      FormationSlot(id: 'cb2', role: PlayerPosition.zag, x: .50, y: .77),
      FormationSlot(id: 'cb3', role: PlayerPosition.zag, x: .73, y: .73),
      FormationSlot(id: 'lwb', role: PlayerPosition.le, x: .12, y: .50),
      FormationSlot(id: 'dm1', role: PlayerPosition.vol, x: .39, y: .53),
      FormationSlot(id: 'dm2', role: PlayerPosition.vol, x: .61, y: .53),
      FormationSlot(id: 'rwb', role: PlayerPosition.ld, x: .88, y: .50),
      FormationSlot(id: 'lw', role: PlayerPosition.pe, x: .18, y: .23),
      FormationSlot(id: 'st', role: PlayerPosition.ca, x: .50, y: .18),
      FormationSlot(id: 'rw', role: PlayerPosition.pd, x: .82, y: .23),
    ],
    FormationType.f532: [
      FormationSlot(id: 'gk', role: PlayerPosition.gol, x: .50, y: .91),
      FormationSlot(id: 'lwb', role: PlayerPosition.le, x: .12, y: .61),
      FormationSlot(id: 'cb1', role: PlayerPosition.zag, x: .30, y: .73),
      FormationSlot(id: 'cb2', role: PlayerPosition.zag, x: .50, y: .78),
      FormationSlot(id: 'cb3', role: PlayerPosition.zag, x: .70, y: .73),
      FormationSlot(id: 'rwb', role: PlayerPosition.ld, x: .88, y: .61),
      FormationSlot(id: 'dm1', role: PlayerPosition.vol, x: .36, y: .47),
      FormationSlot(id: 'cm', role: PlayerPosition.mc, x: .50, y: .42),
      FormationSlot(id: 'dm2', role: PlayerPosition.vol, x: .64, y: .47),
      FormationSlot(id: 'st1', role: PlayerPosition.ca, x: .38, y: .21),
      FormationSlot(id: 'st2', role: PlayerPosition.ca, x: .62, y: .21),
    ],
  };
}
