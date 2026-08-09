import 'package:flutter/material.dart';

// ignore: must_be_immutable
class TimedEnableButton extends StatefulWidget {
  final DateTime? open;
  final DateTime? close;

  final Widget Function(BuildContext, WidgetStatesController, DateTime?)
  builder;
  final void Function()? onOpen;
  final void Function()? onClose;

  TimedEnableButton({
    super.key,
    this.open,
    this.onOpen,
    this.close,
    this.onClose,
    required this.builder,
  }) : assert(open == null || (close?.isAfter(open) ?? true));

  @override
  State<StatefulWidget> createState() => _TimedEnableButton();
}

class _TimedEnableButton extends State<TimedEnableButton> {
  final WidgetStatesController controler = WidgetStatesController();

  void delayedSet(DateTime deadline, bool close) {
    Future.delayed(deadline.difference(DateTime.now()), () {
      if (mounted) {
        setState(() {
          controler.update(WidgetState.disabled, close);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime? open = widget.open;
    DateTime? close = widget.close;
    // Assume its opened until proven otherwise
    controler.update(WidgetState.disabled, false);

    DateTime? nextChange;
    // We know close is after before, so this is valid
    if (open != null) {
      if (open.isAfter(DateTime.now())) {
        controler.update(WidgetState.disabled, true);
        delayedSet(open, false);
        nextChange = open;
      }
    }
    if (close != null) {
      if (close.isAfter(DateTime.now())) {
        delayedSet(close, true);
        nextChange = close;
      } else {
        controler.update(WidgetState.disabled, true);
      }
    }

    return widget.builder(context, controler, nextChange);
  }
}

// `TimedIconButton` shows a generic button, where the text changes based on
// if it is build before or after `opens`. If now is before `opens` it will show
// the prefit with a countdown. See `CountdownText` for more details. If `now` is
// after `opens`, it shows `labelText` as label.  This is usefull in combination with
// `TimedEnableButton`, which rebuilds its children and provides the `DateTime` for
// the next change. This `DateTime` can be passed to `opens`
class TimedIconButton extends StatelessWidget {
  final WidgetStatesController controller;
  final Function onPressed;
  final Widget icon;
  final String labelText;
  final String countdownPrefix;
  final DateTime? opens;

  const TimedIconButton({
    super.key,
    required this.controller,
    required this.onPressed,
    required this.icon,
    required this.labelText,
    required this.countdownPrefix,
    this.opens,
  });

  @override
  Widget build(BuildContext context) {
    late final Widget label;
    // There is also a countdown for the close of registration
    if (opens?.isBefore(DateTime.now()) ?? true) {
      label = Text(labelText);
    } else {
      label = CountdownText(deadline: opens!, prefix: countdownPrefix);
    }

    return ElevatedButton.icon(
      statesController: controller,
      onPressed: !controller.value.contains(WidgetState.disabled)
          ? () => onPressed
          : null,
      icon: icon,
      label: label,
    );
  }
}

// CountdownText is a widget that shows a message with a countdown
// as such: '${prefix} ${timer}', where timer is `deadline-Datetime.now()`
class CountdownText extends StatelessWidget {
  final DateTime deadline;
  final String prefix;

  const CountdownText({
    super.key,
    required this.deadline,
    required this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        Duration timer = deadline.difference(DateTime.now());
        return Text(
          '$prefix ${timer.inMinutes}:${(timer.inSeconds.remainder(60))}',
        );
      },
    );
  }
}
