import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:reaxit/config.dart';

class TPayButton extends StatefulWidget {
  /// A function that performs the payment. If null, the button is disabled.
  ///
  /// This function can also perform extra logic before or after the payment.
  final Future<void> Function()? onPay;

  /// The message to display in the confirmation dialog.
  ///
  /// This can only be null if [onPay] is also null.
  final String? confirmationMessage;

  /// The message to display in a snackbar if the payment fails.
  ///
  /// This can only be null if [onPay] is also null.
  final String? failureMessage;

  /// The message to display in a snackbar if the payment succeeds.
  ///
  /// This can only be null if [onPay] is also null.
  final String? successMessage;

  /// The amount of money to pay.
  ///
  /// This can only be null if [onPay] is also null.
  final String? amount;

  const TPayButton({
    Key? key,
    required this.onPay,
    required this.confirmationMessage,
    required this.failureMessage,
    required this.successMessage,
    required this.amount,
  })  : assert(amount != null || onPay == null),
        assert(confirmationMessage != null || onPay == null),
        assert(failureMessage != null || onPay == null),
        assert(successMessage != null || onPay == null),
        super(key: key);

  const TPayButton.disabled({String? amount})
      : this(
          onPay: null,
          confirmationMessage: null,
          failureMessage: null,
          successMessage: null,
          amount: amount,
        );

  @override
  State<TPayButton> createState() => _TPayButtonState();
}

class _TPayButtonState extends State<TPayButton> {
  bool tmpDisabled = false;

  Future<bool> _showConfirmDialog(String confirmationMessage) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm payment'),
          content: Text(
            confirmationMessage,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.of(
                context,
                rootNavigator: true,
              ).pop(false),
              icon: const Icon(Icons.clear),
              label: const Text('CANCEL'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(
                context,
                rootNavigator: true,
              ).pop(true),
              icon: const Icon(Icons.check),
              label: const Text('YES'),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentUserCubit, PaymentUserState>(
      builder: (context, state) {
        const icon = Icon(Icons.euro);
        final buttonLabel = Text(
          widget.amount != null
              ? 'THALIA PAY: €${widget.amount}'
              : 'THALIA PAY',
        );

        if (widget.onPay == null || tmpDisabled) {
          // The button is disabled.
          return ElevatedButton.icon(
            onPressed: null,
            icon: icon,
            label: buttonLabel,
          );
          // TODO: provide custom tooltip.
        } else if (state.isLoading) {
          // PaymentUser loading.
          return ElevatedButton.icon(
            onPressed: null,
            icon: icon,
            label: buttonLabel,
          );
        } else if (state.hasException) {
          // PaymentUser couldn't load.
          return ElevatedButton.icon(
            onPressed: null,
            icon: icon,
            label: buttonLabel,
          );
        } else {
          final paymentUser = state.user!;
          if (!paymentUser.tpayAllowed) {
            // TPay not allowed for the user.
            return Tooltip(
              message: 'You are not allowed to use Thalia Pay.',
              child: ElevatedButton.icon(
                onPressed: null,
                icon: icon,
                label: buttonLabel,
              ),
            );
          } else if (!paymentUser.tpayEnabled) {
            // TPay not yet enabled.
            final url = Config.of(context).tpaySignDirectDebitMandateUrl;
            final message = TextSpan(
              children: [
                const TextSpan(
                  text: 'To start using Thalia Pay, '
                      'sign a direct debit mandate on ',
                ),
                TextSpan(
                  text: 'the website',
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      } catch (_) {
                        messenger.showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            content: Text(
                              'Could not open "${url.toString()}".',
                            ),
                          ),
                        );
                      }
                    },
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const TextSpan(text: '.'),
              ],
            );

            return Tooltip(
              richMessage: message,
              child: ElevatedButton.icon(
                onPressed: null,
                icon: icon,
                label: buttonLabel,
              ),
            );
          } else {
            // TPay possible.
            final onPay = widget.onPay!;
            final successMessage = widget.successMessage!;
            final failureMessage = widget.failureMessage!;
            final confirmationMessage = widget.confirmationMessage!;
            return ElevatedButton.icon(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                if (await _showConfirmDialog(confirmationMessage)) {
                  try {
                    setState(() {
                      tmpDisabled = true;
                    });
                    await onPay();
                    messenger.showSnackBar(SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text(successMessage),
                    ));
                    setState(() {
                      tmpDisabled = false;
                    });
                  } on ApiException {
                    messenger.showSnackBar(SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text(failureMessage),
                    ));
                  }
                }
              },
              icon: icon,
              label: buttonLabel,
            );
          }
        }
      },
    );
  }
}
