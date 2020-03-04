import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:eosio_passid_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccount.dart";
import 'package:flutter/cupertino.dart';
import 'package:eosio_passid_mobile_app/utils/storage.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:eosio_passid_mobile_app/screen/customBottomPicker.dart';

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

  void selectNetwork(var context) {
    var storage = Storage();
    BottomPickerStructure bps = BottomPickerStructure();
    bps.importStorageNodeList(storage.storageNodes(), storage.getSelectedNode(), "Select node", "Please select the node");
    CustomBottomPickerState cbps = CustomBottomPickerState(structure: bps);
    cbps.showPicker(context);
  }

  void selectNetworkOld(var context) {

    showPlatformModalSheet(
        context: context,
        builder: (_) => PopupMenuButton(
          //child: new ListTile(
          //  title: new Text('11 or 22?'),
          //  trailing: const Icon(Icons.more_vert),
          //),
          itemBuilder: (_) => <PopupMenuItem<String>>[
            new PopupMenuItem<String>(child: new Text('11'), value: '11'),
            new PopupMenuItem<String>(child: new Text('22'), value: '22'),
          ],
          onSelected: (value) => {},
        )
    ).whenComplete(() {
      print('Hey there, I\'m calling after hide bottomSheet');
    });
  }

  Widget selectNetworkWithTile(var context, String _selection) {
    Storage storage = new Storage();
    var nodes = storage.storageNodes();
    return PopupMenuButton<String>(
      color: Colors.amber,
      onSelected: (String value) {
        setState(() {
          print("select something:" + value);
          print (_selection);
          _selection = value;
        });
      },
      child: Container(
        color: Colors.red,
            child:
      ListTile(
        dense: true,
        contentPadding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
        //title: Text('Title'),
        title: /*Column(
          children: <Widget>[
            Text(_selection == null ? 'Nothing selected yet' : _selection.toString(),style: TextStyle(fontWeight: FontWeight.bold, )),
          ],
        )*/
        Row(
          children: <Widget>[
            Icon(Icons.clear_all,color:Colors.black),
            SizedBox(width: 8,),
            Text('Network', style: TextStyle(fontWeight: FontWeight.bold, )),
            SizedBox(width: 8,),
            Container(
                width:MediaQuery.of(context).size.width*0.45,
                child: Align(alignment: Alignment.centerRight, child:Text(_selection == null ? 'Nothing selected yet' : _selection.toString())))
          ],
        ),

        trailing: Icon(Icons.expand_more),
      )
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'Value1',
          child: Text('Choose value 1'),
        ),
        const PopupMenuItem<String>(
          value: 'Value2',
          child: Text('Choose value 2'),
        ),
        const PopupMenuItem<String>(
          value: 'Value3',
          child: Text('Choose value 3'),
        ),
      ],
    );
    /*ListTile(
        dense: true,
        title: Text("Select node", style: TextStyle(fontWeight: FontWeight.bold)),
        //trailing: const Icon(Icons.expand_more),
        leading: IconButton(
          icon: Icon(Icons.add_alarm),
          onPressed: () {
            print('Hello world');
          },
        ),
        subtitle:PopupMenuButton(
          color: Colors.deepPurple,
          /*child: new ListTile(
            title: new Text('Select node'),
            trailing: const Icon(Icons.expand_more),
            leading: const Icon(Icons.arrow_right),
          ),*/
          itemBuilder: (_) => <PopupMenuItem<String>>[
            for(var item in nodes)
              PopupMenuItem<String>(
                child: new Text(item.name + " (" + item.toString() + ")"),
                value: item.name)
          ],
          onSelected: (value) => {},
        )
    );*/
  }



  Widget body(BuildContext context, StepEnterAccountState state,
      var stepEnterAccountBloc) {
    if (state is DeletedState) emptyFields();
    if (state is FullState) updateFields();
    String selectedNode;
    return Column(children: <Widget>[
      //selectNetworkWithTile(context, selectedNode),
      RaisedButton(child: Text("Rock & Roll"),
        onPressed: () => selectNetwork(context),
        color: Colors.red,
        textColor: Colors.yellow,
        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
        splashColor: Colors.grey,
      ),
    /*ListTile(
    dense: true,
    title: Text(
    "Account name",
    style: TextStyle(fontWeight: FontWeight.bold),
    ),
    subtitle:*/ TextFormField(
        controller: _accountTextController,
        decoration: InputDecoration(labelText: 'Account name', ),
        autofocus: true,
        validator: (value) =>
            stepEnterAccountBloc.validatorFunction(value, context)
                ? stepEnterAccountBloc.validatorText
                : null,
        onChanged: (value) {
          if (_accountTextController.text != value.toLowerCase())
            _accountTextController.value = _accountTextController.value
                .copyWith(text: value.toLowerCase());

          //save to storage
          StepDataEnterAccount storageStepEnterAccount =
              _storage.getStorageData(0);
          storageStepEnterAccount.accountID = _accountTextController.text;
        },
      )
    //)
    ]
    );
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final stepEnterAccountBloc = BlocProvider.of<StepEnterAccountBloc>(context);
    print("width");
    print(MediaQuery.of(context).size.width);
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
