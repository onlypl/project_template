import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class JackpotWidget extends StatefulWidget {
  const JackpotWidget({super.key});

  @override
  State<JackpotWidget> createState() => _JackpotWidgetState();
}

class _JackpotWidgetState extends State<JackpotWidget> {
  late Timer _timer;
  double _currentAmount = 0;

  final double baseAmount = 1000000;
  final int baseTime = 1749691340; // UTC秒（与JS一致）
  final List<_Rule> rules = [
    _Rule(start: 0, duration: 5, rate: 20.9),
    _Rule(start: 5, duration: 2, rate: -19.1),
    _Rule(start: 7, duration: 3, rate: -10.3),
    _Rule(start: 10, duration: 4, rate: 38.3),
    _Rule(start: 14, duration: 3, rate: 18.2),
    _Rule(start: 17, duration: 4, rate: -18.4),
    _Rule(start: 21, duration: 4, rate: 13.5),
    _Rule(start: 25, duration: 5, rate: 9.4),
    _Rule(start: 30, duration: 2, rate: 49.2),
    _Rule(start: 32, duration: 3, rate: -12.5),
    _Rule(start: 35, duration: 2, rate: -3.5),
    _Rule(start: 37, duration: 3, rate: 8.3),
    _Rule(start: 40, duration: 5, rate: -7.2),
    _Rule(start: 45, duration: 2, rate: 6.1),
    _Rule(start: 47, duration: 3, rate: 36.4),
    _Rule(start: 50, duration: 4, rate: -12.2),
    _Rule(start: 54, duration: 3, rate: -5.4),
    _Rule(start: 57, duration: 3, rate: 4.8),
  ];

  @override
  void initState() {
    super.initState();
    _updateAmount();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateAmount());
  }

  void _updateAmount() {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final totalElapsed = now - baseTime;

    double amount = baseAmount;

    if (totalElapsed > 0) {
      final totalDuration = rules.fold<int>(0, (sum, rule) => sum + rule.duration);
      final cycleCount = totalElapsed ~/ totalDuration;
      final elapsedInCycle = totalElapsed % totalDuration;

      // 全周期增减
      for (final rule in rules) {
        amount += rule.rate * rule.duration * cycleCount;
      }

      // 当前周期内变化
      int accTime = 0;
      for (final rule in rules) {
        if (elapsedInCycle > accTime + rule.duration) {
          amount += rule.rate * rule.duration;
          accTime += rule.duration;
        } else {
          amount += rule.rate * (elapsedInCycle - accTime);
          break;
        }
      }
    }

    setState(() {
      _currentAmount = amount;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get formattedAmount =>
      NumberFormat("#,##0.00", "en_US").format(_currentAmount);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 24, color: Colors.black),
            children: [
              const TextSpan(text: '🎰 当前奖池金额： '),
              TextSpan(
                text: formattedAmount,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Rule {
  final int start;
  final int duration;
  final double rate;

  const _Rule({required this.start, required this.duration, required this.rate});
}