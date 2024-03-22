import 'package:flutter/material.dart';

class AsyncLoaderPage extends StatefulWidget {
  final Future<dynamic> Function() _asyncOperation;

  const AsyncLoaderPage({
    Key? key,
    required Future<dynamic> Function() asyncOperation,
  })  : _asyncOperation = asyncOperation,
        super(key: key);

  @override
  _AsyncLoaderPageState createState() => _AsyncLoaderPageState(
        asyncOperation: _asyncOperation,
      );
}

enum AsyncState { loading, success, error }

class _AsyncLoaderPageState extends State<AsyncLoaderPage> {
  AsyncState? _state;
  dynamic _data;

  final Future<dynamic> Function() _asyncOperation;

  _AsyncLoaderPageState({
    required Future<dynamic> Function() asyncOperation,
  }) : _asyncOperation = asyncOperation;

  @override
  void initState() {
    super.initState();
    _executeAsyncOperation();
  }

  Future<void> _executeAsyncOperation() async {
    setState(() => _state = AsyncState.loading);
    try {
      // Replace _asyncOperation with your async function
      _data = await _asyncOperation();
      setState(() => _state = AsyncState.success);
      // Navigate back with data after a short delay to show the success animation

      Future.delayed(
          Duration(seconds: 2), () => Navigator.of(context).pop(_data));
    } catch (e) {
      setState(() => _state = AsyncState.error);
      // navigate back with error after showing the animation
      Navigator.of(context).pop(e);
    }
  }

  Widget _buildBody() {
    switch (_state) {
      case AsyncState.loading:
        return Center(child: CircularProgressIndicator());
      case AsyncState.success:
        return Center(
            child: Icon(Icons.check_circle, color: Colors.green, size: 80));
      case AsyncState.error:
        return Center(child: Icon(Icons.error, color: Colors.red, size: 80));
      default:
        return Container(); // Placeholder for initial state or another state management
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 500),
        child: _buildBody(),
      ),
    );
  }
}
