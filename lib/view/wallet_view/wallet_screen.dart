import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_button.dart';
import 'package:firstedu/res/widgets/custom_card.dart';
import 'package:firstedu/res/widgets/custom_filter_chips.dart';
import 'package:firstedu/res/widgets/custom_silverappbar.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:firstedu/view_models/wallet_provider/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int selectedTab = 0;
  final TextEditingController amountController = TextEditingController();
  final TextEditingController pointsController = TextEditingController();
  late WalletProvider _provider;
  final amounts = ["₹100", "₹500", "₹1000"];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _provider = context.read<WalletProvider>();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.fetchBalance();
      _provider.fetchPointsHistory(refresh: true);
    });
  }

  @override
  void dispose() {
    _provider.cleanup();
    amountController.dispose();
    pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Consumer<WalletProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                provider.fetchBalance(),
                provider.fetchPointsHistory(refresh: true),
              ]);
            },
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                const CustomSliverAppBar(title: "My Wallet"),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _balanceCard(provider),
                        const SizedBox(height: 16),
                        _rewardCard(provider),
                        const SizedBox(height: 16),
                        _tabs(),
                        const SizedBox(height: 16),
                        selectedTab == 0
                            ? _topUpCard(provider)
                            : _redeemPointsCard(provider),
                        const SizedBox(height: 20),
                        const CustomText(
                          text: "Recent Transactions",
                          size: 16,
                          weight: FontWeight.w600,
                        ),
                        const SizedBox(height: 10),
                        _buildTransactionList(provider),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _balanceCard(WalletProvider provider) {
    return CustomCard(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              Icons.account_balance_wallet,
              size: 120,
              color: Colors.white.withOpacity(.05),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomText(
                text: "TOTAL BALANCE",
                size: 13,
                weight: FontWeight.w500,
                color: Colors.white70,
              ),
              const SizedBox(height: 6),
              if (provider.isLoading && provider.balance == null)
                const SizedBox(
                  height: 40,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              else
                CustomText(
                  text:
                      "₹${provider.balance?.monetaryBalance.toStringAsFixed(2) ?? '0.00'}",
                  size: 34,
                  weight: FontWeight.w700,
                  color: Colors.white,
                ),
              // const SizedBox(height: 8),
              // const CustomText(
              //   text: "**** **** 4288",
              //   size: 12,
              //   weight: FontWeight.w400,
              //   color: Colors.white70,
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rewardCard(WalletProvider provider) {
    return CustomCard(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6A00), Color(0xFFFF8C00)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              Icons.workspace_premium,
              size: 120,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomText(
                text: "REWARD POINTS",
                size: 13,
                weight: FontWeight.w500,
                color: Colors.white70,
              ),
              const SizedBox(height: 6),
              if (provider.isLoading && provider.balance == null)
                const SizedBox(
                  height: 38,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              else
                CustomText(
                  text:
                      "${provider.balance?.rewardPoints.toStringAsFixed(0) ?? '0'} XP",
                  size: 32,
                  weight: FontWeight.w700,
                  color: Colors.white,
                ),
              const SizedBox(height: 6),
              const CustomText(
                text: "10 XP = ₹1.00",
                size: 12,
                weight: FontWeight.w400,
                color: Colors.white70,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tabs() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            title: "Add Money",
            backgroundColor: selectedTab == 0
                ? drawerColor
                : Colors.grey.shade300,
            textColor: selectedTab == 0 ? Colors.white : Colors.black54,
            onTap: () => setState(() => selectedTab = 0),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: CustomButton(
            title: "Redeem Points",
            backgroundColor: selectedTab == 1
                ? drawerColor
                : Colors.grey.shade300,
            textColor: selectedTab == 1 ? Colors.white : Colors.black54,
            onTap: () => setState(() => selectedTab = 1),
          ),
        ),
      ],
    );
  }

  Widget _topUpCard(WalletProvider provider) {
    return CustomCard(
      child: Column(
        children: [
          const CustomText(
            text: "Top-up Wallet",
            size: 18,
            weight: FontWeight.w600,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: "₹ Enter Amount",
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: amounts.map((e) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: CustomFilterChip(
                    label: e,
                    selected: amountController.text == e.replaceAll("₹", ""),
                    onTap: () => setState(
                      () => amountController.text = e.replaceAll("₹", ""),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          CustomButton(
            title: provider.isRechargePending
                ? "Processing..."
                : "Proceed to Pay",
            onTap: provider.isRechargePending
                ? () {}
                : () {
                    final amt = int.tryParse(amountController.text.trim()) ?? 0;
                    if (amt < 1) {
                      AppToast.error(
                        context,
                        title: 'Invalid',
                        message: 'Please enter a valid amount',
                      );
                      return;
                    }
                    provider.initiateRecharge(
                      amount: amt,
                      // ✅ no String param, no onError
                      onSuccess: () {
                        if (!mounted) return;
                        _showPaymentSuccessDialog(
                          amount: provider.lastRechargedAmount,
                          newBalance: provider.balance?.monetaryBalance ?? 0,
                        );
                        amountController.clear();
                      },
                    );
                  },
          ),
          const SizedBox(height: 6),
          const CustomText(
            text: "Secured by Razorpay",
            size: 11,
            color: Colors.black45,
          ),
        ],
      ),
    );
  }

  Widget _redeemPointsCard(WalletProvider provider) {
    final points = provider.balance?.rewardPoints.toInt() ?? 0;

    return CustomCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CustomText(
            text: "Convert XP to Cash",
            size: 20,
            weight: FontWeight.w600,
          ),
          const SizedBox(height: 6),
          const CustomText(
            text: "Convert your hard-earned XP into wallet balance.",
            size: 13,
            color: Colors.black54,
          ),
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 26),
            decoration: BoxDecoration(
              color: const Color(0xFFF6EDE3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const CustomText(
                  text: "AVAILABLE XP",
                  size: 12,
                  weight: FontWeight.w600,
                  color: accentOrange,
                ),
                const SizedBox(height: 8),
                if (provider.isLoading && provider.balance == null)
                  const CircularProgressIndicator(color: accentOrange)
                else
                  CustomText(
                    text: "$points",
                    size: 38,
                    weight: FontWeight.w700,
                    color: accentOrange,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: pointsController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: "Points to redeem",
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 18),
          CustomButton(
            title: provider.isConverting ? "Converting..." : "Convert Now",
            backgroundColor: accentOrange,
            onTap: provider.isConverting
                ? () {}
                : () {
                    final pts = int.tryParse(pointsController.text.trim()) ?? 0;
                    if (pts < 100) {
                      AppToast.error(
                        context,
                        title: 'Minimum 100 XP',
                        message: 'Enter at least 100 points to convert',
                      );
                      return;
                    }
                    if (pts > points) {
                      AppToast.error(
                        context,
                        title: 'Not enough XP',
                        message: 'You only have $points XP',
                      );
                      return;
                    }
                    provider.convertPoints(
                      points: pts,
                      // ✅ onSuccess only — no onError (provider uses AppToast.errorGlobal)
                      onSuccess: (msg) {
                        if (!mounted) return;
                        pointsController.clear();
                        AppToast.success(
                          context,
                          title: 'Converted!',
                          message: msg,
                        );
                      },
                    );
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(WalletProvider provider) {
    if (provider.isHistoryLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final items = provider.pointsHistory?.items ?? [];

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: CustomText(
            text: "No transactions yet",
            size: 13,
            color: Colors.grey.shade400,
          ),
        ),
      );
    }

    return Column(
      children: items
          .map(
            (item) => _transactionTile(
              item.description,
              "${item.isEarned ? '+' : '-'}${item.amount.toStringAsFixed(0)} XP",
              item.isEarned ? Colors.green : Colors.red,
            ),
          )
          .toList(),
    );
  }

  void _showPaymentSuccessDialog({
    required int amount,
    required double newBalance,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 52,
                ),
              ),
              const SizedBox(height: 24),
              const CustomText(
                text: "Payment Successful!",
                size: 22,
                weight: FontWeight.w800,
                color: Colors.black87,
                align: TextAlign.center,
              ),
              const SizedBox(height: 8),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(fontSize: 15, color: Colors.black54),
                  children: [
                    const TextSpan(text: "₹"),
                    TextSpan(
                      text: "$amount",
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                    const TextSpan(text: " has been added to your wallet"),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1E3A8A).withOpacity(0.07),
                      const Color(0xFF1E3A8A).withOpacity(0.03),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF1E3A8A).withOpacity(0.15),
                  ),
                ),
                child: Column(
                  children: [
                    const CustomText(
                      text: "NEW WALLET BALANCE",
                      size: 11,
                      weight: FontWeight.w600,
                      color: Colors.black45,
                      align: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    CustomText(
                      text: "₹${newBalance.toStringAsFixed(2)}",
                      size: 28,
                      weight: FontWeight.w800,
                      color: const Color(0xFF1E3A8A),
                      align: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                title: "Done",
                backgroundColor: const Color(0xFF1E3A8A),
                textColor: Colors.white,
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _transactionTile(String title, String amount, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CustomCard(
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(.15),
              child: Icon(Icons.arrow_upward, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomText(text: title, size: 14, weight: FontWeight.w600),
            ),
            CustomText(
              text: amount,
              size: 14,
              weight: FontWeight.w600,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}
