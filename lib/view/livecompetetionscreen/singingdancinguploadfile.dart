import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firstedu/data/models/api_models/livecompetetion/livecompetionmodels.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:firstedu/view_models/livecompetetionprovider/livecompetetiondetailsprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FileUploadScreen extends StatefulWidget {
  final LiveCompetition competition;
  final String round;

  const FileUploadScreen({
    required this.competition,
    required this.round,
    super.key,
  });

  @override
  State<FileUploadScreen> createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  File? _pickedFile;
  String? _fileName;
  bool _isSubmitting = false;

  LiveCompetition get comp => widget.competition;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _pickedFile = File(result.files.single.path!);
        _fileName = result.files.single.name;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_pickedFile == null) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(
      //       'Please select a file first.',
      //       style: GoogleFonts.poppins(),
      //     ),
      //     backgroundColor: Colors.orange,
      //     behavior: SnackBarBehavior.floating,
      //   ),
      // );
      AppToast.warning(context, message:'Please select a file first.' );
      return;
    }

    final confirmed = await _confirmSubmit();
    if (!confirmed) return;

    setState(() => _isSubmitting = true);

    final provider = context.read<LiveCompetitionProvider>();
    final ok = await provider.submitWork(
      context,
      competitionId: comp.id!,
      round: widget.round,
      fileList: [_pickedFile!],
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (ok) {
      _showSuccess();
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(
      //       provider.singleError ?? 'Submission failed. Please try again.',
      //       style: GoogleFonts.poppins(),
      //     ),
      //     backgroundColor: Colors.red,
      //     behavior: SnackBarBehavior.floating,
      //   ),
      // );
      AppToast.warningGlobal(message:provider.singleError ?? 'Submission failed. Please try again.', );
    }
  }

  Future<bool> _confirmSubmit() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Submit File?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Once submitted, you cannot change your file. Are you sure?',
          style: GoogleFonts.poppins(fontSize: 13.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Submit',
              style: GoogleFonts.poppins(
                color: Colors.blue,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Column(
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 56.sp,
              color: Colors.green[600],
            ),
            SizedBox(height: 12.h),
            Text(
              'Submitted!',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Colors.green[700],
              ),
            ),
          ],
        ),
        content: Text(
          'Your file has been submitted successfully. Results will be announced soon.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black54),
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // close dialog
                Navigator.of(context).pop(); // back to detail
                Navigator.of(context).pop(); // back to list
              },
              child: Text(
                'Done',
                style: GoogleFonts.poppins(
                  color: activeItemColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: drawerColor,
        foregroundColor: Colors.white,
        title: Text(
          comp.title ?? 'Upload Submission',
          style: GoogleFonts.poppins(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Info Card ──────────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue[700],
                    size: 20.sp,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'Upload your file (video, audio, image, etc.) to complete your submission.',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 28.h),

            // ── File Picker ────────────────────────────────────
            GestureDetector(
              onTap: _isSubmitting ? null : _pickFile,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: _pickedFile != null
                        ? Colors.green.shade400
                        : Colors.grey.shade300,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _pickedFile != null
                          ? Icons.check_circle_rounded
                          : Icons.upload_file_rounded,
                      size: 48.sp,
                      color: _pickedFile != null
                          ? Colors.green
                          : Colors.grey[400],
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      _pickedFile != null
                          ? _fileName ?? 'File selected'
                          : 'Tap to select a file',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: _pickedFile != null
                            ? Colors.green[700]
                            : Colors.grey[500],
                      ),
                    ),
                    if (_pickedFile != null) ...[
                      SizedBox(height: 6.h),
                      TextButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => setState(() {
                                _pickedFile = null;
                                _fileName = null;
                              }),
                        child: Text(
                          'Change file',
                          style: GoogleFonts.poppins(
                            color: Colors.blue,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const Spacer(),

            // ── Submit Button ──────────────────────────────────
            GestureDetector(
              onTap: _isSubmitting ? null : _handleSubmit,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                height: 54.h,
                decoration: BoxDecoration(
                  color: _pickedFile == null || _isSubmitting
                      ? Colors.grey[300]
                      : Colors.blue,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: _pickedFile == null || _isSubmitting
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                ),
                child: Center(
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.cloud_upload_rounded,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Submit File',
                              style: GoogleFonts.poppins(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
