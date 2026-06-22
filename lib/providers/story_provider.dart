import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/quiz_question.dart';
import '../services/elevenlabs_service.dart';

enum AudioState { idle, loading, playing, finished, error }

enum QuizState { hidden, visible, answered }

enum AudioSource { elevenlabs, nativeTts }

class StoryProvider extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _player = AudioPlayer();
  final ElevenLabsService _elevenLabs = ElevenLabsService();

  AudioState _audioState = AudioState.idle;
  QuizState _quizState = QuizState.hidden;
  String? _errorMessage;
  String? _selectedAnswer;
  bool _isCorrect = false;
  int _wrongAttempts = 0;
  bool _shakeTrigger = false;
  AudioSource? _activeSource;

  AudioState get audioState => _audioState;
  QuizState get quizState => _quizState;
  String? get errorMessage => _errorMessage;
  String? get selectedAnswer => _selectedAnswer;
  bool get isCorrect => _isCorrect;
  int get wrongAttempts => _wrongAttempts;
  bool get shakeTrigger => _shakeTrigger;
  AudioSource? get activeSource => _activeSource;

  static const String storyText =
      "Once upon a time, a clever little robot named Pip lost his shiny blue gear in the Whispering Woods...";

  static final QuizQuestion quizQuestion = QuizQuestion.fromJson({
    "question": "What colour was Pip the Robot's lost gear?",
    "options": ["Red", "Green", "Blue", "Yellow"],
    "answer": "Blue",
  });

  Future<void> initTts() async {
    await _tts.setLanguage("en-IN");
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.1);

    _tts.setCompletionHandler(_onAudioComplete);
    _tts.setErrorHandler((_) => _onAudioError());
    _tts.setStartHandler(() {
      _audioState = AudioState.playing;
      notifyListeners();
    });

    _player.onPlayerComplete.listen((_) => _onAudioComplete());
    _player.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.playing) {
        _audioState = AudioState.playing;
        notifyListeners();
      }
    });
  }

  Future<void> readStory() async {
    if (_audioState == AudioState.playing) {
      await stopStory();
      return;
    }

    _audioState = AudioState.loading;
    _errorMessage = null;
    notifyListeners();

    // Try ElevenLabs first, fall back to native TTS
    final success = await _tryElevenLabs();
    if (!success) {
      await _tryNativeTts();
    }
  }

  Future<bool> _tryElevenLabs() async {
    try {
      final path = await _elevenLabs.getAudioPath(storyText);
      _activeSource = AudioSource.elevenlabs;
      await _player.play(DeviceFileSource(path));
      return true;
    } catch (e) {
      debugPrint('ElevenLabs failed: $e — falling back to native TTS');
      return false;
    }
  }

  Future<void> _tryNativeTts() async {
    try {
      final engines = await _tts.getEngines;
      if (engines == null || engines.isEmpty) {
        _onAudioError(message: "No voice engine found on this device!");
        return;
      }
      _activeSource = AudioSource.nativeTts;
      await _tts.speak(storyText);
    } catch (e) {
      _onAudioError();
    }
  }

  void _onAudioComplete() {
    _audioState = AudioState.finished;
    _quizState = QuizState.visible;
    notifyListeners();
  }

  void _onAudioError({String? message}) {
    _audioState = AudioState.error;
    _errorMessage = message ?? "Oops! Couldn't play audio. Tap to try again!";
    notifyListeners();
  }

  Future<void> stopStory() async {
    await _player.stop();
    await _tts.stop();
    _audioState = AudioState.idle;
    notifyListeners();
  }

  void selectAnswer(String answer) {
    if (_isCorrect) return;

    _selectedAnswer = answer;

    if (quizQuestion.isCorrect(answer)) {
      _isCorrect = true;
      _quizState = QuizState.answered;
    } else {
      _wrongAttempts++;
      _shakeTrigger = !_shakeTrigger;
    }
    notifyListeners();
  }

  void resetShake() {
    _shakeTrigger = !_shakeTrigger;
  }

  void resetAll() {
    _player.stop();
    _tts.stop();
    _audioState = AudioState.idle;
    _quizState = QuizState.hidden;
    _errorMessage = null;
    _selectedAnswer = null;
    _isCorrect = false;
    _wrongAttempts = 0;
    _shakeTrigger = false;
    _activeSource = null;
    notifyListeners();
  }

  void debugShowQuiz() {
    _audioState = AudioState.finished;
    _quizState = QuizState.visible;
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    _tts.stop();
    super.dispose();
  }
}
