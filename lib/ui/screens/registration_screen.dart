import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';
import 'package:reaxit/ui/widgets.dart';

class RegistrationScreen extends StatefulWidget {
  final int eventPk;
  final int registrationPk;

  RegistrationScreen({required this.eventPk, required this.registrationPk})
      : super(key: ValueKey(registrationPk));

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
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
    return SafeArea(
      child: BlocBuilder<RegistrationFieldsCubit, RegistrationFieldsState>(
        bloc: _registrationFieldsCubit,
        builder: (context, state) {
          if (state.hasException) {
            return Scaffold(
              appBar: ThaliaAppBar(
                title: const Text('REGISTRATION'),
                leading: const CloseButton(),
              ),
              body: ErrorCenter(state.message!),
            );
          } else if (state.isLoading) {
            return Scaffold(
              appBar: ThaliaAppBar(
                title: const Text('REGISTRATION'),
                leading: const CloseButton(),
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          } else {}
          return Scaffold(
            appBar: ThaliaAppBar(
              title: const Text('REGISTRATION'),
              leading: const CloseButton(),
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
                                left: 16,
                                bottom: 16,
                                right: 16,
                              ),
                              child: TextFormField(
                                initialValue: field.value,
                                minLines: 1,
                                maxLines: 5,
                                decoration: InputDecoration(
                                  labelText: field.isRequired
                                      ? '${field.label} *'
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
                                left: 16,
                                right: 16,
                                bottom: 16,
                              ),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: InputDecoration(
                                  labelText: field.isRequired
                                      ? '${field.label} *'
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
                          padding: const EdgeInsets.only(bottom: 16),
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
                        return const SizedBox(height: 0);
                      }
                    }),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              _formKey.currentState!.reset();
                            },
                            icon: const Icon(Icons.restore_page_outlined),
                            label: const Text('RESTORE'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();

                                final messenger = ScaffoldMessenger.of(context);

                                try {
                                  await _registrationFieldsCubit.update(
                                    eventPk: widget.eventPk,
                                    registrationPk: widget.registrationPk,
                                    fields: state.result!,
                                  );

                                  if (mounted) Navigator.of(context).pop();

                                  messenger.showSnackBar(
                                    const SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      content: Text(
                                        'Your registration has been updated.',
                                      ),
                                    ),
                                  );
                                } on ApiException {
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      content: Text(
                                        'Could not update your registration.',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.check),
                            label: const Text('SUBMIT'),
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
      ),
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
