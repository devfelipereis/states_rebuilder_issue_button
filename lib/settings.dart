import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

final _apiUrlRM = RM.inject<String>(
  () => '',
);
final _scoreRM = RM.inject<String>(() => '');

class SettingsScreen extends StatelessWidget {
  // bool get _isFormValid =>
  //     _apiUrlRM.hasData &&
  //     _scoreRM.hasData; // this will not activate the button
  bool get _isFormValid =>
      _apiUrlRM.state.isNotEmpty &&
      _scoreRM.state.isNotEmpty; // this will activate the button

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Configurações",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              buildLabel(context, 'Dominio'),
              apiInput(),
              buildSpace(),
              buildLabel(context, 'Score'),
              scoreInput(),
              SizedBox(
                height: 50,
              ),
              [_apiUrlRM, _scoreRM].rebuilder(() {
                return Align(
                  alignment: Alignment.center,
                  child: MaterialButton(
                    disabledColor: Colors.blueGrey[100],
                    onPressed: !_isFormValid
                        ? null
                        : () async {
                            FocusScope.of(context).unfocus();
                            print(_scoreRM.state);
                            print(_apiUrlRM.state);
                          },
                    child: Text(
                      'save',
                      style: TextStyle(
                        fontSize: 25,
                      ),
                    ),
                    color: Theme.of(context).primaryColor,
                    elevation: 0,
                    height: 50,
                    minWidth: 400,
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                );
              })
            ],
          ),
        ),
      ),
    );
  }

  SizedBox buildSpace() {
    return SizedBox(
      height: 25,
    );
  }

  Text buildLabel(BuildContext context, String label) {
    return Text(
      label,
      style: TextStyle(
        color: Theme.of(context).primaryColor,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }

  StateBuilder<String> scoreInput() {
    return _scoreRM.whenRebuilderOr(
      builder: () {
        return TextFormField(
          initialValue: _scoreRM.state,
          decoration: InputDecoration(
            errorText: _scoreRM.error == null ? null : _scoreRM.error.message,
          ),
          keyboardType: TextInputType.number,
          autocorrect: false,
          onChanged: (value) {
            _scoreRM.setState(
              (_) {
                if (value.isEmpty) {
                  // the save button will never deactivate because the _scoreRM state will never be empty
                  throw ValidationException('Este campo é obrigatório');
                }

                if (int.tryParse(value) == null) {
                  throw ValidationException(
                    'O Score precisa ser um número',
                  );
                }

                return value;
              },
              catchError: true,
            );
          },
        );
      },
    );
  }

  StateBuilder<String> apiInput() {
    return _apiUrlRM.whenRebuilderOr(
      builder: () {
        return TextFormField(
          initialValue: _apiUrlRM.state,
          decoration: InputDecoration(
            errorText: _apiUrlRM.error == null ? null : _apiUrlRM.error.message,
          ),
          keyboardType: TextInputType.text,
          autocorrect: false,
          onChanged: (value) {
            _apiUrlRM.setState(
              (_) {
                if (value.isEmpty) {
                  // the save button will never deactivate because the _apiUrlRM state will never be empty
                  throw ValidationException('Este campo é obrigatório');
                }
                return value;
              },
              catchError: true,
            );
          },
        );
      },
    );
  }
}

class ValidationException implements Exception {
  final String message;

  ValidationException(this.message);
}
