part of 'counter_bloc.dart';

@immutable
sealed class CounterEvent {}

//计数器加1事件
class Increment extends CounterEvent {}

//计数器减1事件
class Decrement extends CounterEvent {}
