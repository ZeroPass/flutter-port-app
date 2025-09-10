import 'package:dmrtd/extensions.dart';
import 'package:port_mobile_app/screen/requestType.dart';
import 'package:logging/logging.dart';
import 'package:port_mobile_app/utils/structure.dart';
import 'package:port_mobile_app/utils/storage.dart';

var APP_NAME_QR_STRUCTURE = "Port.link";

/**********************
*
*  QR structure
 *  QR code needs to follow this structure to be readable by the app.
*
***********************/

class QRstructure{
  final _log = Logger("QRstrucutre");

  late String appName;
  late double version;
  late String accountID;
  late RequestType requestType;
  late Server host;
  late bool includeDG1;
  late bool includeDG2;

  QRstructure({required double version, required String accountID, required RequestType requestType, required Server host, this.includeDG1 = false, this.includeDG2 = false})
  {
    this.appName = APP_NAME_QR_STRUCTURE;
    this.version  = version;
    this.accountID = accountID;
    this.requestType = requestType;
    this.host = host;
  }

  void QRstrucutreFromJson(Map<String, dynamic> json) {
      this.version = json["version"] as double;
      this.accountID = json['userID'] as String;
      this.requestType = EnumUtil.fromStringEnum(RequestType.values, json['requestType']);
      this.host = Server(host: Uri.parse(json['url']));
  }

  factory QRstructure.fromJson(Map<String, dynamic> json) => _$QRstrucutreFromJson(json);

  Map<String, dynamic> toJson(){
    try {
      return _$QRstrucutreToJson(this);
    }
    catch(e){
      _log.debug("Error occurred while parsing data from QR code: $e");
      throw Exception("Error occurred while parsing data from QR code: $e");
    }
  }

  static String? getRequestTypeString(int number) {
    // Check if the number exists in the map
    if (!numericToRequestType.containsKey(number)) {
      return null;
    }
    
    return numericToRequestType[number].toString()
      .split('.').last
      .toLowerCase();
  }

  static Map<String, dynamic> shortToLong(Map<String, dynamic> data) {
    // Create a new map for the transformed data
    Map<String, dynamic> transformedData = {};
    
    // Transform parameter names and values
    if (data.containsKey('rt')) {
      // Convert rt (request type) value to proper format
      int? rtValue = int.tryParse(data['rt'].toString());
      if (rtValue != null) {
        String? requestTypeStr = getRequestTypeString(rtValue);
        if (requestTypeStr != null) {
          transformedData['requestType'] = requestTypeStr;
        } else {
          throw Exception('Invalid request type value: ${data['rt']}');
        }
      } else {
        throw Exception('Request type value is not a valid number');
      }
    }

    // Transform userID
    if (data.containsKey('uID')) {
      transformedData['userID'] = data['uID'];
    }

    // Transform version
    if (data.containsKey('v')) {
      transformedData['version'] = data['v'];
    }

    // Process URL parameter - add https:// and .port.link if needed
    if (data.containsKey('url')) {
      String urlValue = data['url'].toString();
      
      // Remove any existing http:// or https:// for processing
      urlValue = urlValue.replaceAll(RegExp(r'^https?://'), '');
      
      // Check if domain contains any dots
      if (!urlValue.contains('.')) {
        urlValue = urlValue + '.port.link';
      }
      
      // Add https:// prefix
      urlValue = 'https://' + urlValue;
      
      transformedData['url'] = urlValue;
    }

    // Handle iDG1 and iDG2 conversion to includeDG1 and includeDG2
    if (data.containsKey('iDG1')) {
      int? dg1Value = int.tryParse(data['iDG1'].toString());
      transformedData['includeDG1'] = dg1Value == 1;
    }
    
    if (data.containsKey('iDG2')) {
      int? dg2Value = int.tryParse(data['iDG2'].toString());
      transformedData['includeDG2'] = dg2Value == 1;
    }

    // Copy any other parameters as is
    data.forEach((key, value) {
      if (!['rt', 'uID', 'v', 'url', 'iDG1', 'iDG2'].contains(key)) {
        transformedData[key] = value;
      }
    });
    return transformedData;

  }

}

QRstructure _$QRstrucutreFromJson(Map<String, dynamic> json) {
  return QRstructure(
    version: json["version"] as double,
    accountID: json['userID'] as String,
    requestType: EnumUtil.fromStringEnum(RequestType.values, json['requestType'].toUpperCase()),
    host: Server(host: Uri.parse(json['url'])),
    includeDG1: json['includeDG1'] as bool? ?? false,
    includeDG2: json['includeDG2'] as bool? ?? false,
  );
}

Map<String, dynamic> _$QRstrucutreToJson(QRstructure instance) => <String, dynamic>{
  'appName' : instance.appName,
  'version' : instance.version,
  'userID': instance.accountID,
  'requestType': StringUtil.getWithoutTypeName(instance.requestType),
  'url': instance.host.host.toString(),
  'includeDG1': instance.includeDG1,
  'includeDG2': instance.includeDG2,
};

var VERSION_QR_SERVER_STRUCTURE = 0.1;

final _log = Logger("QRserverStructure");
class QRserverStructure extends QRstructure {
  QRserverStructure(
      {required String accountID, required RequestType requestType, required Server host, bool includeDG1 = false, bool includeDG2 = false})
      :
        super(version: VERSION_QR_SERVER_STRUCTURE,
          accountID: accountID,
          requestType: requestType,
          host: host,
          includeDG1: includeDG1,
          includeDG2: includeDG2);

  static QRserverStructure? parseDynamicLink(String data){
    try{
        _log.info("PARSE DYNAMIC LINK: $data");
        Uri uri = Uri.parse(data);
        if (!uri.hasQuery)
          throw ('No query in dynamic link url.');

        var queryParameters = uri.queryParameters;

        //if (!queryParameters.containsKey('link'))
        //  throw ('No "link" parameter in query');

        //var link = queryParameters['link'];

        //var deepLinkURL = Uri.parse(link!);

        //from shorter to longer format
        Map<String, dynamic> dataLong = QRstructure.shortToLong(queryParameters);

        return QRserverStructure.fromJson(dataLong);
    }
    catch(e){
      _log.debug("Error while parsing dynamic link: " + e.toString());
      return null;
    }

  }

  factory QRserverStructure.fromJson(Map<String, dynamic> json) =>
      _$QRserverStrucutreFromJson(json);


  Map<String, dynamic> toJson() {
    try {
      return _$QRserverStrucutreToJson(this);
    }
    catch (e) {
      _log.debug("QRserverStrucutreToJson; Error occurred while parsing data from QR code: $e");
      throw ("QRserverStrucutreToJson; Error occurred while parsing data from QR code: $e");
    }
  }
}

QRserverStructure _$QRserverStrucutreFromJson(Map<String, dynamic> json) {
  _log.info('Type of json: ${json.runtimeType}');
  _log.info('Keys: ${json.keys.toList()}');

  json.forEach((key, value) {
    _log.info('Key: "$key", Value: "$value"');
  });

  _log.info('QRserverStrucutreFromJson: $json');
  _log.info('QRserverStrucutreFromJson: ${json['userID']}');
  _log.info('QRserverStrucutreFromJson: ${json['requestType']}');
  _log.info('QRserverStrucutreFromJson: ${json['url']}');
  
  var qr = QRserverStructure(
    accountID: json['userID'] as String,
    requestType: EnumUtil.fromStringEnum(RequestType.values, json['requestType'].toUpperCase()),
    host: Server(host: Uri.parse(json['url'])),
    includeDG1: json['includeDG1'] as bool? ?? false,
    includeDG2: json['includeDG2'] as bool? ?? false,
  );
  _log.info('QRserverStrucutreFromJson: $qr');
  return qr;
}

Map<String, dynamic> _$QRserverStrucutreToJson(QRserverStructure instance) => <String, dynamic>{
  'appName' : instance.appName,
  'version' : instance.version,
  'userID': instance.accountID.toLowerCase(),
  'requestType': StringUtil.getWithoutTypeName(instance.requestType),
  'url': instance.host.host.toString(),
  'includeDG1': instance.includeDG1,
  'includeDG2': instance.includeDG2,
};