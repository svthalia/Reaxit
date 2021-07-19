import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api_repository.dart';
import 'package:reaxit/blocs/registration_fields_cubit.dart';
import 'package:reaxit/models/registration_field.dart';
import 'package:reaxit/ui/router.dart';
import 'package:reaxit/ui/widgets/app_bar.dart';
import 'package:reaxit/ui/widgets/error_center.dart';

class RegistrationScreen extends StatefulWidget {
  final int eventPk;
  final int registrationPk;

  RegistrationScreen({required this.eventPk, required this.registrationPk})
      : super(key: ValueKey(registrationPk));

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  late final RegistrationFieldsCubit _registrationFieldsCubit;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _registrationFieldsCubit = RegistrationFieldsCubit(
      RepositoryProvider.of<ApiRepository>(context),
    )..load(
        eventPk: widget.eventPk,
        registrationPk: widget.registrationPk,
      );
    super.initState();
  }

  @override
  void dispose() {
    _registrationFieldsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegistrationFieldsCubit, RegistrationFieldsState>(
      bloc: _registrationFieldsCubit,
      builder: (context, state) {
        if (state.hasException) {
          return Scaffold(
            appBar: ThaliaAppBar(
              title: Text('REGISTRATION'),
              leading: CloseButton(),
            ),
            body: ErrorCenter(state.message!),
          );
        } else if (state.isLoading) {
          return Scaffold(
            appBar: ThaliaAppBar(
              title: Text('REGISTRATION'),
              leading: CloseButton(),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        } else {}
        return Scaffold(
          appBar: ThaliaAppBar(
            title: Text('REGISTRATION'),
            leading: CloseButton(),
          ),
          body: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  ...state.result!.entries.map((entry) {
                    final field = entry.value;
                    if (field is TextRegistrationField) {
                      return Column(
                        children: [
                          ListTile(
                            title: Text(field.label),
                            subtitle: field.description.isNotEmpty
                                ? Text(field.description)
                                : null,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 20,
                              bottom: 20,
                              right: 20,
                            ),
                            child: TextFormField(
                              initialValue: field.value,
                              minLines: 1,
                              maxLines: 5,
                              decoration: InputDecoration(
                                labelText: field.isRequired
                                    ? field.label + ' *'
                                    : field.label,
                                hintText: 'Lorem ipsum...',
                              ),
                              validator: (value) {
                                if (field.isRequired &&
                                    (value == null || value.isEmpty)) {
                                  return 'Please fill in this field.';
                                }
                                return null;
                              },
                              onSaved: (newValue) => field.value = newValue,
                            ),
                          ),
                        ],
                      );
                    } else if (field is IntegerRegistrationField) {
                      return Column(
                        children: [
                          ListTile(
                            dense: field.description.isEmpty,
                            title: Text(field.label),
                            subtitle: field.description.isNotEmpty
                                ? Text(field.description)
                                : null,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                              bottom: 20,
                            ),
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              decoration: InputDecoration(
                                labelText: field.isRequired
                                    ? field.label + ' *'
                                    : field.label,
                                hintText: '123...',
                              ),
                              initialValue: field.value?.toString(),
                              validator: (value) {
                                if (field.isRequired &&
                                    (value == null || value.isEmpty)) {
                                  return 'Please fill in this field.';
                                }
                                return null;
                              },
                              onSaved: (newValue) =>
                                  field.value = int.tryParse(newValue!),
                            ),
                          ),
                        ],
                      );
                    } else if (field is CheckboxRegistrationField) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _CheckboxFormField(
                          initialValue: field.value ?? false,
                          onSaved: (newValue) => field.value = newValue,
                          title: Text(field.label),
                          subtitle: field.description.isNotEmpty
                              ? Text(field.description)
                              : null,
                        ),
                      );
                    } else {
                      return SizedBox(height: 0);
                    }
                  }),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            _formKey.currentState!.reset();
                          },
                          icon: Icon(Icons.restore_page_outlined),
                          label: Text('RESTORE'),
                        ),
                        SizedBox(width: 20),
                        ElevatedButton.icon(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              try {
                                await _registrationFieldsCubit.update(
                                  eventPk: widget.eventPk,
                                  registrationPk: widget.registrationPk,
                                  fields: state.result!,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration: Duration(seconds: 1),
                                    content: Text(
                                      'Your registration has been updated.',
                                    ),
                                  ),
                                );
                                ThaliaRouterDelegate.of(context).pop();
                              } on ApiException {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration: Duration(seconds: 1),
                                    content: Text(
                                      "Couldn't update your registration.",
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          icon: Icon(Icons.check),
                          label: Text('SUBMIT'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CheckboxFormField extends FormField<bool> {
  _CheckboxFormField({
    Widget? title,
    Widget? subtitle,
    FormFieldSetter<bool>? onSaved,
    bool initialValue = false,
  }) : super(
          onSaved: onSaved,
          initialValue: initialValue,
          builder: (FormFieldState<bool> state) {
            return CheckboxListTile(
              dense: state.hasError,
              title: title,
              value: state.value,
              onChanged: state.didChange,
              subtitle: subtitle,
              controlAffinity: ListTileControlAffinity.leading,
            );
          },
        );
}
