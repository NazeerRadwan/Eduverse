import 'package:flutter/material.dart';

class EduversesPage extends StatefulWidget {
  const EduversesPage({super.key});

  @override
  State<EduversesPage> createState() => _EduversesPageState();
}

class _EduversesPageState extends State<EduversesPage> {
  int _selectedIndex = 1;

  final List<Map<String, String>> _cards = [
    {
      'image': 'assets/Mohamed_Farouk.jpg',
      'left': '2rd Secondary',
      'title': 'Mohamed Farouk',
      'subtitle': 'English',
    },
    {
      'image': 'assets/Mustafa_Abdallah.jpg',
      'left': '3rd Secondary',
      'title': 'Mustafa Abdallah',
      'subtitle': 'Physics',
    },
    {
      'image': 'assets/Khaled_Helmy.jpg',
      'left': '1st Secondary',
      'title': 'Khaled Helmy',
      'subtitle': 'Chemistry',
    },
    // add more items if needed
  ];

  Widget _buildCard(Map<String, String> item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // <- added to align all text to left
        children: [
          // image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                item['image']!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: Colors.grey.shade100,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder:
                    (_, __, ___) => Container(
                      color: Colors.grey.shade100,
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 48,
                          color: Colors.grey,
                        ),
                      ),
                    ),
              ),
            ),
          ),
          // divider line
          Container(height: 1, color: Colors.grey.shade200),
          // content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start, // ensure inner column is left-aligned
              children: [
                Text(
                  item['left'] ?? '',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 12, color: Colors.black),
                ),
                const SizedBox(height: 6),
                Text(
                  item['title'] ?? '',
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item['subtitle'] ?? '',
                  textAlign: TextAlign.left,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /*Widget _bottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.feed_outlined, 'Feed', 0),
          _navItem(Icons.book_outlined, 'Eduverses', 1),
          _navItem(Icons.person_outline, 'Profile', 2),
          _navItem(Icons.settings_outlined, 'Settings', 3),
        ],
      ),
    );
  }*/

  Widget _navItem(IconData icon, String label, int index) {
    final selected = _selectedIndex == index;
    final color = selected ? Colors.purple.shade700 : Colors.grey.shade600;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            // top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  Material(
                    color: Colors.white,
                    shape: CircleBorder(
                      side: BorderSide(color: Colors.grey, width: 1),
                    ), // <- red border on back button
                    elevation: 0,
                    child: IconButton(
                      padding: const EdgeInsets.all(6),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                      ),
                      onPressed: () => Navigator.maybePop(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Row(
                      children: [
                        const SizedBox(width: 50),
                        Text(
                          'Your Eduverses',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF002E8A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 8),
                itemCount: _cards.length,
                itemBuilder: (context, i) => _buildCard(_cards[i]),
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: _bottomNav(),
    );
  }
}
