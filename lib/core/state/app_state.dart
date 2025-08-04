import 'package:equatable/equatable.dart';

/// A generic class that represents a state in the application.
/// It can be in one of four states: initial, loading, success, or error.
abstract class AppState<T> extends Equatable {
  const AppState();

  /// Creates an initial state
  const factory AppState.initial() = InitialAppState<T>;

  /// Creates a loading state with optional data
  const factory AppState.loading([T? data]) = LoadingAppState<T>;

  /// Creates a success state with data
  const factory AppState.success(T data) = SuccessAppState<T>;

  /// Creates an error state with an error and optional stack trace and data
  const factory AppState.error(
    Object error, [
    StackTrace? stackTrace,
    T? data,
  ]) = ErrorAppState<T>;

  /// Returns the current data if available, or null
  T? get data => maybeWhen(
        success: (data) => data,
        error: (_, _) => (this as ErrorAppState<T>).data,
        orElse: () => null,
      );

  /// Returns whether the state is in the initial state
  bool get isInitial => this is InitialAppState<T>;

  /// Returns whether the state is in the loading state
  bool get isLoading => this is LoadingAppState<T>;

  /// Returns whether the state is in the success state
  bool get isSuccess => this is SuccessAppState<T>;

  /// Returns whether the state is in the error state
  bool get isError => this is ErrorAppState<T>;

  /// Pattern matching for the state
  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(T data) success,
    required R Function(Object error, StackTrace? stackTrace) error,
  }) {
    if (this is InitialAppState<T>) {
      return initial();
    } else if (this is LoadingAppState<T>) {
      return loading();
    } else if (this is SuccessAppState<T>) {
      return success((this as SuccessAppState<T>).data);
    } else if (this is ErrorAppState<T>) {
      return error(
        (this as ErrorAppState<T>).error,
        (this as ErrorAppState<T>).stackTrace,
      );
    } else {
      throw StateError('Unknown state: $this');
    }
  }

  /// Pattern matching for the state with an orElse fallback
  R maybeWhen<R>({
    R Function()? initial,
    R Function()? loading,
    R Function(T data)? success,
    R Function(Object error, StackTrace? stackTrace)? error,
    required R Function() orElse,
  }) {
    if (this is InitialAppState<T> && initial != null) {
      return initial();
    } else if (this is LoadingAppState<T> && loading != null) {
      return loading();
    } else if (this is SuccessAppState<T> && success != null) {
      return success((this as SuccessAppState<T>).data);
    } else if (this is ErrorAppState<T> && error != null) {
      return error(
        (this as ErrorAppState<T>).error,
        (this as ErrorAppState<T>).stackTrace,
      );
    } else {
      return orElse();
    }
  }
}

/// The initial state of the app
class InitialAppState<T> extends AppState<T> {
  const InitialAppState();

  @override
  List<Object?> get props => [];
}

/// The loading state of the app
class LoadingAppState<T> extends AppState<T> {
  final T? _data;

  const LoadingAppState([this._data]);

  @override
  T? get data => _data;

  @override
  List<Object?> get props => [_data];
}

/// The success state of the app
class SuccessAppState<T> extends AppState<T> {
  @override
  final T data;

  const SuccessAppState(this.data);

  @override
  List<Object?> get props => [data];
}

/// The error state of the app
class ErrorAppState<T> extends AppState<T> {
  final Object error;
  final StackTrace? stackTrace;
  final T? _data;

  const ErrorAppState(this.error, [this.stackTrace, T? data]) : _data = data;

  @override
  T? get data => _data;

  @override
  List<Object?> get props => [error, stackTrace, _data];
}
