import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/story_provider.dart';
import '../utils/app_theme.dart';

class ReadStoryButton extends StatelessWidget {
  const ReadStoryButton({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoryProvider>();
    final state = provider.audioState;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        provider.readStory();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 64,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: state == AudioState.playing
                ? [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)]
                : [AppTheme.primary, AppTheme.primaryLight],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (state == AudioState.playing
                      ? AppTheme.secondary
                      : AppTheme.primary)
                  .withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(child: _buildContent(state)),
      ),
    );
  }

  Widget _buildContent(AudioState state) {
    switch (state) {
      case AudioState.loading:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
            ),
            SizedBox(width: 12),
            Text('Getting ready...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
          ],
        );
      case AudioState.playing:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('⏸️', style: TextStyle(fontSize: 22)),
            SizedBox(width: 10),
            Text('Pause Story', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
          ],
        );
      case AudioState.error:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🔄', style: TextStyle(fontSize: 22)),
            SizedBox(width: 10),
            Text('Try Again!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
          ],
        );
      default:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🔊', style: TextStyle(fontSize: 22)),
            SizedBox(width: 10),
            Text('Read Me a Story!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
          ],
        );
    }
  }
}
