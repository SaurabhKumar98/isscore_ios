import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firstedu/data/models/api_models/teacherconnect/chatmessage.dart'
    hide ChatStatus;
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:firstedu/view_models/teacherconnectprovider/chatprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final String teacherId;
  final String teacherName;
  final String? teacherImage;

  const ChatScreen({
    super.key,
    required this.teacherId,
    required this.teacherName,
    this.teacherImage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().requestChat(
        teacherId: widget.teacherId,
        teacherName: widget.teacherName,
      );
    });
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<bool> _handleBackPress(BuildContext context, ChatProvider chat) async {
    if (chat.isEnded || chat.isIdle) {
      chat.reset();
      return true;
    }

    if (chat.isRequesting) {
      final ok = await _showConfirmDialog(
        context,
        title: "Cancel Request?",
        message: "Are you sure you want to cancel the chat request?",
        confirmLabel: "Cancel Request",
      );
      if (ok == true) {
        chat.cancelRequest();
        return true;
      }
      return false;
    }
if (chat.isActive) {
  final ok = await _showConfirmDialog(
    context,
    title: "End Chat?",
    message: "Are you sure you want to end this chat session?",
    confirmLabel: "End Chat",
  );
  if (ok == true) {
    await chat.endChat();   // ✅ wait for server confirmation
    return false;
  }
  return false;
}

    return true;
  }

  Future<bool?> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16.sp),
        ),
        content: Text(
          message,
          style: TextStyle(fontSize: 13.sp, color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Stay"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              confirmLabel,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _showAttachmentOptions(ChatProvider chat) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              _AttachOption(
                icon: Icons.photo_camera_rounded,
                label: "Camera",
                color: drawerColor,
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(chat, ImageSource.camera);
                },
              ),
              _AttachOption(
                icon: Icons.photo_library_rounded,
                label: "Photo Library",
                color: Colors.purple,
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(chat, ImageSource.gallery);
                },
              ),
              _AttachOption(
                icon: Icons.insert_drive_file_rounded,
                label: "Document",
                color: accentOrange,
                onTap: () {
                  Navigator.pop(context);
                  _pickDocument(chat);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ChatProvider chat, ImageSource source) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1920,
    );
    if (xFile == null) return;

    final file = File(xFile.path);
    await chat.sendFile(
      file: file,
      fileName: p.basename(xFile.path),
      fileType: MessageFileType.image,
    );
  }

  Future<void> _pickDocument(ChatProvider chat) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'txt',
        'xls',
        'xlsx',
        'ppt',
        'pptx',
      ],
    );
    if (result == null || result.files.single.path == null) return;

    final path = result.files.single.path!;
    final name = result.files.single.name;
    await chat.sendFile(
      file: File(path),
      fileName: name,
      fileType: MessageFileType.document,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chat, _) {
        if (chat.isActive && chat.messages.isNotEmpty) _scrollToBottom();

        return WillPopScope(
          onWillPop: () async => _handleBackPress(context, chat),
          child: Scaffold(
            backgroundColor: const Color(0xFFF6F7FB),
            appBar: _buildAppBar(context, chat),
            body: _buildBody(context, chat),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ChatProvider chat) {
    return AppBar(
      backgroundColor: drawerColor,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        onPressed: () async {
          final canPop = await _handleBackPress(context, chat);
          if (canPop && context.mounted) Navigator.pop(context);
        },
      ),
      title: Row(
        children: [
          _TeacherAvatar(
            imageUrl: widget.teacherImage,
            isOnline: chat.isActive || chat.isRequesting,
            size: 36,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: widget.teacherName,
                  size: 15,
                  weight: FontWeight.w700,
                  color: Colors.white,
                  maxLines: 1,
                ),
                CustomText(
                  text: _statusLabel(chat.status),
                  size: 11,
                  weight: FontWeight.w500,
                  color: Colors.white60,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
      if (chat.isActive)
  IconButton(
    icon: const Icon(Icons.call_end_rounded, color: Colors.redAccent),
    onPressed: () async {
      final ok = await _showConfirmDialog(
        context,
        title: "End Chat?",
        message: "Are you sure you want to end this session?",
        confirmLabel: "End",
      );
      if (ok == true) await chat.endChat();   // ✅ wait for server confirmation
    },
  ),
      ],
    );
  }

  String _statusLabel(ChatStatus status) {
    switch (status) {
      case ChatStatus.requesting:
        return "Waiting for response...";
      case ChatStatus.joining:
        return "Connecting...";
      case ChatStatus.active:
        return "Connected";
      case ChatStatus.ended:
        return "Session ended";
      case ChatStatus.idle:
        return "";
    }
  }

  Widget _buildBody(BuildContext context, ChatProvider chat) {
    switch (chat.status) {
      case ChatStatus.idle:
      case ChatStatus.requesting:
      case ChatStatus.joining:
        return _RequestingView(
          teacherName: widget.teacherName,
          status: chat.status,
          errorMessage: chat.errorMessage,
          onCancel: () {
            chat.cancelRequest();
            Navigator.pop(context);
          },
          onDismissError: () {
            chat.reset();
            Navigator.pop(context);
          },
        );

      case ChatStatus.active:
        return _ActiveChatView(
          messages: chat.messages,
          scrollCtrl: _scrollCtrl,
          textCtrl: _textCtrl,
          isUploadingFile: chat.isUploadingFile,
          uploadError: chat.uploadError,
          onSend: (text) {
            chat.sendMessage(text);
            _textCtrl.clear();
          },
          onAttach: () => _showAttachmentOptions(chat),
        );

      case ChatStatus.ended:
        return _SessionEndedView(
          reason: chat.endReason,
          billedMinutes: chat.billedMinutes,
          onClose: () {
            chat.reset();
            Navigator.pop(context);
          },
        );
    }
  }
}

class _RequestingView extends StatelessWidget {
  final String teacherName;
  final ChatStatus status;
  final String? errorMessage;
  final VoidCallback onCancel;
  final VoidCallback onDismissError;

  const _RequestingView({
    required this.teacherName,
    required this.status,
    required this.errorMessage,
    required this.onCancel,
    required this.onDismissError,
  });

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null && status == ChatStatus.idle) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 64.sp),
              SizedBox(height: 16.h),
              CustomText(
                text: "Request Declined",
                size: 20,
                weight: FontWeight.w800,
                color: Colors.black87,
                align: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              CustomText(
                text: errorMessage!,
                size: 13,
                weight: FontWeight.w400,
                color: Colors.black45,
                align: TextAlign.center,
                maxLines: 4,
              ),
              SizedBox(height: 28.h),
              SizedBox(
                width: double.infinity,
                child: _PrimaryButton(
                  label: "Go Back",
                  onTap: onDismissError,
                  color: drawerColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PulseCircle(),
            SizedBox(height: 28.h),
            CustomText(
              text: status == ChatStatus.joining
                  ? "Connecting..."
                  : "Waiting for $teacherName",
              size: 20,
              weight: FontWeight.w800,
              color: Colors.black87,
              align: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            CustomText(
              text: status == ChatStatus.joining
                  ? "Setting up your session..."
                  : "Your request has been sent. Please wait while the teacher reviews it.",
              size: 13,
              weight: FontWeight.w400,
              color: Colors.black45,
              align: TextAlign.center,
              maxLines: 3,
            ),
            SizedBox(height: 32.h),
            if (status == ChatStatus.requesting)
              SizedBox(
                width: double.infinity,
                child: _OutlineButton(
                  label: "Cancel Request",
                  icon: Icons.close_rounded,
                  onTap: onCancel,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActiveChatView extends StatelessWidget {
  final List<ChatMessage> messages;
  final ScrollController scrollCtrl;
  final TextEditingController textCtrl;
  final bool isUploadingFile;
  final String? uploadError;
  final void Function(String) onSend;
  final VoidCallback onAttach;

  const _ActiveChatView({
    required this.messages,
    required this.scrollCtrl,
    required this.textCtrl,
    required this.isUploadingFile,
    required this.uploadError,
    required this.onSend,
    required this.onAttach,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isUploadingFile)
          LinearProgressIndicator(
            minHeight: 2.h,
            backgroundColor: drawerColor.withOpacity(.1),
            color: drawerColor,
          ),

        if (uploadError != null)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            color: Colors.redAccent.withOpacity(.1),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 14.sp,
                  color: Colors.redAccent,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: CustomText(
                    text: uploadError!,
                    size: 12,
                    weight: FontWeight.w500,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),

        // Message list
        Expanded(
          child: messages.isEmpty
              ? Center(
                  child: CustomText(
                    text: "Session started. Say hello! 👋",
                    size: 13,
                    weight: FontWeight.w500,
                    color: Colors.black38,
                    align: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  controller: scrollCtrl,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (_, i) => _MessageBubble(msg: messages[i]),
                ),
        ),

        // Input bar
        _ChatInputBar(
          controller: textCtrl,
          onSend: onSend,
          onAttach: onAttach,
          disabled: isUploadingFile,
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage msg;
  const _MessageBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final isMine = msg.isMine;

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: isMine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine) ...[
            CircleAvatar(
              radius: 14.r,
              backgroundColor: drawerColor.withOpacity(.1),
              child: Icon(Icons.person, size: 14.sp, color: drawerColor),
            ),
            SizedBox(width: 6.w),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              decoration: BoxDecoration(
                color: isMine ? drawerColor : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: Radius.circular(isMine ? 16.r : 4.r),
                  bottomRight: Radius.circular(isMine ? 4.r : 16.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: Radius.circular(isMine ? 16.r : 4.r),
                  bottomRight: Radius.circular(isMine ? 4.r : 16.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (msg.hasFile)
                      msg.isImage
                          ? _ImageAttachment(msg: msg, isMine: isMine)
                          : _DocumentAttachment(msg: msg, isMine: isMine),

                    if (msg.text.trim().isNotEmpty)
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          14.w,
                          msg.hasFile ? 6.h : 10.h,
                          14.w,
                          4.h,
                        ),
                        child: CustomText(
                          text: msg.text,
                          size: 14,
                          weight: FontWeight.w400,
                          color: isMine ? Colors.white : Colors.black87,
                          maxLines: 100,
                          height: 1.5,
                        ),
                      ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 8.h),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: isMine
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          CustomText(
                            text: _formatTime(msg.sentAt),
                            size: 10,
                            weight: FontWeight.w400,
                            color: isMine ? Colors.white54 : Colors.black38,
                          ),
                          if (isMine) ...[
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.done_all_rounded,
                              size: 12.sp,
                              color: Colors.white54,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) =>
      "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
}

class _ImageAttachment extends StatelessWidget {
  final ChatMessage msg;
  final bool isMine;

  const _ImageAttachment({required this.msg, required this.isMine});

  bool get _isLocal => msg.fileUrl != null && !msg.fileUrl!.startsWith('http');

  @override
  Widget build(BuildContext context) {
    final imageWidget = _isLocal
        ? Image.file(
            File(msg.fileUrl!),
            width: double.infinity,
            height: 180.h,
            fit: BoxFit.cover,
          )
        : Image.network(
            msg.fileUrl!,
            width: double.infinity,
            height: 180.h,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, prog) => prog == null
                ? child
                : SizedBox(
                    height: 180.h,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: prog.expectedTotalBytes != null
                            ? prog.cumulativeBytesLoaded /
                                  prog.expectedTotalBytes!
                            : null,
                        color: isMine ? Colors.white : drawerColor,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
            errorBuilder: (_, __, ___) => _errorBox(),
          );

    return GestureDetector(
      onTap: () => _viewFullImage(context),
      onLongPress: _isLocal ? null : () => _downloadFile(context),
      child: Stack(
        children: [
          imageWidget,
          if (!_isLocal)
            Positioned(
              bottom: 6.h,
              right: 6.w,
              child: GestureDetector(
                onTap: () => _downloadFile(context),
                child: Container(
                  padding: EdgeInsets.all(5.w),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Icon(
                    Icons.download_rounded,
                    size: 16.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          // Uploading overlay
          if (_isLocal)
            Positioned.fill(
              child: Container(
                color: Colors.black26,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _viewFullImage(BuildContext context) {
    if (_isLocal) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullImageViewer(
          url: msg.fileUrl!,
          fileName: msg.fileName ?? 'image',
        ),
      ),
    );
  }

  Future<void> _downloadFile(BuildContext context) async {
    if (_isLocal || msg.fileUrl == null) return;
    await _FileDownloader.downloadAndOpen(
      context: context,
      url: msg.fileUrl!,
      fileName: msg.fileName ?? 'image.jpg',
    );
  }

  Widget _errorBox() => Container(
    height: 80.h,
    color: Colors.black12,
    child: Center(
      child: Icon(
        Icons.broken_image_rounded,
        size: 32.sp,
        color: Colors.black26,
      ),
    ),
  );
}

class _DocumentAttachment extends StatelessWidget {
  final ChatMessage msg;
  final bool isMine;

  const _DocumentAttachment({required this.msg, required this.isMine});

  bool get _isLocal => msg.fileUrl != null && !msg.fileUrl!.startsWith('http');

  String get _ext {
    final name = msg.fileName ?? msg.fileUrl ?? '';
    return p.extension(name).replaceFirst('.', '').toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isLocal ? null : () => _downloadAndOpen(context),
      child: Container(
        padding: EdgeInsets.all(12.w),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // File icon
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: isMine
                    ? Colors.white.withOpacity(.15)
                    : drawerColor.withOpacity(.08),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: _isLocal
                  ? Center(
                      child: SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: isMine ? Colors.white70 : drawerColor,
                        ),
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.insert_drive_file_rounded,
                            size: 20.sp,
                            color: isMine ? Colors.white70 : drawerColor,
                          ),
                          if (_ext.isNotEmpty)
                            Text(
                              _ext,
                              style: TextStyle(
                                fontSize: 7.sp,
                                fontWeight: FontWeight.w800,
                                color: isMine ? Colors.white60 : drawerColor,
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
            SizedBox(width: 10.w),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: msg.fileName ?? "Document",
                    size: 13,
                    weight: FontWeight.w600,
                    color: isMine ? Colors.white : Colors.black87,
                    maxLines: 2,
                  ),
                  SizedBox(height: 2.h),
                  CustomText(
                    text: _isLocal ? "Uploading..." : "Tap to download",
                    size: 10,
                    weight: FontWeight.w400,
                    color: isMine ? Colors.white54 : Colors.black38,
                  ),
                ],
              ),
            ),
            SizedBox(width: 6.w),
            if (!_isLocal)
              Icon(
                Icons.download_rounded,
                size: 18.sp,
                color: isMine ? Colors.white54 : Colors.black38,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadAndOpen(BuildContext context) async {
    if (msg.fileUrl == null) return;
    await _FileDownloader.downloadAndOpen(
      context: context,
      url: msg.fileUrl!,
      fileName: msg.fileName ?? 'document',
    );
  }
}

class _FileDownloader {
  static Future<void> downloadAndOpen({
    required BuildContext context,
    required String url,
    required String fileName,
  }) async {
    // Show loading snackbar
    if (context.mounted) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Row(
      //       children: [
      //         SizedBox(
      //           width: 16,
      //           height: 16,
      //           child: CircularProgressIndicator(
      //             strokeWidth: 2,
      //             color: Colors.white,
      //           ),
      //         ),
      //         const SizedBox(width: 12),
      //         Expanded(child: Text("Downloading $fileName…")),
      //       ],
      //     ),
      //     duration: const Duration(seconds: 60),
      //   ),
      // );
    AppToast.success(context, message: "Downloading $fileName…");
    
    }

    try {
      // 1. Download bytes via Dio (same as DownloadsScreen)
      final response = await Dio().get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      // 2. Save via the same MethodChannel used in DownloadsScreen
      const platform = MethodChannel('download_channel');
      await platform.invokeMethod('saveFile', {
        "fileName": fileName,
        "bytes": response.data,
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Saved to Downloads: $fileName"),
            action: SnackBarAction(
              label: "Open",
              onPressed: () async {
                // Try to open from the public Downloads folder
                final path = '/storage/emulated/0/Download/$fileName';
                final result = await OpenFile.open(path);
                if (result.type != ResultType.done) {
                  debugPrint("Open failed: ${result.message}");
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("❌ Download error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Download failed: ${e.toString()}")),
        );
      }
    }
  }
}
// ─────────────────── FULL IMAGE VIEWER ──────────────────────────────────────

class _FullImageViewer extends StatelessWidget {
  final String url;
  final String fileName;

  const _FullImageViewer({required this.url, required this.fileName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(fileName, style: TextStyle(fontSize: 14.sp)),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () => _FileDownloader.downloadAndOpen(
              context: context,
              url: url,
              fileName: fileName,
            ),
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            url,
            fit: BoxFit.contain,
            loadingBuilder: (_, child, prog) => prog == null
                ? child
                : Center(
                    child: CircularProgressIndicator(
                      value: prog.expectedTotalBytes != null
                          ? prog.cumulativeBytesLoaded /
                                prog.expectedTotalBytes!
                          : null,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────── CHAT INPUT BAR ─────────────────────────────────────────

class _ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String) onSend;
  final VoidCallback onAttach;
  final bool disabled;

  const _ChatInputBar({
    required this.controller,
    required this.onSend,
    required this.onAttach,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Attach button
          GestureDetector(
            onTap: disabled ? null : onAttach,
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: drawerColor.withOpacity(disabled ? .05 : .08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.attach_file_rounded,
                size: 20.sp,
                color: disabled ? Colors.black26 : drawerColor,
              ),
            ),
          ),
          SizedBox(width: 8.w),

          // Text field
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: 4,
              minLines: 1,
              enabled: !disabled,
              textInputAction: TextInputAction.send,
              onSubmitted: (v) {
                if (v.trim().isNotEmpty) onSend(v);
              },
              decoration: InputDecoration(
                hintText: disabled ? "Uploading file…" : "Type a message...",
                hintStyle: TextStyle(color: Colors.black38, fontSize: 13.sp),
                filled: true,
                fillColor: const Color(0xFFF6F7FB),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),

          // Send button
          GestureDetector(
            onTap: disabled
                ? null
                : () {
                    final text = controller.text;
                    if (text.trim().isNotEmpty) onSend(text);
                  },
            child: Container(
              width: 46.w,
              height: 46.w,
              decoration: BoxDecoration(
                color: disabled ? Colors.black12 : drawerColor,
                shape: BoxShape.circle,
                boxShadow: disabled
                    ? []
                    : [
                        BoxShadow(
                          color: drawerColor.withOpacity(.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Icon(
                Icons.send_rounded,
                color: disabled ? Colors.black26 : Colors.white,
                size: 20.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────── ATTACH OPTION ──────────────────────────────────────────

class _AttachOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: color.withOpacity(.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, color: color, size: 20.sp),
      ),
      title: Text(
        label,
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
    );
  }
}

// ─────────────────── SESSION ENDED VIEW ─────────────────────────────────────

class _SessionEndedView extends StatelessWidget {
  final String? reason;
  final int billedMinutes;
  final VoidCallback onClose;

  const _SessionEndedView({
    required this.reason,
    required this.billedMinutes,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: drawerColor.withOpacity(.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 36.sp,
                color: drawerColor,
              ),
            ),
            SizedBox(height: 20.h),
            CustomText(
              text: "Session Ended",
              size: 22,
              weight: FontWeight.w800,
              color: Colors.black87,
              align: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            if (reason != null)
              CustomText(
                text: _readableReason(reason!),
                size: 13,
                weight: FontWeight.w400,
                color: Colors.black45,
                align: TextAlign.center,
                maxLines: 3,
              ),
            if (billedMinutes > 0) ...[
              SizedBox(height: 20.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: accentOrange.withOpacity(.08),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: accentOrange.withOpacity(.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 18.sp,
                      color: accentOrange,
                    ),
                    SizedBox(width: 8.w),
                    CustomText(
                      text: "$billedMinutes min billed",
                      size: 13,
                      weight: FontWeight.w700,
                      color: accentOrange,
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              child: _PrimaryButton(
                label: "Back to Mentors",
                onTap: onClose,
                color: drawerColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _readableReason(String reason) {
    switch (reason) {
      case 'student_disconnected':
        return "You were disconnected from the session.";
      case 'teacher_disconnected':
        return "The teacher disconnected from the session.";
      case 'insufficient_balance':
        return "Session ended due to insufficient balance.";
      case 'normal':
        return "The session has been ended successfully.";
      default:
        return reason.replaceAll('_', ' ');
    }
  }
}

// ─────────────────── HELPERS (unchanged) ────────────────────────────────────

class _PulseCircle extends StatefulWidget {
  @override
  State<_PulseCircle> createState() => _PulseCircleState();
}

class _PulseCircleState extends State<_PulseCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _scale = Tween(
      begin: 0.8,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _opacity = Tween(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100.w,
      height: 100.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Transform.scale(
              scale: _scale.value,
              child: Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: drawerColor.withOpacity(_opacity.value * 0.15),
                ),
              ),
            ),
          ),
          Container(
            width: 68.w,
            height: 68.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: drawerColor.withOpacity(.1),
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 30.sp,
              color: drawerColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeacherAvatar extends StatelessWidget {
  final String? imageUrl;
  final bool isOnline;
  final double size;
  const _TeacherAvatar({this.imageUrl, required this.isOnline, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isOnline ? successColor.withOpacity(.5) : Colors.grey.shade500,
          width: 2,
        ),
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallback(),
              )
            : _fallback(),
      ),
    );
  }

  Widget _fallback() => Container(
    color: Colors.grey.shade700,
    child: Icon(Icons.person, size: (size * 0.5).sp, color: Colors.white70),
  );
}

class _BillingBadge extends StatelessWidget {
  final int minutes;
  const _BillingBadge({required this.minutes});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: accentOrange.withOpacity(.15),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 12.sp, color: accentOrange),
          SizedBox(width: 3.w),
          CustomText(
            text: "${minutes}m",
            size: 11,
            weight: FontWeight.w700,
            color: accentOrange,
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;
  const _PrimaryButton({
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52.h,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Center(
          child: CustomText(
            text: label,
            size: 15,
            weight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _OutlineButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52.h,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: Colors.redAccent.withOpacity(.5),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16.sp, color: Colors.redAccent),
            SizedBox(width: 6.w),
            CustomText(
              text: label,
              size: 14,
              weight: FontWeight.w600,
              color: Colors.redAccent,
            ),
          ],
        ),
      ),
    );
  }
}
