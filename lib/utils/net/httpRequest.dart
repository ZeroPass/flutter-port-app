import 'package:http/http.dart';
import 'package:flutter/foundation.dart';
import "dart:convert";

/*
  To store/transfer request data
 */
class Request {
  bool _isValid;
  String _error;
  dynamic _json;

  Request(this._isValid, [this._error = null, this._json = null]);

  bool get isValid => _isValid;

  String get error => _error;

  dynamic get json => _json;
}

/*
  Handle connection on server
 */
class HTTPrequest {
  String url;

  HTTPrequest({required this.url});

  Future<Request> getJsonRequest() async {
    Response response =
        await get(this.url); // sample info available in response

    int statusCode = response.statusCode;
    if (statusCode != 200)
      return Request(false, "HTTP status code error: $statusCode");

    Map<String, String> headers = response.headers;
    String contentType = headers!['content-type'];
    if (contentType != "application/json")
      return Request(false,
          "Header content type is not correct (application/json) It is: $contentType");
    try {
      //no errors
      return Request(true,  null, json.decode(response.body));
    } catch (e) {
      return Request(false, "Error while parsing string: $e");
    }
  }

}
