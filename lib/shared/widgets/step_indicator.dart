import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class StepIndicator extends StatelessWidget {
  final List<String> steps;
  final int currentStep;

  const StepIndicator({
    super.key,
    required this.steps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          return Expanded(
            child: Container(
              height: 2,
              color: _isStepActive((index + 1) ~/ 2)
                  ? AppColors.primaryRed
                  : AppColors.softGray,
            ),
          );
        }

        final stepIndex = index ~/ 2;
        final isActive = _isStepActive(stepIndex);
        final isCurrent = stepIndex + 1 == currentStep;

        return Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primaryRed : Colors.white,
                border: Border.all(
                  color: isActive ? AppColors.primaryRed : AppColors.softGray,
                  width: 2,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${stepIndex + 1}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isActive ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              steps[stepIndex],
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isCurrent
                        ? AppColors.primaryRed
                        : AppColors.textSecondary,
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      }),
    );
  }

  bool _isStepActive(int index) => index + 1 <= currentStep;
}
