import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/openai_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => QuizScreenState();
}

class QuizScreenState extends State<QuizScreen> {
  final OpenAIService openAIService = OpenAIService();
  Question? currentQuestion;
  String? selectedAnswer;
  String? message;
  bool showCorrectAnswer = false;
  int attempts = 0;

  @override
  void initState() {
    super.initState();
    loadQuestion();
  }

  Future<void> loadQuestion() async {
    try {
      final question = await openAIService.getAPCSQuestion();
      setState(() {
        currentQuestion = question;
        selectedAnswer = null;
        message = null;
        showCorrectAnswer = false;
        attempts = 0;
      });
    } catch (e) {
      setState(() {
        message = 'Cannot load question';
      });
    }
  }

  void checkAnswer() {
    if (selectedAnswer == null) return;

    setState(() {
      if (selectedAnswer == currentQuestion!.correctAnswer) {
        message = 'CORRECT!';
        showCorrectAnswer = true;
      } else {
        attempts++;
        if (attempts >= 2) {
          message = 'The correct answer is: ${currentQuestion!.correctAnswer}';
          showCorrectAnswer = true;
        } else {
          message = 'TRY AGAIN!';
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('APCS Practice Questions'),
      ),
      body: currentQuestion == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (message != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: message == 'CORRECT!'
                              ? Colors.green
                              : Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          message!,
                          style: TextStyle(
                            color: message == 'CORRECT!'
                                ? Colors.green
                                : Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentQuestion!.questionText,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          ...currentQuestion!.options.map((option) => Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: RadioListTile<String>(
                                  title: Text(option),
                                  value: option,
                                  groupValue: selectedAnswer,
                                  onChanged: showCorrectAnswer
                                      ? null
                                      : (value) {
                                          setState(() {
                                            selectedAnswer = value;
                                          });
                                        },
                                ),
                              )),
                          if (showCorrectAnswer &&
                              message == 'CORRECT!' &&
                              currentQuestion!.explanation.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Text(
                                'Explanation: ${currentQuestion!.explanation}',
                                style:
                                    const TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: showCorrectAnswer ? loadQuestion : checkAnswer,
                    child: Text(
                      showCorrectAnswer ? 'Next Question' : 'Submit',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
} 