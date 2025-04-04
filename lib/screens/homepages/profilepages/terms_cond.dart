import 'package:flutter/material.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Stack for AppBar & Gradient Background
          Stack(
            children: [
              // Full Gradient Background for seamless blending
              Container(
                height: kToolbarHeight +
                    200, // Enough height to merge with the AppBar
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
              // Transparent AppBar over the gradient
              SafeArea(
                child: AppBar(
                  backgroundColor:
                      Colors.transparent, // Ensures gradient visibility
                  elevation: 0, // Removes shadow
                ),
              ),

              const Padding(
                padding: EdgeInsets.only(top: 150),
                child: Center(
                  child: Text(
                    'Terms & Conditions',
                    style: TextStyle(
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.bold,
                        fontSize: 30),
                  ),
                ),
              )
            ],
          ),

          // Content Section
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection(
                        title: 'Last Updated',
                        content: 'February 17, 2025',
                        isDate: true,
                      ),
                      const SizedBox(height: 24),
                      _buildSection(
                        title: '1. Introduction',
                        content:
                            'Welcome to our learning platform. These terms and conditions outline the rules and regulations for the use of our Platform.',
                      ),
                      const SizedBox(height: 24),
                      _buildSection(
                        title: '2. Account Registration',
                        content:
                            'Users must provide accurate and complete information during registration. You are responsible for maintaining the security of your account.',
                      ),
                      const SizedBox(height: 24),
                      _buildSection(
                        title: '3. Content Usage',
                        content:
                            'All content provided on this platform is for educational purposes only. Users may not reproduce or distribute the content without permission.',
                      ),
                      const SizedBox(height: 24),
                      _buildSection(
                        title: '4. Privacy Policy',
                        content:
                            'Your privacy is important to us. Please refer to our Privacy Policy for information on how we collect and use your data.',
                        isLink: true,
                        onTap: () {
                          // Handle privacy policy navigation
                        },
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: Colors.blue.shade700),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'By using our platform, you agree to these terms and conditions.',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            // Handle download terms
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.download, color: Colors.blue.shade700),
                              const SizedBox(width: 8),
                              Text(
                                'Download Full Terms',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    bool isDate = false,
    bool isLink = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isDate ? 14 : 18,
            fontWeight: FontWeight.bold,
            color: isDate ? Colors.grey.shade600 : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        isLink
            ? InkWell(
                onTap: onTap,
                child: Text(
                  content,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue.shade700,
                    decoration: TextDecoration.underline,
                  ),
                ),
              )
            : Text(
                content,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
      ],
    );
  }
}
