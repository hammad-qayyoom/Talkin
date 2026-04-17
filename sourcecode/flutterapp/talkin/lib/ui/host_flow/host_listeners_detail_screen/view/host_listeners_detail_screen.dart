import 'package:flutter/material.dart';
import 'package:notisboard/ui/host_flow/host_listeners_detail_screen/widget/host_listeners_detail_widget.dart';
import 'package:notisboard/utils/app_color.dart';

class HostListenersDetailScreen extends StatelessWidget {
  const HostListenersDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.redesignScreenBackground,
      bottomNavigationBar: const HostListenersDetailBottomButton(),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            currentFocus.focusedChild?.unfocus();
          }
        },
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxContentWidth =
                  constraints.maxWidth >= 1100 ? 980.0 : constraints.maxWidth;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: 1.0,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HostListenersDetailTopView(),
                        HostListenersDetailView(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
