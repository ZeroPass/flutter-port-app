export 'stepInputDataBloc.dart';
export 'stepInputDataEvent.dart';
export 'stepInputDataForm.dart';
export 'stepInputDataState.dart';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:intl/intl.dart';

import 'package:port/port.dart';
import 'package:port_mobile_app/data/data.dart';
import 'package:port_mobile_app/screen/alert.dart';
import 'package:dmrtd/extensions.dart';
import 'package:logging/logging.dart';
import 'package:rive/rive.dart';

import '../../../utils/storage.dart';
import '../../customDatePicker.dart';
import '../../theme.dart';

class StepInputData extends StatefulWidget {

  @override
  _StepInputData createState() => _StepInputData();
}

enum CANorLegacy { CAN, Legacy }

class _StepInputData extends State<StepInputData>
    with SingleTickerProviderStateMixin {
  static final _log = Logger("AESCipher");
  Storage storage = Storage();
  late TabController _tabController;
  final GlobalKey<FormState> _paceFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _legacyFormKey = GlobalKey<FormState>();
  final TextEditingController _paceCodeController = TextEditingController();
  final TextEditingController _passportNumberController = TextEditingController();
  final TextEditingController _birthTextController = TextEditingController();
  final TextEditingController _validUntilTextController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _paceCodeController.text =
    storage.canData.isValidCan() ? storage.canData.getCan() : "";

    _passportNumberController.text =
    storage.legacyData.isValidDocumentID() ? storage.legacyData.getDocumentID() : "";

    _birthTextController.text =
    storage.legacyData.isValidBirth() ? CustomDatePicker.formatDate(storage.legacyData.getBirth()) : "";

    _validUntilTextController.text =
    storage.legacyData.isValidValidUntil() ? CustomDatePicker.formatDate(storage.legacyData.getValidUntil()) : "";


  }

  Future<bool> showError({required String message}) async {
    _log.info('Show error with message: $message');
    bool? response = await  showAlert<bool>(
        context: context,
        title: Text("Warning"),
        content: Text(message),
        actions: [
          PlatformDialogAction(
              child: PlatformText('Close',
                  style: TextStyle(
                      color: Theme.of(context).focusColor,
                      fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.pop(context, false))
        ]);
    return response ?? false;
  }

  Future<bool> showCANdialog() async {
    _log.info('Show showCANdialog');
    Artboard? _riveArtboard;
    RiveAnimationController _animationController;

    try {
      final data = await rootBundle.load('assets/anim/checkmarks.riv');
      final file = RiveFile.import(data);
      _riveArtboard = file.mainArtboard;
      _animationController = SimpleAnimation('assets/anim/checkmarks.riv');
      _riveArtboard.addController(_animationController);
      _riveArtboard.advance(0);
    } catch (e) {
      _log.severe('Failed to load Rive file: $e');
      return false; // Early return if Rive fails to load
    }

    bool? response = await showAlert<bool>(
      context: context,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Where to find CAN code?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "It could be found on main page of your document (written verticaly):",
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Container(
            height: 100,
            width: 100,
            child: Rive(artboard: _riveArtboard, alignment: Alignment.centerLeft),
            /*const RiveAnimation.asset(
              'assets/anim/nfc.riv',
              fit: BoxFit.contain,
            ),*/
          ),
        ],
      ),
      actions: [
        PlatformDialogAction(
          child: PlatformText(
            'Close',
            style: TextStyle(
              color: Theme.of(context).focusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () => Navigator.pop(context, false),
        ),
      ],
    );

    return response ?? false;
  }

  Widget confirmationButton({required String text,
                              required Function action}) {
    _log.info('Creating button with text: $text');
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 40),
            child: PlatformTextButton(
              color: AndroidThemeST().getValues().themeValues["BUTTON"]["COLOR_BACKGROUND"],

              padding:
              Platform.isIOS ? EdgeInsets.symmetric(horizontal: 0) : null,
              child: Text(text, style: TextStyle(color: Colors.white)),
              onPressed: () => action()
            ))
      ],
    );
  }

  Future<void> _showConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm'),
          content: const Text('Proceed with NFC scanning?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Proceed'),
              onPressed: () {
                Navigator.of(context).pop();
                // Add NFC scanning logic here
              },
            ),
          ],
        );
      },
    );
  }

  void validateAndProceedLegacy(){
    _log.info('Validating input data');
    if (_passportNumberController.text.isEmpty) {
      _log.error('Passport number is required');
      showError(message: 'Passport number is required');
      return;
    }
    if (_birthTextController.text.isEmpty) {
      _log.error('Date of birth must be set');
      showError(message: 'Date of birth must be set');
      return;
    }
    if (_validUntilTextController.text.isEmpty) {
      _log.error('Date of expiry must be set');
      showError(message: 'Date of expiry must be set');
      return;
    }

    _log.sdVerbose('Passport number: ${_passportNumberController.text}');
    _log.sdVerbose('Date of birth: ${_birthTextController.text}');
    _log.sdVerbose('Date of expiry: ${_validUntilTextController.text}');
    _log.finer("All data is valid. Going to scan");

    // Proceed with NFC scanning or next steps
    goToScan();
  }

  void validateAndProceedCAN(){
    _log.info('Validating input data');
    if (_paceCodeController.text.isEmpty) {
      _log.error('PACE code is required');
      showError(message: 'PACE code is required');
      return;
    }

    _log.sdVerbose('PACE code: ${_paceCodeController.text}');
    _log.finer("All data is valid. Going to scan");

    // Proceed with NFC scanning or next steps
    goToScan();
  }

  void goToScan(){
    _log.info('Proceeding to scan');
    //TODO: Navigate to scan screen
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Enter data'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TabBar(
                indicatorColor: Color(0xFFA58157),
                labelStyle: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 25,
                  letterSpacing: 0.0,
                ),
                unselectedLabelStyle:
                TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 23,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.normal,
                ),
                indicatorWeight: 4,
                controller: _tabController,
                tabs: const [
                  Tab(text: 'PACE'),
                  Tab(text: 'Legacy'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // PACE Tab
                    Form(
                      key: _paceFormKey,
                      child: FractionallySizedBox(
                          widthFactor: 0.8,
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _paceCodeController,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly, // Allows only digits
                            ],
                            onChanged: (value) {
                              //save to storage
                              CanData canData = storage.canData;
                              canData.can = _paceCodeController.text;
                              storage.save();
                            },
                            decoration: InputDecoration(
                              labelText: 'PACE Code',
                              suffixIcon: IconButton(
                                icon: Icon(Icons.help_outline), // Mini question mark icon
                                onPressed: () async {
                                  // Call the previous showCANdialog function
                                  await showCANdialog();
                                },
                                tooltip: "What is this?",
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'PACE Code is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          confirmationButton(text: "Verify PACE Code",
                                             action: this.validateAndProceedCAN),
                        ],
                      )
                )
                    ),
                    // Legacy Tab
                    Form(
                      key: _legacyFormKey,
                      child: SingleChildScrollView(
                        child: FractionallySizedBox(
                          widthFactor: 0.8,
                          child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _passportNumberController,
                              textCapitalization: TextCapitalization.characters,
                              textInputAction: TextInputAction.done,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]+')),
                                LengthLimitingTextInputFormatter(14),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Passport Number is required';
                                }
                                if (!RegExp(r"^[a-zA-Z0-9]*$").hasMatch(value)) {
                                  return 'Special characters not allowed.';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'Passport Number',
                              ),
                              onChanged: (value) {
                                if (_passportNumberController.text != value.toUpperCase())
                                  _passportNumberController.value = _passportNumberController
                                      .value
                                      .copyWith(text: value.toUpperCase());

                                //save to storage
                                LegacyData legacyData = storage.legacyData;
                                legacyData.documentID = _passportNumberController.text;
                                storage.save();
                              },
                            ),
                            const SizedBox(height: 20),
                            CustomDatePicker(
                              text: "Date of Birth",
                              firstDate: DateTime(DateTime.now().year - 90),
                              lastDate: DateTime.now(),
                              initialDate: DateTime(DateTime.now().year - 13),
                              callbackOnDatePicked: /*callback*/ (selectedDate) {
                                //save to storage
                                LegacyData legacyData = storage.legacyData;
                                legacyData.birth = selectedDate;
                                //save storage
                                storage.save();
                              },
                              callbackOnUpdate: /*callback*/ (String value) {
                                LegacyData legacyData = storage.legacyData;
                                if (value == "")
                                  legacyData.birth = null;
                                else {
                                  try {
                                    legacyData.birth =
                                        CustomDatePicker.parseDateFormated(value);
                                  } catch (e) {
                                    print("Converting throws error.");
                                  }
                                }
                                //save storage
                                storage.save();

                              },
                              textEditingController: _birthTextController,
                            ),
                            const SizedBox(height: 20),
                            CustomDatePicker(
                                text:"Date of Expiry",
                                firstDate:  /*(this._allowExpiredPassport)
                    ? DateTime(DateTime.now().year - 90) :*/
                                DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1),
                                lastDate: DateTime(DateTime.now().year + 30),
                                initialDate: DateTime(DateTime.now().year + 1),
                                callbackOnDatePicked: /*callback*/ (selectedDate) {
                                  //save to storage
                                  LegacyData legacyData = storage.legacyData;
                                  legacyData.validUntil = selectedDate;
                                  //save storage
                                  storage.save();
                                },
                                callbackOnUpdate:  /*callback*/ (String value) {
                                  LegacyData legacyData = storage.legacyData;
                                  if (value == "")
                                    legacyData.validUntil = null;
                                  else {
                                    try {
                                      legacyData.validUntil =
                                          CustomDatePicker.parseDateFormated(value);
                                    } catch (e) {
                                      print("Converting throws error.");
                                    }
                                  }
                                  //save storage
                                  storage.save();
                                },
                                textEditingController: _validUntilTextController
                            ),
                            //
                            //_buildDateField('Date of Expiry', _dateOfExpiry, false),
                            //
                            const SizedBox(height: 20),
                            confirmationButton(text: "Verify PACE Code",
                                action: this.validateAndProceedLegacy),
                          ],
                        ),
                      ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}