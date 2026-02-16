import 'package:flutter/material.dart';
import 'sign_in_page.dart';

class IndexPage extends StatelessWidget {
  const IndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(
              Icons.layers_outlined, 
              color: Color(0xFF2D5AF0),
              size: 28,
            ),
            const SizedBox(width: 8),
            const Text(
              'TrackDev',
              style: TextStyle(
                color: Color(0xFF1A2B49), 
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInPage()),
                );
              },
              label: const Text('Sign In'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D5AF0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Text(
              'Agile Project Management',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A2B49)),
            ),
            const Text(
              'for Education',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2D5AF0)),
            ),
            const SizedBox(height: 20),
            const Text(
              'TrackDev helps students learn agile methodologies by working together on real projects. Manage sprints, tasks, and track your team\'s progress.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.blueGrey, height: 1.5),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInPage()),
                );
              },
              icon: const Text('Sign In'),
              label: const Icon(Icons.arrow_forward, size: 18),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D5AF0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 50),
            
            _buildFeatureCard(
              Icons.layers_outlined,
              'Sprint Management',
              'Plan and track sprints with your team. Visualize progress with burn-down charts and sprint boards.',
              const Color(0xFFE8F0FE),
            ),
            _buildFeatureCard(
              Icons.check_circle_outline,
              'Task Tracking',
              'Create user stories and tasks. Track status, assign members, and estimate points for each item.',
              const Color(0xFFE8F0FE),
            ),
            _buildFeatureCard(
              Icons.groups_outlined,
              'Team Collaboration',
              'Work together with your team members. Comment on tasks, track history, and review contributions.',
              const Color(0xFFE8F0FE),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String description, Color bgColor) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: const Color(0xFF2D5AF0), size: 30),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A2B49))),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(fontSize: 14, color: Colors.blueGrey, height: 1.4)),
        ],
      ),
    );
  }
}