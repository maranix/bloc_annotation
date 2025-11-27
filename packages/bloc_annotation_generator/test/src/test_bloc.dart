import 'package:bloc_annotation/bloc_annotation.dart';
import 'package:source_gen_test/annotations.dart';

abstract class Bloc<Event, State> {
  Bloc(State initialState) : state = initialState;
  State state;
  void emit(State state) {}
  void on<E>(void Function(E event, void Function(State state) emit) handler) {}
}

typedef Emitter<State> = void Function(State state);

@ShouldGenerate(r'''
abstract class _$TestBloc extends Bloc<TestBlocEvent, int> {
  _$TestBloc(super.initialState) {
    on<_$TestBlocIncrement>(_onIncrement);
  }

  void _onIncrement(_$TestBlocIncrement event, Emitter<int> emit);
}
''')
@BlocClass<TestBlocEvent, int>()
final class TestBloc extends _$TestBloc {
  TestBloc() : super(0);

  @override
  void _onIncrement(_$TestBlocIncrement event, Emitter<int> emit) {
    emit(state + 1);
  }
}

abstract class _$TestBloc extends Bloc<TestBlocEvent, int> {
  _$TestBloc(super.initialState) {
    on<_$TestBlocIncrement>(_onIncrement);
  }

  void _onIncrement(_$TestBlocIncrement event, Emitter<int> emit);
}

sealed class TestBlocEvent {
  const TestBlocEvent();

  factory TestBlocEvent.increment() = _$TestBlocIncrement;
}

final class _$TestBlocIncrement extends TestBlocEvent {
  const _$TestBlocIncrement();
}
