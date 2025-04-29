abstract class CounterEvent {}

class InitEvent extends CounterEvent {}

//计数器加1事件
class Increment extends CounterEvent {}

//计数器减1事件
class Decrement extends CounterEvent {}
