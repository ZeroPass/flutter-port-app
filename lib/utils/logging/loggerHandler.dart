import 'dart:io';

import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:cross_file/cross_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:port_mobile_app/utils/storage.dart';
import 'package:share_plus/share_plus.dart';


String CACHE_KEY_NAME = "Port";

class LoggerHandlerInstance{
  late bool logToAppMemory;
  final List<String> _inMemoryLogs = <String>[];
  File? _logFile;

  // Volatile flag for sensitive logging, auto false on restart
  static bool logSensitiveData = false;

  LoggerHandlerInstance(){
    final storage = Storage();
    logToAppMemory = storage.loggingEnabled;

    Logger.root.onRecord.listen((record) async {
      if (logToAppMemory) {
        translate(record);
      }
    });
  }

  Future<bool> startLoggingToAppMemory() async {
    final storage = Storage();
    storage.loggingEnabled = true;
    storage.save();
    logToAppMemory = true;
    _inMemoryLogs.clear();
    await _ensureLogFileInitialized(clearExisting: true);
    return true;
  }

  void stopLoggingToAppMemory(Function notifyOK, Function notifyError) async{
    try {
      final storage = Storage();
      storage.loggingEnabled = false;
      storage.save();
      logToAppMemory = false;
      await cleanLogs(notifyOK, notifyError);
    } catch (_) {
      notifyError();
    }
  }

  String logLayout(LogRecord logRecord){
    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(logRecord.time);
    return '[$timestamp] ${logRecord.level.name} ${logRecord.loggerName}: ${logRecord.message}';
  }

  void translate(LogRecord logRecord) async{
    final line = logLayout(logRecord);
    _inMemoryLogs.add(line);
    // Keep memory bounded
    if (_inMemoryLogs.length > 2000) {
      _inMemoryLogs.removeRange(0, _inMemoryLogs.length - 2000);
    }
    try {
      await _appendToFile(line + '\n');
    } catch (_) {}
  }

  Future<void> _ensureLogFileInitialized({bool clearExisting = false}) async {
    if (_logFile == null) {
      final Directory dir = await getTemporaryDirectory();
      _logFile = File('${dir.path}/$CACHE_KEY_NAME.log');
    }
    if (clearExisting && _logFile!.existsSync()) {
      await _logFile!.writeAsBytes(const <int>[], mode: FileMode.write, flush: true);
    }
  }

  Future<void> _appendToFile(String text) async {
    await _ensureLogFileInitialized();
    await _logFile!.writeAsString(text, mode: FileMode.append, flush: true);
  }

  Future<void> cleanLogs(Function notifyOK, Function notifyError) async{
    try {
      _inMemoryLogs.clear();
      await _ensureLogFileInitialized();
      if (_logFile!.existsSync()) {
        await _logFile!.delete();
      }
      notifyOK();
    } catch (_) {
      notifyError();
    }
  }

  void cleanLegacyLogs() async{
    // No-op for custom logger; we only keep a single temp file
  }

  void export({bool open = false, Function? showError}) async{
    try {
      await _ensureLogFileInitialized();

      // Ensure file contains current in-memory buffer as well
      if (_inMemoryLogs.isNotEmpty) {
        final String content = _inMemoryLogs.join('\n') + '\n';
        await _logFile!.writeAsString(content, mode: FileMode.write, flush: true);
      }

      // Prefer sharing flow for cross-device compatibility; if open requested,
      // still share the file so users can choose an app to open it.
      await Share.shareXFiles([XFile(_logFile!.path)], text: 'PassIdLog (' + DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()) + ')');
    }
    catch(e){
      if (showError != null) {
        showError();
      }
    }
  }

  Future<String> readLog() async {
    await _ensureLogFileInitialized();
    if (_logFile!.existsSync()) {
      try {
        return await _logFile!.readAsString();
      } catch (_) {
        return '';
      }
    }
    return '';
  }
}

//singelton class
class LoggerHandler extends LoggerHandlerInstance {
  static LoggerHandler _singleton = new LoggerHandler._internal();

  factory LoggerHandler(){
    return _singleton;
  }

  LoggerHandler._internal(){
    LoggerHandlerInstance();
  }
}