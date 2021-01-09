import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class AppSettings {
  final String apiUrl;
  final String score;

  AppSettings({
    this.apiUrl,
    this.score,
  });
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
  @override
  String toString() => message.toString();
}

fetchToSetting() async {
  await Future.delayed(Duration(seconds: 2));
  return AppSettings(apiUrl: 'http://googlec.com', score: '33');
}

//Global
final appSettings = RM.injectFuture<AppSettings>(
  () async => // AppSettings()
      // use this, if you want init settings
      await fetchToSetting(),
);

//Local
final _apiUrlRM = RM.inject<String>(() => '');
final _scoreRM = RM.inject<String>(() => '');

class SettingsScreen extends StatelessWidget {
  bool get _isFormValid => !_apiUrlRM.hasError && !_scoreRM.hasError;

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
          child: appSettings.whenRebuilderOr(
            onWaiting: () => const Center(child: CircularProgressIndicator()),
            builder: () => Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                buildLabel(context, 'Dominio'),
                apiInput(),
                buildSpace(),
                buildLabel(context, 'Score'),
                scoreInput(),
                [_apiUrlRM, _scoreRM].rebuilder(
                  () => Center(child: Text('FormValid: $_isFormValid')),
                  shouldRebuild: () =>
                      _apiUrlRM.hasData ||
                      _scoreRM
                          .hasData, //By default it will rebuild when both have data, or you can simply use whenRebuilderOr()
                ),
                SizedBox(
                  // height: 100.h,
                  height: 100,
                ),
                [_apiUrlRM, _scoreRM].whenRebuilderOr(
                  builder: () {
                    return Align(
                      alignment: Alignment.center,
                      child: MaterialButton(
                        disabledColor: Colors.blueGrey[100],
                        onPressed: !_isFormValid
                            ? null
                            : () async {
                                FocusScope.of(context).unfocus();

                                final settings = AppSettings(
                                  score: _scoreRM.state,
                                  apiUrl: _apiUrlRM.state,
                                );

                                appSettings.setState(
                                  (s) async {
                                    //For showing Indicator only
                                    await Future.delayed(Duration(seconds: 2));

                                    return settings;
                                  },
                                  onData: (context, model) {
                                    // successToast('Configurações atualizadas.');
                                    print('Configurações atualizadas.');
                                  },
                                  onError: (context, error) => print(
                                      'Não foi possível fazer o registro.'),
                                  shouldAwait: true,
                                );
                              },
                        child: Text(
                          'salvar',
                          style: TextStyle(
                            fontSize: 25,
                          ),
                        ),
                        color: Theme.of(context).primaryColor,
                        elevation: 0,
                        // height: 150.h,
                        // minWidth: 0.7.sw,
                        height: 150,
                        textColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  SizedBox buildSpace() {
    return SizedBox(
      // height: 25.h,
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

  Widget apiInput() {
    return _apiUrlRM.whenRebuilderOr(
      initState: () => _apiUrlRM.setState((s) => appSettings.state.apiUrl),
      builder: () {
        return TextFormField(
          initialValue: _apiUrlRM.state,
          decoration: InputDecoration(
            errorText: _apiUrlRM.hasError ? _apiUrlRM.error.message : null,
          ),
          keyboardType: TextInputType.text,
          autocorrect: false,
          onChanged: (value) {
            _apiUrlRM.setState(
              (_) {
                if (value.isEmpty) {
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

  Widget scoreInput() {
    return _scoreRM.whenRebuilderOr(
      initState: () => _scoreRM.setState((s) => appSettings.state.score),
      builder: () {
        return TextFormField(
          initialValue: _scoreRM.state,
          decoration: InputDecoration(
            errorText: _scoreRM.hasError ? _scoreRM.error.message : null,
          ),
          keyboardType: TextInputType.number,
          autocorrect: false,
          onChanged: (value) {
            _scoreRM.setState(
              (_) {
                if (value.isEmpty) {
                  throw ValidationException('Este campo é obrigatório');
                }

                if (int.tryParse(value) == null) {
                  throw ValidationException('O Score precisa ser um número');
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
