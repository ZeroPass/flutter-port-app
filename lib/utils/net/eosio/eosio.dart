import 'package:eosdart/eosdart.dart';
import 'package:eosio_passid_mobile_app/utils/storage.dart';
import 'dart:collection';

import 'package:flutter/material.dart';



enum EosioVersion { v1, v2 }

class PrivateKey{
  String privateKey;

  PrivateKey({this.privateKey}) {
    //you can put here any restrictions (length, type, etc)
    if (this.privateKey == null)
      throw FormatException("Private key must be valid - not null.");
  }
  String get(){
    return privateKey;
  }

}
class test{}


class Keys extends ListBase<PrivateKey>{
  List<PrivateKey> _list;

  Keys() : _list = new List();


  void set length(int l) {
    this._list.length=l;
  }

  int get length => _list.length;

  PrivateKey operator [](int index) => _list[index];

  void operator []=(int index, PrivateKey value) {
    _list[index]=value;
  }

  Iterable<PrivateKey> myFilter(text) => _list.where( (PrivateKey e) => e.privateKey != null);

}

class Eosio{
  EOSClient _eosClient;

  Eosio(StorageNode storageNode, EosioVersion version, Keys privateKeys, {int httpTimeout = 15}) {
    assert(storageNode != null);
    assert(privateKeys.length > 0);

    _eosClient =  EOSClient('https://eos.greymass.com', 'v1', httpTimeout: httpTimeout);

  }


}