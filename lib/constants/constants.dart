enum NetworkType{ MAINNET, KYLIN, EOSIO_TESTNET, JUNGLE, CUSTOM}
enum NetworkTypeServer { MAIN_SERVER, TEMPORARY_SERVER }

String NETWORK_CHAIN_NAME = "network_chain_name";
String NETWORK_CHAIN_ID = "network_chain_id";
String NETWORK_CHAIN_DEFAULT = "network_chain_default";

var MAINNET_CHAIN_ID = "aca376f206b8fc25a6ed44dbdc66547c36c6c33e3a119ffbeaef943642f0e906";
var KYLIN_CHAIN_ID = "5fff1dae8dc8e2fc4d5b23b2c7665c97f9e9d8edf2b6485a86ba311c25639191";
var JUNGLE_CHAIN_ID = "e70aaab8997e1dfce58fbfac80cbbb8fecec7b99cf982a9444273cbc64c41473";
var EOSIO_CHAIN_ID = "e70aaab8997e1dfce58fbfac80cbbb8fecec7b99cf982a9444273cbc64c41473";

var NETWORK_CHAINS ={
    //chain id of different chain types; leave it null if you do not want a specify network chain id
    NetworkType.MAINNET:{NETWORK_CHAIN_NAME: "Mainnet", NETWORK_CHAIN_ID : MAINNET_CHAIN_ID, NETWORK_CHAIN_DEFAULT: true},
    NetworkType.KYLIN: {NETWORK_CHAIN_NAME: "Kylin network", NETWORK_CHAIN_ID : KYLIN_CHAIN_ID, NETWORK_CHAIN_DEFAULT: true},
    NetworkType.EOSIO_TESTNET: {NETWORK_CHAIN_NAME: "EOSIO testnet", NETWORK_CHAIN_ID : EOSIO_CHAIN_ID, NETWORK_CHAIN_DEFAULT: true},
    NetworkType.JUNGLE: {NETWORK_CHAIN_NAME: "Jungle network", NETWORK_CHAIN_ID : JUNGLE_CHAIN_ID, NETWORK_CHAIN_DEFAULT: true},
    NetworkType.CUSTOM: {NETWORK_CHAIN_NAME: null, NETWORK_CHAIN_ID : null, NETWORK_CHAIN_DEFAULT: false},
};

var TEST_PRIVATE_KEY = '5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3';