import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TasbihState extends Equatable {
  final int counter;

  const TasbihState({this.counter = 0});

  TasbihState copyWith({int? counter}) {
    return TasbihState(counter: counter ?? this.counter);
  }

  @override
  List<Object?> get props => [counter];
}

class TasbihCubit extends Cubit<TasbihState> {
  TasbihCubit() : super(const TasbihState());

  Future<void> increment() async {
    final newCount = state.counter + 1;
    emit(state.copyWith(counter: newCount));
    await HapticFeedback.lightImpact();
  }

  Future<void> reset() async {
    emit(const TasbihState(counter: 0));
    await HapticFeedback.mediumImpact();
  }
}
