import 'package:flutter/material.dart';
import 'package:notisboard/ui/user_flow/all_review_screen/widget/all_review_widget.dart';
import 'package:notisboard/utils/app_color.dart';

class AllReviewScreen extends StatelessWidget {
  const AllReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: AllReviewAppBar(),
      ),
      body: AllReview(),
    );
  }
}
