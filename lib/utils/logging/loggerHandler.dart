import 'package:eosio_passid_mobile_app/utils/structure.dart';
import 'package:f_logs/model/flog/log_level.dart';
//import 'package:flutter_logs/flutter_logs.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:f_logs/f_logs.dart';
import 'package:logging/logging.dart';
import 'package:eosio_passid_mobile_app/utils/storage.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:share/share.dart';
import 'package:open_file/open_file.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:sembast/sembast.dart';


String CACHE_KEY_NAME = "PassId";

class LoggerHandlerInstance{
  bool logToAppMemory;
  final PermissionGroup _permissionGroup = PermissionGroup.storage;

  LoggerHandlerInstance(){
    Storage storage = Storage();
    storage.loggingEnabled = false;
    logToAppMemory = false;
  }

  Future<bool> startLoggingToAppMemory() async {
    //ask for permission
    if (await requestPermission(_permissionGroup) == false)
      return false;

    Storage storage = Storage();
    storage.loggingEnabled = true;
    storage.save();
    logToAppMemory = true;
    return true;
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
    LogLevel classificationLogLevel(Level level){
      return LogLevel.INFO;

      //TODO:need to work with all types
      switch(level.name){
        case 'ALL': return LogLevel.ALL;
        case 'OFF': return LogLevel.ALL;
        case 'FINEST': return LogLevel.TRACE;
        case 'FINER': return LogLevel.TRACE;
        case 'FINE': return LogLevel.TRACE;
        case 'CONFIG': return LogLevel.TRACE;
        case 'INFO': return LogLevel.INFO;
        case 'WARNING': return LogLevel.WARNING;
        case 'SEVERE': return LogLevel.SEVERE;
        case 'SHOUT': return LogLevel.FATAL;
        default: return LogLevel.ALL;
      }
    }

    void translate(LogRecord logRecord) async{
      if (this.logToAppMemory) {
        await FLog.logThis(text: logRecord.message,
            type: classificationLogLevel(logRecord.level),
            className: "PassID");
      }
      }

    void initialize() async {
      //logging library
      //Logger.root.level = Level.ALL;

      //flutter-logs library
      /*WidgetsFlutterBinding.ensureInitialized();

      //Initialize Logging
      await FlutterLogs.initLogs(
          logLevelsEnabled: [
            LogLevel.INFO,
            LogLevel.WARNING,
            LogLevel.ERROR,
            LogLevel.SEVERE
          ],
          timeStampFormat: TimeStampFormat.TIME_FORMAT_READABLE,
          directoryStructure: DirectoryStructure.FOR_DATE,
          logTypesEnabled: ["device","network","errors"],
          logFileExtension: LogFileExtension.LOG,
          logsWriteDirectoryName: "PassID",
          logsExportDirectoryName: "PassID/Exported",
          debugFileOperations: true,
          isDebuggable: true);*/

      Logger.root.onRecord.listen((record) {
        if (this.logToAppMemory)
          translate(record);
      });
    }

    void cleanLogs(Function notifyOK, Function notifyError) async{
      try {
        //delete log database
        FLog.clearLogs();
        //delete log - specific file
        await DefaultCacheManager().removeFile(CACHE_KEY_NAME);
        //delete whole log
        await DefaultCacheManager().emptyCache();
        notifyOK();
      }
      catch(e){
        notifyError();
      }
    }

    void cleanLegacyLogs() async{
      //delete logs older than <numberOfDays> days
      int numberOfDays = 15;
      FLog.deleteAllLogsByFilter(filters: [
        Filter.lessThan(DBConstants.FIELD_TIME_IN_MILLIS,
            DateTime.now().millisecondsSinceEpoch - 1000 * 60/*minute*/ * 60/*hour*/ * 24/*day*/ * numberOfDays/*days*/ )
      ]);
    }

    void export({bool open = false, Function showError = null}) async{
      try {
        List<Log> logs = await FLog.getAllLogs();
        String logs2 = "";
        logs.forEach((Log element) {
          logs2 += element.toMap().toString() + '\n';
        });

        List<int> list = logs2.codeUnits;
        Uint8List bytes = Uint8List.fromList(list);

        var file = await DefaultCacheManager().putFile(
            CACHE_KEY_NAME + ".txt", bytes, fileExtension: "txt",
            key: CACHE_KEY_NAME,
            maxAge: Duration(days: 1));

        if (open)
          OpenFile.open(file.path, type: "text/plain", uti: "public.plain-text");
        else
          Share.shareFiles([file.path], text: "PassIdLog (" + DateTimeUtil.current(DateFormat("yyyy-MM-dd HH:mm:ss")) + ")");
      }
      catch(e){
        if (showError != null)
          showError();
      }
    }

    Future<bool> requestPermission(PermissionGroup permission) async {
      final List<PermissionGroup> permissions = <PermissionGroup>[permission];
      final Map<PermissionGroup, PermissionStatus> permissionRequestResult =
      await PermissionHandler().requestPermissions(permissions);
      PermissionStatus ps = permissionRequestResult[PermissionGroup.storage];
      return ps == PermissionStatus.granted ? true : false;
    }
}

//singelton class
class LoggerHandler extends LoggerHandlerInstance {
  static LoggerHandler _singleton = new LoggerHandler._internal();

  factory LoggerHandler(){
    LoggerHandlerInstance();
    return _singleton;
  }

  LoggerHandler._internal(){}
}
