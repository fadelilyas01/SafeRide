import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }

  static Widget rideCardSkeleton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SkeletonLoader(width: 60, height: 24),
                  SkeletonLoader(width: 80, height: 24),
                ],
              ),
              const SizedBox(height: 32),
              const Row(
                children: [
                  SkeletonLoader(width: 24, height: 24, borderRadius: BorderRadius.all(Radius.circular(12))),
                  SizedBox(width: 12),
                  SkeletonLoader(width: 150, height: 16),
                ],
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  SkeletonLoader(width: 24, height: 24, borderRadius: BorderRadius.all(Radius.circular(12))),
                  SizedBox(width: 12),
                  SkeletonLoader(width: 180, height: 16),
                ],
              ),
              const SizedBox(height: 24),
              SkeletonLoader(width: double.infinity, height: 50, borderRadius: BorderRadius.circular(15)),
            ],
          ),
        ),
      ),
    );
  }
}
