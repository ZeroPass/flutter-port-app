enum NetworkType{ MAINNET, KYLIN, EOSIO_TESTNET, JUNGLE, CUSTOM}


var settings ={
  "chain_id": {
    //chain id of different chain types; leave it null if you do not want a specify network chain id
    NetworkType.MAINNET: null,
    NetworkType.KYLIN: null,
    NetworkType.EOSIO_TESTNET: null,
    NetworkType.JUNGLE: null,
    NetworkType.CUSTOM: null
  }
};

NetworkType getNetworkTypeFromString(String networkAsString) {
  for (NetworkType element in NetworkType.values) {
    if (element.toString() == networkAsString) {
      return element;
    }
  }
  return null;
}