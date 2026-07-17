import 'package:buymarket_frontend/features/wallet/screens/wallet_screen.dart';
import 'package:buymarket_frontend/features/wallet/services/wallet_preferences.dart';
import 'package:buymarket_frontend/features/wallet/models/wallet_earnings.dart';
import 'package:buymarket_frontend/features/wallet/models/wallet_sale.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Wallet balance visibility', () {
    const preferences = WalletPreferences();

    test('is visible by default', () async {
      SharedPreferences.setMockInitialValues({});

      expect(await preferences.loadBalanceVisibility(), isTrue);
    });

    test('persists the selected visibility', () async {
      SharedPreferences.setMockInitialValues({});

      await preferences.saveBalanceVisibility(false);

      expect(await preferences.loadBalanceVisibility(), isFalse);
    });
  });

  group('Pending withdrawals', () {
    test('accepts pending statuses in English and Spanish', () {
      expect(isPendingWithdrawalStatus('pending'), isTrue);
      expect(isPendingWithdrawalStatus('PENDIENTE'), isTrue);
      expect(isPendingWithdrawalStatus('approved'), isTrue);
      expect(isPendingWithdrawalStatus('APROBADO'), isTrue);
    });

    test('rejects completed withdrawal statuses', () {
      expect(isPendingWithdrawalStatus('paid'), isFalse);
      expect(isPendingWithdrawalStatus('rejected'), isFalse);
    });
  });

  test('parses the financial detail of a sale', () {
    final sale = WalletSale.fromJson({
      'saleId': 'item-1',
      'orderId': 'order-1',
      'product': {'title': 'Teclado'},
      'variant': {'size': 'M', 'color': 'Negro'},
      'quantity': 2,
      'unitPrice': 1500,
      'subtotal': 3000,
      'financial': {
        'grossAmount': 3000,
        'deductions': [
          {'code': 'commission', 'label': 'Comision', 'amount': 300},
        ],
        'netAmount': 2700,
        'walletStatus': 'completed',
        'effectiveAt': '2026-07-10T12:00:00.000Z',
      },
    });

    expect(sale.productTitle, 'Teclado');
    expect(sale.variantLabel, 'Talle M · Negro');
    expect(sale.deductions.single.amount, 300);
    expect(sale.netAmount, 2700);
    expect(sale.isAccredited, isTrue);
  });

  test('creates inclusive custom ranges with an exclusive API end', () {
    final period = WalletDatePeriod.range(
      DateTimeRangeValues(
        start: DateTime(2026, 7, 1),
        end: DateTime(2026, 7, 15),
      ),
    );

    expect(period.from, DateTime(2026, 7, 1));
    expect(period.toExclusive, DateTime(2026, 7, 16));
  });
}
