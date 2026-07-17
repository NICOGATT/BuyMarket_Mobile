import 'package:flutter/material.dart';

import '../models/wallet_sale.dart';
import '../services/wallet_service_instance.dart';

class WalletBillingSalesScreen extends StatefulWidget {
  const WalletBillingSalesScreen({super.key});

  @override
  State<WalletBillingSalesScreen> createState() =>
      _WalletBillingSalesScreenState();
}

class _WalletBillingSalesScreenState extends State<WalletBillingSalesScreen> {
  late Future<List<WalletSale>> _salesFuture;

  @override
  void initState() {
    super.initState();
    _salesFuture = walletService.loadSales();
  }

  Future<void> _reload() async {
    final future = walletService.loadSales();
    setState(() => _salesFuture = future);
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFAFAFC),
      appBar: _appBar('Facturación'),
      body: SafeArea(
        child: FutureBuilder<List<WalletSale>>(
          future: _salesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _ErrorContent(
                message: _cleanError(snapshot.error!),
                onRetry: _reload,
              );
            }
            final sales = snapshot.data ?? const [];
            if (sales.isEmpty) {
              return _EmptySales(onRefresh: _reload);
            }
            return RefreshIndicator(
              onRefresh: _reload,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                itemCount: sales.length,
                itemBuilder: (context, index) {
                  final sale = sales[index];
                  return _SaleCard(
                    sale: sale,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WalletSaleDetailScreen(sale: sale),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class WalletSaleDetailScreen extends StatelessWidget {
  final WalletSale sale;

  const WalletSaleDetailScreen({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFAFAFC),
      appBar: _appBar('Detalle de venta'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            _whiteCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xffEEE8F8),
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          color: Color(0xff2D006B),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sale.productTitle,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            if (sale.variantLabel.isNotEmpty)
                              Text(
                                sale.variantLabel,
                                style: const TextStyle(color: Colors.black54),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _infoRow('Cantidad', '${sale.quantity}'),
                  _infoRow('Precio unitario', _money(sale.unitPrice)),
                  _infoRow('Fecha de venta', _dateTime(sale.createdAt)),
                  _infoRow('Orden', sale.orderId),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _whiteCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detalle del ingreso',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 16),
                  _moneyRow('Importe bruto', sale.grossAmount),
                  for (final deduction in sale.deductions)
                    _moneyRow(
                      deduction.label,
                      -deduction.amount,
                      color: Colors.red.shade700,
                    ),
                  const Divider(height: 28),
                  _moneyRow(
                    sale.isAccredited
                        ? 'Dinero que ingresó'
                        : 'Pendiente de acreditación',
                    sale.netAmount,
                    emphasized: true,
                    color: sale.isAccredited
                        ? const Color(0xff16A34A)
                        : const Color(0xffF97316),
                  ),
                  if (sale.isAccredited && sale.effectiveAt != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Acreditado el ${_dateTime(sale.effectiveAt)}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaleCard extends StatelessWidget {
  final WalletSale sale;
  final VoidCallback onTap;

  const _SaleCard({required this.sale, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xffECEEF3)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xffEEE8F8),
                child: Icon(
                  Icons.receipt_long_outlined,
                  color: Color(0xff2D006B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sale.productTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${sale.quantity} unidad(es) · ${_dateTime(sale.createdAt)}',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      sale.isAccredited
                          ? 'Acreditado'
                          : 'Pendiente de acreditación',
                      style: TextStyle(
                        color: sale.isAccredited
                            ? const Color(0xff16A34A)
                            : const Color(0xffF97316),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _money(sale.netAmount),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.black38),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptySales extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const _EmptySales({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        children: const [
          SizedBox(height: 90),
          Icon(Icons.receipt_long_outlined, size: 58, color: Color(0xff2D006B)),
          SizedBox(height: 14),
          Text(
            'Todavía no hay ventas realizadas',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _ErrorContent extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorContent({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}

AppBar _appBar(String title) => AppBar(
  title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
  backgroundColor: Colors.white,
  foregroundColor: const Color(0xff2D006B),
);

Widget _whiteCard({required Widget child}) => Container(
  padding: const EdgeInsets.all(18),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: const Color(0xffECEEF3)),
  ),
  child: child,
);

Widget _infoRow(String label, String value) => Padding(
  padding: const EdgeInsets.only(bottom: 8),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 115,
        child: Text(label, style: const TextStyle(color: Colors.black54)),
      ),
      Expanded(
        child: Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    ],
  ),
);

Widget _moneyRow(
  String label,
  double value, {
  bool emphasized = false,
  Color? color,
}) => Padding(
  padding: const EdgeInsets.only(bottom: 8),
  child: Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: TextStyle(
            fontWeight: emphasized ? FontWeight.w900 : FontWeight.w600,
          ),
        ),
      ),
      Text(
        '${value < 0 ? '-' : ''}${_money(value.abs())}',
        style: TextStyle(
          color: color,
          fontSize: emphasized ? 18 : 14,
          fontWeight: emphasized ? FontWeight.w900 : FontWeight.w700,
        ),
      ),
    ],
  ),
);

String _cleanError(Object error) =>
    error.toString().replaceFirst('Exception: ', '');

String _money(double value) =>
    '\$${value.toStringAsFixed(2).replaceAll('.', ',')}';

String _dateTime(DateTime? value) {
  if (value == null) return '-';
  return '${value.day.toString().padLeft(2, '0')}/'
      '${value.month.toString().padLeft(2, '0')}/${value.year}';
}
