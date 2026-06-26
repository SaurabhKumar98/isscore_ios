import 'dart:io';
import 'dart:ui' as ui;
import 'package:firstedu/data/models/api_models/community_models/communitypostmodels.dart'
    as api;
import 'package:firstedu/view_models/communityprvider/postforms_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

// ─── Design tokens ───────────────────────────────────────────────────────────
const _ink = Color(0xFF0D0D0D);
const _slate = Color(0xFF6B7280);
const _mist = Color(0xFFF5F5F7);
const _line = Color(0xFFE8E8EC);
const _white = Color(0xFFFFFFFF);
const _accent = Color(0xFF2563EB);
const _accentL = Color(0xFFEFF4FF);
const _danger = Color(0xFFEF4444);

// ─── Screen ──────────────────────────────────────────────────────────────────
class NewDiscussionScreen extends StatefulWidget {
  /// Pass an existing post to enter edit mode.
  final api.CommunityPost? editPost;
  const NewDiscussionScreen({super.key, this.editPost});

  bool get isEditing => editPost != null;

  @override
  State<NewDiscussionScreen> createState() => _NewDiscussionScreenState();
}

class _NewDiscussionScreenState extends State<NewDiscussionScreen>
    with SingleTickerProviderStateMixin {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();
  final List<String> _tags = [];
  File? _image;
  String? _existingImageUrl;
  bool _tagExpanded = false;
  final _topicCtrl = TextEditingController();

  // For the interactive image viewer
  final TransformationController _transformCtrl = TransformationController();

  // ← KEY: used to capture exactly what's visible in the preview frame
  final GlobalKey _previewKey = GlobalKey();

  late AnimationController _anim;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    if (widget.isEditing) {
      final p = widget.editPost!;
      _titleCtrl.text = p.title;
      _descCtrl.text = p.description;
      _topicCtrl.text = p.topic;
      for (final t in p.tags) {
        final clean = t.startsWith('#') ? t : '#$t';
        if (!_tags.contains(clean)) _tags.add(clean);
      }
      if (p.attachment?.trim().isNotEmpty == true) {
        _existingImageUrl = p.attachment;
      }
    }

    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..forward();
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _anim.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _tagCtrl.dispose();
    _topicCtrl.dispose();
    _transformCtrl.dispose();
    super.dispose();
  }

  // ── Tags ──────────────────────────────────────────────────────────────────
  void _addTag(String raw) {
    final t = raw.trim().replaceAll(' ', '');
    if (t.isEmpty || _tags.length >= 5) return;
    final withHash = t.startsWith('#') ? t : '#$t';
    if (_tags.contains(withHash)) return;
    setState(() {
      _tags.add(withHash);
      _tagCtrl.clear();
      _tagExpanded = false;
    });
  }

  void _removeTag(int i) => setState(() => _tags.removeAt(i));

  // ── Image ─────────────────────────────────────────────────────────────────
  Future<void> _pickImage() async {
    final p = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (p != null) {
      setState(() {
        _image = File(p.path);
        _existingImageUrl = null;
        _transformCtrl.value = Matrix4.identity();
      });
    }
  }

  void _removeImage() => setState(() {
    _image = null;
    _existingImageUrl = null;
    _transformCtrl.value = Matrix4.identity();
  });

  // ── Capture exactly what's visible inside the preview frame ───────────────
  Future<File?> _captureVisibleFrame() async {
    try {
      final boundary =
          _previewKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return null;

      // pixelRatio: 3.0 → high-res output (3× logical pixels)
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final bytes = byteData.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/post_preview_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      debugPrint('Frame capture failed: $e');
      return null;
    }
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: _danger,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
          content: Text(
            "Title is required",
            style: GoogleFonts.dmSans(
              color: _white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    File? finalImage = _image;
    if (_image != null || _existingImageUrl != null) {
      final croppedFile = await _captureVisibleFrame();
      if (croppedFile != null) finalImage = croppedFile;
    }

    final provider = context.read<PostProvider>();
    bool success;

    if (widget.isEditing) {
      success = await provider.updateDiscussion(
        context,
        postId: widget.editPost!.id,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        topic: _topicCtrl.text.trim().isEmpty
            ? "General"
            : _topicCtrl.text.trim(),
        tags: _tags,
        attachment: finalImage,
      );
    } else {
      success = await provider.postDiscussion(
        context,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        topic: _topicCtrl.text.trim().isEmpty
            ? "General"
            : _topicCtrl.text.trim(),
        tags: _tags,
        attachment: finalImage,
      );
    }

    if (success && mounted) Navigator.pop(context, true);
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<PostProvider>().isLoading;
    final hasImage = _image != null || _existingImageUrl != null;

    return Scaffold(
      backgroundColor: _white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Column(
              children: [
                // ── Top bar ────────────────────────────────────────────────
                _TopBar(
                  isLoading: isLoading,
                  isEditing: widget.isEditing,
                  onCancel: () => Navigator.pop(context),
                  onPost: _submit,
                ),

                // ── Scrollable body ────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),

                        // ── Author row ─────────────────────────────────────
                        Row(
                          children: [
                            const _Avatar(initials: "Y"),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "You",
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: _ink,
                                  ),
                                ),
                                Text(
                                  widget.isEditing
                                      ? "Editing your discussion"
                                      : "Posting a discussion",
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    color: _slate,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ── Topic ──────────────────────────────────────────
                        TextField(
                          controller: _topicCtrl,
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _accent,
                          ),
                          decoration: InputDecoration(
                            hintText: "Topic (e.g. Science, Math…)",
                            hintStyle: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: _slate.withOpacity(0.5),
                            ),
                            filled: true,
                            fillColor: _accentL,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 9,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: _accent.withOpacity(0.2),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: _accent.withOpacity(0.2),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: _accent,
                                width: 1.5,
                              ),
                            ),
                            isDense: true,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Title ──────────────────────────────────────────
                        TextField(
                          controller: _titleCtrl,
                          style: GoogleFonts.dmSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: _ink,
                            height: 1.3,
                          ),
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: "What's on your mind?",
                            hintStyle: GoogleFonts.dmSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: _slate.withOpacity(0.4),
                              height: 1.3,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                        ),

                        const SizedBox(height: 14),
                        Container(height: 1, color: _line),
                        const SizedBox(height: 14),

                        // ── Description ────────────────────────────────────
                        TextField(
                          controller: _descCtrl,
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            color: _slate.withOpacity(0.85),
                            height: 1.7,
                          ),
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText:
                                "Add details, context, or your question...",
                            hintStyle: GoogleFonts.dmSans(
                              fontSize: 15,
                              color: _slate.withOpacity(0.35),
                              height: 1.7,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                        ),

                        // ── Image preview with drag-to-pan ─────────────────
                        if (hasImage) ...[
                          const SizedBox(height: 20),
                          _ImagePreviewInteractive(
                            localFile: _image,
                            networkUrl: _existingImageUrl,
                            transformCtrl: _transformCtrl,
                            onRemove: _removeImage,
                            previewKey: _previewKey, // ← pass the key here
                          ),
                        ],

                        // ── Tags ───────────────────────────────────────────
                        if (_tags.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: List.generate(
                              _tags.length,
                              (i) => _TagChip(
                                label: _tags[i],
                                onRemove: () => _removeTag(i),
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),

                // ── Bottom toolbar ─────────────────────────────────────────
                _BottomToolbar(
                  tagExpanded: _tagExpanded,
                  tagController: _tagCtrl,
                  tagCount: _tags.length,
                  onPhoto: _pickImage,
                  onTagToggle: () =>
                      setState(() => _tagExpanded = !_tagExpanded),
                  onTagAdd: _addTag,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Interactive image preview (pan + zoom + drag to reposition) ─────────────
class _ImagePreviewInteractive extends StatelessWidget {
  final File? localFile;
  final String? networkUrl;
  final TransformationController transformCtrl;
  final VoidCallback onRemove;
  final GlobalKey previewKey; // ← captures this exact widget area on post

  const _ImagePreviewInteractive({
    required this.localFile,
    required this.networkUrl,
    required this.transformCtrl,
    required this.onRemove,
    required this.previewKey,
  });

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width - 40;

    Widget imgWidget;
    if (localFile != null) {
      imgWidget = Image.file(localFile!, fit: BoxFit.contain, width: screenW);
    } else {
      imgWidget = Image.network(
        networkUrl!,
        fit: BoxFit.contain,
        width: screenW,
        loadingBuilder: (_, child, prog) => prog == null
            ? child
            : SizedBox(
                width: screenW,
                height: 240,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: _accent,
                    strokeWidth: 2,
                  ),
                ),
              ),
      );
    }

    return Stack(
      children: [
        RepaintBoundary(
          key: previewKey,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              height: 260,
              color: Colors.black,
              child: InteractiveViewer(
                transformationController: transformCtrl,
                panEnabled: true,
                scaleEnabled: true,
                minScale: 0.5,
                maxScale: 5.0,
                constrained: false,
                child: imgWidget,
              ),
            ),
          ),
        ),

        // ── Drag hint badge ────────────────────────────────────────────────
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.open_with_rounded, color: _white, size: 13),
                  const SizedBox(width: 5),
                  Text(
                    "Drag to adjust · Pinch to zoom",
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: _white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Remove button ──────────────────────────────────────────────────
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, color: _white, size: 16),
            ),
          ),
        ),

        // ── Reset zoom button ──────────────────────────────────────────────
        Positioned(
          top: 8,
          right: 46,
          child: GestureDetector(
            onTap: () => transformCtrl.value = Matrix4.identity(),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fit_screen_rounded,
                color: _white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Top bar ─────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final bool isLoading, isEditing;
  final VoidCallback onCancel, onPost;
  const _TopBar({
    required this.isLoading,
    required this.isEditing,
    required this.onCancel,
    required this.onPost,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    decoration: const BoxDecoration(
      color: _white,
      border: Border(bottom: BorderSide(color: _line, width: 1)),
    ),
    child: Row(
      children: [
        GestureDetector(
          onTap: onCancel,
          child: Text(
            "Cancel",
            style: GoogleFonts.dmSans(
              fontSize: 15,
              color: _slate,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Spacer(),
        Text(
          isEditing ? "Edit Discussion" : "New Discussion",
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: isLoading ? null : onPost,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
            decoration: BoxDecoration(
              color: isLoading ? _accent.withOpacity(0.5) : _accent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _white,
                    ),
                  )
                : Text(
                    isEditing ? "Save" : "Post",
                    style: GoogleFonts.dmSans(
                      color: _white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
      ],
    ),
  );
}

// ─── Bottom toolbar ───────────────────────────────────────────────────────────
class _BottomToolbar extends StatelessWidget {
  final bool tagExpanded;
  final TextEditingController tagController;
  final int tagCount;
  final VoidCallback onPhoto, onTagToggle;
  final void Function(String) onTagAdd;

  const _BottomToolbar({
    required this.tagExpanded,
    required this.tagController,
    required this.tagCount,
    required this.onPhoto,
    required this.onTagToggle,
    required this.onTagAdd,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
    decoration: const BoxDecoration(
      color: _white,
      border: Border(top: BorderSide(color: _line)),
    ),
    child: Row(
      children: [
        _IconAction(icon: Icons.image_outlined, label: "Photo", onTap: onPhoto),
        const SizedBox(width: 8),
        if (!tagExpanded)
          _IconAction(
            icon: Icons.tag_rounded,
            label: tagCount > 0 ? "Tags ($tagCount)" : "Tag",
            onTap: onTagToggle,
          )
        else
          Expanded(
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: tagController,
                autofocus: true,
                style: GoogleFonts.dmSans(fontSize: 14, color: _ink),
                decoration: InputDecoration(
                  hintText: "Tag name",
                  hintStyle: GoogleFonts.dmSans(fontSize: 14, color: _slate),
                  filled: true,
                  fillColor: _mist,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  prefixText: "# ",
                  prefixStyle: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: _accent,
                    fontWeight: FontWeight.w700,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () => onTagAdd(tagController.text),
                    child: const Icon(
                      Icons.check_rounded,
                      color: _accent,
                      size: 18,
                    ),
                  ),
                ),
                onSubmitted: onTagAdd,
              ),
            ),
          ),
      ],
    ),
  );
}

// ─── Shared small components ──────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final String initials;
  const _Avatar({required this.initials});
  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: _accentL,
      shape: BoxShape.circle,
      border: Border.all(color: _accent.withOpacity(0.2), width: 1.5),
    ),
    child: Center(
      child: Text(
        initials,
        style: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: _accent,
        ),
      ),
    ),
  );
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _IconAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: _mist,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: _slate),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _slate,
            ),
          ),
        ],
      ),
    ),
  );
}

class _TagChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _TagChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onRemove,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _accentL,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _accent.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _accent,
            ),
          ),
          const SizedBox(width: 5),
          Icon(Icons.close_rounded, size: 12, color: _accent.withOpacity(0.6)),
        ],
      ),
    ),
  );
}
