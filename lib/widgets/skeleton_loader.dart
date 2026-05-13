import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// --- Base du Squelette (l'effet lumineux) ---
class Skeleton extends StatelessWidget {
  const Skeleton({super.key, this.height, this.width, this.radius = 16});

  final double? height, width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

// --- Squelette pour la grille Pinterest de la page d'accueil ---
class PinterestGridSkeleton extends StatelessWidget {
  const PinterestGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      padding: const EdgeInsets.all(10),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      itemCount: 6, // Affiche 6 squelettes pour remplir l'écran
      itemBuilder: (context, index) {
        // Hauteurs aléatoires pour simuler le style Pinterest
        final double itemHeight = (index % 2 == 0) ? 220 : 280;
        return Skeleton(height: itemHeight);
      },
    );
  }
}

// --- Squelette pour une liste d'éléments ---
class ListSkeleton extends StatelessWidget {
  const ListSkeleton({super.key, this.itemCount = 5});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          children: [
            const Skeleton(height: 60, width: 60, radius: 8),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Skeleton(height: 16, width: 150),
                  const SizedBox(height: 8),
                  Skeleton(height: 12, width: double.infinity),
                  const SizedBox(height: 4),
                  Skeleton(height: 12, width: 100),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// --- Squelette pour une grille de cartes (utilisé pour les spécialistes) ---
class GridSkeleton extends StatelessWidget {
  const GridSkeleton({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) => const Column(
          children: [
            Expanded(child: Skeleton(radius: 16)),
            SizedBox(height: 12),
            Skeleton(height: 16, width: 120),
            SizedBox(height: 8),
            Skeleton(height: 12, width: 80),
          ],
        ));
  }
}

// --- Squelette pour l'étape des services dans la réservation ---
class ServiceStepSkeleton extends StatelessWidget {
  const ServiceStepSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: 6,
      itemBuilder: (context, i) => const Skeleton(radius: 16),
    );
  }
}

// --- Squelette pour l'étape des spécialistes dans la réservation ---
class SpecialistStepSkeleton extends StatelessWidget {
  const SpecialistStepSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            const Skeleton(height: 56, width: 56, radius: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Skeleton(height: 16, width: 150),
                  const SizedBox(height: 8),
                  const Skeleton(height: 12, width: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
