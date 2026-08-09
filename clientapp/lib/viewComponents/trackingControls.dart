import 'package:auto_size_text/auto_size_text.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/themes.dart';
import 'package:clientapp/viewComponents/parts/atomic.dart';
import 'package:clientapp/viewmodels/navigationVM.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TrackingControls extends StatelessWidget {
  final bool tracking;
  final void Function() onStart;
  final void Function() onCancel;
  final void Function() onSubmit;

  const TrackingControls(
    this.tracking,
    this.onStart,
    this.onCancel,
    this.onSubmit, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Widget label = AutoText("Tracking:", maxLines: 1);
    if (tracking) {
      return Row(
        children: [
          Expanded(child: label),
          LabeledIcon.icon(CupertinoIcons.xmark, "Cancel", onSelect: onCancel),
          LabeledIcon.icon(
            CupertinoIcons.check_mark,
            "Submit",
            onSelect: onSubmit,
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Align(alignment: AlignmentGeometry.centerEnd, child: label),
          ),
          Align(
            child: SizedBox(
              width: Defaults.iconSize * 0.6 + 4,
              child: IconButton(
                padding: EdgeInsets.all(2),
                iconSize: Defaults.iconSize * 0.6,
                alignment: AlignmentGeometry.center,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) {
                      return AlertDialog(
                        backgroundColor: AppTheme.colors.background,
                        content: Text(
                          "We request your consent to collect GPS location data while you record a journey.\n\nWhat we collect: approximate route, timestamps, and device-derived speed/altitude.\nWhy: to improve routing accuracy, travel-time predictions, and overall navigation quality.\nHow we use it: aggregated and anonymized data will be analyzed to refine models; raw data may be used transiently for debugging and feature improvements.\nData control: you can stop tracking at any time; recordings are only kept for as long as needed and are protected per our privacy policy.\nBy selecting \"Start\" you consent to this collection for the current journey.",
                          style: TextStyle(color: AppTheme.colors.neutral),
                        ),
                        actions: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: AppTheme.colors.secondary,
                              ),
                              child: Text(
                                "OK",
                                style: TextStyle(
                                  color: AppTheme.colors.neutral,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: Icon(CupertinoIcons.question_circle_fill),
              ),
            ),
          ),
          LabeledIcon.icon(
            CupertinoIcons.play_fill,
            "Start",
            onSelect: () => showDialog(
              context: context,
              builder: (ctx) => TrackingConsentDialog(onStart),
            ),
          ),
        ],
      );
    }
  }
}

class TrackingConsentDialog extends StatelessWidget {
  final void Function() onAcceptSelect;

  const TrackingConsentDialog(this.onAcceptSelect, {super.key});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.colors.background,
      content: Text(
        "We request your consent to collect GPS location data while you record your journey.\n\nWhat we collect: approximate route, timestamps, and device-derived GPS snapshots.\nWhy: fine-tune our models to improve routing accuracy, travel-time predictions, and overall navigation quality.\nHow your data is used: aggregated and anonymized data will be analyzed to refine duration estimates of individual route sections; raw data may be used transiently for debugging and feature improvements.\nData control: you can stop tracking at any time; recordings are only kept for as long as needed and are protected per our privacy policy.\nSelect \"Accept\" to allow collection for this journey.",
        style: TextStyle(color: AppTheme.colors.neutral),
      ),
      actions: [
        IconButton(
          onPressed: () {
            onAcceptSelect();
            Navigator.pop(context);
          },
          icon: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: AppTheme.colors.secondary,
            ),
            child: Text(
              "Accept",
              style: TextStyle(color: AppTheme.colors.neutral),
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: AppTheme.colors.secondary,
            ),
            child: Text(
              "Reject",
              style: TextStyle(color: AppTheme.colors.neutral),
            ),
          ),
        ),
      ],
    );
  }
}
