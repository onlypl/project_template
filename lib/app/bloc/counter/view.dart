import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc.dart';
import 'event.dart';

class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => CounterBloc()..add(InitEvent()),
      child: Builder(builder: (context) => _buildPage(context)),
    );
  }

  Widget _buildPage(BuildContext context) {
    final bloc = BlocProvider.of<CounterBloc>(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${bloc.state.count}'),
            ElevatedButton(
              onPressed: () {
                BlocProvider.of<CounterBloc>(context).add(Increment());
              },
              child: Text('+1'),
            ),
            ElevatedButton(
              onPressed: () {
                bloc.add(Decrement());
              },
              child: Text('-1'),
            ),
          ],
        ),
      ),
    );
  }
}
