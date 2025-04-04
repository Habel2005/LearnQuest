import 'dart:convert';
import 'package:our_own_project/auth-service/api.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class DailyChallengesPage extends StatefulWidget {
  final String userId;

  const DailyChallengesPage({super.key, required this.userId});

  @override
  State<DailyChallengesPage> createState() => _DailyChallengesPageState();
}

class _DailyChallengesPageState extends State<DailyChallengesPage> {
  late Future<Map<String, dynamic>> _challengesFuture;

  @override
  void initState() {
    super.initState();
    _challengesFuture = _fetchChallenges();
  }

  Future<Map<String, dynamic>> _fetchChallenges() async {
    final response = await http.get(
      Uri.parse(
          'https://learnquestapi-production.up.railway.app/daily-challenges?userId=${widget.userId}'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load challenges');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Challenges'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade200, Colors.pink.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.pink.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _challengesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingShimmer();
            } else if (snapshot.hasError) {
              return _buildErrorState();
            }
            return _buildChallengeList(snapshot.data!);
          },
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.pink.shade300, size: 48),
          const SizedBox(height: 16),
          const Text('Failed to load challenges',
              style: TextStyle(color: Colors.blueGrey)),
          TextButton.icon(
            onPressed: () async {
              final newFuture = _fetchChallenges(); // Call it outside setState
              setState(() {
                _challengesFuture = newFuture; // Update synchronously
              });
            },
            icon: Icon(Icons.refresh, color: Colors.blue.shade300),
            label: Text('Try Again',
                style: TextStyle(color: Colors.blue.shade300)),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeList(Map<String, dynamic> data) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          automaticallyImplyLeading: false,
          expandedHeight: 100,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade100, Colors.pink.shade50],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🔥 ${data['streakCount']} Day Streak',
                            style: TextStyle(color: Colors.orange.shade800)),
                        const SizedBox(
                          height: 10,
                        ),
                        Text('${data['completedToday'].length} Completed Today',
                            style: TextStyle(color: Colors.blue.shade800)),
                      ],
                    ),
                    Chip(
                      backgroundColor: Colors.blue.shade50,
                      labelStyle: const TextStyle(color: Colors.black87),
                      label: Text(data['date']),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildChallengeCard(data['challenges'][index]),
            childCount: (data['challenges'] as List).length,
          ),
        ),
      ],
    );
  }

  Widget _buildChallengeCard(Map<String, dynamic> challenge) {
    return Card(
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => _handleChallengeTap(challenge),
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.pink.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15)),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(challenge['title'],
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800)),
                    ),
                    _getChallengeIcon(challenge['type']),
                  ],
                ),
                const SizedBox(height: 8),
                Text(challenge['description'],
                    style: TextStyle(color: Colors.blueGrey.shade800)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: Colors.pink.shade300),
                    Text(' ${challenge['estimatedTime']}',
                        style: TextStyle(color: Colors.pink.shade800)),
                    const Spacer(),
                    Icon(Icons.star, size: 16, color: Colors.amber.shade600),
                    Text(' ${challenge['difficulty']}',
                        style: TextStyle(color: Colors.amber.shade800)),
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  Widget _getChallengeIcon(String type) {
    final icons = {
      'coding': Icons.code,
      'learning': Icons.school,
      'project': Icons.architecture,
      'quiz': Icons.quiz,
    };
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.blue.shade100, blurRadius: 5)],
      ),
      child: Icon(icons[type.toLowerCase()] ?? Icons.extension,
          color: Colors.blue.shade300),
    );
  }

  void _handleChallengeTap(Map<String, dynamic> challenge) {
    // Handle challenge navigation based on type
    showModalBottomSheet(
      context: context,
      builder: (context) => ChallengeDetailsSheet(challenge: challenge),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }
}

class ChallengeDetailsSheet extends StatefulWidget {
  final Map<String, dynamic> challenge;

  const ChallengeDetailsSheet({super.key, required this.challenge});

  @override
  _ChallengeDetailsSheetState createState() => _ChallengeDetailsSheetState();
}

class _ChallengeDetailsSheetState extends State<ChallengeDetailsSheet> {
  bool isCompleted = false;
  bool hasStarted = false;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    _fetchChallengeStatus();
  }

  Future<void> _fetchChallengeStatus() async {
    bool status =
        await CourseService.fetchChallengeStatus(widget.challenge['id']);
    setState(() {
      isCompleted = status;
      hasStarted = status; // If completed before, assume it was started
    });
  }

  Future<void> _toggleChallenge() async {
    bool newStatus =
        await CourseService.toggleChallengeCompletion(widget.challenge['id']);
    setState(() {
      isCompleted = newStatus;
    });
  }

  void _launchChallenge(BuildContext context) {
    if (!hasStarted) setState(() => hasStarted = true);

    if (widget.challenge['resourceUrl'] != null) {
      launchUrl(Uri.parse(widget.challenge['resourceUrl']));
    }
    else if(widget.challenge['type'] == 'quiz')
    {
      Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(questions: widget.challenge['questions']),
      ),
    );
    }
    else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.challenge['title'],
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    widget.challenge['description'],
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.purple.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Challenge Title
          Text(
            widget.challenge['title'],
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const SizedBox(height: 16),

          // Challenge Info
          _buildDetailRow(Icons.access_time_rounded,
              widget.challenge['estimatedTime'], "Duration"),
          _buildDetailRow(
              Icons.star_rounded, widget.challenge['difficulty'], "Difficulty"),
          _buildDetailRow(Icons.category_rounded,
              widget.challenge['resourceType'], "Category"),
          const SizedBox(height: 20),

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Start Challenge Button
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.play_arrow, color: Colors.blue),
                  label: const Text("Start",
                      style: TextStyle(color: Colors.black)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    side: const BorderSide(color: Colors.blue),
                  ),
                  onPressed: () => _launchChallenge(context),
                ),
              ),
              const SizedBox(width: 8),

              // Complete Challenge Button
              Expanded(
                child: ElevatedButton.icon(
                  icon: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)
                      : Icon(
                          isCompleted ? Icons.check_circle : Icons.done,
                          color: isCompleted ? Colors.white : Colors.white,
                        ),
                  label: Text(
                    isCompleted ? "Completed" : "Mark Complete",
                    style: TextStyle(
                        color: isCompleted ? Colors.white : Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCompleted ? Colors.green : Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: hasStarted
                      ? () async {
                          setState(() => isLoading = true);
                          await _toggleChallenge();
                          setState(() => isLoading = false);
                        }
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple.shade300, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "$label: $text",
              style: TextStyle(
                  color: Colors.blue.shade800,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}


class QuizScreen extends StatefulWidget {
  final List<dynamic> questions;

  const QuizScreen({super.key, required this.questions});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  String? selectedAnswer;
  bool showResult = false;
  int score = 0;

  void _submitAnswer() {
    if (selectedAnswer == widget.questions[currentQuestionIndex]['answer']) {
      score++;
    }

    if (currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswer = null;
      });
    } else {
      setState(() {
        showResult = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define soft pink & white theme
    const Color primaryColor = Color(0xFFFFC0CB); // Light Pink
    const Color backgroundColor = Colors.white;
    const Color textColor = Color(0xFF333333);
    const Color buttonColor = Color(0xFFFFA6C1); // Soft Pink

    if (showResult) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text("Quiz Results"),
          backgroundColor: primaryColor,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Your Score: $score / ${widget.questions.length}",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text("Close Quiz", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    var currentQuestion = widget.questions[currentQuestionIndex];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Quiz"),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                "Q${currentQuestionIndex + 1}: ${currentQuestion['question']}",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
              ),
            ),
            const SizedBox(height: 20),
            ...currentQuestion['options'].entries.map((entry) {
              String optionKey = entry.key;
              String optionValue = entry.value;
              bool isSelected = selectedAnswer == optionKey;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedAnswer = optionKey;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? buttonColor.withOpacity(0.6) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? buttonColor : Colors.grey.shade300,
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected ? buttonColor : Colors.grey,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          optionValue,
                          style: TextStyle(
                            fontSize: 16,
                            color: isSelected ? textColor : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: selectedAnswer != null ? _submitAnswer : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text("Submit Answer", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
