import 'package:bloc/bloc.dart';
import 'package:bloc_annotation/bloc_annotation.dart';

part 'counter_cubit.g.dart';

@CubitClass(state: int)
final class CounterCubit extends _$CounterCubit {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
  void reset() => emit(0);
}
