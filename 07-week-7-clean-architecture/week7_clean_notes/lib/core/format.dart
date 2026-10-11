/// Fungsi murni yang dapat diuji tanpa widget.
String formatDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];
  final d = date.day.toString().padLeft(2, '0');
  final m = months[date.month - 1];
  return '$d $m ${date.year}';
}
