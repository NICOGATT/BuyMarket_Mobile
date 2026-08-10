import 'package:flutter/material.dart';

import '../models/product.dart';
import 'product_grid.dart';

typedef ProductVariantFilters = Map<String, Set<String>>;

enum ProductSortOption { none, priceLowToHigh, priceHighToLow, alphabetical }

class ProductFilterSelection {
  final ProductVariantFilters variantFilters;
  final ProductSortOption sortOption;
  final bool freeShippingOnly;

  ProductFilterSelection({
    ProductVariantFilters variantFilters = const {},
    this.sortOption = ProductSortOption.none,
    this.freeShippingOnly = false,
  }) : variantFilters = {
         for (final entry in variantFilters.entries)
           entry.key: Set<String>.from(entry.value),
       };
}

class ProductFilterSection extends StatefulWidget {
  final String title;
  final List<Product> products;
  final TextStyle? titleStyle;
  final String emptyMessage;
  final bool includeCategoryFilter;

  const ProductFilterSection({
    super.key,
    required this.title,
    required this.products,
    this.titleStyle,
    this.emptyMessage = 'No hay productos con esos filtros.',
    this.includeCategoryFilter = false,
  });

  @override
  State<ProductFilterSection> createState() => _ProductFilterSectionState();
}

class _ProductFilterSectionState extends State<ProductFilterSection> {
  ProductFilterSelection _selection = ProductFilterSelection();

  @override
  void didUpdateWidget(covariant ProductFilterSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    final available = {
      for (final option in buildProductVariantFilterOptions(
        widget.products,
        includeCategory: widget.includeCategoryFilter,
      ))
        option.key: option.values.keys.toSet(),
    };

    _selection.variantFilters.removeWhere((key, selectedValues) {
      final availableValues = available[key];
      if (availableValues == null) return true;
      selectedValues.retainAll(availableValues);
      return selectedValues.isEmpty;
    });
  }

  List<Product> get _filteredProducts => applyProductFilters(
    widget.products,
    _selection,
  );

  int get _selectedCount {
    final variantCount = _selection.variantFilters.values.fold(
      0,
      (total, values) => total + values.length,
    );
    return variantCount +
        (_selection.freeShippingOnly ? 1 : 0) +
        (_selection.sortOption == ProductSortOption.none ? 0 : 1);
  }

  Future<void> _openFilters() async {
    final filters = await showProductVariantFilterModal(
      context,
      products: widget.products,
      selection: _selection,
      includeCategory: widget.includeCategoryFilter,
    );
    if (filters == null || !mounted) return;
    setState(() => _selection = filters);
  }

  @override
  Widget build(BuildContext context) {
    final products = _filteredProducts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                widget.title,
                style: widget.titleStyle ??
                    const TextStyle(
                      color: Color(0xff2D006B),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            TextButton.icon(
              onPressed: _openFilters,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xff2D006B),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                visualDensity: VisualDensity.compact,
              ),
              icon: const Icon(Icons.filter_alt_outlined, size: 18),
              label: Text(
                _selectedCount == 0 ? 'Filtrar' : 'Filtrar ($_selectedCount)',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (products.isEmpty)
          _FilteredEmptyState(
            message: widget.emptyMessage,
            onClear: _selectedCount == 0
                ? null
                : () => setState(
                    () => _selection = ProductFilterSelection(),
                  ),
          )
        else
          ProductGrid(products: products),
      ],
    );
  }
}

class ProductVariantFilterOption {
  final String key;
  final String label;
  final Map<String, String> values;

  const ProductVariantFilterOption({
    required this.key,
    required this.label,
    required this.values,
  });
}

List<ProductVariantFilterOption> buildProductVariantFilterOptions(
  List<Product> products, {
  bool includeCategory = false,
}) {
  final labels = <String, String>{};
  final values = <String, Map<String, String>>{};

  void addValue(String label, String? rawValue) {
    final value = rawValue?.trim() ?? '';
    if (value.isEmpty) return;

    final key = _normalize(label);
    final normalizedValue = _normalize(value);
    if (key.isEmpty || normalizedValue.isEmpty) return;

    labels.putIfAbsent(key, () => label.trim());
    values.putIfAbsent(key, () => {})[normalizedValue] = value;
  }

  for (final product in products) {
    if (includeCategory) {
      addValue('Categoría', product.category);
    }
    for (final variant in product.variants.where((item) => item.isActive)) {
      addValue('Talle', variant.size);
      addValue('Color', variant.color ?? variant.colorHex);
      for (final attribute in variant.attributes) {
        addValue(attribute.name, attribute.value);
      }
    }
  }

  final options = values.entries
      .map(
        (entry) => ProductVariantFilterOption(
          key: entry.key,
          label: labels[entry.key] ?? entry.key,
          values: entry.value,
        ),
      )
      .where((option) => option.values.isNotEmpty)
      .toList();

  const preferredOrder = {'categoria': 0, 'talle': 1, 'color': 2};
  options.sort((first, second) {
    final firstOrder = preferredOrder[first.key] ?? 2;
    final secondOrder = preferredOrder[second.key] ?? 2;
    if (firstOrder != secondOrder) return firstOrder.compareTo(secondOrder);
    return first.label.toLowerCase().compareTo(second.label.toLowerCase());
  });

  for (final option in options) {
    final sortedEntries = option.values.entries.toList()
      ..sort((first, second) => first.value.compareTo(second.value));
    option.values
      ..clear()
      ..addEntries(sortedEntries);
  }

  return options;
}

List<Product> filterProductsByVariants(
  List<Product> products,
  ProductVariantFilters filters,
) {
  final activeFilters = Map<String, Set<String>>.fromEntries(
    filters.entries.where((entry) => entry.value.isNotEmpty),
  );
  if (activeFilters.isEmpty) return products;

  return products.where((product) {
    final categoryFilter = activeFilters['categoria'];
    if (categoryFilter != null &&
        !categoryFilter.contains(_normalize(product.category))) {
      return false;
    }

    final variantFilters = Map<String, Set<String>>.from(activeFilters)
      ..remove('categoria');
    if (variantFilters.isEmpty) return true;

    return product.variants.where((variant) => variant.isActive).any((variant) {
      final values = <String, String>{};

      void addValue(String label, String? rawValue) {
        final value = rawValue?.trim() ?? '';
        if (value.isEmpty) return;
        values[_normalize(label)] = _normalize(value);
      }

      addValue('Talle', variant.size);
      addValue('Color', variant.color ?? variant.colorHex);
      for (final attribute in variant.attributes) {
        addValue(attribute.name, attribute.value);
      }

      return variantFilters.entries.every((filter) {
        final variantValue = values[filter.key];
        return variantValue != null && filter.value.contains(variantValue);
      });
    });
  }).toList();
}

List<Product> applyProductFilters(
  List<Product> products,
  ProductFilterSelection selection,
) {
  var result = filterProductsByVariants(
    products,
    selection.variantFilters,
  );

  if (selection.freeShippingOnly) {
    result = result.where((product) => product.hasFreeShipping).toList();
  } else {
    result = List<Product>.from(result);
  }

  switch (selection.sortOption) {
    case ProductSortOption.priceLowToHigh:
      result.sort((first, second) => _priceOf(first).compareTo(_priceOf(second)));
      break;
    case ProductSortOption.priceHighToLow:
      result.sort((first, second) => _priceOf(second).compareTo(_priceOf(first)));
      break;
    case ProductSortOption.alphabetical:
      result.sort(
        (first, second) => _normalize(
          first.title,
        ).compareTo(_normalize(second.title)),
      );
      break;
    case ProductSortOption.none:
      break;
  }

  return result;
}

Future<ProductFilterSelection?> showProductVariantFilterModal(
  BuildContext context, {
  required List<Product> products,
  required ProductFilterSelection selection,
  bool includeCategory = false,
}) {
  final options = buildProductVariantFilterOptions(
    products,
    includeCategory: includeCategory,
  );
  final draft = {
    for (final entry in selection.variantFilters.entries)
      entry.key: Set<String>.from(entry.value),
  };
  var sortOption = selection.sortOption;
  var freeShippingOnly = selection.freeShippingOnly;

  return showModalBottomSheet<ProductFilterSelection>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (modalContext) => StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.82,
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            MediaQuery.viewInsetsOf(context).bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Color(0xffFFFCFF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xffC9BDD8),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Filtrar productos',
                      style: TextStyle(
                        color: Color(0xff2D006B),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setModalState(() {
                      draft.clear();
                      sortOption = ProductSortOption.none;
                      freeShippingOnly = false;
                    }),
                    child: const Text('Limpiar'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<ProductSortOption>(
                initialValue: sortOption,
                decoration: const InputDecoration(
                  labelText: 'Ordenar por',
                  prefixIcon: Icon(Icons.swap_vert),
                ),
                items: const [
                  DropdownMenuItem(
                    value: ProductSortOption.none,
                    child: Text('Sin orden específico'),
                  ),
                  DropdownMenuItem(
                    value: ProductSortOption.priceLowToHigh,
                    child: Text('Precio: menor a mayor'),
                  ),
                  DropdownMenuItem(
                    value: ProductSortOption.priceHighToLow,
                    child: Text('Precio: mayor a menor'),
                  ),
                  DropdownMenuItem(
                    value: ProductSortOption.alphabetical,
                    child: Text('Orden alfabético'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setModalState(() => sortOption = value);
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: const Color(0xff5E2CA5),
                title: const Text(
                  'Solo productos con envío gratis',
                  style: TextStyle(
                    color: Color(0xff2D006B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                value: freeShippingOnly,
                onChanged: (value) {
                  setModalState(() => freeShippingOnly = value);
                },
              ),
              const SizedBox(height: 6),
              Flexible(
                child: options.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 36),
                        child: Text(
                          'Estos productos no tienen variantes para filtrar.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: options.length,
                        separatorBuilder: (_, _) => const Divider(height: 28),
                        itemBuilder: (context, index) {
                          final option = options[index];
                          final selected = draft[option.key] ?? <String>{};

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                option.label,
                                style: const TextStyle(
                                  color: Color(0xff2D006B),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: option.values.entries.map((value) {
                                  return FilterChip(
                                    label: Text(value.value),
                                    selected: selected.contains(value.key),
                                    selectedColor: const Color(0xffEEE6FF),
                                    checkmarkColor: const Color(0xff5E2CA5),
                                    onSelected: (isSelected) {
                                      setModalState(() {
                                        final values = draft.putIfAbsent(
                                          option.key,
                                          () => <String>{},
                                        );
                                        if (isSelected) {
                                          values.add(value.key);
                                        } else {
                                          values.remove(value.key);
                                          if (values.isEmpty) {
                                            draft.remove(option.key);
                                          }
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: () => Navigator.pop(
                    modalContext,
                    ProductFilterSelection(
                      variantFilters: draft,
                      sortOption: sortOption,
                      freeShippingOnly: freeShippingOnly,
                    ),
                  ),
                  child: const Text('Aplicar filtros'),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

class _FilteredEmptyState extends StatelessWidget {
  final String message;
  final VoidCallback? onClear;

  const _FilteredEmptyState({required this.message, this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.filter_alt_off_outlined,
            color: Color(0xff5E2CA5),
            size: 38,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xff2D006B)),
          ),
          if (onClear != null) ...[
            const SizedBox(height: 10),
            TextButton(onPressed: onClear, child: const Text('Quitar filtros')),
          ],
        ],
      ),
    );
  }
}

String _normalize(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ü', 'u');
}

double _priceOf(Product product) {
  final normalized = product.price
      .trim()
      .replaceAll(',', '.')
      .replaceAll(RegExp(r'[^0-9.]'), '');
  return double.tryParse(normalized) ?? double.infinity;
}
