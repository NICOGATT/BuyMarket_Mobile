import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'plan_purchase_screen.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  static const _selectedPlanKey = 'selected_membership_plan';
  static const _primaryColor = Color(0xff2D006B);

  String _currentPlan = 'free';
  bool _isLoading = true;
  bool _trialModalShown = false;

  static const _plans = [
    _PlanOption(
      id: 'free',
      name: 'Free',
      price: 0,
      description: 'Empezá gratis y accedé a las funciones esenciales.',
      color: Color(0xff7C3AED),
      features: ['Sin costo', 'Acceso a Buy Market', 'Funciones básicas'],
    ),
    _PlanOption(
      id: 'plus',
      name: 'Plus',
      price: 25000,
      description: 'Más herramientas para impulsar tu experiencia.',
      color: Color(0xff00AEEF),
      assetPath: 'assets/images/plans/plan_plus.png',
      features: ['Beneficios Plus', 'Más herramientas', 'Soporte prioritario'],
    ),
    _PlanOption(
      id: 'premium',
      name: 'Premium',
      price: 49000,
      description:
          'La experiencia más completa, gratis durante tus primeros 6 meses.',
      color: Color(0xffF59E0B),
      assetPath: 'assets/images/plans/plan_premium.png',
      features: [
        'Beneficios Premium',
        'Todas las herramientas',
        'Atención preferencial',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadSelectedPlan();
  }

  Future<void> _loadSelectedPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPlan = prefs.getString(_selectedPlanKey);
    if (!mounted) return;
    setState(() {
      _currentPlan = switch (savedPlan) {
        'plus' => 'plus',
        'premium' => 'premium',
        _ => 'free',
      };
      _isLoading = false;
    });
    if (savedPlan == null) {
      await prefs.setString(_selectedPlanKey, 'free');
    }
    if (_currentPlan != 'premium') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPremiumTrialModal();
      });
    }
  }

  Future<void> _showPremiumTrialModal({bool force = false}) async {
    if (!mounted || _currentPlan == 'premium') return;
    if (_trialModalShown && !force) return;
    _trialModalShown = true;

    final shouldClaim = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Image.asset(
          'assets/images/plans/plan_premium.png',
          width: 118,
          height: 118,
        ),
        title: const Text(
          '¡Tenés Premium gratis por 6 meses!',
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'Reclamá el beneficio para activar Premium como tu plan actual durante tus primeros 6 meses.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Ahora no'),
          ),
          FilledButton(
            key: const Key('claim-premium-trial'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reclamar Premium'),
          ),
        ],
      ),
    );
    if (shouldClaim != true || !mounted) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedPlanKey, 'premium');
    if (!mounted) return;
    setState(() => _currentPlan = 'premium');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Activaste Premium gratis por 6 meses.')),
    );
  }

  Future<void> _selectPlan(_PlanOption plan) async {
    if (plan.price > 0) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PlanPurchaseScreen(
            planName: plan.name,
            price: plan.price,
            assetPath: plan.assetPath!,
            color: plan.color,
          ),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Elegir plan ${plan.name}'),
        content: Text(
          plan.price == 0
              ? '¿Querés usar el plan Free sin costo?'
              : 'El plan ${plan.name} tiene un valor de ${plan.formattedPrice}. ¿Querés seleccionarlo?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedPlanKey, plan.id);
    if (!mounted) return;
    setState(() => _currentPlan = plan.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Seleccionaste el plan ${plan.name}.')),
    );
    if (plan.id != 'premium') {
      await _showPremiumTrialModal(force: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Mi plan'),
        backgroundColor: Colors.transparent,
        foregroundColor: _primaryColor,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
                children: [
                  const Text(
                    'Elegí el plan ideal para vos',
                    style: TextStyle(
                      color: _primaryColor,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Podés cambiar tu selección cuando quieras.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  if (_currentPlan == 'premium') ...[
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xffFFF7E6),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xffF59E0B)),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.workspace_premium,
                            color: Color(0xffF59E0B),
                            size: 30,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tu plan actual: Premium',
                                  style: TextStyle(
                                    color: Color(0xff2D006B),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'Lo tenés gratis durante tus primeros 6 meses.',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  for (final plan in _plans) ...[
                    _PlanCard(
                      plan: plan,
                      isCurrent: _currentPlan == plan.id,
                      onSelect: () => _selectPlan(plan),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final _PlanOption plan;
  final bool isCurrent;
  final VoidCallback onSelect;

  const _PlanCard({
    required this.plan,
    required this.isCurrent,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isCurrent ? plan.color : Colors.black12,
          width: isCurrent ? 2.5 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PlanIcon(plan: plan),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            plan.name,
                            style: const TextStyle(
                              color: Color(0xff2D006B),
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (isCurrent)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: plan.color.withValues(alpha: 0.13),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Tu plan',
                              style: TextStyle(
                                color: plan.color,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plan.formattedPrice,
                      style: TextStyle(
                        color: plan.color,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            plan.description,
            style: const TextStyle(color: Colors.black54, height: 1.35),
          ),
          const SizedBox(height: 14),
          ...plan.features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: plan.color, size: 19),
                  const SizedBox(width: 9),
                  Expanded(child: Text(feature)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          FilledButton(
            key: Key('select-plan-${plan.id}'),
            onPressed: isCurrent ? null : onSelect,
            style: FilledButton.styleFrom(
              backgroundColor: plan.color,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
            ),
            child: Text(
              isCurrent
                  ? plan.id == 'premium'
                        ? 'Tu plan · 6 meses gratis'
                        : 'Tu plan'
                  : plan.price == 0
                  ? 'Elegir Free'
                  : 'Elegir ${plan.name} · ${plan.formattedPrice}',
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanIcon extends StatelessWidget {
  final _PlanOption plan;

  const _PlanIcon({required this.plan});

  @override
  Widget build(BuildContext context) {
    if (plan.assetPath != null) {
      return SizedBox(
        width: 88,
        height: 88,
        child: Image.asset(plan.assetPath!, fit: BoxFit.contain),
      );
    }

    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: plan.color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(color: plan.color, width: 3),
      ),
      child: Icon(Icons.auto_awesome, color: plan.color, size: 42),
    );
  }
}

class _PlanOption {
  final String id;
  final String name;
  final int price;
  final String description;
  final Color color;
  final String? assetPath;
  final List<String> features;

  const _PlanOption({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.color,
    required this.features,
    this.assetPath,
  });

  String get formattedPrice {
    if (price == 0) return 'Gratis';
    final value = price.toString();
    final formatted = value.length > 3
        ? '${value.substring(0, value.length - 3)}.${value.substring(value.length - 3)}'
        : value;
    return '\$$formatted';
  }
}
