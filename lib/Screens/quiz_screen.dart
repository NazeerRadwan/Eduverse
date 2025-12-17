import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/exam_service.dart';
import 'view_examas_screen.dart';

late List<CameraDescription> cameras;

class EnglishExamScreen extends StatefulWidget {
  final int examId;
  const EnglishExamScreen({super.key, this.examId = 1});

  @override
  State<EnglishExamScreen> createState() => _EnglishExamScreenState();
}

class _EnglishExamScreenState extends State<EnglishExamScreen> {
  CameraController? _cameraController;
  bool _cameraReady = false;
  bool _isLoading = true;
  String? _errorMessage;

  late Map<String, dynamic> _examData;
  late List<dynamic> _questions;
  int _currentQuestionIndex = 0;
  Map<int, int> _selectedAnswers = {}; // questionId -> selectedOptionId

  int _warningActive = 3;
  final int _warningTotal = 5;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _loadQuestions();
  }

  Future<void> _initCamera() async {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
    final CameraDescription cam = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    _cameraController = CameraController(
      cam,
      ResolutionPreset.low,
      enableAudio: false,
    );
    await _cameraController!.initialize();
    if (!mounted) return;
    setState(() => _cameraReady = true);
  }

  Future<void> _loadQuestions() async {
    try {
      final response = await ExamService.getExamQuestions(
        examId: widget.examId,
      );

      if (response['success'] == true) {
        setState(() {
          _examData = response['data'];
          _questions = _examData['questions'] ?? [];
          _isLoading = false;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = response['message'] ?? 'Failed to load questions';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading questions: $e';
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  void _handleAnswerSelection(int optionId) async {
    setState(() {
      _selectedAnswers[_questions[_currentQuestionIndex]['id']] = optionId;
    });

    // Save answer to API
    final response = await ExamService.saveAnswer(
      questionId: _questions[_currentQuestionIndex]['id'],
      selectedOptionIds: [optionId],
    );

    if (response['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Failed to save answer'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleSubmitExam() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const Dialog(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text('Submitting exam...'),
                ],
              ),
            ),
          ),
    );

    try {
      final response = await ExamService.submitExam(examId: widget.examId);

      if (mounted) {
        Navigator.pop(context);

        if (response['success'] == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const QuizzesScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to submit exam'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _goToNextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() => _currentQuestionIndex++);
    }
  }

  void _goToPreviousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() => _currentQuestionIndex--);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadQuestions,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(child: Text('No questions available')),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    final List<dynamic> options = currentQuestion['options'] ?? [];
    final int? selectedOptionId = _selectedAnswers[currentQuestion['id']];
    final isLastQuestion = _currentQuestionIndex == _questions.length - 1;

    const Color brandRed = Color(0xFFE53935);
    const Color cardBorder = Color(0xFFE6E6E6);
    const double contentPadding = 16;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.only(
                left: contentPadding,
                right: contentPadding,
                top: 13,
                bottom: contentPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top bar: Title + small warning points + question progress
                  Row(
                    children: [
                      // Title on the left
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _examData['examTitle'] ?? 'Exam',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF002E8A),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(
                                  Icons.timer_outlined,
                                  color: Color(0xFF002E8A),
                                  size: 28,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${_examData['remainingMinutes'] ?? 0}:00',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall?.copyWith(
                                    color: Color(0xFF002E8A),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 56),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Camera preview thumbnail (top-right)
                      if (_cameraController != null)
                        Container(
                          height: 125,
                          width: 155,
                          child: _CameraThumbnail(
                            cameraReady: _cameraReady,
                            controller: _cameraController!,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Full-width warning panel (matches visual emphasis)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.57,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 134, 171, 246),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF002E8A)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: List.generate(_warningTotal, (i) {
                                final bool active = i < _warningActive;
                                return Padding(
                                  padding: EdgeInsets.only(
                                    right: i == _warningTotal - 1 ? 12 : 8,
                                  ),
                                  child: Icon(
                                    Icons.warning_amber_rounded,
                                    size: 26,
                                    color:
                                        active
                                            ? brandRed
                                            : Colors.grey.shade400,
                                  ),
                                );
                              }),
                            ),
                            const Divider(
                              color: Color(0xFF002E8A),
                              height: 20,
                              thickness: 2,
                            ),
                            const Text(
                              'Warning Points',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Question progress
                  Text(
                    'Question ${_currentQuestionIndex + 1}/${_questions.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF606060),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Question text
                  Text(
                    currentQuestion['text'] ?? 'No question text',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Options list
                  ...List.generate(options.length, (index) {
                    final option = options[index];
                    final optionId = option['id'];
                    final isSelected = selectedOptionId == optionId;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _handleAnswerSelection(optionId),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? const Color.fromARGB(255, 134, 171, 246)
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  isSelected ? Color(0xFF002E8A) : cardBorder,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color:
                                    isSelected
                                        ? Color(0xFF002E8A)
                                        : Colors.grey,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  option['text'] ?? 'No option text',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  const Spacer(),

                  // Navigation buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentQuestionIndex > 0)
                        ElevatedButton(
                          onPressed: _goToPreviousQuestion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Previous',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      if (!isLastQuestion)
                        ElevatedButton(
                          onPressed: _goToNextQuestion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF002E8A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Next',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      else
                        ElevatedButton(
                          onPressed: _handleSubmitExam,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF002E8A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Submit',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Separate widget for camera thumbnail to keep layout tidy
class _CameraThumbnail extends StatelessWidget {
  final bool cameraReady;
  final CameraController controller;

  const _CameraThumbnail({
    Key? key,
    required this.cameraReady,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6E6E6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child:
          cameraReady
              ? CameraPreview(controller)
              : const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
    );
  }
}

/*@override
  void dispose() {
    _cameraController?.dispose(); // safe dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color cardBorder = Color(0xFFE6E6E6);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // كاميرا فوق يمين
            if (_cameraController != null)
              Container(
                height: 125,
                width: 155,
                child: _CameraThumbnail(
                  cameraReady: _cameraReady,
                  controller: _cameraController!,
                ),
              )
            const SizedBox(height: 20),
            const Text(
              "7- Which word best replaces 'exhausted'?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            ...List.generate(_options.length, (index) {
              final bool isSelected = _selectedIndex == index;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => setState(() => _selectedIndex = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? const Color.fromARGB(255, 134, 171, 246)
                              : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected ? const Color(0xFF002E8A) : cardBorder,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color:
                              isSelected
                                  ? const Color(0xFF002E8A)
                                  : Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _options[index],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _CameraThumbnail extends StatelessWidget {
  final bool cameraReady;
  final CameraController? controller;

  const _CameraThumbnail({
    super.key,
    required this.cameraReady,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6E6E6)),
      ),
      clipBehavior: Clip.antiAlias,
      child:
          controller != null && cameraReady
              ? CameraPreview(controller!)
              : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}*/
