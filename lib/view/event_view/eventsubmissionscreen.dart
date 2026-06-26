import 'package:firstedu/data/models/event_models.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_button.dart';
import 'package:firstedu/res/widgets/custom_card.dart';
import 'package:firstedu/res/widgets/custom_silverappbar.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:file_picker/file_picker.dart'; // Add this to pubspec.yaml

class EventSubmissionScreen extends StatefulWidget {
  final EventModel event;

  const EventSubmissionScreen({super.key, required this.event});

  @override
  State<EventSubmissionScreen> createState() => _EventSubmissionScreenState();
}

class _EventSubmissionScreenState extends State<EventSubmissionScreen> {
  final TextEditingController _essayController = TextEditingController();
  String? _uploadedFileName;
  int _wordCount = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _essayController.addListener(_updateWordCount);
  }

  @override
  void dispose() {
    _essayController.dispose();
    super.dispose();
  }

  void _updateWordCount() {
    final text = _essayController.text.trim();
    setState(() {
      _wordCount = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
    });
  }

  Future<void> _pickFile() async {
    // For demo purposes:
    setState(() {
      _uploadedFileName = "my_video.mp4";
    });
  }

  void _removeFile() {
    setState(() {
      _uploadedFileName = null;
    });
  }

  Future<void> _submitEntry() async {
    // Validation
    if (widget.event.type == EventType.written) {
      if (_essayController.text.trim().isEmpty) {
        AppToast.infoGlobal(message: "Please write something before submitting");
        return;
      }
      if (_wordCount < 50) {
        AppToast.infoGlobal(message: "Minimum 50 words required");
        return;
      }
    } else {
      if (_uploadedFileName == null) {
        AppToast.infoGlobal(message: "Please upload a file first");
        return;
      }
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isSubmitting = false);

    if (mounted) {
      _showSuccessDialog();
    }
  }



void _showSuccessDialog() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Padding(
        padding: EdgeInsets.all(28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated Success Icon
             Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow circle
                Container(
                  width: 120.w,
                  height: 120.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: successColor.withOpacity(0.1),
                  ),
                ),
                // Middle circle
                Container(
                  width: 95.w,
                  height: 95.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: successColor.withOpacity(0.2),
                  ),
                ),
                // Main success circle with gradient
                Container(
                  width: 75.w,
                  height: 75.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        successColor,
                        const Color(0xFF2EAF32),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: successColor.withOpacity(0.5),
                        blurRadius: 25.r,
                        offset: Offset(0, 10.h),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 45.sp,
                    weight: 700,
                  ),
                ),
             
             
              ],
            ),
           
            SizedBox(height: 24.h),
            
            // Title
            const CustomText(
              text: "Success!",
              size: 24,
              weight: FontWeight.w700,
              color: Colors.black87,
              align: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            
            // Message
            CustomText(
              text: "Your submission has been received successfully.",
              size: 14,
              color: Colors.grey.shade600,
              align: TextAlign.center,
              maxLines: 3,
            ),
            SizedBox(height: 28.h),
            
            // Done Button
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                title: "Done",
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                backgroundColor: drawerColor,
                textColor: Colors.white,
                height: 48.h,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
 
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: CustomScrollView(
        slivers: [
          CustomSliverAppBar(
            title: widget.event.title,
            subtitle: "${widget.event.category} • ${widget.event.date}",
          ),
          SliverPadding(
            padding: EdgeInsets.all(16.w),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildEventInfo(),
                SizedBox(height: 16.h),
                _buildSubmissionForm(),
                SizedBox(height: 100.h),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventInfo() {
    return CustomCard(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: drawerColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: drawerColor,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              const Expanded(
                child: CustomText(
                  text: "Event Details",
                  size: 16,
                  weight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          CustomText(
            text: widget.event.description,
            size: 14,
            color: Colors.grey.shade700,
            maxLines: 10,
            height: 1.5,
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16.sp,
                color: Colors.grey.shade600,
              ),
              SizedBox(width: 8.w),
              CustomText(
                text: "Due: ${widget.event.date}",
                size: 13,
                weight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionForm() {
    return CustomCard(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: activeItemColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  widget.event.type == EventType.written
                      ? Icons.edit_note
                      : Icons.file_upload_outlined,
                  color: activeItemColor,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CustomText(
                  text: widget.event.type == EventType.written
                      ? "Write Your Submission"
                      : "Upload Your Submission",
                  size: 16,
                  weight: FontWeight.w600,
                  color: Colors.black87,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          
          // Content
          widget.event.type == EventType.written
              ? _buildEssayField()
              : _buildUploadField(),
              
          SizedBox(height: 20.h),
          
          // Submit Button
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              title: _isSubmitting ? "Submitting..." : "Submit",
              onTap: _isSubmitting ? () {} : _submitEntry,
              backgroundColor: _isSubmitting ? Colors.grey : drawerColor,
              textColor: Colors.white,
              enabled: !_isSubmitting,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEssayField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _essayController,
          maxLines: 10,
          style: TextStyle(fontSize: 15.sp, height: 1.5),
          decoration: InputDecoration(
            hintText: "Start writing your submission here...",
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: EdgeInsets.all(16.w),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: drawerColor, width: 2),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Icon(
              _wordCount >= 50 ? Icons.check_circle : Icons.info,
              size: 16.sp,
              color: _wordCount >= 50 ? successColor : Colors.orange,
            ),
            SizedBox(width: 6.w),
            CustomText(
              text: "$_wordCount words ${_wordCount < 50 ? '(min. 50)' : ''}",
              size: 13,
              weight: FontWeight.w500,
              color: _wordCount >= 50 ? successColor : Colors.orange,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUploadField() {
    return Column(
      children: [
        if (_uploadedFileName == null)
          GestureDetector(
            onTap: _pickFile,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 40.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: activeItemColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.cloud_upload_outlined,
                      size: 40.sp,
                      color: activeItemColor,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  const CustomText(
                    text: "Click to Upload File",
                    size: 15,
                    weight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  SizedBox(height: 6.h),
                  CustomText(
                    text: "MP4, WEBM, MP3 (Max 500MB)",
                    size: 12,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: successColor, width: 2),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: const BoxDecoration(
                    color: successColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.insert_drive_file,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: _uploadedFileName!,
                        size: 14,
                        weight: FontWeight.w600,
                        color: Colors.black87,
                        maxLines: 2,
                      ),
                      SizedBox(height: 2.h),
                      const CustomText(
                        text: "Ready to submit",
                        size: 12,
                        color: successColor,
                        weight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _removeFile,
                  icon: const Icon(Icons.close, color: Colors.red),
                  iconSize: 22.sp,
                ),
              ],
            ),
          ),
      ],
    );
  }
}