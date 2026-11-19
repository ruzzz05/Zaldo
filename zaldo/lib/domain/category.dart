import 'package:flutter/material.dart';

enum Category {
  alimentacion(
    'Alimentación',
    'Cafés, comidas y supermercado',
    Icons.restaurant,
  ),
  transporte('Transporte', 'Bus, tren, gasolina y taxi', Icons.directions_bus),
  ocio('Ocio', 'Cine, salidas y aficiones', Icons.sports_esports),
  compras('Compras', 'Ropa, material y otras compras', Icons.shopping_bag),
  otros('Otros', 'Cualquier otro gasto', Icons.more_horiz);

  const Category(this.label, this.hint, this.icon);
  final String label;
  final String hint;
  final IconData icon;
}
