import 'dart:ui';

import 'package:firstedu/core/navigatorkey/navigatorkey.dart';
import 'package:flutter/material.dart';

const Color _drawerColor = Color.fromRGBO(22, 37, 86, 1);
const Color _successColor = Color.fromARGB(255, 46, 175, 50);
const Color _errorColor = Color(0xFFD32F2F);
const Color _warningColor = Color(0xFFF57C00);

enum ToastType { success, error, warning, info }

class AppToast {
  // ─────────────────── CORE ────────────────────────────

  static void _insert(
    OverlayState overlay, {
    required String message,
    String? title,
    required ToastType type,
    required Duration duration,
  }) {
    final entry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        title: title,
        type: type,
        duration: duration,
      ),
    );
    overlay.insert(entry);
    Future.delayed(duration + const Duration(milliseconds: 400), () {
      entry.remove();
    });
  }

  // ─────────────────── WITH CONTEXT ────────────────────

  static void show(
    BuildContext context, {
    required String message,
    String? title,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    _insert(
      Overlay.of(context),
      message: message,
      title: title,
      type: type,
      duration: duration,
    );
  }

  static void success(BuildContext context,
          {required String message, String? title}) =>
      show(context,
          message: message,
          title: title ?? "Success",
          type: ToastType.success);

  static void error(BuildContext context,
          {required String message, String? title}) =>
      show(context,
          message: message,
          title: title ?? "Error",
          type: ToastType.error);

  static void warning(BuildContext context,
          {required String message, String? title}) =>
      show(context,
          message: message,
          title: title ?? "Warning",
          type: ToastType.warning);

  static void info(BuildContext context,
          {required String message, String? title}) =>
      show(context,
          message: message,
          title: title ?? "Info",
          type: ToastType.info);

  // ─────────────────── WITHOUT CONTEXT ─────────────────
  // Use from repositories, interceptors, anywhere

  static void showGlobal({
    required String message,
    String? title,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) return;
    _insert(overlay,
        message: message, title: title, type: type, duration: duration);
  }

  static void successGlobal({required String message, String? title}) =>
      showGlobal(
          message: message,
          title: title ?? "Success",
          type: ToastType.success);

  static void errorGlobal({required String message, String? title}) =>
      showGlobal(
          message: message, title: title ?? "Error", type: ToastType.error);

  static void warningGlobal({required String message, String? title}) =>
      showGlobal(
          message: message,
          title: title ?? "Warning",
          type: ToastType.warning);

  static void infoGlobal({required String message, String? title}) =>
      showGlobal(
          message: message, title: title ?? "Info", type: ToastType.info);
}

// ─────────────────── WIDGET ──────────────────────────────────────────────────

class _ToastWidget extends StatefulWidget {
  final String message;
  final String? title;
  final ToastType type;
  final Duration duration;

  const _ToastWidget({
    required this.message,
    required this.title,
    required this.type,
    required this.duration,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _accentColor {
    switch (widget.type) {
      case ToastType.success:
        return _successColor;
      case ToastType.error:
        return _errorColor;
      case ToastType.warning:
        return _warningColor;
      case ToastType.info:
        return _drawerColor;
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case ToastType.success:
        return Icons.check_circle_rounded;
      case ToastType.error:
        return Icons.error_rounded;
      case ToastType.warning:
        return Icons.warning_rounded;
      case ToastType.info:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 24,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Left color bar ──────────────────────
                  Container(
                    width: 5,
                    height: 70,
                    decoration: BoxDecoration(
                      color: _accentColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        bottomLeft: Radius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // ── Icon ────────────────────────────────
                  Icon(_icon, color: _accentColor, size: 26),
                  const SizedBox(width: 10),

                  // ── Title + Message ──────────────────────
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.title != null) ...[
                            Text(
                              widget.title!,
                              style: TextStyle(
                                color: _accentColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 2),
                          ],
                          Text(
                            widget.message,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Poppins',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}