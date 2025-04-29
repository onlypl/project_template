import 'package:bloc/bloc.dart';

import 'event.dart';
import 'state.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(CounterState().init()) {
    on<InitEvent>(_init);
  }

  void _init(InitEvent event, Emitter<CounterState> emit) async {
    emit(state.clone());
  }

  Stream<CounterState> mapEventToState(CounterEvent event) async* {
    if (event is Increment) {
      yield CounterState(count: state.count + 1);
    } else if (event is Decrement) {
      yield CounterState(count: state.count - 1);
    }
  }
}
