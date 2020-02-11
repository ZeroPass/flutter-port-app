import 'package:eosign_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccount.dart';
import 'package:eosign_mobile_app/screen/main/stepper/stepScan/stepScan.dart';
import 'package:eosign_mobile_app/screen/main/stepper/stepper.dart';

int _NUM_OF_STEPS = 3;
//data stored in the singelton class
class StorageData {
  List<StepData> _steps;

  StorageData(){
    this._steps = new List(_NUM_OF_STEPS);
    //initialize every step
    this._steps[0] = StepDataEnterAccount();
    this._steps[1] = StepDataScan();
    // this._steps[2] =
  }

  StepData getStorageData(int index){
    //out of array
    if (index > _NUM_OF_STEPS)
      return null;

    return _steps[index];
  }

}

//singelton class
class Storage extends StorageData {
  static final Storage _singleton = new Storage._internal();

  factory Storage(){
    StorageData();
    return _singleton;
  }

  Storage._internal(){
    //initialization your logic here
  }
}
