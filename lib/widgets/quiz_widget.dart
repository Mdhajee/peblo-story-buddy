import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/story_provider.dart';
import '../models/quiz_question.dart';
import '../utils/app_theme.dart';
import 'shake_widget.dart';

class QuizWidget extends StatelessWidget {
  const QuizWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoryProvider>();

    return AnimatedSlide(
      offset: provider.quizState == QuizState.hidden
          ? const Offset(0, 0.3)
          : Offset.zero,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      child: AnimatedOpacity(
        opacity: provider.quizState == QuizState.hidden ? 0 : 1,
        duration: const Duration(milliseconds: 400),
        child: _QuizContent(question: StoryProvider.quizQuestion),
      ),
    );
  }
}

class _QuizContent extends StatelessWidget {
  final QuizQuestion question;

  const _QuizContent({required this.question});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoryProvider>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Text('🧠', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 6),
                    Text(
                      'Quiz Time!',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (provider.wrongAttempts > 0 && !provider.isCorrect)
                _HintStars(attempts: provider.wrongAttempts),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            question.question,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          // Data-driven: renders any number of options from JSON
          ...List.generate(question.options.length, (i) {
            final option = question.options[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _OptionTile(
                option: option,
                index: i,
                isSelected: provider.selectedAnswer == option,
                isCorrect: question.isCorrect(option),
                hasAnswered: provider.selectedAnswer != null,
                isWon: provider.isCorrect,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String option;
  final int index;
  final bool isSelected;
  final bool isCorrect;
  final bool hasAnswered;
  final bool isWon;

  const _OptionTile({
    required this.option,
    required this.index,
    required this.isSelected,
    required this.isCorrect,
    required this.hasAnswered,
    required this.isWon,
  });

  static const _letters = ['A', 'B', 'C', 'D', 'E'];

  Color _bgColor() {
    if (isWon && isCorrect) return AppTheme.success.withValues(alpha: 0.15);
    if (isSelected && isCorrect) return AppTheme.success.withValues(alpha: 0.15);
    if (isSelected && !isCorrect) return AppTheme.wrongRed.withValues(alpha: 0.1);
    return AppTheme.background;
  }

  Color _borderColor() {
    if (isWon && isCorrect) return AppTheme.success;
    if (isSelected && isCorrect) return AppTheme.success;
    if (isSelected && !isCorrect) return AppTheme.wrongRed;
    return Colors.transparent;
  }

  String _emoji() {
    if (isWon && isCorrect) return '✅';
    if (isSelected && isCorrect) return '✅';
    if (isSelected && !isCorrect) return '❌';
    return _letters[index % _letters.length];
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<StoryProvider>();
    final isShaking = isSelected && !isCorrect;

    final tile = GestureDetector(
      onTap: isWon
          ? null
          : () {
              HapticFeedback.selectionClick();
              provider.selectAnswer(option);
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _bgColor(),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor(), width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isWon && isCorrect
                    ? AppTheme.success
                    : isSelected && isCorrect
                        ? AppTheme.success
                        : isSelected && !isCorrect
                            ? AppTheme.wrongRed
                            : AppTheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  _emoji(),
                  style: TextStyle(
                    fontSize: (isSelected || (isWon && isCorrect)) ? 16 : 15,
                    fontWeight: FontWeight.w800,
                    color: isSelected || (isWon && isCorrect)
                        ? Colors.white
                        : AppTheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                option,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (isShaking) {
      return ShakeWidget(
        key: ValueKey('shake_${option}_${provider.wrongAttempts}'),
        child: tile,
      );
    }

    return tile;
  }
}

class _HintStars extends StatelessWidget {
  final int attempts;

  const _HintStars({required this.attempts});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        attempts.clamp(0, 3),
        (_) => const Text('💫', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
