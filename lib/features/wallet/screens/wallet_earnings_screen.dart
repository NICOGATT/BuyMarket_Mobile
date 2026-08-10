import 'package:flutter/material.dart';

import '../models/wallet_earnings.dart';
import '../services/wallet_service_instance.dart';

class WalletPeriodEarningsScreen extends StatefulWidget {
  const WalletPeriodEarningsScreen({super.key});

  @override
  State<WalletPeriodEarningsScreen> createState() =>
      _WalletPeriodEarningsScreenState();
}

class _WalletPeriodEarningsScreenState
    extends State<WalletPeriodEarningsScreen> {
  late DateTime _selectedMonth;
  DateTimeRange? _selectedRange;
  bool _custom = false;
  late Future<WalletEarnings> _future;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
    _future = _load();
  }

  WalletDatePeriod get _period {
    final range = _selectedRange;
    if (_custom && range != null) {
      return WalletDatePeriod.range(
        DateTimeRangeValues(start: range.start, end: range.end),
      );
    }
    return WalletDatePeriod.month(_selectedMonth);
  }

  Future<WalletEarnings> _load() => walletService.loadEarnings(
    from: _period.from,
    toExclusive: _period.toExclusive,
  );

  void _reload() => setState(() => _future = _load());

  Future<void> _pickMonth() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Elegir mes',
    );
    if (date == null) return;
    _selectedMonth = DateTime(date.year, date.month);
    _reload();
  }

  Future<void> _pickRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedRange,
      helpText: 'Elegir período',
    );
    if (range == null) return;
    _selectedRange = range;
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Ganancias',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xff2D006B),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Por mes'),
                          selected: !_custom,
                          onSelected: (_) {
                            _custom = false;
                            _reload();
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ChoiceChip(
                          label: const FittedBox(
                            child: Text('Fechas específicas'),
                          ),
                          selected: _custom,
                          onSelected: (_) async {
                            _custom = true;
                            if (_selectedRange == null) {
                              await _pickRange();
                            } else {
                              _reload();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _custom ? _pickRange : _pickMonth,
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: Text(_label),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<WalletEarnings>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: FilledButton.icon(
                        onPressed: _reload,
                        icon: const Icon(Icons.refresh),
                        label: Text(_cleanError(snapshot.error!)),
                      ),
                    );
                  }
                  return _Summary(earnings: snapshot.data!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _label {
    final range = _selectedRange;
    if (_custom && range != null) {
      return '${_date(range.start)} - ${_date(range.end)}';
    }
    return '${_months[_selectedMonth.month - 1]} ${_selectedMonth.year}';
  }
}

class _Summary extends StatelessWidget {
  final WalletEarnings earnings;

  const _Summary({required this.earnings});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xff1A003F), Color(0xff2D006B)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total ganado',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              Text(
                _money(earnings.total),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _Metric(
                label: 'Ingresos',
                value: earnings.income,
                color: const Color(0xff16A34A),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Metric(
                label: 'Ajustes',
                value: earnings.adjustments,
                color: earnings.adjustments < 0
                    ? const Color(0xffDC2626)
                    : const Color(0xff16A34A),
              ),
            ),
          ],
        ),
        if (earnings.total == 0 && earnings.income == 0) ...[
          const SizedBox(height: 40),
          const Icon(Icons.query_stats, size: 52, color: Colors.black38),
          const SizedBox(height: 12),
          const Text(
            'No hubo ganancias en este período',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _Metric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffECEEF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 6),
          FittedBox(
            child: Text(
              _money(value),
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const _months = [
  'Enero',
  'Febrero',
  'Marzo',
  'Abril',
  'Mayo',
  'Junio',
  'Julio',
  'Agosto',
  'Septiembre',
  'Octubre',
  'Noviembre',
  'Diciembre',
];

String _date(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

String _money(double value) =>
    '${value < 0 ? '-' : ''}\$${value.abs().toStringAsFixed(2).replaceAll('.', ',')}';

String _cleanError(Object error) =>
    error.toString().replaceFirst('Exception: ', '');
