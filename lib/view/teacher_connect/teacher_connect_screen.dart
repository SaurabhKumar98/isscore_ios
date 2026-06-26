import 'package:firstedu/res/widgets/custom_filter_chips.dart';
import 'package:firstedu/res/widgets/custom_silverappbar.dart';
import 'package:firstedu/view/teacher_connect/mentors_card.dart';
import 'package:firstedu/view_models/teacherconnectprovider/mentors_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class TeacherConnectScreen extends StatefulWidget {
  const TeacherConnectScreen({super.key});

  @override
  State<TeacherConnectScreen> createState() => _TeacherConnectScreenState();
}

class _TeacherConnectScreenState extends State<TeacherConnectScreen> {
  int selectedFilter = 0;
  final filters = ["All", "Online", "Offline"];

final ScrollController _scrollController = ScrollController();

@override
void initState() {
  super.initState();

  final provider = context.read<MentorsProvider>();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    provider.fetchMentors(context);
  });

  _scrollController.addListener(() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      provider.loadMore(context);
    }
  });
}
@override
Widget build(BuildContext context) {
  final provider = context.watch<MentorsProvider>();

  return Scaffold(
    backgroundColor: const Color(0xFFF6F7FB),
    body: RefreshIndicator(
        onRefresh: () => context.read<MentorsProvider>().fetchMentors(context),

      child: CustomScrollView(
        controller: _scrollController,
          physics: const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    ),
        slivers: [
          const CustomSliverAppBar(
            title: "Teacher Connect",
            subtitle: "Book 1-on-1 sessions with expert mentors.",
          ),
      
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  /// 🔍 SEARCH
                  TextField(
                    onChanged: (v) =>
                        provider.setSearch(context, v.trim()),
                    decoration: InputDecoration(
                      hintText: "Search mentors...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
      
                  SizedBox(height: 16.h),
      
                  /// 🟢 FILTERS
                  SizedBox(
                    height: 42.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: filters.length,
                      separatorBuilder: (_, __) => SizedBox(width: 10.w),
                      itemBuilder: (context, index) {
                        return CustomFilterChip(
                          label: filters[index],
                          selected: provider.selectedFilterIndex == index,
                          onTap: () =>
                              provider.setFilter(context, index),
                        );
                      },
                    ),
                  ),
      
                  SizedBox(height: 16.h),
      
                  /// ⏳ LOADING
                  if (provider.isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: CircularProgressIndicator(),
                    )
      
                  /// ❌ ERROR
                  else if (provider.errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Text(provider.errorMessage),
                    )
      
                  /// 📭 EMPTY
                  else if (provider.mentors.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Text("No mentors found"),
                    )
      
                  /// ✅ LIST
                  else
                    Column(
                      children: [
                        ...provider.mentors.map(
                          (mentor) => MentorCard(data: mentor),
                        ),
      
                        /// PAGINATION LOADER
                        if (provider.isPaginationLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: CircularProgressIndicator(),
                          ),
                      ],
                    ),
      
                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
