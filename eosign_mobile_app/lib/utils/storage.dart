import 'package:eosign_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccount.dart';
import 'package:eosign_mobile_app/screen/main/stepper/stepper.dart';

int _NUM_OF_STEPS = 3;
//data stored in the singelton class
class StorageData {
  List<StepData> _steps;

  StorageData(){
    this._steps = new List(_NUM_OF_STEPS);
    this._steps[0] = StepDataEnterAccount();
  }

}

//singelton class
class Storage {
  static final Storage _singleton = new Storage._internal();

  StorageData _sd;

  factory Storage(){
    return _singleton;
  }

  Storage._internal(){
    //initialization your logic here
    _sd = new StorageData();
  }

  StorageData getStorageData(int index){
    //out of array
    if (index > _NUM_OF_STEPS)
      return null;

    //return _sd[index];

  }
}

//how to call a class
//Storage mClass = new Storage(); //get back the singleton to you