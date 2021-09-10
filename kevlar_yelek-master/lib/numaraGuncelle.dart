import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mm_app/degisken.dart';
import 'package:mm_app/validator/phone_validator_mixin.dart';

class NumaraGuncelle extends StatelessWidget with PhoneValidatorMixin {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen.shade900,
      body: Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: Container(
            padding: const EdgeInsets.only(top: 150),
            margin: const EdgeInsets.only(right: 15, left: 15),
            width: double.infinity,
            child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.phone,
                          color: Colors.white,
                        ),
                        labelText: "Telefon Numarası Giriniz",
                        labelStyle: TextStyle(color: Colors.white),
                        hintText: '+90',
                        prefixText: ' ',
                        hintStyle: TextStyle(color: Colors.white),
                        focusColor: Colors.white,
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                          color: Colors.white,
                        )),
                      ),
                      validator: validatePhone,
                      onSaved: (value) {
                        Degisken.arananNumara = value;
                      },
                    ),
                    Padding(padding: EdgeInsets.only(top: 15)),
                    InkWell(
                      onTap: () {
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                        }
                        ;
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.black,
                            border: Border.all(color: Colors.white, width: 2),
                            borderRadius:
                                BorderRadius.all(Radius.circular(100))),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Center(
                              child: Text(
                            (Degisken.butonMesaji),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          )),
                        ),
                      ),
                    ),
                  ],
                ))),
      ),
    );
  }
}
