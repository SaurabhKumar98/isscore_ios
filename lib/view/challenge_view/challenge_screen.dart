import 'package:firstedu/core/network/api_endpoint.dart';
import 'package:firstedu/data/models/api_models/challengeyourfriend/challengeroom_models.dart';
import 'package:firstedu/data/models/api_models/challengeyourfriend/challengeyourfriend_models.dart';
import 'package:firstedu/data/models/api_models/challengeyourfriend/completechallenge_models.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:firstedu/view/challenge_view/challengeanalytics.dart';
import 'package:firstedu/view/indexscreen/examhallscreen/questionscreen.dart';
import 'package:firstedu/view_models/authprovider/userSessionProvider.dart';
import 'package:firstedu/view_models/challengeyourgfriendprovider/challengeyourfriend_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

void _navigateToExam(
  BuildContext context, {
  required String sessionId,
  required String testId,
  required bool isHost,
}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ExamScreen(
        testId: testId,
        existingSessionId: sessionId,
        isHost: isHost,
        examTitle: "challenge",
      ),
    ),
  );
}

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  ChallengeRoom? _selectedRoom;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  bool _hasAutoSelected = false;
  bool _navigationScheduled = false;
  String? _joinedRoomCodeByUser;

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final provider = context.read<ChallengeProvider>();
    final sessionProvider = context.read<UserSessionProvider>();
    final token = sessionProvider.accessToken ?? '';

    // ✅ Set currentUserId so host checks work
    provider.currentUserId = sessionProvider.userId;

    provider.initSocket(baseUrl: ApiEndpoint.socketBaseUrl, token: token);
    provider.fetchAll(context);
  });
}

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ChallengeRoom> _filtered(List<ChallengeRoom> rooms) {
    if (_searchQuery.isEmpty) return rooms;
    final q = _searchQuery.toLowerCase();
    return rooms
        .where(
          (r) =>
              (r.title ?? '').toLowerCase().contains(q) ||
              (r.roomCode ?? '').toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChallengeProvider>(
      builder: (context, provider, _) {
        // ── NAVIGATION ──────────────────────────────────────────────
        // In build() — replace the navigation block at the top:
if (provider.pendingSessionId != null &&
    provider.pendingTestId != null &&
    provider.pendingTestId!.isNotEmpty &&
    !_navigationScheduled) {
  _navigationScheduled = true;
  final sid = provider.pendingSessionId!;
  final testId = provider.pendingTestId!;
  final challengeId = provider.pendingChallengeId;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;
    final room = provider.rooms.firstWhere(
      (r) => r.id == challengeId,
      orElse: () => ChallengeRoom(),
    );
    final isHost = provider.currentUserId != null &&
        room.createdBy?.id == provider.currentUserId;
    provider.consumePendingSession();
    _navigationScheduled = false;

    debugPrint('🚀 Navigating → sid=$sid testId=$testId isHost=$isHost');
    _navigateToExam(context, sessionId: sid, testId: testId, isHost: isHost);
  });
}

        // ── AUTO-SELECT first room ONCE ─────────────────────────────
        if (!_hasAutoSelected &&
            _selectedRoom == null &&
            provider.rooms.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {
              _hasAutoSelected = true;
              _selectedRoom = provider.rooms.first;
            });
            if (_joinedRoomCodeByUser == null) {
              provider.joinSocketRoom(provider.rooms.first.roomCode ?? '');
            }
          });
        }

        // ── Keep _selectedRoom in sync with live data ───────────────
        if (_selectedRoom != null) {
          final live = provider.rooms
              .where((r) => r.id == _selectedRoom!.id)
              .toList();
          if (live.isNotEmpty && live.first != _selectedRoom) {
            _selectedRoom = live.first;
          }
        }

        final totalRooms = provider.rooms.length;
        final waitingRooms = provider.rooms
            .where((r) => r.roomStatus?.toLowerCase() == 'waiting')
            .length;
        final activeRooms = provider.rooms
            .where((r) => r.roomStatus?.toLowerCase() == 'started')
            .length;
        final filtered = _filtered(provider.rooms);

        return Scaffold(
          backgroundColor: const Color(0xFFF0F2F8),
          body: RefreshIndicator(
            onRefresh: () => provider.fetchAll(context),
            color: accentOrange,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHero(provider)),
                if (provider.isLoading)
                  const SliverToBoxAdapter(
                    child: LinearProgressIndicator(
                      minHeight: 3,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(accentOrange),
                    ),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildStatsGrid(
                        totalRooms,
                        waitingRooms,
                        activeRooms,
                        provider.completed.length,
                      ),
                      const SizedBox(height: 16),
                      _sectionLabel(
                        icon: Icons.meeting_room_rounded,
                        iconColor: accentOrange,
                        title: 'Rooms',
                        subtitle: 'Select a room to manage details.',
                      ),
                      const SizedBox(height: 10),

                      // Search bar
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'Search rooms',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 13,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 11,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: drawerColor,
                                    width: 1.5,
                                  ),
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  size: 18,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              onChanged: (v) =>
                                  setState(() => _searchQuery = v),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: drawerColor,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 13,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => setState(
                              () => _searchQuery = _searchController.text,
                            ),
                            child: const Text(
                              'Search',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      if (provider.isLoading && provider.rooms.isEmpty)
                        _buildShimmer()
                      else if (filtered.isEmpty)
                        _buildEmptyRooms()
                      else
                        ...filtered.map((r) => _buildRoomListItem(r, provider)),

                      if (_selectedRoom != null) ...[
                        const SizedBox(height: 16),
                        _sectionLabel(
                          icon: Icons.desktop_windows_outlined,
                          iconColor: drawerColor,
                          title: 'Room Details',
                          subtitle: 'Manage selected room',
                        ),
                        const SizedBox(height: 10),
                        _buildRoomDetailCard(_selectedRoom!, provider),
                      ],

                      const SizedBox(height: 16),
                      _buildCompletedSection(provider),
                      const SizedBox(height: 14),
                      _buildTip(),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // HERO
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildHero(ChallengeProvider provider) {
    return Container(
      color: drawerColor,
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Challenge Arena',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Create rooms, invite friends, start battles, and track rankings.',
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentOrange,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _showCreateRoomSheet(provider),
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 16,
                          ),
                          label: const Text(
                            'Create Room',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Colors.white38,
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _showJoinRoomDialog(provider),
                          icon: const Icon(
                            Icons.login,
                            color: Colors.white,
                            size: 16,
                          ),
                          label: const Text(
                            'Join Room',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // STATS GRID
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildStatsGrid(int total, int waiting, int active, int completed) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.2,
      children: [
        _statCard('TOTAL ROOMS', '$total', Colors.black87),
        _statCard('WAITING', '$waiting', accentOrange),
        _statCard('ACTIVE', '$active', const Color(0xFF7C4DFF)),
        _statCard('COMPLETED', '$completed', Colors.green),
      ],
    );
  }

  Widget _statCard(String label, String value, Color valueColor) {
    return Container(
      constraints: const BoxConstraints(minHeight: 60),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // ROOM LIST ITEM
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildRoomListItem(ChallengeRoom room, ChallengeProvider provider) {
    final isSelected = _selectedRoom?.id == room.id;
    final status = room.roomStatus?.toLowerCase() ?? '';
    final count = room.participants?.length ?? 0;

    Color dotColor;
    switch (status) {
      case 'started':
        dotColor = Colors.green;
        break;
      case 'waiting':
        dotColor = accentOrange;
        break;
      case 'completed':
        dotColor = const Color(0xFF7C4DFF);
        break;
      default:
        dotColor = Colors.grey;
    }

   final isCreator = provider.currentUserId != null &&
    room.createdBy?.id == provider.currentUserId;
    // Can delete: host + waiting + no one else has joined (only 0 or 1 participant = just the host)
    final canQuickDelete = isCreator && status == 'waiting' && count <= 1;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedRoom = room);
        provider.joinSocketRoom(room.roomCode ?? '');
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? drawerColor : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: drawerColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
              margin: const EdgeInsets.only(right: 10, top: 1),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.title ?? 'Room',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Code ${room.roomCode ?? '-'} · $status · $count participant${count == 1 ? '' : 's'}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            // Quick-delete icon for empty waiting rooms
           if (canQuickDelete)
  GestureDetector(
    onTap: () async {
      final confirm = await _confirmDelete(context);
      if (!confirm || !context.mounted) return;
      final ok = await provider.deleteChallenge(context, room.id ?? '');
      if (ok && mounted) {
        setState(() {
          // ✅ Clear selected room if it was the deleted one
          if (_selectedRoom?.id == room.id) {
            _selectedRoom = null;
            _hasAutoSelected = false; // allow re-auto-select
          }
        });
      }
    },

                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: provider.isDeleting
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.red.shade300,
                          ),
                        )
                      : Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: Colors.red.shade300,
                        ),
                ),
              ),
            if (isSelected && !canQuickDelete)
              const Icon(Icons.chevron_right, color: drawerColor, size: 18),
          ],
        ),
      ),
    );
  }
Future<void> _shareViaWhatsApp(ChallengeRoom room) async {
  final code = room.roomCode ?? '';
  final title = room.title ?? 'Challenge';

  final message = Uri.encodeComponent(
    '🏆 *$title* — Challenge Invite!\n\n'
    'Join my challenge on Firstedu!\n\n'
    '📌 Room Code: *$code*\n\n'
    '👉 Open the app → Challenge Arena → Join Room → Enter code *$code*\n\n'
    '⚡ Let\'s battle it out!',
  );

  final whatsappUrl = 'whatsapp://send?text=$message';
  final fallbackUrl = 'https://wa.me/?text=$message';

  final whatsappUri = Uri.parse(whatsappUrl);
  final fallbackUri = Uri.parse(fallbackUrl);

  if (await canLaunchUrl(whatsappUri)) {
    await launchUrl(whatsappUri);
  } else {
    if (await canLaunchUrl(fallbackUri)) {
      await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
    } else {
      AppToast.infoGlobal(message: 'WhatsApp is not installed');
    }
  }
}
  // ═══════════════════════════════════════════════════════════════════
  // ROOM DETAIL CARD
  // ═══════════════════════════════════════════════════════════════════
 Widget _buildRoomDetailCard(ChallengeRoom room, ChallengeProvider provider) {
  final participants = room.participants ?? [];
  final status = room.roomStatus?.toLowerCase() ?? '';
  
  // ✅ isCreator must be declared BEFORE canStart
  final isCreator = provider.currentUserId != null &&
      room.createdBy?.id == provider.currentUserId;
  final canStart = isCreator && status == 'waiting' && participants.length >= 2;
  final canDelete = isCreator && status == 'waiting';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  room.title ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
              _statusBadge(status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Tap the code to copy it.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 14),

          GestureDetector(
            onTap: () => _copyCode(room.roomCode ?? ''),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ROOM CODE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: accentOrange,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  room.roomCode ?? '------',
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: accentOrange,
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          _actionButton(
            icon: Icons.copy_rounded,
            label: 'Copy Code',
            onTap: () => _copyCode(room.roomCode ?? ''),
          ),
          const SizedBox(height: 8),
          _actionButton(
  icon: Icons.share_outlined,
  label: 'Share Link',
  onTap: () => _shareViaWhatsApp(room),
),

          if (canStart) ...[
            const SizedBox(height: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                elevation: 0,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: provider.isStarting
                  ? null
                  : () async {
                      await provider.startChallenge(context, room.id ?? '');
                    },
              icon: provider.isStarting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
              label: Text(
                provider.isStarting ? 'Starting…' : 'Start Challenge',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Min 2 participants required — all are ready!',
              style: TextStyle(fontSize: 11, color: Colors.green.shade600),
            ),
          ],

          if (isCreator && status == 'waiting' && participants.length < 2) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.hourglass_top_rounded,
                    size: 16,
                    color: Colors.amber.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Waiting for more participants (${participants.length}/2 min)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── DELETE BUTTON (host only, waiting status) ─────────────
          if (canDelete) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red.shade300),
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: provider.isDeleting
                  ? null
                  : () async {
                      final confirm = await _confirmDelete(context);
                      if (!confirm || !context.mounted) return;
                      final ok = await provider.deleteChallenge(
                        context,
                        room.id ?? '',
                      );
                      if (ok && mounted) setState(() => _selectedRoom = null);
                    },
              icon: provider.isDeleting
                  ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.red.shade400,
                      ),
                    )
                  : Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: Colors.red.shade400,
                    ),
              label: Text(
                provider.isDeleting ? 'Deleting…' : 'Delete Room',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade400,
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),
          Text(
            'PARTICIPANTS (${participants.length})',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),

          if (participants.isEmpty)
            Text(
              'No participants yet.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            )
          else
            ...participants.asMap().entries.map((entry) {
              final p = entry.value;
              final name = p.student?.name ?? 'Unknown';
              final isHost =
                  room.createdBy?.id != null &&
                  p.student?.id == room.createdBy?.id;
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade100, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: drawerColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                    if (isHost)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Host',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE65100),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color bg;
    Color fg;
    String label;
    switch (status) {
      case 'started':
        bg = Colors.green.shade50;
        fg = Colors.green.shade700;
        label = 'Active';
        break;
      case 'waiting':
        bg = Colors.orange.shade50;
        fg = Colors.orange.shade700;
        label = 'Waiting';
        break;
      case 'completed':
        bg = const Color(0xFFEDE7F6);
        fg = const Color(0xFF6750A4);
        label = 'Done';
        break;
      default:
        bg = Colors.grey.shade100;
        fg = Colors.grey.shade600;
        label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: Colors.black54),
            const SizedBox(width: 7),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    AppToast.successGlobal(message: "Room code copied!");
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Room'),
            content: const Text(
              'This room will be deleted and all participants will be notified. Continue?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.red.shade600),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _buildCompletedSection(ChallengeProvider provider) {
    final completedRooms = provider.completed;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events, color: accentOrange, size: 18),
              const SizedBox(width: 6),
              Text(
                'Completed Challenges (${completedRooms.length})',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (completedRooms.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 36,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No completed challenges yet.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  ),
                ],
              ),
            )
          else
            ...completedRooms.map((c) => _buildCompletedCard(c, provider)),
        ],
      ),
    );
  }

  Widget _buildCompletedCard(CompletedChallenge c, ChallengeProvider provider) {
    final myStats = c.myStats;
    final myRank = myStats?.myRank ?? 0;
    final myScore = myStats?.myScore ?? 0;
    final highestScore = myStats?.highestScore ?? 0;
    final totalP = c.participantCount ?? 0;

    // Rank badge colour
    Color rankBg;
    Color rankFg;
    if (myRank == 1) {
      rankBg = const Color(0xFFFFF8E1);
      rankFg = const Color(0xFFE65100);
    } else if (myRank == 2) {
      rankBg = const Color(0xFFECEFF1);
      rankFg = const Color(0xFF546E7A);
    } else {
      rankBg = const Color(0xFFF3E5F5);
      rankFg = const Color(0xFF6A1B9A);
    }

    // Score percentage for progress bar
    final double scorePercent = highestScore > 0
        ? (myScore / highestScore).clamp(0.0, 1.0)
        : 0.0;

    final leaderboard = c.leaderboard ?? [];

    return GestureDetector(
      onTap: () async {
        if (c.challengeId == null) {
          print("ID NULL");
          return;
        }

        print("CLICKED ID: ${c.challengeId}");

        final detail = await provider.fetchCompletedChallengeDetail(
          context,
          c.challengeId!,
        );

        if (detail == null) {
          print("API FAILED");
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChallengeAnalyticsScreen(
              detail: detail,
              currentUserId: provider.currentUserId,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header strip ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6750A4), Color(0xFF9C7EC4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: Row(
                children: [
                  // Trophy / rank icon
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        myRank == 1
                            ? '🥇'
                            : myRank == 2
                            ? '🥈'
                            : '🥉',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.title ?? 'Challenge',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Code ${c.roomCode ?? '-'}  ·  ${c.test?.title ?? ''}  ·  ${c.test?.durationMinutes ?? 0} min',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── My result row ──────────────────────────────────
                  Row(
                    children: [
                      // Rank badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: rankBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'RANK',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: rankFg.withOpacity(0.7),
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              '#$myRank',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: rankFg,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Score
                            Row(
                              children: [
                                Text(
                                  '$myScore',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1A1A2E),
                                  ),
                                ),
                                Text(
                                  ' / $highestScore pts',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '$totalP players',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Progress bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: scorePercent,
                                minHeight: 6,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  myRank == 1
                                      ? Colors.amber.shade600
                                      : const Color(0xFF6750A4),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              myRank == 1
                                  ? '🏆 You won this challenge!'
                                  : 'Rank #$myRank out of $totalP',
                              style: TextStyle(
                                fontSize: 11,
                                color: myRank == 1
                                    ? Colors.amber.shade700
                                    : Colors.grey.shade500,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  if (leaderboard.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    // ── Leaderboard ────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LEADERBOARD',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade500,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...leaderboard.take(3).map((entry) {
                            final rank = entry.rank ?? 0;
                            final name = entry.name ?? 'Unknown';
                            final score = entry.score ?? 0;
                            final maxScore = entry.maxScore ?? 0;
                            final isMe =
                                entry.studentId == provider.currentUserId;
                            final rankEmoji = rank == 1
                                ? '🥇'
                                : rank == 2
                                ? '🥈'
                                : '🥉';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? const Color(0xFFEDE7F6)
                                    : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: isMe
                                    ? Border.all(
                                        color: const Color(
                                          0xFF6750A4,
                                        ).withOpacity(0.3),
                                      )
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    rankEmoji,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      isMe ? '$name (You)' : name,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isMe
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: isMe
                                            ? const Color(0xFF6750A4)
                                            : const Color(0xFF1A1A2E),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '$score/$maxScore',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: rank == 1
                                          ? Colors.amber.shade700
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                          if (leaderboard.length > 3)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '+${leaderboard.length - 3} more',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 10),
                  // ── Completed at ────────────────────────────────────
                  if (c.completedAt != null)
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 13,
                          color: Colors.green.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Completed ${_formatDate(c.completedAt!)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'today';
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  // ═══════════════════════════════════════════════════════════════════
  // SECTION / TIP / EMPTY / SHIMMER
  // ═══════════════════════════════════════════════════════════════════
  Widget _sectionLabel({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTip() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.amber.shade700, size: 18),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Create a room, share the code with friends, and press Start only when everyone is ready.',
              style: TextStyle(fontSize: 12, color: Color(0xFF7A6000)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRooms() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.meeting_room_outlined,
            size: 44,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 10),
          Text(
            'No rooms yet',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Create a room or join one with a code',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Column(
      children: List.generate(
        2,
        (_) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 140,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 200,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // JOIN ROOM DIALOG
  // ═══════════════════════════════════════════════════════════════════
  void _showJoinRoomDialog(ChallengeProvider provider) {
    final codeCtrl = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: !provider.isJoining,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: accentOrange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.login, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Join Room',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'Enter the room code shared by your friend',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 20),
                TextField(
  controller: codeCtrl,
  textAlign: TextAlign.center,
  keyboardType: TextInputType.number,
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(8),
  ],
  style: const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: 5,
  ),
  decoration: InputDecoration(
    hintText: '12345678',
    counterText: '',
    filled: true,
    fillColor: Colors.grey.shade50,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: provider.isJoining
                            ? null
                            : () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentOrange,
                        ),
                        onPressed: provider.isJoining
                            ? null
                            : () async {
                                final code = codeCtrl.text.trim();
                                if (code.isEmpty) {
                                  AppToast.infoGlobal(
                                    message: "Enter room code",
                                  );
                                  return;
                                }
                                final ok = await provider.joinRoom(
                                  context,
                                  code,
                                );
                                if (ok && context.mounted) {
                                  _joinedRoomCodeByUser = code;
                                  Navigator.pop(ctx);
                                  final joined = provider.rooms.firstWhere(
                                    (r) => r.roomCode == code,
                                    orElse: () => ChallengeRoom(),
                                  );
                                  if (joined.id != null && mounted)
                                    setState(() => _selectedRoom = joined);
                                }
                              },
                        child: provider.isJoining
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Join Room'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // CREATE ROOM BOTTOM SHEET
  // ═══════════════════════════════════════════════════════════════════
void _showCreateRoomSheet(
  ChallengeProvider provider, {
  ChallengeItem? preselected,
}) {
  // Fetch categories + reset filters when sheet opens
  provider.fetchCategories(context);
  provider.clearCategoryFilter();
  provider.fetchChallengesFiltered(context);

  final titleCtrl = TextEditingController();
  final descCtrl  = TextEditingController();
  final searchCtrl = TextEditingController();
  ChallengeItem? selected = preselected;

  InputDecoration dec({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      prefixIcon: Icon(icon, color: drawerColor, size: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: drawerColor, width: 2),
      ),
    );
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Consumer<ChallengeProvider>(
              builder: (context, prov, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Drag handle ─────────────────────────────────────
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Header ──────────────────────────────────────────
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: drawerColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.group_add, color: drawerColor, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create a Room',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          Text(
                            'Invite friends with a room code',
                            style: TextStyle(
                                fontSize: 12, color: Colors.black45),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // ── Title ───────────────────────────────────────────
                  TextField(
                    controller: titleCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: dec(
                      label: 'Room Title',
                      hint: 'e.g. Saturday Physics Battle',
                      icon: Icons.title_rounded,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Description ─────────────────────────────────────
                  TextField(
                    controller: descCtrl,
                    maxLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: dec(
                      label: 'Description (optional)',
                      hint: 'What is this challenge about?',
                      icon: Icons.description_rounded,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── Category Filter label ────────────────────────────
                  Text(
                    'Filter by Category (optional)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Category chips ───────────────────────────────────
                  prov.isCategoryLoading
                      ? const SizedBox(
                          height: 36,
                          child: Center(
                            child: SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2, color: drawerColor),
                            ),
                          ),
                        )
                      : prov.categories.isEmpty
                          ? Text(
                              'No categories available',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade400),
                            )
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  // "All" chip
                                  GestureDetector(
                                    onTap: () {
                                      prov.selectCategory(null);
                                      prov.setTestSearchQuery(
                                          searchCtrl.text.trim());
                                      prov.fetchChallengesFiltered(context);
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 150),
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: prov.selectedCategory == null
                                            ? drawerColor
                                            : Colors.grey.shade100,
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'All',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              prov.selectedCategory == null
                                                  ? Colors.white
                                                  : Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Category chips
                                  ...prov.categories.map((cat) {
                                    final isSelected =
                                        prov.selectedCategory?.id == cat.id;
                                    return GestureDetector(
                                      onTap: () {
                                        prov.selectCategory(cat);
                                        prov.setTestSearchQuery(
                                            searchCtrl.text.trim());
                                        prov.fetchChallengesFiltered(
                                            context);
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                            milliseconds: 150),
                                        margin:
                                            const EdgeInsets.only(right: 8),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? drawerColor
                                              : Colors.grey.shade100,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          cat.name??'',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.grey.shade700,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                  const SizedBox(height: 14),

                  // ── Search tests ─────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: searchCtrl,
                          decoration: InputDecoration(
                            hintText: 'Search tests...',
                            hintStyle: TextStyle(
                                color: Colors.grey.shade400, fontSize: 13),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            prefixIcon: Icon(Icons.search,
                                color: Colors.grey.shade400, size: 18),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: drawerColor, width: 1.5),
                            ),
                          ),
                          onSubmitted: (v) {
                            prov.setTestSearchQuery(v.trim());
                            prov.fetchChallengesFiltered(context);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          prov.setTestSearchQuery(
                              searchCtrl.text.trim());
                          prov.fetchChallengesFiltered(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: drawerColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Search',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Select Challenge Test label ───────────────────────
                  Text(
                    'Select Challenge Test',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Test picker ──────────────────────────────────────
                  prov.isLoading
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: drawerColor),
                          ),
                        )
                      : prov.challenges.isEmpty
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: Colors.grey.shade300),
                              ),
                              child: Text(
                                'No tests found',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade400),
                              ),
                            )
                         : GestureDetector(
    onTap: () async {
      final picked = await showModalBottomSheet<ChallengeItem>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Select Challenge Test',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: prov.challenges.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: Colors.grey.shade100),
                  itemBuilder: (_, i) {
                    final c = prov.challenges[i];
                    final isSel = selected?.id == c.id;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 4,
                      ),
                      leading: Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          color: isSel
                              ? drawerColor.withOpacity(0.1)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.quiz_rounded,
                          color: isSel ? drawerColor : Colors.grey.shade400,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        c.title ?? 'Untitled',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSel ? drawerColor : const Color(0xFF1A1A2E),
                        ),
                      ),
                      subtitle: Text(
                        '${c.durationMinutes ?? 0} min  ·  '
                        '${(c.price ?? 0) == 0 ? 'Free' : '₹${c.price}'}',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                      ),
                      trailing: isSel
                          ? const Icon(Icons.check_circle_rounded,
                              color: drawerColor, size: 20)
                          : null,
                      onTap: () => Navigator.pop(context, c),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
      if (picked != null) {
        setSheet(() => selected = picked);
      }
    },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selected != null
                                        ? drawerColor.withOpacity(0.5)
                                        : Colors.grey.shade300,
                                    width: selected != null ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.quiz_rounded,
                                      color: selected != null
                                          ? drawerColor
                                          : Colors.grey.shade400,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        selected != null
                                            ? '${selected!.title ?? 'Untitled'}  ·  ${selected!.durationMinutes ?? 0} min'
                                            : 'Choose a challenge…',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: selected != null
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                          color: selected != null
                                              ? const Color(0xFF1A1A2E)
                                              : Colors.grey.shade400,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: Colors.grey.shade500,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                  // ── Selected preview chip ────────────────────────────
                  if (selected != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: drawerColor.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: drawerColor.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: drawerColor, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              selected!.title ?? '',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: drawerColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${selected!.durationMinutes ?? 0} min',
                            style: const TextStyle(
                                fontSize: 11, color: drawerColor),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 22),

                  // ── Create button ────────────────────────────────────
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: drawerColor,
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      final title = titleCtrl.text.trim();
                      if (title.isEmpty) {
                        AppToast.infoGlobal(
                            message: "Please enter a room title");
                        return;
                      }
                      if (selected == null) {
                        AppToast.infoGlobal(
                            message: "Please select a challenge");
                        return;
                      }
                      Navigator.pop(ctx);
                      await provider.createRoom(
                        context,
                        testId: selected!.id ?? '',
                        title: title,
                        description: descCtrl.text.trim(),
                      );
                    },
                    icon: const Icon(Icons.rocket_launch_rounded,
                        color: Colors.white, size: 18),
                    label: const Text(
                      'Create Room',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
}
