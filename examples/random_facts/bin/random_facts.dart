import 'dart:convert';
import 'dart:io' as io;
import 'package:random_facts/random_fact_bloc.dart'
    show RandomFactBloc, FetchRandomFact;
import 'package:random_facts/random_facts.dart';

void main() async {
  final randomFactBloc = RandomFactBloc();

  _renderState(randomFactBloc.state);

  randomFactBloc.stream.listen(_renderState);

  randomFactBloc.add(FetchRandomFact());

  if (io.Platform.isWindows) {
    io.stdin.echoMode = false;
  }
  io.stdin.lineMode = false;
  io.stdin
      .transform(utf8.decoder)
      .listen(
        (key) async => switch (key) {
          'f' || 'F' => randomFactBloc.add(FetchRandomFact()),
          's' || 'S' => _renderState(randomFactBloc.latestFact?.text),
          'l' || 'L' => _renderState(
            randomFactBloc.allFacts.map((f) => f.text).toList(),
          ),
          'q' || 'Q' => (() async {
            await randomFactBloc.close();
            io.exit(0);
          })(),
          _ => io.stdout.writeln(
            "Unknown command $key. Use 'a', 'd', 'r', or 'q'.",
          ),
        },
      );
}

void _renderState(Object? state) {
  io.stdout.write('\x1B[2J\x1B[0;0H'); // clear
  if (state != null) {
    if (state is List) {
      for (var fact in state) {
        if (fact is Fact) {
          io.stdout.writeln(fact.text);
        } else {
          io.stdout.writeln(fact);
        }
      }
    } else if (state is Fact) {
      io.stdout.writeln(state.text);
    } else {
      io.stdout.writeln(state);
    }
    io.stdout.writeln();
    io.stdout.writeln();
  }
  io.stdout.writeln(
    "Press 'f' to fetch a fact, 's' to show latest fact, 'l' to list all facts, 'q' to quit.",
  );
}
