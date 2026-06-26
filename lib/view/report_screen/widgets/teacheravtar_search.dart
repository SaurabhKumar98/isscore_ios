

import 'package:flutter/material.dart';

const Color _kPrimary = Color(0xFF4361EE);
const Color _kAvatarBg1 = Color(0xFF7B61FF);
const Color _kAvatarBg2 = Color(0xFF06B6D4);
const Color _kBorder = Color(0xFFE2E4F0);
const Color _kMuted = Color(0xFF9EA3B5);

/// Circular teacher avatar. Shows the network image when [imageUrl] is
/// present and loads successfully; otherwise falls back to a colored
/// circle with the teacher's initials.
class TeacherAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double size;

  const TeacherAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 40,
  });

  String get _initials {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  Color get _bgColor {
    final hash = name.codeUnits.fold<int>(0, (a, b) => a + b);
    return hash.isEven ? _kAvatarBg1 : _kAvatarBg2;
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: _bgColor.withOpacity(0.15),
        child: hasImage
            ? Image.network(
                imageUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                loadingBuilder: (ctx, child, progress) {
                  if (progress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: size * 0.4,
                      height: size * 0.4,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _kPrimary,
                      ),
                    ),
                  );
                },
                errorBuilder: (ctx, error, stack) => _initialsFallback(),
              )
            : _initialsFallback(),
      ),
    );
  }

  Widget _initialsFallback() {
    return Center(
      child: Text(
        _initials,
        style: TextStyle(
          fontSize: size * 0.38,
          fontWeight: FontWeight.w700,
          color: _bgColor,
        ),
      ),
    );
  }
}

/// Search bar used at the top of the Chat Report / Call Report lists.
/// Forwards every keystroke to [onChanged] — the 300ms debounce already
/// lives in ChatReportProvider/CallReportProvider.onSearchChanged, so this
/// widget stays dumb on purpose.
class ReportSearchBar extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onChanged;

  const ReportSearchBar({
    super.key,
    required this.hint,
    required this.onChanged,
  });

  @override
  State<ReportSearchBar> createState() => _ReportSearchBarState();
}

class _ReportSearchBarState extends State<ReportSearchBar> {
  final _ctrl = TextEditingController();
  bool _hasText = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _clear() {
    _ctrl.clear();
    setState(() => _hasText = false);
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: TextField(
        controller: _ctrl,
        onChanged: (v) {
          setState(() => _hasText = v.isNotEmpty);
          widget.onChanged(v);
        },
        style: const TextStyle(fontSize: 14, color: Color(0xFF1A1D2E)),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: const TextStyle(fontSize: 14, color: _kMuted),
          prefixIcon:
              const Icon(Icons.search_rounded, color: _kMuted, size: 20),
          suffixIcon: _hasText
              ? IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: _kMuted, size: 18),
                  onPressed: _clear,
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        ),
      ),
    );
  }
}