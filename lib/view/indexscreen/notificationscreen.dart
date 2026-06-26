
import 'package:firstedu/data/models/api_models/notification/notification_models.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_card.dart';
import 'package:firstedu/res/widgets/custom_silverappbar.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:firstedu/view_models/notificationprovider/notificationprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {

  @override
  void initState() {
    super.initState();

    /// 🔥 FETCH NOTIFICATIONS
    Future.microtask(() {
      context.read<NotificationProvider>().fetchNotifications(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {

          /// 🔄 LOADING
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          /// ❌ ERROR
          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          final notifications = provider.notifications;
          final unreadCount = provider.unreadCount;

          return CustomScrollView(
            slivers: [
              const CustomSliverAppBar(
                title: "Notifications",
                subtitle:
                    "History of all past alerts. Click an item to mark it as read.",
              ),

              SliverPadding(
                padding: EdgeInsets.all(16.w),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([

                    /// 🔥 HEADER (UNREAD + BUTTON)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _unreadBadge(unreadCount),

                        ElevatedButton(
                          onPressed: unreadCount == 0
                              ? null
                              : () {
                                  context
                                      .read<NotificationProvider>()
                                      .markAllAsReadFromApi(context);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            disabledBackgroundColor: Colors.grey.shade300,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            "Mark all read",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),

                    16.h.verticalSpace,

                    /// 🔥 EMPTY STATE
                    if (notifications.isEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 80.h),
                        child: Center(
                          child: Text(
                            "No notifications available",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ),

                    /// 🔥 LIST
                    ...notifications.map((n) => _notificationCard(n)),

                    100.h.verticalSpace,
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 🔔 UNREAD BADGE
  Widget _unreadBadge(int count) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: CustomText(
        text: "$count unread",
        size: 12,
        weight: FontWeight.w600,
        color: Colors.orange,
      ),
    );
  }

  /// 🔔 NOTIFICATION CARD
  Widget _notificationCard(NotificationItem item) {
    return GestureDetector(
      onTap: () {
        /// ✅ MARK SINGLE AS READ (LOCAL)
        context.read<NotificationProvider>().markAsRead(item.id ?? "");
      },
      child: CustomCard(
          margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: item.isRead == false
              ? Colors.blue.withOpacity(0.05)
              : containerColor,
          borderRadius: BorderRadius.circular(16.r),
          border: item.isRead == false
              ? Border.all(color: Colors.blue.withOpacity(0.2))
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ICON
            Container(
              width: 46.w,
              height: 46.w,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.notifications, size: 22.sp),
            ),

            14.w.horizontalSpace,

            /// CONTENT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    children: [
                      Expanded(
                        child: CustomText(
                          text: item.title ?? "No Title",
                          size: 14,
                          weight: FontWeight.w700,
                          maxLines: 1,
                        ),
                      ),

                      /// 🔴 UNREAD DOT
                      if (item.isRead == false)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),

                  6.h.verticalSpace,

                  CustomText(
                    text: item.body ?? "",
                    size: 13,
                    color: Colors.grey.shade700,
                    maxLines: 3,
                  ),

                  10.h.verticalSpace,

                  Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 14.sp, color: Colors.grey),
                      6.w.horizontalSpace,
                      CustomText(
                        text: item.createdAt?.toString() ?? "",
                        size: 11,
                        color: Colors.grey.shade600,
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
}
