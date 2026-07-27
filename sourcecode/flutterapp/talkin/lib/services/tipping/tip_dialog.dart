import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:notisboard/services/tipping/tip_api.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/utils.dart';

class TipSheet extends StatefulWidget {
  final String expertId;
  final String expertName;
  final String? expertImage;
  final String? sessionBookingId;
  final Function(int amount)? onTipSent;

  const TipSheet({
    super.key,
    required this.expertId,
    required this.expertName,
    this.expertImage,
    this.sessionBookingId,
    this.onTipSent,
  });

  static Future<void> show({
    required String expertId,
    required String expertName,
    String? expertImage,
    String? sessionBookingId,
    Function(int amount)? onTipSent,
  }) async {
    final config = await TipApi.fetchConfig();
    if (config == null || !config.enabled) {
      Utils.showLog("Tipping is disabled or config unavailable");
      return;
    }

    if (!Get.isDialogOpen!) {
      Get.bottomSheet(
        TipSheet(
          expertId: expertId,
          expertName: expertName,
          expertImage: expertImage,
          sessionBookingId: sessionBookingId,
          onTipSent: onTipSent,
        ),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
      );
    }
  }

  @override
  State<TipSheet> createState() => _TipSheetState();
}

class _TipSheetState extends State<TipSheet> {
  TippingConfig? _config;
  bool _loading = true;
  bool _sending = false;
  int? _selectedAmount;
  final TextEditingController _customAmountController = TextEditingController();
  bool _showCustomInput = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    final config = await TipApi.fetchConfig();
    if (mounted) {
      setState(() {
        _config = config;
        _loading = false;
        if (config != null && config.suggestedAmounts.isNotEmpty) {
          _selectedAmount = config.suggestedAmounts.first;
        }
      });
    }
  }

  int get _effectiveAmount {
    if (_showCustomInput) {
      return int.tryParse(_customAmountController.text) ?? 0;
    }
    return _selectedAmount ?? 0;
  }

  Future<void> _sendTip() async {
    final amount = _effectiveAmount;
    if (amount <= 0) {
      Get.snackbar('Invalid Amount', 'Please select or enter a valid tip amount.',
          backgroundColor: AppColors.redesignBrandRed, colorText: AppColors.white);
      return;
    }

    if (_config != null && amount < _config!.minAmount) {
      Get.snackbar('Too Low', 'Minimum tip amount is ₹${_config!.minAmount}.',
          backgroundColor: AppColors.redesignBrandRed, colorText: AppColors.white);
      return;
    }

    if (_config != null && amount > _config!.maxAmount) {
      Get.snackbar('Too High', 'Maximum tip amount is ₹${_config!.maxAmount}.',
          backgroundColor: AppColors.redesignBrandRed, colorText: AppColors.white);
      return;
    }

    final userBalance = int.tryParse(Database.userCoin) ?? 0;
    if (userBalance < amount) {
      Get.snackbar('Insufficient Coins', 'You need ₹$amount but only have ₹$userBalance coins.',
          backgroundColor: AppColors.redesignBrandRed, colorText: AppColors.white);
      return;
    }

    setState(() => _sending = true);

    final result = await TipApi.sendTip(
      expertId: widget.expertId,
      amount: amount,
      sessionBookingId: widget.sessionBookingId,
      paymentMethod: 'wallet',
    );

    if (!mounted) return;

    setState(() => _sending = false);

    if (result != null && result['status'] == true) {
      Get.back();
      widget.onTipSent?.call(amount);
      Get.snackbar(
        'Tip Sent!',
        '₹$amount tip sent to ${widget.expertName} successfully.',
        backgroundColor: AppColors.redesignStatusSuccess,
        colorText: AppColors.white,
      );
    } else {
      final msg = result?['message'] ?? 'Failed to send tip. Please try again.';
      Get.snackbar('Error', msg,
          backgroundColor: AppColors.redesignBrandRed, colorText: AppColors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_config == null || !_config!.enabled) {
      return const SizedBox.shrink();
    }

    final userBalance = int.tryParse(Database.userCoin) ?? 0;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.redesignSoftBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.redesignAccentSoftBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.volunteer_activism, color: AppColors.redesignBrandRed, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Send a Tip',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.redesignBrandDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'To ${widget.expertName}',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.redesignMutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.redesignSoftBorder),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, size: 18, color: AppColors.redesignBrandDark),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.redesignSurfaceNeutralAlt,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.account_balance_wallet, size: 18, color: AppColors.redesignCoinText),
                    const SizedBox(width: 8),
                    Text(
                      'Your Balance: ₹$userBalance',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.redesignBrandDark,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              if (_config!.refundPolicyEnabled)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Refund available within ${_config!.refundTimeLimitMinutes} minutes',
                    style: TextStyle(fontSize: 12, color: AppColors.redesignMutedText),
                    textAlign: TextAlign.center,
                  ),
                ),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: _config!.suggestedAmounts.map((amount) {
                  final isSelected = !_showCustomInput && _selectedAmount == amount;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _selectedAmount = amount;
                        _showCustomInput = false;
                        _customAmountController.clear();
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.redesignBrandRed : AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.redesignBrandRed : AppColors.redesignSoftBorder,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        '₹$amount',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? AppColors.white : AppColors.redesignBrandDark,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 14),

              GestureDetector(
                onTap: () {
                  setState(() {
                    _showCustomInput = !_showCustomInput;
                    if (_showCustomInput) {
                      _selectedAmount = null;
                    } else {
                      _customAmountController.clear();
                      if (_config!.suggestedAmounts.isNotEmpty) {
                        _selectedAmount = _config!.suggestedAmounts.first;
                      }
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    _showCustomInput ? 'Choose from suggestions' : 'Enter custom amount',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.redesignBrandRed,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              if (_showCustomInput) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _customAmountController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: 'Enter amount (₹${_config!.minAmount} - ₹${_config!.maxAmount})',
                    hintStyle: TextStyle(color: AppColors.redesignMutedText, fontSize: 14),
                    prefixText: '₹ ',
                    prefixStyle: TextStyle(
                      color: AppColors.redesignBrandDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                    filled: true,
                    fillColor: AppColors.redesignSurfaceNeutralAlt,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.redesignSoftBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.redesignSoftBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.redesignBrandRed, width: 1.5),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],

              const SizedBox(height: 24),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: (_sending || _effectiveAmount <= 0) ? null : _sendTip,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.redesignBrandRed,
                    disabledBackgroundColor: AppColors.redesignBrandRed.withValues(alpha: 0.5),
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _sending
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _effectiveAmount > 0 ? 'Send ₹$_effectiveAmount Tip' : 'Select Amount',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 8),

              if (_config!.platformFeePercent > 0)
                Text(
                  'Platform fee: ${_config!.platformFeePercent}% · Expert receives ₹${(_effectiveAmount * (100 - _config!.platformFeePercent) ~/ 100)}',
                  style: TextStyle(fontSize: 11, color: AppColors.redesignMutedText),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
