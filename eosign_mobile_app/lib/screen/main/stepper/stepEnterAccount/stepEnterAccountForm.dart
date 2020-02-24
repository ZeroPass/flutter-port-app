import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:eosign_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccount.dart";
import 'package:flutter/cupertino.dart';
import 'package:eosign_mobile_app/utils/storage.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class StepEnterAccountForm extends StatefulWidget {
  StepEnterAccountForm({Key key}) : super(key: key);

  @override
  _StepEnterAccountFormState createState() => _StepEnterAccountFormState();
}


class _StepEnterAccountFormState extends State<StepEnterAccountForm> {
  //Stepper steps
  TextEditingController _accountTextController; // = TextEditingController();
  var _storage;

  _StepEnterAccountFormState({Key key}) {
    this._accountTextController = TextEditingController();
    this._storage = Storage();
  }

  //update fields in account form
  void updateFields() {
    var storage = Storage();
    StepDataEnterAccount storageStepEnterAccount = storage.getStorageData(0);
    _accountTextController = TextEditingController();
    _accountTextController.text = storageStepEnterAccount.accountID;
  }

  //clear fields in account form
  void emptyFields() {
    _accountTextController = TextEditingController();
    _accountTextController.text = "";
  }

  void selectNetwork(var context){
    showPlatformModalSheet(
        context: context, builder: (_) => PopupMenuButton(
      child: new ListTile(
        title: new Text('11 or 22?'),
        trailing: const Icon(Icons.more_vert),
      ),
      itemBuilder: (_) => <PopupMenuItem<String>>[
        new PopupMenuItem<String>(
            child: new Text('11'), value: '11'),
        new PopupMenuItem<String>(
            child: new Text('22'), value: '22'),
      ],
      onSelected: (value) => {} ,
    )
    )
      .whenComplete(() {
      print('Hey there, I\'m calling after hide bottomSheet');
    });
  }

  Widget selectNetwork1(var context){
   return PopupMenuButton(
      child: new ListTile(
        title: new Text('Select node'),
        trailing: const Icon(Icons.account_balance),
      ),
      itemBuilder: (_) => <PopupMenuItem<String>>[
        new PopupMenuItem<String>(
            child: new Text('Mainnet'), value: 'Mainnet'),
        new PopupMenuItem<String>(
            child: new Text('EOS testnet'), value: 'eostestnet'),
        new PopupMenuItem<String>(
            child: new Text('Kylin'), value: 'Kylin'),
      ],
      onSelected: (value) => {} ,
    );
  }

  Widget body(BuildContext context, StepEnterAccountState state,
      var stepEnterAccountBloc) {
    if (state is DeletedState)
      emptyFields();
    if (state is FullState)
      updateFields();

    return Column(children:
        <Widget>[
          selectNetwork1(context)
          /*RaisedButton(
            child: Text("Test modal sheet"),
            onPressed: () {
              selectNetwork(context);
            },
            color: Colors.red,
            textColor: Colors.yellow,
            //padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
            splashColor: Colors.grey,
          )*/,

          TextFormField(
        //maxLength: 12,
        controller: _accountTextController,
        //initialValue: state.accountID,

        decoration: InputDecoration(labelText: 'Account name'),
    autofocus: true,
    validator: (value) => stepEnterAccountBloc.validatorFunction(value, context) ? stepEnterAccountBloc.validatorText : null,
    onChanged: (value) {
    if (_accountTextController.text != value.toLowerCase())
    _accountTextController.value =
    _accountTextController.value.copyWith(
    text: value.toLowerCase());

    //save to storage
    StepDataEnterAccount storageStepEnterAccount = _storage.getStorageData(0);
    storageStepEnterAccount.accountID = _accountTextController.text;
    },
    )

    ]
    );
  }


  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final stepEnterAccountBloc = BlocProvider.of<StepEnterAccountBloc>(context);
    return Form(
        key: _formKey,
        autovalidate: true,
        child: BlocBuilder(
          bloc: stepEnterAccountBloc,
          builder: (BuildContext context, StepEnterAccountState state) {
            return body(context, state, stepEnterAccountBloc);
          },
        ));
  }
}