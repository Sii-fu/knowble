import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'teacher_navbar.dart';

class InstructorProfilePage2 extends StatefulWidget {
  const InstructorProfilePage2({super.key});

  @override
  State<InstructorProfilePage2> createState() => _InstructorProfilePage2State();
}

class _InstructorProfilePage2State extends State<InstructorProfilePage2> {
  int _selectedIndex = 3;

  Future<void> _logout(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // Profile Image
                    CircleAvatar(
                      radius: 48,
                      backgroundImage: AssetImage('assets/Profile 2 (teacher).jpg'),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Samuel Prince',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '@samuel.prince123',
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    const SizedBox(height: 40),
                    // Tabs
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) => Navigator.of(context).widget,
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                            Navigator.pushNamed(context, '/instructor_profile_page');
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'General',
                            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 16),
                        TextButton(
                          onPressed: null, // Disabled because this is the current page
                          style: TextButton.styleFrom(
                            backgroundColor: Color(0xFF5271FF),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Badges',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Badges List
                    _badgeItem('Good Teacher', 'Awarded for consistently high student ratings and positive feedback.'),
                    _badgeItem('Patient', 'Recognized for taking time to help every student understand.'),
                    _badgeItem('Responsive', 'Quick to answer questions and provide support.'),
                    _badgeItem('Story Teller', 'Engages students with creative and memorable lessons.'),
                    _badgeItem('Famous', 'Popular among students and faculty for outstanding teaching.'),
                    const Spacer(),
                    // Log out
                    TextButton(
                      onPressed: () => _logout(context),
                      child: const Text(
                        'LOG OUT',
                        style: TextStyle(
                          color: Color(0xFF5271FF),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          // Add navigation logic if needed
        },
      ),
    );
  }

  Widget _badgeItem(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Image.asset(
            'assets/medal.png',
            width: 32,
            height: 32,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}
