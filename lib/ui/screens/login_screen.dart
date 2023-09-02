import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/config.dart';
import 'package:reaxit/ui/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  ImageProvider logo = const AssetImage('assets/img/logo.png');

  @override
  void didChangeDependencies() {
    precacheImage(logo, context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (previous, current) =>
          current is LoggedOutAuthState || current is LoadingAuthState,
      builder: (context, authState) {
        if (authState is LoggedOutAuthState) {
          return Scaffold(
            backgroundColor: magenta,
            body: SafeArea(
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      color: Colors.white54,
                      padding: const EdgeInsets.all(16),
                      icon: const Icon(Icons.build_rounded),
                      tooltip:
                          "Select environment, you probably don't need this",
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const SelectEnvironmentDialog(),
                        );
                      },
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(child: Image(image: logo, width: 260)),
                      const SizedBox(height: 50),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black87,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            BlocProvider.of<AuthCubit>(context)
                                .logIn(authState.selectedEnvironment);
                          },
                          child: Text(switch (authState.selectedEnvironment) {
                            Environment.production => 'LOG IN',
                            Environment.staging => 'LOG IN - STAGING',
                            Environment.local => 'LOG IN - LOCAL',
                          }),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        } else {
          return Scaffold(
            backgroundColor: const Color(0xFFE62272),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: Image(image: logo, width: 260)),
                const SizedBox(height: 50),
                const SizedBox(
                  height: 50,
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

class SelectEnvironmentDialog extends StatelessWidget {
  const SelectEnvironmentDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('SELECT ENVIRONMENT'),
      content: BlocBuilder<AuthCubit, AuthState>(
        buildWhen: (previous, current) => current is LoggedOutAuthState,
        builder: (context, state) {
          final selectedEnvironment = state is LoggedOutAuthState
              ? state.selectedEnvironment
              : Environment.defaultEnvironment;
          return Column(mainAxisSize: MainAxisSize.min, children: [
            Text(
              'Select an alternative server to log in to. '
              'If you are not sure you need this, just use production.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            const Divider(height: 0),
            if (ApiConfig.production != null)
              RadioListTile(
                title: const Text('PRODUCTION'),
                subtitle: const Text('Default: thalia.nu'),
                value: Environment.production,
                groupValue: selectedEnvironment,
                onChanged: (environment) {
                  BlocProvider.of<AuthCubit>(context).selectEnvironment(
                    Environment.production,
                  );
                },
              ),
            RadioListTile(
              title: const Text('STAGING'),
              value: Environment.staging,
              subtitle: const Text(
                'Used by the Technicie for testing: staging.thalia.nu',
              ),
              groupValue: selectedEnvironment,
              onChanged: (environment) {
                BlocProvider.of<AuthCubit>(context).selectEnvironment(
                  Environment.staging,
                );
              },
            ),
            if (ApiConfig.local != null)
              RadioListTile(
                title: const Text('LOCAL'),
                subtitle: const Text('You should know what you are doing.'),
                value: Environment.local,
                groupValue: selectedEnvironment,
                onChanged: (environment) {
                  BlocProvider.of<AuthCubit>(context).selectEnvironment(
                    Environment.local,
                  );
                },
              ),
          ]);
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('CLOSE'),
        )
      ],
    );
  }
}
