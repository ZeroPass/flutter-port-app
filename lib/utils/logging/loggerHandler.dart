/*import 'package:port_mobile_app/utils/structure.dart';
//import 'package:f_logs/model/flog/log_level.dart';
import 'package:flutter_logs/flutter_logs.dart';
//import 'package:permission_handler/permission_handler.dart';
//import 'package:f_logs/f_logs.dart';
import 'package:logging/logging.dart';
import 'package:port_mobile_app/utils/storage.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:share/share.dart';
import 'package:open_file_safe_plus/open_file_safe_plus.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';
// import 'package:sembast/sembast.dart';


String CACHE_KEY_NAME = "Port";

class LoggerHandlerInstance{
  late bool logToAppMemory;

  LoggerHandlerInstance(){
    Storage storage = Storage();
    storage.loggingEnabled = false;
    logToAppMemory = false;

    /*LogsConfig config = FLog.getDefaultConfigurations()
    ..isDevelopmentDebuggingEnabled = false
    ..timestampFormat = TimestampFormat.TIME_FORMAT_FULL_3
    ..formatType = FormatType.FORMAT_CUSTOM
    ..fieldOrderFormatCustom = [
      FieldName.TIMESTAMP,
      FieldName.CLASSNAME,
      FieldName.LOG_LEVEL,
      FieldName.TEXT,
    ]
    ..activeLogLevel = LogLevel.ALL;


    FLog.applyConfigurations(config);*/

    FlutterLogs.initLogs(
      logLevelsEnabled: [       LogLevel.INFO,
        LogLevel.WARNING,
        LogLevel.ERROR,
        LogLevel.SEVERE],
      timeStampFormat: TimeStampFormat.TIME_FORMAT_FULL_1,
      directoryStructure: DirectoryStructure.FOR_DATE,
      logTypesEnabled: ["device", "network", "errors"],
      logFileExtension: LogFileExtension.LOG,
      logsWriteDirectoryName: "PassID",
      logsExportDirectoryName: "PassID/Exported",
      debugFileOperations: true,
      isDebuggable: true,
    );

    Logger.root.onRecord.listen((record) {
      if (this.logToAppMemory)
        translate(record);
    });
  }

  Future<bool> startLoggingToAppMemory() async {
    //if (await Permission.storage.request().isGranted) {
      Storage storage = Storage();
      storage.loggingEnabled = true;
      storage.save();
      logToAppMemory = true;
      return true;
    //}
    //return false;
  }
    void stopLoggingToAppMemory(Function notifyOK, Function notifyError) {
      Storage storage = Storage();
      storage.loggingEnabled = false;
      storage.save();
      logToAppMemory = false;
      cleanLogs(notifyOK, notifyError);
    }

    String logLayout(LogRecord logRecord)
    {
      return '[${logRecord.time}] ${logRecord.level.name}: ${logRecord.message}';
    }

    /*
   * Classifitacion log levels from 'logging' library to 'flutter_logs'
  */

  //ALL, TRACE, DEBUG, INFO, WARNING, ERROR, SEVERE, FATAL, OFF }
    LogLevel classificationLogLevel(Level level) {
      if (level == Level.ALL) return LogLevel.ALL;
      if (level == Level.OFF) return LogLevel.OFF;
      if (level == Level.FINEST) return LogLevel.TRACE;
      if (level == Level.FINER) return LogLevel.TRACE;
      if (level == Level.FINE) return LogLevel.DEBUG;
      if (level == Level.CONFIG) return LogLevel.DEBUG;
      if (level == Level.INFO) return LogLevel.INFO;
      if (level == Level.WARNING) return LogLevel.WARNING;
      if (level == Level.SEVERE) return LogLevel.SEVERE;
      if (level == Level.SHOUT) return LogLevel.FATAL;
      else
        return LogLevel.ALL;
    }

    void translate(LogRecord logRecord) async{
      if (this.logToAppMemory) {
        FLog.logThis(text: logRecord.message,
            type: classificationLogLevel(logRecord.level),
            className: logRecord.loggerName,
            methodName: "");
      }
    }


    void cleanLegacyLogs() async {
      int numberOfDays = 15;
      final currentTime = DateTime.now();
      final cutoffTime = currentTime.subtract(Duration(days: numberOfDays));

      try {
        final logs = await FlutterLogs.getAllLogs();
        for (var log in logs) {
          final logTime = DateTime.tryParse(log.split('|').first); // Assumes logs have timestamp at the start
          if (logTime != null && logTime.isBefore(cutoffTime)) {
            await FlutterLogs.deleteLogFile(log);
          }
        }
      } catch (e) {
        print("Error cleaning legacy logs: $e");
      }
    }

    void cleanLegacyLogs() async{
      //delete logs older than <numberOfDays> days
      int numberOfDays = 15;
      FlutterLogs.deleteAllLogsOlderThan(numberOfDays);
    }

    void export({bool open = false, Function? showError}) async{
      try {
        LogsConfig config = FLog.getDefaultConfigurations();
        final logs = await FLog.getAllLogs();
        var buffer = StringBuffer();
        logs.forEach((Log log) {
          buffer.write(Formatter.format(log, config)); // TODO: When log will be sent over net make it json format e.g.: log.toMap()
        });

        List<int> list = buffer.toString().codeUnits;
        Uint8List bytes = Uint8List.fromList(list);

        var file = await DefaultCacheManager().putFile(
            CACHE_KEY_NAME + ".txt", bytes, fileExtension: "txt",
            key: CACHE_KEY_NAME,
            maxAge: Duration(days: 1));

        if (open)
          OpenFilePlus.open(file.path, type: "text/plain", uti: "public.plain-text");
        else
          Share.shareFiles([file.path], text: "PassIdLog (" + DateTimeUtil.current(DateFormat("yyyy-MM-dd HH:mm:ss")) + ")");
      }
      catch(e){
        if (showError != null)
          showError();
      }
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
*/