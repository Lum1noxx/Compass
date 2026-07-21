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
            child: Align(
              alignment: AlignmentGeometry.centerEnd,
              child: label,
            ),
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
                          "Select \"Start\" to record GPS tracking data for your journey.\nYour data helps us fine-tune our models to provide better routes and duration estimates in the future.",
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
            onSelect: onStart,
          ),
        ],
      );
    }
  }
}
