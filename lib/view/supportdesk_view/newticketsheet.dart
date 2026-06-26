// import 'package:firstedu/res/constants/colors/appcolors.dart';
// import 'package:firstedu/res/widgets/custom_button.dart';
// import 'package:firstedu/res/widgets/custom_text.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class NewTicketSheet extends StatefulWidget {
//   const NewTicketSheet({super.key});

//   @override
//   State<NewTicketSheet> createState() => _NewTicketSheetState();
// }

// class _NewTicketSheetState extends State<NewTicketSheet> {
//   final TextEditingController _subjectController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();

//   @override
//   void dispose() {
//     _subjectController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.only(
//         left: 20.w,
//         right: 20.w,
//         top: 24.h,
//         bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
//       ),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Expanded(
//                 child: CustomText(
//                   text: "Submit a New Request",
//                   size: 20,
//                   weight: FontWeight.w700,
//                   color: Colors.black87,
//                 ),
//               ),
//               IconButton(
//                 icon: Icon(Icons.close_rounded, size: 24.sp),
//                 onPressed: () => Navigator.pop(context),
//                 padding: EdgeInsets.zero,
//               ),
//             ],
//           ),
//           SizedBox(height: 24.h),

//           const CustomText(
//             text: "SUBJECT",
//             size: 12,
//             weight: FontWeight.w700,
//             color: Colors.grey,
//           ),
//           SizedBox(height: 8.h),
//           _buildTextField(
//             controller: _subjectController,
//             hint: "Brief description of your issue",
//             maxLines: 1,
//           ),

//           SizedBox(height: 20.h),

//           const CustomText(
//             text: "DESCRIBE YOUR PROBLEM",
//             size: 12,
//             weight: FontWeight.w700,
//             color: Colors.grey,
//           ),
//           SizedBox(height: 8.h),
//           _buildTextField(
//             controller: _descriptionController,
//             hint: "Provide details so we can help you faster...",
//             maxLines: 5,
//           ),

//           SizedBox(height: 28.h),

//           Row(
//             children: [
//               Expanded(
//                 child: CustomButton(
//                   title: "Cancel",
//                   onTap: () => Navigator.pop(context),
//                   primary: false,
//                   backgroundColor: Colors.white,
//                   textColor: Colors.grey.shade700,
//                   borderColor: Colors.grey.shade300,
//                   height: 50.h,
//                 ),
//               ),
//               SizedBox(width: 12.w),
//               Expanded(
//                 child: CustomButton(
//                   title: "Submit",
//                   onTap: () => Navigator.pop(context),
//                   backgroundColor: drawerColor,
//                   textColor: Colors.white,
//                   height: 50.h,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String hint,
//     required int maxLines,
//   }) {
//     return TextField(
//       controller: controller,
//       maxLines: maxLines,
//       style: TextStyle(fontSize: 15.sp),
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle: TextStyle(color: Colors.grey.shade400),
//         filled: true,
//         fillColor: Colors.grey.shade50,
//         contentPadding: EdgeInsets.all(16.w),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12.r),
//           borderSide: BorderSide(color: Colors.grey.shade300),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12.r),
//           borderSide: BorderSide(color: Colors.grey.shade300),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12.r),
//           borderSide: BorderSide(color: drawerColor, width: 2),
//         ),
//       ),
//     );
//   }
// }
