import 'package:flutter_bloc/flutter_bloc.dart';

import 'logger.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    Logger.green(name: "${bloc.runtimeType}", "", emoji: '+');
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    Logger.gray(name: "${bloc.runtimeType}", '• ${event.runtimeType}');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    final message =
        '⚡ '
        '[ ${change.currentState.runtimeType} ]'
        ' ⇨ '
        '[ ${change.nextState.runtimeType} ]';
    Logger.gray(name: "${bloc.runtimeType}", message);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    Logger.error(bloc.runtimeType.toString(), error, stackTrace);
  }
}
