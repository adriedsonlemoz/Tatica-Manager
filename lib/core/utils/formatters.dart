String formatMoney(int value) {
  final negative = value < 0;
  final amount = value.abs();
  final formatted = amount >= 1000000000
      ? 'R\$ ${(amount / 1000000000).toStringAsFixed(1)} bi'
      : amount >= 1000000
          ? 'R\$ ${(amount / 1000000).toStringAsFixed(1)} mi'
          : amount >= 1000
              ? 'R\$ ${(amount / 1000).toStringAsFixed(0)} mil'
              : 'R\$ $amount';
  return negative ? '-$formatted' : formatted;
}

String compactMoney(int value) {
  if (value.abs() >= 1000000) return 'R\$ ${(value / 1000000).toStringAsFixed(1)}M';
  if (value.abs() >= 1000) return 'R\$ ${(value / 1000).toStringAsFixed(0)}K';
  return 'R\$ $value';
}

String shortDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';

String fullDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

String weekdayLabel(DateTime date) => switch (date.weekday) {
      DateTime.monday => 'Segunda-feira',
      DateTime.tuesday => 'Terça-feira',
      DateTime.wednesday => 'Quarta-feira',
      DateTime.thursday => 'Quinta-feira',
      DateTime.friday => 'Sexta-feira',
      DateTime.saturday => 'Sábado',
      DateTime.sunday => 'Domingo',
      _ => '',
    };

String calendarDate(DateTime date) => '${weekdayLabel(date)} • ${fullDate(date)}';
