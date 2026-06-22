import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/story_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/buddy_character.dart';
import '../widgets/story_card.dart';
import '../widgets/read_story_button.dart';
import '../widgets/quiz_widget.dart';
import '../widgets/success_overlay.dart';
import '../widgets/error_banner.dart';
import '../widgets/stars_painter.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoryProvider>().initTts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoryProvider>();
    final isPlaying = provider.audioState == AudioState.playing;
    final isSuccess = provider.isCorrect;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0, height: 260,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4A1FA8), Color(0xFF6C3FF5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: CustomPaint(painter: StarsPainter()),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('🌟 Peblo', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                          Text('Story Buddy', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white70)),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Text('⭐', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 4),
                            Text(
                              '${provider.isCorrect ? 10 : 0} pts',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  BuddyCharacter(isHappy: isSuccess, isPlaying: isPlaying),
                  const SizedBox(height: 4),
                  Text(
                    isSuccess ? 'You got it right! 🎉' : isPlaying ? 'Listen carefully...' : 'Hi, I\'m Pip! 👋',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  const StoryCard(),
                  const SizedBox(height: 16),
                  if (provider.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ErrorBanner(message: provider.errorMessage!),
                    ),
                  if (!isSuccess) ...[
                    const ReadStoryButton(),
                    const SizedBox(height: 24),
                  ],
                  if (provider.quizState != QuizState.hidden) ...[
                    const QuizWidget(),
                    const SizedBox(height: 20),
                  ],
                  if (isSuccess) ...[
                    const SizedBox(height: 16),
                    const SuccessOverlay(),
                    const SizedBox(height: 24),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
