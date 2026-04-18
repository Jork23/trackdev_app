import 'package:flutter/material.dart';
import 'sign_in_page.dart';
import '../../utils/theme.dart';
import '../../utils/translations.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> with ThemePage {

  Widget _buildFeatureCard(IconData icon, String title, String description, Color bgColor) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor, 
              borderRadius: BorderRadius.circular(8)
            ),
            child: Icon(icon, color: const Color(0xFF2D5AF0), size: 30),
          ),
          const SizedBox(height: 16),
          Text(
            title, 
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold, 
              color: textColor
            )
          ),
          const SizedBox(height: 8),
          Text(
            description, 
            style: TextStyle(
              fontSize: 14, 
              color: subtitleColor, 
              height: 1.4
            )
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Row(
          children: [
            const Icon(
              Icons.layers_outlined, 
              color: Color(0xFF2D5AF0),
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              'TrackDev',
              style: TextStyle(
                color: textColor, 
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignInPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D5AF0),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: Text(
              Translations.get('index_page1', currentLang),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold
              ),
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
            Text(
              Translations.get('index_page2', currentLang),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28, 
                fontWeight: FontWeight.bold, 
                color: textColor
              ),
            ),
            Text(
              Translations.get('index_page3', currentLang),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28, 
                fontWeight: FontWeight.bold, 
                color: Color(0xFF2D5AF0)
              ),
            ),
            const SizedBox(height: 20),
            Text(
              Translations.get('index_page4', currentLang),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16, 
                color: subtitleColor, 
                height: 1.5
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignInPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D5AF0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: Text(
                  Translations.get('index_page1', currentLang),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),           
            _buildFeatureCard(
              Icons.layers_outlined,
              Translations.get('index_page5', currentLang),
              Translations.get('index_page6', currentLang),
              const Color(0xFFE8F0FE),
            ),
            _buildFeatureCard(
              Icons.check_circle_outline,
              Translations.get('index_page7', currentLang),
              Translations.get('index_page8', currentLang),
              const Color(0xFFE8F0FE),
            ),
            _buildFeatureCard(
              Icons.groups_outlined,
              Translations.get('index_page9', currentLang),
              Translations.get('index_page10', currentLang),
              const Color(0xFFE8F0FE),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}