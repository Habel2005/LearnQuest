import 'package:flutter/material.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // AppBar + Gradient Background
          Stack(
            children: [
              // Gradient Background
              Container(
                height: kToolbarHeight + 200, // Make it large enough to blend
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromARGB(255, 177, 116, 212),
                      Color.fromARGB(255, 138, 202, 254),
                    ],
                  ),
                ),
              ),
              // AppBar with Transparent Background
              SafeArea(
                child: AppBar(
                  backgroundColor: Colors.transparent, // Transparent to blend
                  elevation: 0, // Remove shadow
                ),
              ),

              const Padding(
                padding: EdgeInsets.only(top: 150),
                child: Center(
                  child: Text(
                    'Contact Us',
                    style: TextStyle(
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.bold,
                        fontSize: 30),
                  ),
                ),
              )
            ],
          ),

          // Content Section (Pushes content down)
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    _buildContactMethod(
                      icon: Icons.email_outlined,
                      title: 'Email Us',
                      subtitle: 'Get in touch via email',
                      onTap: () {},
                    ),
                    const SizedBox(height: 24),
                    _buildContactMethod(
                      icon: Icons.chat_bubble_outline,
                      title: 'Live Chat',
                      subtitle: 'Chat with our support team',
                      onTap: () {},
                    ),
                    const SizedBox(height: 24),
                    _buildContactMethod(
                      icon: Icons.help_outline,
                      title: 'FAQ',
                      subtitle: 'Find quick answers',
                      onTap: () {},
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Connect With Us',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSocialButton(Icons.facebook, 'Facebook', () {}),
                        _buildSocialButton(Icons.link, 'LinkedIn', () {}),
                        _buildSocialButton(
                            Icons.camera_alt_outlined, 'Instagram', () {}),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.blue),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Support Hours',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(182, 75, 89, 138)),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Monday - Friday: 9:00 AM - 6:00 PM',
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10,)
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactMethod({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue.shade100),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 59, 59, 59)),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(
      IconData icon, String platform, VoidCallback onTap) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.blue),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          platform,
          style: const TextStyle(
              fontSize: 12, color: Color.fromARGB(196, 14, 27, 58)),
        ),
      ],
    );
  }
}
