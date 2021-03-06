import 'package:csci3100/models/user.dart';
import 'package:csci3100/services/supportdb.dart';
import 'package:csci3100/shared/constants.dart';
import 'package:csci3100/shared/inputs.dart';
import 'package:csci3100/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Report extends StatefulWidget {
  final User target;

  const Report({this.target});
  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> {

  final _formKey = GlobalKey<FormState>();
  String content;
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<UserId>(context);
    void submit() async {
      setState(() {loading = true;});
      if (_formKey.currentState.validate()) {
        SupportDB(content: content).setReport(userId.uid, widget.target.uid);
        Navigator.of(context).pop();
      }
      setState(() {loading = false;});
    }
    return loading ? Loading() : Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text('Report user "${widget.target.name}"'),
        flexibleSpace: Container(
          decoration: appBarDecoration,
        ),
      ),
      body: Container(
        decoration: bodyDecoration,
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 20,),
                  MyTextFormField(type: "Detail of report", changeFunc: (String val) => setState(()=> content = val)),
                  MySubmitButton("Submit", submit),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
