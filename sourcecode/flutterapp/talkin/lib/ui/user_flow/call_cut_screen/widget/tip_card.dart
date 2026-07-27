import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notisboard/services/tipping/tip_api.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/font_style.dart';
import 'package:notisboard/utils/utils.dart';

class TipCard extends StatefulWidget {
  final String receiverId;
  final String expertName;
  final String? expertImage;
  final String? callType;
  final Function(int amount)? onTipSent;

  const TipCard({
    super.key,
    required this.receiverId,
    required this.expertName,
    this.expertImage,
    this.callType,
    this.onTipSent,
  });

  @override
  State<TipCard> createState() => _TipCardState();
}

class _TipCardState extends State<TipCard> {
  TippingConfig? _config;
  bool _loading = true;
  bool _sending = false;
  int? _selectedAmount;
  final TextEditingController _customController = TextEditingController();
  bool _showCustom = false;
  bool _tipSent = false;

  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandRedDark = AppColors.redesignBrandRedDark;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _mutedText = AppColors.redesignMutedText;
  static final Color _softBorder = AppColors.redesignSoftBorder;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  void dispose() {
    _customController.dispose();
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
    if (_showCustom) return int.tryParse(_customController.text) ?? 0;
    return _selectedAmount ?? 0;
  }

  Future<void> _sendTip() async {
    final amount = _effectiveAmount;
    if (amount <= 0) {
      Utils.showToast(context, 'Please select or enter a valid amount.');
      return;
    }

    if (_config != null && amount < _config!.minAmount) {
      Utils.showToast(context, 'Minimum tip amount is ₹${_config!.minAmount}.');
      return;
    }

    if (_config != null && amount > _config!.maxAmount) {
      Utils.showToast(context, 'Maximum tip amount is ₹${_config!.maxAmount}.');
      return;
    }

    final userBalance = int.tryParse(Database.userCoin) ?? 0;
    if (userBalance < amount) {
      Utils.showToast(context, 'Insufficient coins. You have ₹$userBalance.');
      return;
    }

    setState(() => _sending = true);

    final result = await TipApi.sendTip(
      receiverId: widget.receiverId,
      amount: amount,
      callType: widget.callType ?? 'audio',
      paymentMethod: 'wallet',
    );

    if (!mounted) return;

    setState(() {
      _sending = false;
      if (result != null && result['status'] == true) {
        _tipSent = true;
      }
    });

    if (result != null && result['status'] == true) {
      Utils.showToast(context, '₹$amount tip sent to ${widget.expertName}!');
      widget.onTipSent?.call(amount);
    } else {
      final msg = result?['message'] ?? 'Failed to send tip.';
      Utils.showToast(context, msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox.shrink();
    }

    if (_config == null || !_config!.enabled) {
      return const SizedBox.shrink();
    }

    if (_tipSent) {
      return _buildSentConfirmation();
    }

    return _buildTipCard();
  }

  Widget _buildSentConfirmation() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.redesignStatusSuccessBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.redesignStatusSuccessBorder),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: AppColors.redesignStatusSuccess,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tip Sent Successfully!',
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 15,
                    fontColor: AppColors.redesignStatusSuccessDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Thank you for tipping ${widget.expertName}',
                  style: AppFontStyle.fontStyleW500(
                    fontSize: 13,
                    fontColor: AppColors.redesignMutedText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard() {
    final userBalance = int.tryParse(Database.userCoin) ?? 0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _softBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: AppColors.redesignAccentSoftBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.volunteer_activism,
                  color: _brandRed,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Send a Tip to ${widget.expertName}',
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 15,
                    fontColor: _brandDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Show your appreciation for the great consultation',
            style: AppFontStyle.fontStyleW500(
              fontSize: 12,
              fontColor: _mutedText,
            ),
          ),
          const SizedBox(height: 12),

          // Balance row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.redesignSurfaceNeutralAlt,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.account_balance_wallet, size: 16, color: AppColors.redesignCoinText),
                const SizedBox(width: 6),
                Text(
                  'Balance: ₹$userBalance',
                  style: AppFontStyle.fontStyleW600(
                    fontSize: 13,
                    fontColor: _brandDark,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Suggested amounts
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _config!.suggestedAmounts.map((amount) {
              final isSelected = !_showCustom && _selectedAmount == amount;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _selectedAmount = amount;
                    _showCustom = false;
                    _customController.clear();
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? _brandRed : AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? _brandRed : _softBorder,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    '₹$amount',
                    style: AppFontStyle.fontStyleW700(
                      fontSize: 14,
                      fontColor: isSelected ? AppColors.white : _brandDark,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 10),

          // Custom amount toggle
          GestureDetector(
            onTap: () {
              setState(() {
                _showCustom = !_showCustom;
                if (_showCustom) {
                  _selectedAmount = null;
                } else {
                  _customController.clear();
                  if (_config!.suggestedAmounts.isNotEmpty) {
                    _selectedAmount = _config!.suggestedAmounts.first;
                  }
                }
              });
            },
            child: Text(
              _showCustom ? 'Choose from suggestions' : 'Enter custom amount',
              style: AppFontStyle.fontStyleW600(
                fontSize: 13,
                fontColor: _brandRed,
              ),
            ),
          ),

          if (_showCustom) ...[
            const SizedBox(height: 10),
            TextField(
              controller: _customController,
              keyboardType: TextInputType.number,
              autofocus: true,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: '₹${_config!.minAmount} - ₹${_config!.maxAmount}',
                hintStyle: TextStyle(color: _mutedText, fontSize: 13),
                prefixText: '₹ ',
                prefixStyle: TextStyle(
                  color: _brandDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
                filled: true,
                fillColor: AppColors.redesignSurfaceNeutralAlt,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _softBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _softBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _brandRed, width: 1.5),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],

          const SizedBox(height: 14),

          // Send button
          GestureDetector(
            onTap: (_sending || _effectiveAmount <= 0) ? null : _sendTip,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 48,
              decoration: BoxDecoration(
                gradient: (_effectiveAmount > 0 && !_sending)
                    ? LinearGradient(colors: [_brandRed, _brandRedDark])
                    : null,
                color: (_effectiveAmount > 0 && !_sending) ? null : _softBorder,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: _sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        _effectiveAmount > 0 ? 'Send ₹$_effectiveAmount Tip' : 'Select Amount',
                        style: AppFontStyle.fontStyleW700(
                          fontSize: 15,
                          fontColor: _effectiveAmount > 0 ? AppColors.white : _mutedText,
                        ),
                      ),
              ),
            ),
          ),

          if (_config!.refundPolicyEnabled) ...[
            const SizedBox(height: 8),
            Text(
              'Refund available within ${_config!.refundTimeLimitMinutes} min · Platform fee: ${_config!.platformFeePercent}%',
              style: AppFontStyle.fontStyleW500(
                fontSize: 11,
                fontColor: _mutedText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
