import 'package:http/http.dart';
import 'package:flutter/foundation.dart';
import "dart:convert";

class HTTPrequest
{
  String url;

  HTTPrequest({@required this.url});

  void getRequestJson (Function (bool, String) function) async
  {
    Response response = await get(this.url);  // sample info available in response

    int statusCode = response.statusCode;
    if (statusCode != 200)
      function(false, "HTTP status code error: $statusCode");

    Map<String, String> headers = response.headers;
    String contentType = headers['content-type'];
    if (contentType != "application/json")
      function(false, "Header content type is not correct (application/json) It is: $contentType");
    try
    {
      //no errors
      function(true, json.decode(response.body));
    } catch(e) {
      function(false, "Error while parsing string: $e");
    }
    }

}