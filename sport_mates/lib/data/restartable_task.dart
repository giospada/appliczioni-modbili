import 'dart:async';

class RestartableAsyncTask<T> {
  Completer<void>? _currentTaskCompleter;
  // The asyncTask function should return a Future<T>.
  Future<T> run(Future<T> Function() asyncTask) async {
    // Cancel the task if it is not completed
    if (_currentTaskCompleter != null && !_currentTaskCompleter!.isCompleted) {
      _currentTaskCompleter!.completeError('Task cancelled');
    }

    // Create a new task
    _currentTaskCompleter = Completer<void>();
    var localCompleter = _currentTaskCompleter;

    try {
      // Execute the provided async task and wait for it to complete.
      T result = await asyncTask();

      // If the task completed without being restarted, complete the associated Completer.
      if (!localCompleter!.isCompleted) {
        localCompleter.complete();
      }

      return result;
    } catch (e) {
      if (!localCompleter!.isCompleted) {
        // If an error occurs and the task hasn't been cancelled or completed, mark it as error.
        localCompleter.completeError(e);
      }
      // To satisfy the function's return type, rethrow the error here.
      // This will propagate the error to where 'run' is awaited.
      rethrow;
    }
  }
}
