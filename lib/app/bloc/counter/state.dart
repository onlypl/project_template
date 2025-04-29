import 'package:equatable/equatable.dart';

class CounterState extends Equatable {
  final int count;
  const CounterState({this.count = 0});
  CounterState init() {
    return CounterState();
  }

  CounterState clone() {
    return CounterState();
  }

  @override
  List<Object?> get props => [count];
}
