import 'package:flutter/material.dart';
import '../services/classes_service.dart';

class EduversesPage extends StatefulWidget {
  const EduversesPage({super.key});

  @override
  State<EduversesPage> createState() => _EduversesPageState();
}

class _EduversesPageState extends State<EduversesPage> {
  late Future<Map<String, dynamic>> _classesData;

  @override
  void initState() {
    super.initState();
    _classesData = ClassesService.getMyClasses();
  }

  Widget _buildCard(Map<String, dynamic> item) {
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
              child: Image.asset(
                'assets/Mohamed_Farouk.jpg',
                fit: BoxFit.cover,
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
                  item['className'] ?? '',
                  textAlign: TextAlign.left,
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                ),
                const SizedBox(height: 6),
                Text(
                  item['instructorName'] ?? '',
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item['classDescription'] ?? '',
                  textAlign: TextAlign.left,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
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
              child: FutureBuilder<Map<String, dynamic>>(
                future: _classesData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.blue.shade700,
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading classes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.red.shade700,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _classesData = ClassesService.getMyClasses();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A3C7B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Retry',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData ||
                      snapshot.data!['success'] != true) {
                    return Center(
                      child: Text(
                        snapshot.data?['message'] ?? 'Failed to load classes',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    );
                  } else {
                    final List<Map<String, dynamic>> classes =
                        (snapshot.data!['data'] as List).cast();

                    if (classes.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.menu_book_outlined,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No Classes Yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 8),
                      itemCount: classes.length,
                      itemBuilder: (context, i) => _buildCard(classes[i]),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: _bottomNav(),
    );
  }
}
