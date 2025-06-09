import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:port_mobile_app/screen/flow/stepInputData/stepInputData.dart';
import 'package:logging/logging.dart';
import "package:intl/intl.dart";

GlobalKey<ScaffoldState> _SCAFFOLD_KEY = GlobalKey<ScaffoldState>();

class StepInputDataForm extends StatefulWidget {

  @override
  _StepInputDataState createState() => _StepInputDataState();
}

Widget bufferState(BuildContext context) {
  double marginOnRight = MediaQuery
      .of(context)
      .size
      .width;
  double percentageMarginOnRight = 0.09;
  return Padding(
      padding: EdgeInsets.all(0.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 30),
            Container(
                margin: EdgeInsets.only(
                    right: marginOnRight * percentageMarginOnRight),
                child: Text("abc")
            )
          ]
      )
  );
}

class _StepInputDataState extends State<StepInputDataForm>
    with SingleTickerProviderStateMixin {

  final _log = Logger('StepInputDataForm');

  late TabController _tabController;
  final TextEditingController _paceCodeController = TextEditingController();
  final TextEditingController _passportNumberController = TextEditingController();
  DateTime? _dateOfBirth;
  DateTime? _dateOfExpiry;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _selectDate(BuildContext context, bool isBirthDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: isBirthDate ? DateTime(1900) : DateTime.now(),
      lastDate: isBirthDate ? DateTime.now() : DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isBirthDate) {
          _dateOfBirth = picked;
        } else {
          _dateOfExpiry = picked;
        }
      });
    }
  }

  Widget _buildDateField(String label, DateTime? date, bool isBirthDate) {
    return InkWell(
      onTap: () => _selectDate(context, isBirthDate),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
        ),
        child: Text(
          date != null ? DateFormat('yyyy-MM-dd').format(date) : 'Select Date',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
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

  void validateLegacy() {
    if (_passportNumberController.text.isEmpty) {
      _showError('Please enter passport number');
      return;
    }
    if (_dateOfBirth == null) {
      _showError('Please select date of birth');
      return;
    }
    if (_dateOfExpiry == null) {
      _showError('Please select date of expiry');
      return;
    }
    // Proceed with NFC scanning or next steps
    _showConfirmationDialog();
  }

  void validateCAN() {
    if (_paceCodeController.text.isEmpty) {
      _showError('Please enter CAN code');
      return;
    }
    // Proceed with NFC scanning or next steps
    _showConfirmationDialog();
  }

  @override
  Widget build(BuildContext context) {
    _SCAFFOLD_KEY = GlobalKey<ScaffoldState>();
    final stepInputDataBloc = BlocProvider.of<StepInputDataBloc>(context);
    return BlocBuilder(
        bloc: stepInputDataBloc,
        builder: (BuildContext context, StepInputDataState state) {
          return Container(
              child:
              Scaffold(
                appBar: AppBar(
                  title: const Text('Submit Passport Data'),
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 20),
                                  TextField(
                                    controller: _paceCodeController,
                                    decoration: InputDecoration(
                                      labelText: 'PACE Code',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(40),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () {
                                      /* Add PACE verification logic */
                                    },
                                    child: const Text('Scan with NFC'),
                                  ),
                                ],
                              ),
                              // DBA Tab
                              SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 20),
                                    TextField(
                                      controller: _passportNumberController,
                                      decoration: InputDecoration(
                                        labelText: 'Passport Number',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              40),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    _buildDateField(
                                        'Date of Birth', _dateOfBirth, true),
                                    const SizedBox(height: 20),
                                    _buildDateField(
                                        'Date of Expiry', _dateOfExpiry, false),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: validateLegacy,
                                      child: const Text('Scan with NFC'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
          );
        });
  }
}
