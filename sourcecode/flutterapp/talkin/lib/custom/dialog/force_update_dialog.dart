import 'package:flutter/material.dart';
import 'package:notisboard/custom/dialog/app_update_dialog.dart';

class ForceUpdateDialog extends StatelessWidget {
  const ForceUpdateDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppUpdateDialog(
      isForceUpdate: true,
    );
  }
}
