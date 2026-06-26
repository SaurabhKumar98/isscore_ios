// // ─── lib/presentation/screens/report/report_hub_screen.dart ──────────────────
// //
// // Entry point added to the drawer under "Teacher Connect" or as its own item.
// // Hosts Chat Report and Call Report as two tabs.

// import 'package:firstedu/view/report_screen/call_report_list_screen.dart';
// import 'package:firstedu/view/report_screen/chat_report_list_screen.dart';
// import 'package:firstedu/view_models/report/call_report_provider.dart';
// import 'package:firstedu/view_models/report/chat_report_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';


// class ReportHubScreen extends StatelessWidget {
//   const ReportHubScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(
//           create: (_) => ChatReportProvider(
//             repo: context.read(), // ReportRepository from top-level provider
//           )..fetchConversations(),
//         ),
//         ChangeNotifierProvider(
//           create: (_) => CallReportProvider(
//             repo: context.read(),
//           )..fetchTeachers(),
//         ),
//       ],
//       child: DefaultTabController(
//         length: 2,
//         child: Scaffold(
//           backgroundColor: const Color(0xFFF6F8FF),
//           appBar: AppBar(
//             backgroundColor: Colors.white,
//             elevation: 0,
//             centerTitle: false,
//             title: const Text(
//               'Reports',
//               style: TextStyle(
//                 color: Color(0xFF1A1D2E),
//                 fontSize: 20,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//             iconTheme: const IconThemeData(color: Color(0xFF1A1D2E)),
//             bottom: PreferredSize(
//               preferredSize: const Size.fromHeight(48),
//               child: Container(
//                 margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFF0F1F8),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: TabBar(
//                   indicator: BoxDecoration(
//                     color: const Color(0xFF4361EE),
//                     borderRadius: BorderRadius.circular(10),
//                     boxShadow: [
//                       BoxShadow(
//                         color: const Color(0xFF4361EE).withOpacity(0.3),
//                         blurRadius: 8,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   indicatorSize: TabBarIndicatorSize.tab,
//                   labelColor: Colors.white,
//                   unselectedLabelColor: const Color(0xFF6B7080),
//                   labelStyle: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                   ),
//                   unselectedLabelStyle: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                   tabs: const [
//                     Tab(
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.chat_bubble_outline, size: 16),
//                           SizedBox(width: 6),
//                           Text('Chat Report'),
//                         ],
//                       ),
//                     ),
//                     Tab(
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.mic_none_rounded, size: 16),
//                           SizedBox(width: 6),
//                           Text('Call Report'),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           body: const TabBarView(
//             children: [
//               ChatReportListScreen(),
//               CallReportListScreen(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }