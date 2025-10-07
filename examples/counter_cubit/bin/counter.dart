import 'dart:convert';
import "dart:io" as io;

import 'package:counter/counter_cubit.dart';

void main() {
  final counter = CounterCubit();

  // Draw initial state
  _renderState(counter.state);

  // Listen for state changes and redraw
  counter.stream.listen(_renderState);

  // Handle user input
  if (io.Platform.isWindows) {
    io.stdin.echoMode = false;
  }
  io.stdin.lineMode = false;
  io.stdin
      .transform(utf8.decoder)
      .listen(
        (key) async => switch (key) {
          'a' || 'A' => counter.increment(),
          'd' || 'D' => counter.decrement(),
          'r' || 'R' => counter.reset(),
          'q' || 'Q' => (() async {
            await counter.close();
            io.exit(0);
          })(),
          _ => io.stdout.writeln(
            "Unknown command $key. Use 'a', 'd', 'r', or 'q'.",
          ),
        },
      );
}

void _renderState(int state) {
  io.stdout.write('\x1B[2J\x1B[0;0H'); // clear
  io.stdout.writeln("Counter $state.");
  io.stdout.writeln(
    "Press 'a' to increment, 'd' to decrement, 'r' to reset, 'q' to quit.",
  );
}
