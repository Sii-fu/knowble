import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/theme.dart';
import 'teacher_navbar.dart';
import 'home_teacher.dart';
import 'course_screen.dart';

class InstructorProfilePage extends StatefulWidget {
  const InstructorProfilePage({super.key});

  @override
  State<InstructorProfilePage> createState() => _InstructorProfilePageState();
}

class _InstructorProfilePageState extends State<InstructorProfilePage> {
  int _selectedIndex = 3;

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TeacherHomePage()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CourseScreen()),
      );
    } else if (index == 3) {
      // Already on profile
    }
  }

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Profile Image
            CircleAvatar(
              radius: 48,
              backgroundImage: AssetImage('assets/Profile 1 (teacher) (1).jpg'),
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
            const SizedBox(height: 32),
            // Tabs
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: null, // Disabled because this is the current page
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue[400],
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'General',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/instructor_profile_page2');
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue[50],
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Badges',
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Info List
            _profileItem(Icons.person, 'Name', 'Christina Angela', onEdit: () {}),
            _profileItem(Icons.email, 'Email', 'christina.angela123@mail.com', onEdit: () {}),
            _profileItem(Icons.lock, 'Password', 'Tap to Change Password', onEdit: () {}),
            _profileItem(Icons.phone_iphone, 'Phone Number', '(684) 555-0102', onEdit: () {}),
            _profileItem(Icons.credit_card, 'Payment', 'Tap to Change Payment', onEdit: () {}),
            _profileItem(Icons.verified_user, 'Privacy Policy', 'Tap to See Privacy Policy', trailingArrow: true, onEdit: () {}),
            const SizedBox(height: 32),
            // Log out
            TextButton(
              onPressed: () => _logout(context),
              child: const Text(
                'LOG OUT',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _profileItem(IconData icon, String title, String value, {bool trailingArrow = false, required VoidCallback onEdit}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue[400], size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),
          if (trailingArrow)
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
              onPressed: onEdit,
            )
          else
            TextButton(
              onPressed: onEdit,
              child: const Text('Edit', style: TextStyle(color: Colors.blue)),
            ),
        ],
      ),
    );
  }
}
