import 'package:flutter/material.dart';

/// Global cartography: halfway between source colors and the Explore finish.
/// Apply only to tiles, preserving product overlays and attribution contrast.
abstract final class MapStyle {
  static const background = Color(0xFFF5F5F3);
  static const tileColorFilter = ColorFilter.matrix([
    .597796,
    .328992,
    .033212,
    0,
    10.2,
    .097796,
    .828992,
    .033212,
    0,
    10.2,
    .097796,
    .328992,
    .533212,
    0,
    8.2,
    0,
    0,
    0,
    1,
    0,
  ]);
}
