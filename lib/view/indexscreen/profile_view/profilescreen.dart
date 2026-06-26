import 'package:firstedu/data/models/api_models/profile/profileandeditmodels.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:firstedu/view/indexscreen/certificatedownload_screen.dart';
import 'package:firstedu/view/indexscreen/profile_view/editprofilescreen.dart';
import 'package:firstedu/view/indexscreen/profile_view/referandearnscreen.dart';
import 'package:firstedu/view/wallet_view/wallet_screen.dart';
import 'package:firstedu/view_models/authprovider/authprovider.dart';
import 'package:firstedu/view_models/certificatedownloadprovider/certificatedownload_provider.dart';
import 'package:firstedu/view_models/everydaychallengeprovider/everydaychallengeprovider.dart';
import 'package:firstedu/view_models/profile_provider/profile_provider.dart';
import 'package:firstedu/view_models/refferandearnprovider/refferandearn_provider.dart';
import 'package:firstedu/view_models/wallet_provider/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchProfile(context);
      context.read<ReferAndEarnProvider>().fetchReferData(context);
      context.read<WalletProvider>().fetchPointsHistory(refresh: true);
      context.read<CertificateDownloadProvider>().fetchCertificates(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pv = context.watch<ProfileProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: pv.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: accentOrange),
              )
            : pv.profile == null
            ? _errorView(pv.error, () => pv.fetchProfile(context))
            : RefreshIndicator(
                color: accentOrange,
                onRefresh: () => pv.fetchProfile(context),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _header(context, pv.profile!),
                      const SizedBox(height: 20),
                      _profileCard(context, pv.profile!),
                      const SizedBox(height: 24),
                      _referCard(context, pv.profile!),
                      const SizedBox(height: 24),
                      _statsGrid(),
                      const SizedBox(height: 24),
                      _badgesEarned(context),
                      const SizedBox(height: 24),
                      _certificates(context),
                      const SizedBox(height: 24),
                      _accountSettings(context),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // ── Error view ────────────────────────────────────────────────────────────
  Widget _errorView(String msg, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 52, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              "Couldn't load profile",
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (msg.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                msg,
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Retry",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _header(BuildContext context, ProfileModel p) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "My Profile",
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
        ),
        GestureDetector(
          onTap: () => _openEdit(context, p),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: drawerColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.edit_outlined, color: Colors.white, size: 15),
                const SizedBox(width: 6),
                Text(
                  "Edit",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openEdit(BuildContext context, ProfileModel p) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EditProfileScreen(profile: p)),
    );
    if (updated == true && context.mounted) {
      context.read<ProfileProvider>().fetchProfile(context);
    }
  }

  // ── Profile card ──────────────────────────────────────────────────────────
  Widget _profileCard(BuildContext context, ProfileModel p) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _avatar(p),
          const SizedBox(height: 12),
          Text(
            p.name.isNotEmpty ? p.name : "—",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            [
                  if (p.status?.isNotEmpty == true) p.status!,
                  if (p.createdAt != null) "joined ${p.createdAt!.year}",
                ].join(" • ").isNotEmpty
                ? [
                    if (p.status?.isNotEmpty == true) p.status!,
                    if (p.createdAt != null) "joined ${p.createdAt!.year}",
                  ].join(" • ")
                : "Student",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          _infoTile(
            Icons.person_outline_rounded,
            "FULL NAME",
            p.name.isNotEmpty ? p.name : "—",
          ),
          const SizedBox(height: 12),
          _infoTile(
            Icons.email_outlined,
            "EMAIL",
            p.email.isNotEmpty ? p.email : "—",
          ),
          if (p.phone?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            _infoTile(Icons.phone_outlined, "PHONE", p.phone!),
          ],
          if (p.schoolOrCollege?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            _infoTile(
              Icons.school_outlined,
              "SCHOOL / COLLEGE",
              p.schoolOrCollege!,
            ),
          ],
          if (p.classOrGrade?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            _infoTile(Icons.class_outlined, "CLASS / GRADE", p.classOrGrade!),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: drawerColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => _openEdit(context, p),
              child: Text(
                "Edit Profile",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar(ProfileModel p) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [accentOrange.withValues(alpha: 0.6), Colors.transparent],
        ),
      ),
      child: CircleAvatar(
        radius: 44,
        backgroundImage: p.profileImage?.isNotEmpty == true
            ? NetworkImage(p.profileImage!)
            : null,
        backgroundColor: accentOrange.withOpacity(0.15),
        child: p.profileImage?.isNotEmpty != true
            ? Text(
                p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: accentOrange,
                ),
              )
            : null,
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Refer card ────────────────────────────────────────────────────────────
  Widget _referCard(BuildContext context, ProfileModel p) {
    return Consumer<ReferAndEarnProvider>(
      builder: (context, provider, _) {
        final data = provider.data;

        final code = data?.referralCode ?? "—";
        final totalReferrals = data?.totalReferrals ?? 0;
        final points = data?.pointsPerReferral ?? 0;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEF6C00), Color(0xFFF57C00)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Refer & Earn",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Invite friends and earn $points XP.",
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: code));
                  AppToast.successGlobal(message: "Referral code copied!");
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        code,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const Icon(Icons.copy, color: Colors.white),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.group_outlined,
                    size: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "$totalReferrals Friends Invited",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "How to Refer & earn",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReferEarnScreen(),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Standalone widgets ──────────────────────────────────────────────────────

Widget _certificates(BuildContext context) {
  return Consumer<CertificateDownloadProvider>(
    builder: (context, provider, _) {
      final certificates = provider.certificates;

      if (provider.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (certificates.isEmpty) {
        return _sectionCard(
          title: "Certificates",
          icon: Icons.badge_outlined,
          children: const [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text("No certificates available"),
            ),
          ],
        );
      }

      final cert = certificates.first;

      return _sectionCard(
        title: "Certificates",
        action: "View All",
        icon: Icons.badge_outlined,
        onActionTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CertificatesEarnedScreen(),
            ),
          );
        },
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cert.title ?? "Certificate",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "Issued: ${_formatDate(cert.createdAt)} · ID: ${cert.id ?? ""}",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.download, color: Colors.grey),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}

String _formatDate(DateTime? date) {
  if (date == null) return "";
  return "${date.day} ${_monthName(date.month)} ${date.year}";
}

String _monthName(int m) {
  const months = [
    "",
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];
  return months[m];
}

Widget _sectionCard({
  required String title,
  required IconData icon,
  String? action,
  VoidCallback? onActionTap,
  required List<Widget> children,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      children: [
        Row(
          children: [
            Icon(icon, color: accentOrange),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (action != null)
              GestureDetector(
                onTap: onActionTap,
                child: Text(
                  action,
                  style: GoogleFonts.poppins(
                    color: accentOrange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    ),
  );
}

Widget _badgesEarned(BuildContext context) {
  return Consumer<WalletProvider>(
    builder: (context, wallet, _) {
      final history = wallet.pointsHistory?.items ?? [];

      if (wallet.isHistoryLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (history.isEmpty) {
        return _sectionCard(
          title: "Badges Earned",
          icon: Icons.emoji_events_outlined,
          children: const [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text("No badges earned yet"),
            ),
          ],
        );
      }

      return _sectionCard(
        title: "Badges Earned",
        action: "View All",
        icon: Icons.emoji_events_outlined,
        onActionTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WalletScreen()),
          );
        },
        children: history
            .take(3)
            .map(
              (item) => _BadgeTile(
                icon: _getIcon(item.source),
                title: _getTitle(item.source),
                subtitle: item.description ?? "",
                xp: "+${item.amount} XP",
              ),
            )
            .toList(),
      );
    },
  );
}

IconData _getIcon(String? source) {
  switch (source) {
    case "everyday_challenge":
      return Icons.local_fire_department;
    case "test_completion":
      return Icons.school;
    default:
      return Icons.star;
  }
}

String _getTitle(String? source) {
  switch (source) {
    case "everyday_challenge":
      return "Daily Streak";
    case "test_completion":
      return "Test Completed";
    default:
      return "Achievement";
  }
}

class _BadgeTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle, xp;
  const _BadgeTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.xp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: accentOrange.withValues(alpha: 0.15),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(14),
                  topRight: Radius.circular(100),
                  bottomRight: Radius.circular(14),
                ),
              ),
              child: Text(
                xp,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: accentOrange,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accentOrange),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey,
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
    );
  }
}

// ── Account Settings (Sign Out + Delete Account) ──────────────────────────────
Widget _accountSettings(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Sign Out ──────────────────────────────────────────────
        GestureDetector(
          onTap: () => _showLogoutDialog(context),
          child: Row(
            children: [
              const Icon(Icons.logout, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                "Sign Out",
                style: GoogleFonts.poppins(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        Divider(color: Colors.grey.shade200, height: 1),
        const SizedBox(height: 16),

        // ── Delete Account ────────────────────────────────────────
        GestureDetector(
          onTap: () => _showDeleteAccountDialog(context),
          child: Row(
            children: [
              const Icon(Icons.delete_forever_outlined, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                "Delete Account",
                style: GoogleFonts.poppins(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "Permanent",
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ── Logout dialog ─────────────────────────────────────────────────────────────
void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.logout_rounded,
                color: Colors.red.shade600,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Sign Out",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Are you sure you want to sign out of your account?",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(dialogContext);
                      await context.read<Authprovider>().logout(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "Sign Out",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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
  );
}

// ── Delete Account dialog ─────────────────────────────────────────────────────
void _showDeleteAccountDialog(BuildContext context) {
  final passwordController = TextEditingController();

  bool obscure = true;
  bool isLoading = false;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.delete, color: Colors.red, size: 40),
                  const SizedBox(height: 10),

                  const Text(
                    "Delete Account",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: passwordController,
                    obscureText: obscure,
                    decoration: InputDecoration(
                      hintText: "Enter password",
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscure
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            obscure = !obscure;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  Navigator.pop(dialogContext);
                                },
                          child: const Text("Cancel"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  if (passwordController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text("Enter password")),
                                    );
                                    return;
                                  }

                                  setDialogState(() {
                                    isLoading = true;
                                  });

                                  final success = await context
                                      .read<ProfileProvider>()
                                      .deleteAccount(
                                        context,
                                        password:
                                            passwordController.text.trim(),
                                      );

                                  setDialogState(() {
                                    isLoading = false;
                                  });

                                  if (success) {
                                    Navigator.pop(dialogContext);
                                    await context
                                        .read<Authprovider>()
                                        .logout(context);
                                  }
                                },
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text("Delete"),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
Widget _statsGrid() {
  return GridView.count(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount: 2,
    mainAxisSpacing: 16,
    crossAxisSpacing: 16,
    childAspectRatio: 1.6,
    children: [
      Consumer<WalletProvider>(
        builder: (context, provider, _) {
          return _StatTile(
            value: provider.totalPoints.toString(),
            label: "BADGES",
          );
        },
      ),
      Consumer<CertificateDownloadProvider>(
        builder: (context, provider, _) {
          return _StatTile(
            value: provider.totalCertificates.toString(),
            label: "CERTS",
          );
        },
      ),
      Consumer<Everydaychallengeprovider>(
        builder: (context, provider, _) {
          return _StatTile(
            value: provider.totalStreak.toString(),
            label: "DAY STREAK",
          );
        },
      ),
    ],
  );
}
class _StatTile extends StatelessWidget {
  final String value, label;
  const _StatTile({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: accentOrange,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}