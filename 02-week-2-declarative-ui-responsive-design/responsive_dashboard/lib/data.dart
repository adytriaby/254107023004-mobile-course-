import 'package:flutter/material.dart';

/// Batas lebar layar untuk beralih dari satu kolom ke dua kolom.
const double kWideBreakpoint = 700;

/// Data satu kartu informasi pada dashboard.
class DashboardData {
  const DashboardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.semanticLabel,
  });

  final String title;
  final String value;
  final IconData icon;
  final String semanticLabel;
}

const List<DashboardData> kDashboardItems = [
  DashboardData(
    title: 'Assignments',
    value: '8',
    icon: Icons.assignment,
    semanticLabel: 'Tugas: 8 tugas belum selesai',
  ),
  DashboardData(
    title: 'Attendance',
    value: '92%',
    icon: Icons.event_available,
    semanticLabel: 'Kehadiran: 92 persen',
  ),
  DashboardData(
    title: 'GPA',
    value: '3.72',
    icon: Icons.grade,
    semanticLabel: 'IPK: 3.72',
  ),
  DashboardData(
    title: 'Current Week',
    value: '02',
    icon: Icons.calendar_today,
    semanticLabel: 'Minggu berjalan: minggu 2',
  ),
];
