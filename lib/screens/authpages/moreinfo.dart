import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math' show pi;
import 'package:our_own_project/auth-service/auth.dart';
import 'package:our_own_project/screens/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LearningPreferencesScreen extends StatefulWidget {
  const LearningPreferencesScreen({super.key});

  @override
  State<LearningPreferencesScreen> createState() =>
      _LearningPreferencesScreenState();
}

class SkillMeterPainter extends CustomPainter {
  Color firstc = const Color.fromARGB(255, 251, 251, 251);
  Color secondc = const Color.fromARGB(255, 109, 63, 124);
  Color thirdc = const Color.fromARGB(255, 81, 42, 95);
  final int selectedSkill;

  SkillMeterPainter({required this.selectedSkill});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0;

    final Offset center = Offset(size.width / 2, size.height);
    final double radius = size.width * 0.4;

    //  Draw the background arc (gray)
    paint.color = const Color.fromARGB(255, 246, 244, 244);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi,
      pi,
      false,
      paint,
    );

    if (selectedSkill >= 0) {
      // Correct the gradient to map properly
      final Gradient gradient = SweepGradient(
        colors: [thirdc, firstc, secondc],
        stops: const [0.0, 0.5, 1.0],
        transform: const GradientRotation(-pi / 2), // Ensure correct alignment
      );

      paint.shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

      // Calculate sweep angle based on selected skill
      double sweepAngle = ((selectedSkill + 1) / 4) * pi;

      // Draw colored arc
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(SkillMeterPainter oldDelegate) =>
      selectedSkill != oldDelegate.selectedSkill;
}

class _LearningPreferencesScreenState extends State<LearningPreferencesScreen> {
  Color backcolor = const Color.fromARGB(255, 235, 196, 245);
  Color titlecolor = const Color.fromARGB(255, 81, 60, 95);
  String? _skillLevel;
  final List<String> _selectedInterests = [];
  String? _learningStyle;
  String? _timeCommitment;

  final List<String> _interests = [
    'UI/UX Design',
    'Artificial Intelligence',
    'Finance',
    'Web Development',
    'Mobile Development',
    'Data Science',
    'Cybersecurity',
    'Cloud Computing',
    'Blockchain',
    'Other'
  ];

  Auth auth = Auth();
  Future<void> _completePreferences() async {
    if (_skillLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Skill Level can't be empty"),
      ));
      return;
    } else if (_selectedInterests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Plase Select a Valid Interest/Goal"),
      ));
      return;
    } else if (_learningStyle == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Select valid Learning Style'),
      ));
      return;
    } else if (_timeCommitment == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Pick Valid Learning Time!'),
      ));
      return;
    }
    try {
      auth.saveUserPref(
        FirebaseAuth.instance.currentUser!.uid,
        {
          'skillLevel': _skillLevel,
          'interests': _selectedInterests,
          'learningStyle': _learningStyle,
          'dailyCommitment': _timeCommitment
        },
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Homepage()),
        (route) => false,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isPersonalInfoCompleted', true);
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text(
                  "Error Saving Preferences",
                  style: TextStyle(color: Color.fromARGB(255, 191, 177, 206)),
                ),
                content: Text(e.toString()),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("OK"))
                ],
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backcolor,
      appBar: AppBar(
        backgroundColor: backcolor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A4A4A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Learning Preferences',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A4A4A),
                decoration: TextDecoration.underline,
                decorationStyle: TextDecorationStyle.dashed,
                decorationColor: Color(0xFF4A4A4A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Help us customize your learning experience',
              style: TextStyle(
                  fontSize: 16, color: Color.fromARGB(255, 95, 95, 95)),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Skill Level',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: titlecolor,
              ),
            ),
            const SizedBox(height: 55),
            _buildSection(
              title: '',
              child: _buildSkillMeter(),
            ),
            _buildSection(
              title: 'Interests & Goals',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _interests.map((interest) {
                  final isSelected = _selectedInterests.contains(interest);
                  return FilterChip(
                    label: Text(interest),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedInterests.add(interest);
                        } else {
                          _selectedInterests.remove(interest);
                        }
                      });
                    },
                    selectedColor: const Color.fromARGB(255, 181, 102, 206),
                    checkmarkColor: Colors.white,
                    backgroundColor: const Color(0xFFF5F5F5),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  );
                }).toList(),
              ),
            ),
            _buildSection(
              title: 'Preferred Learning Style',
              child: _buildOptionCards(
                options: [
                  'Videos',
                  'Articles',
                  'Flashcards & Summaries',
                  'Step by Step Guides'
                ],
                selectedOption: _learningStyle,
                onSelect: (value) => setState(() => _learningStyle = value),
                icons: [
                  Icons.play_circle_outline,
                  Icons.article_outlined,
                  Icons.touch_app_outlined,
                  Icons.engineering_outlined,
                ],
              ),
            ),
            _buildSection(
              title: 'Daily Learning Commitment',
              child: _buildTimeCommitmentSlider(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _completePreferences,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 155, 104, 170),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Preferences',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: titlecolor,
          ),
        ),
        const SizedBox(height: 16),
        child,
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSkillMeter() {
    final skills = ['Basic', 'Intermediate', 'Advanced'];
    return SizedBox(
      height: 160,
      child: Column(
        children: [
          SizedBox(
            height: 100,
            child: CustomPaint(
              size: Size.infinite,
              painter: SkillMeterPainter(
                selectedSkill:
                    _skillLevel != null ? skills.indexOf(_skillLevel!) : -1,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: skills
                .map((skill) => GestureDetector(
                      onTap: () => setState(() => _skillLevel = skill),
                      child: Container(
                        decoration: ShapeDecoration(
                            color: const Color(0xFFF5F5F5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15))),
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          skill,
                          style: TextStyle(
                            color: _skillLevel == skill
                                ? const Color.fromARGB(255, 95, 31, 114)
                                : Colors.black,
                            fontWeight: _skillLevel == skill
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCards({
    required List<String> options,
    required String? selectedOption,
    required Function(String) onSelect,
    List<IconData>? icons,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final isSelected = options[index] == selectedOption;
        return InkWell(
          onTap: () => onSelect(options[index]),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color.fromARGB(255, 179, 123, 196)
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icons != null)
                  Icon(
                    icons[index],
                    size: 32,
                    color: isSelected ? Colors.white : Colors.black54,
                  ),
                const SizedBox(height: 8),
                Text(
                  options[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeCommitmentSlider() {
    final commitments = ['5 min', '10 min', '30 min', '1 hour', '2 hours'];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: commitments
              .map((time) => Text(
                    time,
                    style: const TextStyle(color: Color(0xFF4A4A4A)),
                  ))
              .toList(),
        ),
        Slider(
          value: _timeCommitment == null
              ? 0
              : commitments.indexOf(_timeCommitment!).toDouble(),
          min: 0,
          max: commitments.length - 1.0,
          divisions: commitments.length - 1,
          activeColor: const Color.fromARGB(255, 140, 62, 164),
          onChanged: (value) {
            setState(() {
              _timeCommitment = commitments[value.round()];
            });
          },
        ),
        Text(
          _timeCommitment ?? 'Select time',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A4A4A),
          ),
        ),
      ],
    );
  }
}
