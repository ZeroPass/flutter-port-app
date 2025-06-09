import 'package:dmrtd/extensions.dart';
import 'package:port_mobile_app/screen/requestType.dart';
import 'package:logging/logging.dart';
import 'package:port_mobile_app/utils/structure.dart';
import 'package:port_mobile_app/utils/storage.dart';
import 'package:meta/meta.dart';

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

  QRstructure({required double version, required String accountID, required RequestType requestType, required Server host})
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

    // Copy any other parameters as is
    data.forEach((key, value) {
      if (!['rt', 'uID', 'v', 'url'].contains(key)) {
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
  );
}

Map<String, dynamic> _$QRstrucutreToJson(QRstructure instance) => <String, dynamic>{
  'appName' : instance.appName,
  'version' : instance.version,
  'userID': instance.accountID,
  'requestType': StringUtil.getWithoutTypeName(instance.requestType),
  'url': instance.host.host.toString(),
};

var VERSION_QR_SERVER_STRUCTURE = 0.1;

final _log = Logger("QRserverStructure");
class QRserverStructure extends QRstructure {
  QRserverStructure(
      {required String accountID, required RequestType requestType, required Server host})
      :
        super(version: VERSION_QR_SERVER_STRUCTURE,
          accountID: accountID,
          requestType: requestType,
          host: host);

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
};