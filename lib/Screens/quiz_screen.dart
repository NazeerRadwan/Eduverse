// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';

// late List<CameraDescription> cameras;


// class ExamApp extends StatelessWidget {
//   const ExamApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'English Exam',
//       theme: ThemeData(useMaterial3: true, fontFamily: 'Roboto'),
//       home: const EnglishExamScreen(),
//     );
//   }
// }

// class EnglishExamScreen extends StatefulWidget {
//   const EnglishExamScreen({super.key});

//   @override
//   State<EnglishExamScreen> createState() => _EnglishExamScreenState();
// }

// class _EnglishExamScreenState extends State<EnglishExamScreen> {
//   late CameraController _cameraController;
//   bool _cameraReady = false;

//   final String _title = 'English Exam Three';
//   final int _questionIndex = 1;
//   final int _questionTotal = 2;

//   final List<String> _options = ['Thrilled', 'Fatigued', 'Curious', 'Relaxed'];
//   int? _selectedIndex;

//   // Warning points (3 active, 2 inactive)
//   final int _warningActive = 3;
//   final int _warningTotal = 5;

//   @override
//   void initState() {
//     super.initState();
//     // Try to use front camera if available
//     final CameraDescription cam = cameras.firstWhere(
//       (c) => c.lensDirection == CameraLensDirection.front,
//       orElse: () => cameras.first,
//     );
//     _cameraController = CameraController(
//       cam,
//       ResolutionPreset.low,
//       enableAudio: false,
//     );
//     _cameraController.initialize().then((_) {
//       if (!mounted) return;
//       setState(() => _cameraReady = true);
//     });
//   }

//   @override
//   void dispose() {
//     _cameraController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     const Color brandOrange = Color(0xFFFF8A00);
//     const Color brandRed = Color(0xFFE53935);
//     const Color greyText = Color(0xFF606060);
//     const Color cardBorder = Color(0xFFE6E6E6);
//     const double contentPadding = 16;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Stack(
//           children: [
//             // Main content
//             Padding(
//               //padding: const EdgeInsets.all(contentPadding),
//               padding: const EdgeInsets.only(
//                 left: contentPadding,
//                 right: contentPadding,
//                 top: 13,
//                 bottom: contentPadding,
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Top bar: Title + small warning points + question progress
//                   Row(
//                     children: [
//                       // Title on the left
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               _title,
//                               style: const TextStyle(
//                                 fontSize: 22,
//                                 fontWeight: FontWeight.w800,
//                                 color: Color(0xFF002E8A),
//                               ),
//                             ),
//                             const SizedBox(height: 10),
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.timer_outlined,
//                                   color: Color(0xFF002E8A),
//                                   size: 28,
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   //_formatDuration(_elapsed),
//                                   "27:46",
//                                   style: Theme.of(
//                                     context,
//                                   ).textTheme.headlineSmall?.copyWith(
//                                     color: Color(0xFF002E8A),
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 56),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       // Camera preview thumbnail (top-right)
//                       Container(
//                         height: 125,
//                         width: 155,
//                         child: _CameraThumbnail(
//                           cameraReady: _cameraReady,
//                           controller: _cameraController,
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 20),

//                   // Full-width warning panel (matches visual emphasis)
//                   Align(
//                     alignment: Alignment.centerLeft,
//                     child: SizedBox(
//                       // لو عايز العرض يكون نصف الشاشة
//                       width: MediaQuery.of(context).size.width * 0.55,

//                       // لو عايز العرض يكون على قد المحتوى فقط، استخدم بدل SizedBox:
//                       // child: IntrinsicWidth(
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 12,
//                         ),
//                         decoration: BoxDecoration(
//                           color: const Color.fromARGB(255, 134, 171, 246),
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(color: const Color(0xFF002E8A)),
//                         ),
//                         child: Column(
//                           crossAxisAlignment:
//                               CrossAxisAlignment.start, // مهم جداً
//                           children: [
//                             Row(
//                               children: List.generate(_warningTotal, (i) {
//                                 final bool active = i < _warningActive;
//                                 return Padding(
//                                   padding: EdgeInsets.only(
//                                     right: i == _warningTotal - 1 ? 12 : 8,
//                                   ),
//                                   child: Icon(
//                                     Icons.warning_amber_rounded,
//                                     size: 26,
//                                     color:
//                                         active
//                                             ? brandRed
//                                             : Colors.grey.shade400,
//                                   ),
//                                 );
//                               }),
//                             ),
//                             const Divider(
//                               color: Color(0xFF002E8A),
//                               height: 20,
//                               thickness: 2,
//                             ),
//                             const Text(
//                               'Warning Points',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w700,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 40),

//                   // Question text
//                   const Text(
//                     "7- Which word best replaces 'exhausted' in the sentence: 'After the long hike, she was exhausted'?",
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w800,
//                       height: 1.4,
//                     ),
//                   ),

//                   const SizedBox(height: 16),

//                   // Options list
//                   ...List.generate(_options.length, (index) {
//                     final bool isSelected = _selectedIndex == index;
//                     return Padding(
//                       padding: const EdgeInsets.only(bottom: 12),
//                       child: InkWell(
//                         borderRadius: BorderRadius.circular(12),
//                         onTap: () => setState(() => _selectedIndex = index),
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 14,
//                             vertical: 16,
//                           ),
//                           decoration: BoxDecoration(
//                             color:
//                                 isSelected
//                                     ? const Color.fromARGB(255, 134, 171, 246)
//                                     : Colors.white,
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(
//                               color:
//                                   isSelected ? Color(0xFF002E8A) : cardBorder,
//                               width: isSelected ? 2 : 1,
//                             ),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.04),
//                                 blurRadius: 8,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: Row(
//                             children: [
//                               Icon(
//                                 isSelected
//                                     ? Icons.radio_button_checked
//                                     : Icons.radio_button_off,
//                                 color:
//                                     isSelected
//                                         ? Color(0xFF002E8A)
//                                         : Colors.grey,
//                               ),
//                               const SizedBox(width: 12),
//                               Expanded(
//                                 child: Text(
//                                   _options[index],
//                                   style: const TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   }),

//                   const Spacer(),

//                   // Bottom-right Next button
//                   Row(
//                     children: [
//                       const Spacer(),
//                       ElevatedButton(
//                         onPressed: () {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                               content: Text(
//                                 _selectedIndex == null
//                                     ? 'اختر إجابة أولاً'
//                                     : 'تم اختيار: ${_options[_selectedIndex!]}',
//                               ),
//                             ),
//                           );
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Color(0xFF002E8A),
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 22,
//                             vertical: 12,
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           elevation: 0,
//                         ),
//                         child: const Text(
//                           'Next',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Separate widget for camera thumbnail to keep layout tidy
// class _CameraThumbnail extends StatelessWidget {
//   final bool cameraReady;
//   final CameraController controller;

//   const _CameraThumbnail({
//     super.key,
//     required this.cameraReady,
//     required this.controller,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 92,
//       height: 92,
//       decoration: BoxDecoration(
//         color: Colors.black,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFFE6E6E6)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       clipBehavior: Clip.antiAlias,
//       child:
//           cameraReady
//               ? CameraPreview(controller)
//               : const Center(
//                 child: SizedBox(
//                   width: 20,
//                   height: 20,
//                   child: CircularProgressIndicator(strokeWidth: 2),
//                 ),
//               ),
//     );
//   }
// }


