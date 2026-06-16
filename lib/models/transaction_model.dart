import 'package:flutter/material.dart';

class TransactionModel {
  final String title;
  final String subtitle;
  final double amount;
  final DateTime date;
  final bool isIncome;
  final IconData icon;

  TransactionModel({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.isIncome,
    required this.icon,
  });
}
