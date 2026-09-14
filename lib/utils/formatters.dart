String timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);

  if (diff.inMinutes < 1) return 'À l\'instant';
  if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
  if (diff.inDays < 7) return 'Il y a ${diff.inDays} j';

  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

String formatPrice(double value, {String symbol = '€'}) {
  return '${value.toStringAsFixed(2)} $symbol';
}
