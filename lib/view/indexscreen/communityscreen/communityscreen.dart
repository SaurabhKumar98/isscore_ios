import 'package:firstedu/data/models/api_models/community_models/commentauthor.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/view/indexscreen/communityscreen/newpostscreen.dart';
import 'package:firstedu/data/models/api_models/community_models/communitypostmodels.dart'
    as api;
import 'package:firstedu/view_models/authprovider/userSessionProvider.dart';
import 'package:firstedu/view_models/communityprvider/commentprovider.dart';
import 'package:firstedu/view_models/communityprvider/communityprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

const _bg = Color(0xFFF4F6FB);
const _white = Colors.white;
const _navy = Color(0xFF162556);
const _orange = Color(0xFFFA6C00);
const _txtPri = Color(0xFF0F1521);
const _txtSec = Color(0xFF8A95B0);
const _border = Color(0xFFEAEDF5);
const _red = Color(0xFFEF4444);

const List<String> _quickEmojis = [
  "❤️",
  "🙌",
  "🔥",
  "👏",
  "😢",
  "😍",
  "😮",
  "😂",
];

const _palette = [
  Color(0xFF4A7CF7),
  Color(0xFF16A97A),
  Color(0xFFE0457B),
  Color(0xFF8B5CF6),
  Color(0xFFFA6C00),
  Color(0xFF0EA5E9),
  Color(0xFF10B981),
  Color(0xFF6366F1),
  Color(0xFFF59E0B),
  Color(0xFFEF4444),
];
Color _tc(String t) =>
    _palette[t.toUpperCase().hashCode.abs() % _palette.length];
String _ini(String n) => n.trim().isEmpty
    ? '?'
    : n
          .trim()
          .split(' ')
          .take(2)
          .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
          .join();

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});
  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  String _q = '';

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<CommunityProvider>().fetchPosts(context),
    );
  }

  // ── FIX (setState-during-build): seed likes here, NOT in build() or initState of card ──
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    Future.microtask(() {
      final cp = context.read<CommentProvider>();
      final posts = context.read<CommunityProvider>().posts;

      for (final p in posts) {
        cp.seedForumLikes(p.id, p.likes);
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200)
      context.read<CommunityProvider>().loadMore(context);
  }

  List<api.CommunityPost> _filter(List<api.CommunityPost> all) {
    if (_q.isEmpty) return all;
    final q = _q.toLowerCase();
    return all
        .where(
          (p) =>
              p.title.toLowerCase().contains(q) ||
              p.description.toLowerCase().contains(q) ||
              p.tags.any((t) => t.toLowerCase().contains(q)) ||
              (p.createdBy?.name.toLowerCase().contains(q) ?? false) ||
              p.topic.toLowerCase().contains(q),
        )
        .toList();
  }

  void _openComments(api.CommunityPost p) {
    final cp = context.read<CommentProvider>();
    if (p.comments.isNotEmpty) {
      cp.seedComments(
        p.id,
        p.comments
            .map((c) => PostComment.fromJson(c as Map<String, dynamic>))
            .toList(),
      );
    }
    cp.seedForumLikes(p.id, p.likes);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: cp,
        child: _CommentsSheet(post: p, accentColor: _tc(p.topic)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<UserSessionProvider>().userId ?? '';
    final pv = context.watch<CommunityProvider>();
    final posts = _filter(pv.posts);

    // ── FIX: removed addPostFrameCallback from build() — was causing
    //    "setState() called during build" every frame ──

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: RefreshIndicator(
          color: _orange,
          onRefresh: () => pv.fetchPosts(context),
          child: CustomScrollView(
            controller: _scrollCtrl,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _Header(
                  onNewPost: () => Navigator.push<bool>(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, a1, a2) => const NewDiscussionScreen(),
                      transitionsBuilder: (_, a, __, child) => SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(0, 1),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: a,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                        child: child,
                      ),
                      transitionDuration: const Duration(milliseconds: 340),
                    ),
                  ).then((_) => pv.fetchPosts(context)),
                ),
              ),
              SliverToBoxAdapter(
                child: _SearchBar(
                  ctrl: _searchCtrl,
                  onChanged: (v) => setState(() => _q = v),
                ),
              ),
              if (pv.isLoading)
                const SliverFillRemaining(child: _LoadingView())
              else if (pv.errorMessage.isNotEmpty)
                SliverFillRemaining(
                  child: _ErrorView(
                    msg: pv.errorMessage,
                    onRetry: () => pv.fetchPosts(context),
                  ),
                )
              else if (posts.isEmpty)
                SliverFillRemaining(child: _EmptyView(hasQ: _q.isNotEmpty))
              else ...[
                SliverList(
                  delegate: SliverChildBuilderDelegate((_, i) {
                    final p = posts[i];
                    return _PostCard(
                      post: p,
                      currentUserId: currentUserId,
                      onLike: () =>
                          context.read<CommentProvider>().toggleForumLike(
                            context,
                            postId: p.id,
                            currentUserId: currentUserId,
                            seedLikes: p.likes,
                          ),
                      onDoubleTap: () {
                        final cp = context.read<CommentProvider>();
                        cp.seedForumLikes(p.id, p.likes);
                        final likes = cp.forumLikesFor(p.id);
                        if (!likes.contains(currentUserId)) {
                          HapticFeedback.mediumImpact();
                          cp.toggleForumLike(
                            context,
                            postId: p.id,
                            currentUserId: currentUserId,
                            seedLikes: p.likes,
                          );
                        }
                      },
                      onOpenComments: () => _openComments(p),
                      onDelete: () async {
                        final ok = await context
                            .read<CommentProvider>()
                            .deleteForum(context, postId: p.id);
                        if (ok && context.mounted) pv.fetchPosts(context);
                      },
                      onEdit: () async {
                        final edited = await Navigator.push<bool>(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, a1, a2) =>
                                NewDiscussionScreen(editPost: p),
                            transitionsBuilder: (_, a, __, child) =>
                                SlideTransition(
                                  position:
                                      Tween<Offset>(
                                        begin: const Offset(0, 1),
                                        end: Offset.zero,
                                      ).animate(
                                        CurvedAnimation(
                                          parent: a,
                                          curve: Curves.easeOutCubic,
                                        ),
                                      ),
                                  child: child,
                                ),
                            transitionDuration: const Duration(
                              milliseconds: 340,
                            ),
                          ),
                        );
                        if ((edited == true) && context.mounted)
                          pv.fetchPosts(context);
                      },
                    );
                  }, childCount: posts.length),
                ),
                if (pv.isPaginationLoading)
                  const SliverToBoxAdapter(child: _Paginator()),
                if (!pv.hasMore && posts.isNotEmpty)
                  const SliverToBoxAdapter(child: _EndLabel()),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 60)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onNewPost;
  const _Header({required this.onNewPost});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Community",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _navy,
                ),
              ),
              Text(
                "Learn together, grow together",
                style: GoogleFonts.poppins(fontSize: 12, color: _txtSec),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onNewPost,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: _orange,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: _orange.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.add_rounded, color: _white, size: 18),
                const SizedBox(width: 6),
                Text(
                  "Discuss",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _SearchBar extends StatelessWidget {
  final TextEditingController ctrl;
  final void Function(String) onChanged;
  const _SearchBar({required this.ctrl, required this.onChanged});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
    child: Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: _txtSec, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: ctrl,
              onChanged: onChanged,
              style: GoogleFonts.poppins(fontSize: 13, color: _txtPri),
              decoration: InputDecoration(
                hintText: "Search by title, topic, tag or author...",
                hintStyle: GoogleFonts.poppins(
                  color: _txtSec.withValues(alpha: 0.55),
                  fontSize: 13,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (ctrl.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                ctrl.clear();
                onChanged('');
              },
              child: const Icon(Icons.close_rounded, color: _txtSec, size: 16),
            ),
        ],
      ),
    ),
  );
}

// ══════════════════════════════════════════════════════════
// POST CARD
// ══════════════════════════════════════════════════════════
class _PostCard extends StatefulWidget {
  final api.CommunityPost post;
  final String currentUserId;
  final VoidCallback onLike, onDoubleTap, onOpenComments, onDelete, onEdit;
  const _PostCard({
    required this.post,
    required this.currentUserId,
    required this.onLike,
    required this.onDoubleTap,
    required this.onOpenComments,
    required this.onDelete,
    required this.onEdit,
  });
  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> with TickerProviderStateMixin {
  late AnimationController _lc, _hc;
  late Animation<double> _hs, _ho;
  bool _showHeart = false;
  bool _showFullDescription = false;

  // ── FIX (ownership): computed from widget props, no Provider needed ──
  bool get _isOwner =>
      widget.currentUserId.isNotEmpty &&
      widget.post.createdBy?.id == widget.currentUserId;

  @override
  void initState() {
    super.initState();
    // ── FIX (setState-during-build): DO NOT call seedForumLikes here.
    //    Seeding happens in _CommunityScreenState.didChangeDependencies()
    //    which runs after the build phase completes. Calling it here
    //    triggers notifyListeners() mid-build causing the Flutter error.

    _lc = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.8,
      upperBound: 1.3,
      value: 1.0,
    );
    _hc = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _hs = TweenSequence([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.3,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.3,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 50),
    ]).animate(_hc);
    _ho = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 10),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 45),
    ]).animate(_hc);
  }

  @override
  void dispose() {
    _lc.dispose();
    _hc.dispose();
    super.dispose();
  }

  Future<void> _likeTap() async {
    HapticFeedback.lightImpact();
    widget.onLike();
    await _lc.forward();
    await _lc.reverse();
  }

  Future<void> _dtap() async {
    widget.onDoubleTap();
    setState(() => _showHeart = true);
    _hc.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 710));
    if (mounted) setState(() => _showHeart = false);
  }

  Future<void> _openPostMenu() async {
    final cp = context.read<CommentProvider>();
    final pv = context.read<CommunityProvider>();

    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        decoration: const BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: _border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: _navy),
                title: Text(
                  "Edit Post",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _txtPri,
                  ),
                ),
                onTap: () => Navigator.of(sheetCtx).pop('edit'),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: _red),
                title: Text(
                  "Delete Post",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _red,
                  ),
                ),
                onTap: () => Navigator.of(sheetCtx).pop('delete'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );

    if (!mounted) return;

    if (result == 'edit') {
      widget.onEdit();
      return;
    }

    if (result == 'delete') {
      final confirm =
          await showDialog<bool>(
            context: context,
            builder: (dlgCtx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                "Delete Post",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _txtPri,
                ),
              ),
              content: Text(
                "Are you sure you want to delete this post? This cannot be undone.",
                style: GoogleFonts.poppins(fontSize: 13, color: _txtSec),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dlgCtx).pop(false),
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.poppins(color: _txtSec),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dlgCtx).pop(true),
                  child: Text(
                    "Delete",
                    style: GoogleFonts.poppins(
                      color: _red,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ) ??
          false;

      if (!mounted || !confirm) return;
      final ok = await cp.deleteForum(context, postId: widget.post.id);
      if (ok && mounted) pv.fetchPosts(context);
    }
  }

  String get _author => widget.post.createdBy?.name.trim().isNotEmpty == true
      ? widget.post.createdBy!.name
      : "Anonymous";
  String get _ago => widget.post.createdAt != null
      ? timeago.format(widget.post.createdAt!)
      : '';
  bool get _hasImg => widget.post.attachment?.trim().isNotEmpty == true;
  Color get _color => _tc(widget.post.topic);

  @override
  Widget build(BuildContext context) {
    final p = widget.post;
    final likes = context.select<CommentProvider, List<dynamic>>(
      (cp) => cp.forumLikesFor(p.id),
    );
    final liked = likes.contains(widget.currentUserId);
    final likeCount = likes.length;
    final isLiking = context.select<CommentProvider, bool>(
      (cp) => cp.isLikingForum(p.id),
    );
    final isDeleting = context.select<CommentProvider, bool>(
      (cp) => cp.isDeletingForum(p.id),
    );
    final cc = context.select<CommentProvider, int>((cp) {
      final l = cp.commentsFor(p.id);
      return l.isNotEmpty ? l.length : p.comments.length;
    });
    final fc = context.select<CommentProvider, PostComment?>((cp) {
      final l = cp.commentsFor(p.id);
      return l.isNotEmpty ? l.first : null;
    });

    return AnimatedOpacity(
      opacity: isDeleting ? 0.4 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        color: _white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Row(
                children: [
                  _Av(i: _ini(_author), c: _color, s: 40),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _author,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _txtPri,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (p.topic.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 100,
                                ), // badge never exceeds this
                                child: _Badge(p.topic, _color),
                              ),
                            ],
                          ],
                        ),

                        if (_ago.isNotEmpty)
                          Text(
                            _ago,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: _txtSec,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // ── FIX (ownership): three-dot ONLY shown to the post's author ──
                  if (_isOwner)
                    GestureDetector(
                      onTap: _openPostMenu,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.more_horiz_rounded,
                          color: _txtSec,
                          size: 22,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            GestureDetector(
              onDoubleTap: _dtap,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_hasImg)
                    SizedBox(
                      width: double.infinity,
                      height: 280,
                      child: Image.network(
                        p.attachment!,
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, prog) => prog == null
                            ? child
                            : Container(
                                height: 280,
                                color: _color.withValues(alpha: 0.08),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: _color,
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                        errorBuilder: (_, __, ___) => Container(
                          height: 280,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _color.withValues(alpha: 0.12),
                                _color.withValues(alpha: 0.35),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image_outlined,
                                size: 48,
                                color: _color.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Image unavailable",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: _color.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (p.title.isNotEmpty)
                            Text(
                              p.title,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _txtPri,
                                height: 1.35,
                              ),
                            ),
                          if (p.description.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final style = GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: _txtSec,
                                  height: 1.55,
                                );
                                final tp = TextPainter(
                                  text: TextSpan(
                                    text: p.description,
                                    style: style,
                                  ),
                                  maxLines: 1,
                                  textDirection: TextDirection.ltr,
                                )..layout(maxWidth: constraints.maxWidth);

                                final isOverflowing = tp.didExceedMaxLines;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.description,
                                      maxLines: _showFullDescription ? null : 1,
                                      overflow: _showFullDescription
                                          ? TextOverflow.visible
                                          : TextOverflow.ellipsis,
                                      style: style,
                                    ),
                                    if (isOverflowing)
                                      GestureDetector(
                                        onTap: () => setState(
                                          () => _showFullDescription =
                                              !_showFullDescription,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4,
                                          ),
                                          child: Text(
                                            _showFullDescription
                                                ? "View less"
                                                : "View more",
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: _orange,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
                          if (p.tags.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: p.tags.map((t) => _TagW(t)).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),

                  if (_showHeart)
                    AnimatedBuilder(
                      animation: _hc,
                      builder: (_, __) => Opacity(
                        opacity: _ho.value,
                        child: Transform.scale(
                          scale: _hs.value,
                          child: Icon(
                            Icons.favorite_rounded,
                            size: 100,
                            color: _hasImg
                                ? _white.withValues(alpha: 0.9)
                                : _red,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Below the Stack: image post caption ──
            if (_hasImg)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "$_author  ",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _txtPri,
                            ),
                          ),
                          TextSpan(
                            text: p.title,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: _txtPri,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ✅ FIXED: expandable description for image posts
                    if (p.description.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final style = GoogleFonts.poppins(
                            fontSize: 13,
                            color: _txtSec,
                            height: 1.5,
                          );
                          final tp = TextPainter(
                            text: TextSpan(text: p.description, style: style),
                            maxLines: 1,
                            textDirection: TextDirection.ltr,
                          )..layout(maxWidth: constraints.maxWidth);

                          final isOverflowing = tp.didExceedMaxLines;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.description,
                                maxLines: _showFullDescription ? null : 1,
                                overflow: _showFullDescription
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                                style: style,
                              ),
                              if (isOverflowing)
                                GestureDetector(
                                  onTap: () => setState(
                                    () => _showFullDescription =
                                        !_showFullDescription,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      _showFullDescription
                                          ? "View less"
                                          : "View more",
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _orange,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                    if (p.tags.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 5,
                        children: p.tags.map((t) => _TagW(t)).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
              child: Row(
                children: [
                  ScaleTransition(
                    scale: _lc,
                    child: GestureDetector(
                      onTap: isLiking ? null : _likeTap,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: isLiking
                            ? SizedBox(
                                width: 26,
                                height: 26,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: liked ? _red : _txtSec,
                                ),
                              )
                            : Icon(
                                liked
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                key: ValueKey(liked),
                                size: 26,
                                color: liked ? _red : _txtPri,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: liked ? _red : _txtPri,
                    ),
                    child: Text("$likeCount"),
                  ),
                  const SizedBox(width: 18),
                  GestureDetector(
                    onTap: widget.onOpenComments,
                    child: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 24,
                      color: _txtPri,
                    ),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: widget.onOpenComments,
                    child: Text(
                      "$cc",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _txtPri,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (fc != null)
              GestureDetector(
                onTap: widget.onOpenComments,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 4),
                  child: RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "${fc.author?.name ?? 'Someone'}  ",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _txtPri,
                          ),
                        ),
                        TextSpan(
                          text: fc.content,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: _txtSec,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            if (cc > 1)
              GestureDetector(
                onTap: widget.onOpenComments,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 2, 14, 12),
                  child: Text(
                    "View all $cc comments",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: _txtSec,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

            Container(height: 8, color: _bg),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// COMMENTS SHEET
// ══════════════════════════════════════════════════════════
class _CommentsSheet extends StatefulWidget {
  final api.CommunityPost post;
  final Color accentColor;
  const _CommentsSheet({required this.post, required this.accentColor});
  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _ctrl = TextEditingController();
  final _fn = FocusNode();
  String? _replyCommentId;
  String? _replyAuthorName;

  void _startReply(String cid, String name) {
    setState(() {
      _replyCommentId = cid;
      _replyAuthorName = name;
    });
    _fn.requestFocus();
  }

  void _cancelReply() => setState(() {
    _replyCommentId = null;
    _replyAuthorName = null;
  });

  Future<void> _submit() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();
    final cp = context.read<CommentProvider>();
    bool ok;
    if (_replyCommentId != null) {
      ok = await cp.addReply(
        context,
        postId: widget.post.id,
        commentId: _replyCommentId!,
        content: text,
      );
    } else {
      ok = await cp.addComment(context, postId: widget.post.id, content: text);
    }
    if (ok) _cancelReply();
  }

  void _emoji(String e) {
    _ctrl.text += e;
    _ctrl.selection = TextSelection.collapsed(offset: _ctrl.text.length);
  }

  // ── FIX (ownership): guard before showing sheet — only owner sees menu ──
  Future<void> _showCommentOptions(PostComment c) async {
    final userId = context.read<UserSessionProvider>().userId ?? '';
    if (userId.isEmpty || c.author?.id != userId) return; // not your comment

    final cp = context.read<CommentProvider>();
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        decoration: const BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: _border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: _red),
                title: Text(
                  "Delete Comment",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _red,
                  ),
                ),
                onTap: () => Navigator.of(sheetCtx).pop('delete'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
    if (!mounted || result != 'delete') return;
    final confirm =
        await showDialog<bool>(
          context: context,
          builder: (dlgCtx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              "Delete Comment",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _txtPri,
              ),
            ),
            content: Text(
              "Delete this comment and all its replies?",
              style: GoogleFonts.poppins(fontSize: 13, color: _txtSec),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dlgCtx).pop(false),
                child: Text(
                  "Cancel",
                  style: GoogleFonts.poppins(color: _txtSec),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(dlgCtx).pop(true),
                child: Text(
                  "Delete",
                  style: GoogleFonts.poppins(
                    color: _red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
    if (!mounted || !confirm) return;
    cp.deleteComment(context, postId: widget.post.id, commentId: c.id);
  }

  // ── FIX (ownership): guard before showing sheet — only owner sees menu ──
  Future<void> _showReplyOptions(PostComment c, CommentReply r) async {
    final userId = context.read<UserSessionProvider>().userId ?? '';
    if (userId.isEmpty || r.author?.id != userId) return; // not your reply

    final cp = context.read<CommentProvider>();
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        decoration: const BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: _border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: _red),
                title: Text(
                  "Delete Reply",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _red,
                  ),
                ),
                onTap: () => Navigator.of(sheetCtx).pop('delete'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
    if (!mounted || result != 'delete') return;
    final confirm =
        await showDialog<bool>(
          context: context,
          builder: (dlgCtx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              "Delete Reply",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _txtPri,
              ),
            ),
            content: Text(
              "Delete this reply?",
              style: GoogleFonts.poppins(fontSize: 13, color: _txtSec),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dlgCtx).pop(false),
                child: Text(
                  "Cancel",
                  style: GoogleFonts.poppins(color: _txtSec),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(dlgCtx).pop(true),
                child: Text(
                  "Delete",
                  style: GoogleFonts.poppins(
                    color: _red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
    if (!mounted || !confirm) return;
    cp.deleteReply(
      context,
      postId: widget.post.id,
      commentId: c.id,
      replyId: r.id,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _fn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<CommentProvider>();
    final comments = cp.commentsFor(widget.post.id);
    final sending = cp.isSubmitting(widget.post.id);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              decoration: BoxDecoration(
                color: _border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                "Comments",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _txtPri,
                ),
              ),
            ),
            Container(height: 1, color: _border),

            Expanded(
              child: comments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 48,
                            color: _txtSec.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "No comments yet.",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: _txtSec,
                            ),
                          ),
                          Text(
                            "Be the first!",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: _txtSec.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: ctrl,
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      itemCount: comments.length,
                      itemBuilder: (_, i) {
                        final c = comments[i];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _CT(
                              c: c,
                              postId: widget.post.id,
                              ac: widget.accentColor,
                              onReply: () => _startReply(
                                c.id,
                                c.author?.name ?? 'Someone',
                              ),
                              onMoreTap: () => _showCommentOptions(c),
                            ),
                            ...c.replies.map(
                              (r) => Padding(
                                padding: const EdgeInsets.only(left: 52),
                                child: _RT(
                                  r: r,
                                  postId: widget.post.id,
                                  commentId: c.id,
                                  ac: widget.accentColor,
                                  onMoreTap: () => _showReplyOptions(c, r),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),

            Container(
              decoration: BoxDecoration(
                color: _white,
                border: Border(top: BorderSide(color: _border)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 46,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      itemCount: _quickEmojis.length,
                      itemBuilder: (_, i) => GestureDetector(
                        onTap: () => _emoji(_quickEmojis[i]),
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _bg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _border),
                          ),
                          child: Text(
                            _quickEmojis[i],
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (_replyAuthorName != null)
                    Container(
                      padding: const EdgeInsets.fromLTRB(14, 6, 14, 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.reply_rounded,
                            size: 14,
                            color: widget.accentColor,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              "Replying to @$_replyAuthorName",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: widget.accentColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _cancelReply,
                            child: const Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: _txtSec,
                            ),
                          ),
                        ],
                      ),
                    ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      14,
                      6,
                      14,
                      MediaQuery.of(context).viewInsets.bottom + 12,
                    ),
                    child: Row(
                      children: [
                        _Av(i: "Y", c: _orange, s: 36),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _ctrl,
                            focusNode: _fn,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: _txtPri,
                            ),
                            decoration: InputDecoration(
                              hintText: _replyAuthorName != null
                                  ? "Reply to @$_replyAuthorName..."
                                  : "Join the conversation...",
                              hintStyle: GoogleFonts.poppins(
                                fontSize: 14,
                                color: _txtSec.withValues(alpha: 0.55),
                              ),
                              filled: true,
                              fillColor: _bg,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide(
                                  color: widget.accentColor.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ),
                              suffixIcon: sending
                                  ? Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: widget.accentColor,
                                        ),
                                      ),
                                    )
                                  : GestureDetector(
                                      onTap: _submit,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          right: 6,
                                        ),
                                        child: Icon(
                                          Icons.send_rounded,
                                          color: widget.accentColor,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                            ),
                            onSubmitted: (_) => _submit(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Comment tile ──────────────────────────────────────────────────────────────
class _CT extends StatelessWidget {
  final PostComment c;
  final String postId;
  final Color ac;
  final VoidCallback onReply, onMoreTap;
  const _CT({
    required this.c,
    required this.postId,
    required this.ac,
    required this.onReply,
    required this.onMoreTap,
  });

  String get _name => c.author?.name ?? "Someone";
  String get _ago => c.createdAt != null ? timeago.format(c.createdAt!) : '';

  @override
  Widget build(BuildContext context) {
    final userId = context.read<UserSessionProvider>().userId ?? '';
    final liked = c.likes.contains(userId);
    // ── FIX (ownership): three-dot visible only to comment owner ──
    final isOwner = userId.isNotEmpty && c.author?.id == userId;
    final isLiking = context.select<CommentProvider, bool>(
      (cp) => cp.isLikingComment(c.id),
    );
    final isDeleting = context.select<CommentProvider, bool>(
      (cp) => cp.isDeletingComment(c.id),
    );

    return AnimatedOpacity(
      opacity: isDeleting ? 0.3 : 1.0,
      duration: const Duration(milliseconds: 250),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Av(i: _ini(_name), c: _tc(_name), s: 36),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          _name,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _txtPri,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (_ago.isNotEmpty)
                        Text(
                          _ago,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: _txtSec,
                          ),
                        ),
                      const Spacer(),
                      // ── FIX: only show three-dot to this comment's owner ──
                      if (isOwner)
                        GestureDetector(
                          onTap: onMoreTap,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.more_horiz_rounded,
                              size: 18,
                              color: _txtSec,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    c.content,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: _txtPri,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (c.likes.isNotEmpty) ...[
                        Text(
                          "${c.likes.length} like${c.likes.length == 1 ? '' : 's'}",
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: liked ? _red : _txtSec,
                          ),
                        ),
                        const SizedBox(width: 14),
                      ],
                      if (c.replies.isNotEmpty) ...[
                        Text(
                          "${c.replies.length} repl${c.replies.length == 1 ? 'y' : 'ies'}",
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: _txtSec,
                          ),
                        ),
                        const SizedBox(width: 14),
                      ],
                      GestureDetector(
                        onTap: onReply,
                        child: Text(
                          "Reply",
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: ac,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: isLiking
                  ? null
                  : () => context.read<CommentProvider>().toggleCommentLike(
                      context,
                      postId: postId,
                      commentId: c.id,
                      currentUserId: userId,
                    ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  isLiking
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: liked ? _red : _txtSec,
                          ),
                        )
                      : AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: Icon(
                            liked
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            key: ValueKey(liked),
                            size: 18,
                            color: liked ? _red : _txtSec,
                          ),
                        ),
                  if (c.likes.isNotEmpty)
                    Text(
                      "${c.likes.length}",
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: liked ? _red : _txtSec,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reply tile ────────────────────────────────────────────────────────────────
class _RT extends StatelessWidget {
  final CommentReply r;
  final String postId, commentId;
  final Color ac;
  final VoidCallback onMoreTap;
  const _RT({
    required this.r,
    required this.postId,
    required this.commentId,
    required this.ac,
    required this.onMoreTap,
  });

  String get _name => r.author?.name ?? "Someone";
  String get _ago => r.createdAt != null ? timeago.format(r.createdAt!) : '';

  @override
  Widget build(BuildContext context) {
    final userId = context.read<UserSessionProvider>().userId ?? '';
    final liked = r.likes.contains(userId);
    // ── FIX (ownership): three-dot visible only to reply owner ──
    final isOwner = userId.isNotEmpty && r.author?.id == userId;
    final isLiking = context.select<CommentProvider, bool>(
      (cp) => cp.isLikingReply(r.id),
    );
    final isDeleting = context.select<CommentProvider, bool>(
      (cp) => cp.isDeletingReply(r.id),
    );

    return AnimatedOpacity(
      opacity: isDeleting ? 0.3 : 1.0,
      duration: const Duration(milliseconds: 250),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Av(i: _ini(_name), c: ac, s: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          _name,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _txtPri,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (_ago.isNotEmpty)
                        Text(
                          _ago,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: _txtSec,
                          ),
                        ),
                      const Spacer(),
                      // ── FIX: only show three-dot to this reply's owner ──
                      if (isOwner)
                        GestureDetector(
                          onTap: onMoreTap,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.more_horiz_rounded,
                              size: 16,
                              color: _txtSec,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    r.content,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: _txtPri,
                      height: 1.4,
                    ),
                  ),
                  if (r.likes.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      "${r.likes.length} like${r.likes.length == 1 ? '' : 's'}",
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: liked ? _red : _txtSec,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: isLiking
                  ? null
                  : () => context.read<CommentProvider>().toggleReplyLike(
                      context,
                      postId: postId,
                      commentId: commentId,
                      replyId: r.id,
                      currentUserId: userId,
                    ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  isLiking
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: liked ? _red : _txtSec,
                          ),
                        )
                      : AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: Icon(
                            liked
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            key: ValueKey(liked),
                            size: 16,
                            color: liked ? _red : _txtSec,
                          ),
                        ),
                  if (r.likes.isNotEmpty)
                    Text(
                      "${r.likes.length}",
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: liked ? _red : _txtSec,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(color: _orange, strokeWidth: 2.5),
        const SizedBox(height: 16),
        Text(
          "Loading discussions...",
          style: GoogleFonts.poppins(fontSize: 13, color: _txtSec),
        ),
      ],
    ),
  );
}

class _ErrorView extends StatelessWidget {
  final String msg;
  final VoidCallback onRetry;
  const _ErrorView({required this.msg, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 56,
            color: _txtSec.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            "Couldn't load posts",
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _txtPri,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            msg,
            style: GoogleFonts.poppins(fontSize: 13, color: _txtSec),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: _orange,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _orange.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                "Try again",
                style: GoogleFonts.poppins(
                  color: _white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _EmptyView extends StatelessWidget {
  final bool hasQ;
  const _EmptyView({required this.hasQ});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          hasQ ? Icons.search_off_rounded : Icons.forum_outlined,
          size: 56,
          color: _txtSec.withValues(alpha: 0.35),
        ),
        const SizedBox(height: 16),
        Text(
          hasQ ? "No results found" : "No discussions yet",
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _txtPri,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          hasQ ? "Try a different search term" : "Be the first to start one!",
          style: GoogleFonts.poppins(fontSize: 13, color: _txtSec),
        ),
      ],
    ),
  );
}

class _Paginator extends StatelessWidget {
  const _Paginator();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 20),
    child: Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(color: _orange, strokeWidth: 2.5),
      ),
    ),
  );
}

class _EndLabel extends StatelessWidget {
  const _EndLabel();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Center(
      child: Text(
        "You're all caught up 🎉",
        style: GoogleFonts.poppins(fontSize: 12, color: _txtSec),
      ),
    ),
  );
}

class _Av extends StatelessWidget {
  final String i;
  final Color c;
  final double s;
  const _Av({required this.i, required this.c, required this.s});
  @override
  Widget build(BuildContext context) => Container(
    width: s,
    height: s,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [c, c.withValues(alpha: 0.65)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(s * 0.32),
    ),
    alignment: Alignment.center,
    child: Text(
      i,
      style: GoogleFonts.poppins(
        fontSize: s * 0.33,
        fontWeight: FontWeight.w800,
        color: _white,
      ),
    ),
  );
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(7),
    ),
    child: Text(
      label.toUpperCase(),
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.poppins(
        fontSize: 9,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 0.6,
      ),
    ),
  );
}

class _TagW extends StatelessWidget {
  final String label;
  const _TagW(this.label);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
    decoration: BoxDecoration(
      color: _bg,
      borderRadius: BorderRadius.circular(7),
      border: Border.all(color: _border),
    ),
    child: Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 11,
        color: _txtSec,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}
