import 'package:flutter/material.dart';

import '../models/wallet_balance.dart';
import '../models/wallet_transaction.dart';
import '../models/wallet_withdrawal.dart';
import '../services/wallet_service_instance.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  static const Color _primaryColor = Color(0xff2D006B);
  static const Color _primaryDark = Color(0xff1A003F);
  static const Color _accentColor = Color(0xff168BEE);
  static const Color _softColor = Color(0xffF4F6FA);
  static const Color _greenColor = Color(0xff16A34A);
  static const Color _redColor = Color(0xffDC2626);
  static const Color _orangeColor = Color(0xffF97316);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      walletService.loadWallet();
    });
  }

  Future<void> _openWithdrawalModal() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        return _WithdrawalForm(
          availableBalance: walletService.availableBalance,
        );
      },
    );

    if (created == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud de retiro creada')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xffFAFAFC),
        appBar: AppBar(
          title: const Text(
            'Billetera',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          centerTitle: false,
          backgroundColor: Colors.white,
          foregroundColor: _primaryColor,
          elevation: 0,
          bottom: const TabBar(
            labelColor: _primaryColor,
            unselectedLabelColor: Colors.black45,
            indicatorColor: _accentColor,
            indicatorWeight: 4,
            labelStyle: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
            tabs: [
              Tab(text: 'Movimientos'),
              Tab(text: 'Retiros'),
            ],
          ),
        ),
        body: SafeArea(
          child: AnimatedBuilder(
            animation: walletService,
            builder: (context, child) {
              if (walletService.isLoading) {
                return const _LoadingState();
              }

              if (walletService.error != null) {
                return _ErrorState(
                  message: walletService.error!,
                  onRetry: walletService.loadWallet,
                );
              }

              final balance = walletService.balance;

              if (balance == null) {
                return _ErrorState(
                  message: 'Todavia no tenes una billetera activa',
                  onRetry: walletService.loadWallet,
                );
              }

              return Column(
                children: [
                  _BalanceSummary(
                    balance: balance,
                    onWithdrawPressed: _openWithdrawalModal,
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _TransactionList(
                          transactions: walletService.transactions,
                          onRefresh: walletService.loadWallet,
                        ),
                        _WithdrawalList(
                          withdrawals: walletService.withdrawals,
                          onRefresh: walletService.loadWallet,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BalanceSummary extends StatelessWidget {
  final WalletBalance balance;
  final VoidCallback onWithdrawPressed;

  const _BalanceSummary({
    required this.balance,
    required this.onWithdrawPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  _WalletScreenState._primaryDark,
                  _WalletScreenState._primaryColor,
                  Color(0xff4B00A8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: _WalletScreenState._primaryColor.withValues(
                    alpha: 0.22,
                  ),
                  blurRadius: 22,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Colors.white,
                      size: 26,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'BuyMarket Wallet',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.verified_outlined,
                      color: Colors.white70,
                      size: 22,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Saldo disponible',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatMoney(balance.balance),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onWithdrawPressed,
                    icon: const Icon(Icons.payments_outlined),
                    label: const Text('Solicitar retiro'),
                    style: FilledButton.styleFrom(
                      backgroundColor: _WalletScreenState._accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.85,
            children: [
              _MetricCard(
                title: 'Pendiente',
                value: _formatMoney(balance.pendingBalance),
                icon: Icons.schedule_outlined,
              ),
              _MetricCard(
                title: 'Total ganado',
                value: _formatMoney(balance.totalEarned),
                icon: Icons.trending_up_outlined,
              ),
              _MetricCard(
                title: 'Disponible',
                value: _formatMoney(balance.balance),
                icon: Icons.savings_outlined,
              ),
              const _MetricCard(
                title: 'Comision',
                value: '5%',
                icon: Icons.percent_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffECEEF3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _WalletScreenState._primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: _WalletScreenState._primaryColor,
              size: 21,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black45,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  final List<WalletTransaction> transactions;
  final Future<void> Function() onRefresh;

  const _TransactionList({
    required this.transactions,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return _EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'Todavia no hay movimientos',
        subtitle: 'Cuando tengas ventas o ajustes, los vas a ver aca.',
        onRefresh: onRefresh,
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: _WalletScreenState._primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];

          final amount = transaction.netAmount != 0
              ? transaction.netAmount
              : transaction.amount;

          return _ListCard(
            icon: _transactionIcon(transaction.type),
            iconColor: _transactionColor(transaction.type, amount),
            title: _transactionTitle(transaction.type),
            amount: amount,
            status: transaction.status,
            date: transaction.createdAt,
            lines: [
              if (transaction.commissionAmount != 0)
                'Comision BuyMarket: ${_formatMoney(transaction.commissionAmount)}',
              if (transaction.orderId != null) 'Orden: ${transaction.orderId}',
            ],
          );
        },
      ),
    );
  }

  IconData _transactionIcon(String type) {
    final lower = type.toLowerCase();

    if (lower.contains('sale') || lower.contains('venta')) {
      return Icons.trending_up_outlined;
    }

    if (lower.contains('commission') || lower.contains('comision')) {
      return Icons.percent_outlined;
    }

    if (lower.contains('withdraw') || lower.contains('retiro')) {
      return Icons.account_balance_outlined;
    }

    if (lower.contains('refund') || lower.contains('reembolso')) {
      return Icons.replay_outlined;
    }

    return Icons.swap_vert;
  }

  Color _transactionColor(String type, double amount) {
    final lower = type.toLowerCase();

    if (lower.contains('sale') || lower.contains('venta') || amount > 0) {
      return _WalletScreenState._greenColor;
    }

    if (lower.contains('commission') || lower.contains('comision')) {
      return _WalletScreenState._orangeColor;
    }

    if (amount < 0) {
      return _WalletScreenState._redColor;
    }

    return _WalletScreenState._primaryColor;
  }

  String _transactionTitle(String type) {
    final lower = type.toLowerCase();

    if (lower.contains('sale') || lower.contains('venta')) {
      return 'Venta realizada';
    }

    if (lower.contains('commission') || lower.contains('comision')) {
      return 'Comision BuyMarket';
    }

    if (lower.contains('withdraw') || lower.contains('retiro')) {
      return 'Retiro';
    }

    if (lower.contains('refund') || lower.contains('reembolso')) {
      return 'Reembolso';
    }

    return type.isEmpty ? 'Movimiento' : type;
  }
}

class _WithdrawalList extends StatelessWidget {
  final List<WalletWithdrawal> withdrawals;
  final Future<void> Function() onRefresh;

  const _WithdrawalList({
    required this.withdrawals,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (withdrawals.isEmpty) {
      return _EmptyState(
        icon: Icons.payments_outlined,
        title: 'Todavia no hay retiros',
        subtitle: 'Tus solicitudes de retiro van a aparecer en esta lista.',
        onRefresh: onRefresh,
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: _WalletScreenState._primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
        itemCount: withdrawals.length,
        itemBuilder: (context, index) {
          final withdrawal = withdrawals[index];

          return _ListCard(
            icon: Icons.payments_outlined,
            iconColor: _WalletScreenState._accentColor,
            title: 'Retiro solicitado',
            amount: -withdrawal.amount,
            status: withdrawal.status,
            date: withdrawal.createdAt,
            lines: [
              if (withdrawal.alias != null && withdrawal.alias!.isNotEmpty)
                'Alias: ${withdrawal.alias}',
              if (withdrawal.cbu != null && withdrawal.cbu!.isNotEmpty)
                'CBU/CVU: ${withdrawal.cbu}',
              if (withdrawal.adminNote != null &&
                  withdrawal.adminNote!.isNotEmpty)
                withdrawal.adminNote!,
            ],
          );
        },
      ),
    );
  }
}

class _ListCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final double amount;
  final String status;
  final DateTime? date;
  final List<String> lines;

  const _ListCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.amount,
    required this.status,
    required this.date,
    required this.lines,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = amount >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffECEEF3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: iconColor, size: 23),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Text(
                      '${isPositive ? '+' : '-'}${_formatMoney(amount.abs())}',
                      style: TextStyle(
                        color: isPositive
                            ? _WalletScreenState._greenColor
                            : _WalletScreenState._redColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (status.isNotEmpty) _StatusChip(label: status),
                    Text(
                      _formatDate(date),
                      style: const TextStyle(
                        color: Colors.black45,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                for (final line in lines) ...[
                  const SizedBox(height: 6),
                  Text(
                    line,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;

  const _StatusChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(label);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _statusText(label),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Color _statusColor(String value) {
    final lower = value.toLowerCase();

    if (lower.contains('approved') || lower.contains('aprobado')) {
      return _WalletScreenState._greenColor;
    }

    if (lower.contains('rejected') || lower.contains('rechazado')) {
      return _WalletScreenState._redColor;
    }

    if (lower.contains('pending') || lower.contains('pendiente')) {
      return _WalletScreenState._orangeColor;
    }

    return _WalletScreenState._accentColor;
  }

  String _statusText(String value) {
    final lower = value.toLowerCase();

    if (lower.contains('approved')) return 'Aprobado';
    if (lower.contains('rejected')) return 'Rechazado';
    if (lower.contains('pending')) return 'Pendiente';

    return value;
  }
}

class _WithdrawalForm extends StatefulWidget {
  final double availableBalance;

  const _WithdrawalForm({required this.availableBalance});

  @override
  State<_WithdrawalForm> createState() => _WithdrawalFormState();
}

class _WithdrawalFormState extends State<_WithdrawalForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _destinationController = TextEditingController();

  String _method = 'alias';

  @override
  void dispose() {
    _amountController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final amount = _parseAmount(_amountController.text);
    final destination = _destinationController.text.trim();

    try {
      await walletService.requestWithdrawal(
        amount: amount,
        alias: _method == 'alias' ? destination : '',
        cbu: _method == 'cbu' ? destination : '',
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  String? _validateAmount(String? value) {
    final amount = _parseAmount(value ?? '');

    if (amount <= 0) {
      return 'Ingresa un monto mayor a 0';
    }

    if (amount > widget.availableBalance) {
      return 'El monto no puede superar el saldo disponible';
    }

    return null;
  }

  String? _validateDestination(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return _method == 'alias' ? 'Ingresa un alias' : 'Ingresa un CBU/CVU';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedBuilder(
      animation: walletService,
      builder: (context, child) {
        final isSubmitting = walletService.isSubmittingWithdrawal;

        return Padding(
          padding: EdgeInsets.fromLTRB(18, 18, 18, 18 + bottom),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Solicitar retiro',
                    style: TextStyle(
                      color: _WalletScreenState._primaryColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Disponible: ${_formatMoney(widget.availableBalance)}',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: _validateAmount,
                    decoration: _inputDecoration(
                      label: 'Monto a retirar',
                      icon: Icons.attach_money,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Metodo de retiro',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _MethodChip(
                          selected: _method == 'alias',
                          label: 'Alias',
                          icon: Icons.alternate_email,
                          onTap: () {
                            setState(() {
                              _method = 'alias';
                              _destinationController.clear();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MethodChip(
                          selected: _method == 'cbu',
                          label: 'CBU/CVU',
                          icon: Icons.account_balance_outlined,
                          onTap: () {
                            setState(() {
                              _method = 'cbu';
                              _destinationController.clear();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _destinationController,
                    validator: _validateDestination,
                    keyboardType: _method == 'cbu'
                        ? TextInputType.number
                        : TextInputType.text,
                    decoration: _inputDecoration(
                      label: _method == 'alias' ? 'Alias' : 'CBU/CVU',
                      icon: _method == 'alias'
                          ? Icons.alternate_email
                          : Icons.account_balance_outlined,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: isSubmitting ? null : _submit,
                      icon: isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.send_outlined),
                      label: Text(
                        isSubmitting ? 'Enviando...' : 'Solicitar retiro',
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: _WalletScreenState._accentColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: _WalletScreenState._softColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: _WalletScreenState._accentColor,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }
}

class _MethodChip extends StatelessWidget {
  final bool selected;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _MethodChip({
    required this.selected,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? _WalletScreenState._primaryColor : Colors.black45;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? _WalletScreenState._primaryColor.withValues(alpha: 0.08)
              : _WalletScreenState._softColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? _WalletScreenState._primaryColor
                : Colors.transparent,
            width: 1.4,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Future<void> Function() onRefresh;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: _WalletScreenState._primaryColor,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 52),
          Icon(
            icon,
            size: 56,
            color: _WalletScreenState._primaryColor,
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.account_balance_wallet_outlined,
              size: 54,
              color: _WalletScreenState._primaryColor,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: FilledButton.styleFrom(
                backgroundColor: _WalletScreenState._accentColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: _WalletScreenState._primaryColor,
      ),
    );
  }
}

String _formatMoney(double value) {
  final fixed = value.toStringAsFixed(2);
  final parts = fixed.split('.');
  final whole = parts.first;
  final decimals = parts.last;
  final buffer = StringBuffer();

  for (var index = 0; index < whole.length; index++) {
    final remaining = whole.length - index;

    buffer.write(whole[index]);

    if (remaining > 1 && remaining % 3 == 1) {
      buffer.write('.');
    }
  }

  return '\$${buffer.toString()},$decimals';
}

String _formatDate(DateTime? date) {
  if (date == null) return '-';

  return '${_twoDigits(date.day)}/${_twoDigits(date.month)}/${date.year} '
      '${_twoDigits(date.hour)}:${_twoDigits(date.minute)}';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');

double _parseAmount(String value) {
  final normalized = value.trim().replaceAll('.', '').replaceAll(',', '.');
  return double.tryParse(normalized) ?? 0;
}
