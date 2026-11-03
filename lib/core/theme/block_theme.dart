import 'package:flutter/material.dart';

enum BlockTheme {
  classic(
    'Cổ điển',
    'Khối màu nguyên bản',
    Icons.view_module_rounded,
  ),
  geometric(
    'Hình học',
    'Ngôi sao, kim cương và tia sét',
    Icons.category_rounded,
  ),
  fruit(
    'Trái cây',
    'Những loại quả nhỏ đầy màu sắc',
    Icons.eco_rounded,
  ),
  gem(
    'Đá quý',
    'Kim cương, hồng ngọc và lăng kính lấp lánh',
    Icons.diamond_outlined,
  ),
  space(
    'Vũ trụ',
    'Phi thuyền, hành tinh và dải ngân hà huyền ảo',
    Icons.rocket_launch_outlined,
  ),
  ocean(
    'Đại dương',
    'Cá nhỏ, sao biển và thế giới đại dương kỳ thú',
    Icons.water_drop_outlined,
  ),
  candy(
    'Kẹo ngọt',
    'Kẹo mút xoắn, bánh kem và que kem ngọt ngào',
    Icons.cake_outlined,
  ),
  animal(
    'Động vật',
    'Dấu chân thú, mèo con và những người bạn đáng yêu',
    Icons.pets_rounded,
  );

  const BlockTheme(this.label, this.description, this.icon);
  final String label;
  final String description;
  final IconData icon;

  static BlockTheme fromName(String? name) =>
      values.firstWhere((theme) => theme.name == name, orElse: () => classic);
}
