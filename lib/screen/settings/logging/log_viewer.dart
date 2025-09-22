import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:port_mobile_app/utils/logging/loggerHandler.dart';

class LogViewerScreen extends StatefulWidget {
  const LogViewerScreen({super.key});

  @override
  State<LogViewerScreen> createState() => _LogViewerScreenState();
}

class _LogViewerScreenState extends State<LogViewerScreen> {
  final LoggerHandler _loggerHandler = LoggerHandler();
  String _content = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });
    final content = await _loggerHandler.readLog();
    setState(() {
      _content = content.isEmpty ? 'No log entries yet.' : content;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      material: (_, __) => MaterialScaffoldData(resizeToAvoidBottomInset: false),
      cupertino: (_, __) => CupertinoPageScaffoldData(resizeToAvoidBottomInset: false),
      appBar: PlatformAppBar(
        title: const Text('Log viewer'),
        trailingActions: <Widget>[
          PlatformIconButton(
            onPressed: _load,
            icon: Icon(context.platformIcons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Scrollbar(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: SelectableText(
                    _content,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12.0),
                  ),
                ),
              ),
            ),
    );
  }
}


