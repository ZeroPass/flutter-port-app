import 'package:port_mobile_app/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:port_mobile_app/screen/main/stepper/stepScan/stepScan.dart";
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import "package:port_mobile_app/screen/main/stepper/stepper.dart";
import 'package:flutter/cupertino.dart';
import 'package:port_mobile_app/screen/customDatePicker.dart';
import 'package:port_mobile_app/screen/theme.dart';
import 'package:logging/logging.dart';
import 'package:port_mobile_app/utils/size.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:port_mobile_app/can_code.dart';
import 'dart:math';


///temp
///
///
///
///
///
/////
///
class DebugTextEditingController extends TextEditingController {
  final String identifier;

  DebugTextEditingController({String? text, required this.identifier}) : super(text: text);

  @override
  void dispose() {
    debugPrint('DISPOSED: TextEditingController [$identifier]');
    // Optionally, print stack trace:
    debugPrint(StackTrace.current.toString());

    super.dispose();
  }
}

class StepScanForm extends StatefulWidget {
  final void Function(bool isPaceMode, bool isDBA)? onStepContinueWithParams;
  StepScanForm({this.onStepContinueWithParams}) : super();

  @override
  _StepScanFormState createState() => _StepScanFormState();
}

class _StepScanFormState extends State<StepScanForm> with SingleTickerProviderStateMixin {
  static final _log = Logger('StepScanForm');
  late TabController _tabController;
  final DebugTextEditingController _paceCodeController = DebugTextEditingController(identifier: "neki");
  final TextEditingController _passportIdTextController = TextEditingController();
  final TextEditingController _birthTextController = TextEditingController();
  final TextEditingController _validUntilTextController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final GlobalKey<FormState> _paceFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _legacyFormKey = GlobalKey<FormState>();
  List<double> _tabHeights = [0.0, 0.0];
  int _currentIndex = 0;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index.toDouble() == _tabController.animation!.value) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });
    updateFields();
  }

  @override
  void dispose() {
    _paceCodeController.dispose();
    _passportIdTextController.dispose();
    _birthTextController.dispose();
    _validUntilTextController.dispose();
    _pinController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  //update fields in account form
  void updateFields() {
    var storage = Storage();
    StepDataScan storageStepScan = storage.getStorageData(1) as StepDataScan;
    
    // Legacy data
    _passportIdTextController.text =
        storageStepScan.isValidDocumentID() ? storageStepScan.getDocumentID() : "";
    _birthTextController.text = storageStepScan.isValidBirth()
        ? CustomDatePicker.formatDate(storageStepScan.getBirth())
        : "";
    _validUntilTextController.text = storageStepScan.isValidValidUntil()
        ? CustomDatePicker.formatDate(storageStepScan.getValidUntil())
        : "";
        
    // PACE data
    _paceCodeController.text = storageStepScan.isValidPaceCode() ? storageStepScan.getPaceCode() : "";
    _pinController.text = storageStepScan.isValidPaceCode() ? storageStepScan.getPaceCode() : "";
  }

  //clear fields in account form
  void emptyFields() {
    _passportIdTextController.text = '';
    _birthTextController.text = '';
    _validUntilTextController.text = '';
    _paceCodeController.text = '';
    _pinController.text = '';
  }

  Future<bool> showError({required String message}) async {
    _log.info('Show error with message: $message');
    bool? response = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Warning"),
        content: Text(message),
        actions: [
          TextButton(
            child: Text('Close', 
              style: TextStyle(
                color: Theme.of(context).focusColor,
                fontWeight: FontWeight.bold
              )
            ),
            onPressed: () => Navigator.pop(context, false)
          )
        ]
      )
    );
    return response ?? false;
  }

  void _updateHeight(int index, double height) {
    if (mounted && height > 0 && _tabHeights[index] != height) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if(mounted) {
          setState(() {
            _tabHeights[index] = height;
          });
        }
      });
    }
  }

  void validateAndProceedPACE(StepperBloc stepperBloc, {required bool isDBA}) {
    _log.info('Validating PACE input data');
    if (_paceCodeController.text.isEmpty) {
      _log.info('PACE code is required');
      showError(message: 'PACE code is required');
      return;
    }

    _log.info("PACE data is valid. Going to scan");
    //this should always be true
    bool isPaceMode = true;
    _log.info("isPaceMode: $isPaceMode, isDBA: $isDBA");
    widget.onStepContinueWithParams?.call(isPaceMode, isDBA);
  }

  void validateAndProceedLegacy(StepperBloc stepperBloc, {required bool isDBA}) {
    _log.info('Validating Legacy input data');
    if (_passportIdTextController.text.isEmpty) {
      _log.info('Passport number is required');
      showError(message: 'Passport number is required');
      return;
    }
    if (_birthTextController.text.isEmpty) {
      _log.info('Date of birth must be set');
      showError(message: 'Date of birth must be set');
      return;
    }
    if (_validUntilTextController.text.isEmpty) {
      _log.info('Date of expiry must be set');
      showError(message: 'Date of expiry must be set');
      return;
    }

    //this should always be false
    bool isPaceMode = false;
    _log.info("Legacy data is valid. Going to scan");
    _log.info("isPaceMode: $isPaceMode, isDBA: $isDBA");
    widget.onStepContinueWithParams?.call(isPaceMode, isDBA);
  }

  @override
  Widget build(BuildContext context) {
    Storage storage = Storage();
    final stepScanBloc = BlocProvider.of<StepScanBloc>(context);
    final stepperBloc = BlocProvider.of<StepperBloc>(context);

    return BlocBuilder(
      bloc: stepScanBloc,
      builder: (BuildContext context, StepScanState state) {
        if (state is StateScan) emptyFields();
        updateFields();

        return DefaultTabController(
          length: 2,
          child: Material(
            color: Colors.white10,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  color: Colors.transparent,
                  child: TabBar(
                    indicatorColor: Color(0xFFA58157),
                    labelColor: AndroidThemeST().getValues().themeValues["STEPPER"]["STEP_SCAN"]["COLOR_TEXT"],
                    unselectedLabelColor: AndroidThemeST().getValues().themeValues["STEPPER"]["STEP_SCAN"]["COLOR_TEXT"].withOpacity(0.5),
                    labelStyle: TextStyle(
                      //fontFamily: 'Outfit',
                      fontSize: 14,
                      letterSpacing: 0.0,
                    ),
                    unselectedLabelStyle: TextStyle(
                      //fontFamily: 'Outfit',
                      fontSize: 14,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.normal,
                    ),
                    indicatorWeight: 4,
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'CAN'),
                      Tab(text: 'Legacy'),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: _tabHeights.isNotEmpty ? _tabHeights[_currentIndex] : 0,
                  child: IndexedStack(
                    index: _currentIndex,
                    children: [
                      // PACE Tab
                      LayoutBuilder(
                        builder: (context, constraints) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                              final keyContext = _paceFormKey.currentContext;
                              if (keyContext != null) {
                                final box = keyContext.findRenderObject() as RenderBox;
                                _updateHeight(0, box.size.height);
                              }
                          });
                          return SingleChildScrollView(
                            child: Form(
                              key: _paceFormKey,
                              autovalidateMode: AutovalidateMode.always,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          color: AndroidThemeST().getValues().themeValues["STEPPER"]["STEP_SCAN"]["COLOR_TEXT"]
                                        ),
                                        children: [
                                          TextSpan(
                                            text: "Input the 6-digit CAN number, usually right on your passport's page.\n"
                                          ),
                                          TextSpan(
                                            text: "Click here",
                                            style: TextStyle(
                                              color: Colors.blue,
                                              decoration: TextDecoration.underline,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () async {
                                                final Uri url = Uri.parse('https://github.com/ZeroPass/flutter-port-app/blob/master/country-guide.md');
                                                if (await canLaunchUrl(url)) {
                                                  await launchUrl(url);
                                                }
                                              }
                                          ),
                                          TextSpan(
                                            text: " for the country-specific guide,"
                                          ),
                                          TextSpan(
                                            text: " or use the "
                                          ),
                                          TextSpan(
                                            text: "'Legacy' tab",
                                            style: TextStyle(
                                              color: Colors.blue,
                                              decoration: TextDecoration.underline,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                _tabController.animateTo(1); // Switch to Legacy tab
                                              }
                                          ),
                                          TextSpan(
                                            text: "."
                                          ),
                                        ]
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    CanCodeWidget(
                                      controller: _paceCodeController,
                                      onChanged: (value) {
                                        StepDataScan storageStepScan = storage.getStorageData(1) as StepDataScan;
                                        storageStepScan.paceCode = value;
                                        storage.save();
                                        stepperBloc.liveModifyHeader(1, context);
                                      },
                                      onVerified: (value) {
                                        StepDataScan storageStepScan = storage.getStorageData(1) as StepDataScan;
                                        if (value.isEmpty) {
                                          storageStepScan.paceCode = null;
                                        } else {
                                          storageStepScan.paceCode = value;
                                        }
                                        storage.save();
                                        stepperBloc.liveModifyHeader(1, context);
                                        
                                        if (value.isEmpty) {
                                          return 'PACE Code is required';
                                        }
                                        return null;
                                      },
                                      key: ValueKey('pace_can_code'),
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: () => validateAndProceedPACE(stepperBloc, isDBA: false),
                                      child: Text('Scan with CAN'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AndroidThemeST().getValues().themeValues["BUTTON"]["COLOR_BACKGROUND"],
                                        foregroundColor: AndroidThemeST().getValues().themeValues["BUTTON"]["COLOR"],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                      ),
                      // Legacy Tab
                      LayoutBuilder(
                        builder: (context, constraints) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                              final keyContext = _legacyFormKey.currentContext;
                              if (keyContext != null) {
                                final box = keyContext.findRenderObject() as RenderBox;
                                _updateHeight(1, box.size.height);
                              }
                          });
                          return SingleChildScrollView(
                            child: Form(
                              key: _legacyFormKey,
                              autovalidateMode: AutovalidateMode.always,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SelectableText(
                                      'Data only used to establish secure communication.',
                                      style: TextStyle(
                                        color: AndroidThemeST().getValues().themeValues["STEPPER"]["STEP_SCAN"]["COLOR_TEXT"]
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: _passportIdTextController,
                                      decoration: InputDecoration(
                                        labelText: 'Passport No.',
                                      ),
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]+')),
                                        LengthLimitingTextInputFormatter(14)
                                      ],
                                      textInputAction: TextInputAction.done,
                                      textCapitalization: TextCapitalization.characters,
                                      validator: (value) => value != null ? 
                                        RegExp(r"^[a-zA-Z0-9]*$").hasMatch(value) ? null : "Special characters not allowed."
                                        : null,
                                      onChanged: (value) {
                                        if (_passportIdTextController.text != value.toUpperCase())
                                          _passportIdTextController.value = _passportIdTextController
                                              .value
                                              .copyWith(text: value.toUpperCase());

                                        StepDataScan storageStepScan = storage.getStorageData(1) as StepDataScan;
                                        storageStepScan.documentID = _passportIdTextController.text;
                                        storage.save();
                                        stepperBloc.liveModifyHeader(1, context);
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                    CustomDatePicker(
                                      text: "Date of Birth",
                                      firstDate: DateTime(DateTime.now().year - 90),
                                      lastDate: DateTime.now(),
                                      initialDate: DateTime(DateTime.now().year - 13),
                                      callbackOnDatePicked: (selectedDate) {
                                        StepDataScan storageStepScan = storage.getStorageData(1) as StepDataScan;
                                        storageStepScan.birth = selectedDate;
                                        storage.save();
                                        stepperBloc.liveModifyHeader(1, context);
                                      },
                                      callbackOnUpdate: (String value) {
                                        StepDataScan storageStepScan = storage.getStorageData(1) as StepDataScan;
                                        if (value == "")
                                          storageStepScan.birth = null;
                                        else {
                                          try {
                                            storageStepScan.birth = CustomDatePicker.parseDateFormated(value);
                                          } catch (e) {
                                            print("Converting throws error.");
                                          }
                                        }
                                        storage.save();
                                        stepperBloc.liveModifyHeader(1, context);
                                      },
                                      textEditingController: _birthTextController,
                                    ),
                                    const SizedBox(height: 8),
                                    CustomDatePicker(
                                      text: "Date of Expiry",
                                      firstDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1),
                                      lastDate: DateTime(DateTime.now().year + 30),
                                      initialDate: DateTime(DateTime.now().year + 1),
                                      callbackOnDatePicked: (selectedDate) {
                                        StepDataScan storageStepScan = storage.getStorageData(1) as StepDataScan;
                                        storageStepScan.validUntil = selectedDate;
                                        storage.save();
                                        stepperBloc.liveModifyHeader(1, context);
                                      },
                                      callbackOnUpdate: (String value) {
                                        StepDataScan storageStepScan = storage.getStorageData(1) as StepDataScan;
                                        if (value == "")
                                          storageStepScan.validUntil = null;
                                        else {
                                          try {
                                            storageStepScan.validUntil = CustomDatePicker.parseDateFormated(value);
                                          } catch (e) {
                                            print("Converting throws error.");
                                          }
                                        }
                                        storage.save();
                                        stepperBloc.liveModifyHeader(1, context);
                                      },
                                      textEditingController: _validUntilTextController,
                                    ),
                                    const SizedBox(height: 15),
                                    ElevatedButton(
                                      onPressed: () => validateAndProceedLegacy(stepperBloc, isDBA: true),
                                      child: Text('Scan with Legacy'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AndroidThemeST().getValues().themeValues["BUTTON"]["COLOR_BACKGROUND"],
                                        foregroundColor: AndroidThemeST().getValues().themeValues["BUTTON"]["COLOR"],
                                      )
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
