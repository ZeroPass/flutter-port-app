import 'package:eosio_passid_mobile_app/utils/storage.dart';
import 'package:eosio_passid_mobile_app/utils/net/httpRequest.dart';

//Node url paths

String NODE_GET_INFO = "v1/chain/get_info";

class Node
{
  StorageNode _storageNode;

  Node (this._storageNode);

  String createLinkPath({String url, String path}){
    return url + '/' + path;
  }

  Future<bool> checkStatus() async
  {
    Request request = await HTTPrequest(url:createLinkPath(url: _storageNode.url(), path: NODE_GET_INFO)).getJsonRequest();
    //request is not valid
    if (!request.isValid)
      throw Exception("Request on server failed with error: ${request.error}");


  }

}