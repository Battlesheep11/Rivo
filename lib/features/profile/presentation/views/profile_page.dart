import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rivo_app_beta/core/design_system/design_system.dart';
import 'package:rivo_app_beta/features/profile/data/models/profile_model.dart';
import 'package:rivo_app_beta/features/profile/data/profile_service.dart';
import 'package:rivo_app_beta/features/profile/presentation/widgets/profile_header.dart';
import 'package:rivo_app_beta/features/profile/presentation/widgets/spotlight_section.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late Future<Profile> _profileFuture;
  final ProfileService _profileService = ProfileService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final userId = Supabase.instance.client.auth.currentUser!.id;
    _profileFuture = _profileService.getProfileData(userId).then((data) => Profile.fromData(data));
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<Profile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: AppColors.error)));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Profile not found.', style: TextStyle(color: AppColors.onSurface, fontSize: 16)));
          }

          final profile = snapshot.data!;

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  backgroundColor: AppColors.surface,
                  title: Text(profile.username, style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
                  centerTitle: true,
                  pinned: true,
                  floating: true,
                  actions: [
                    IconButton(onPressed: () => context.push('/settings'), icon: const Icon(Icons.settings_outlined, color: AppColors.onSurface)),
                  ],
                ),
                SliverToBoxAdapter(child: ProfileHeader(profile: profile)),
                SliverToBoxAdapter(child: SpotlightSection()),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.gray600,
                      indicatorColor: AppColors.primary,
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.grid_view_rounded),
                              SizedBox(width: 8),
                              Text('My Style'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.receipt_long),
                              SizedBox(width: 8),
                              Text('Purchases'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: const [
                Center(child: Text('My Style Content')),
                Center(child: Text('Purchase History Content')),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.surface,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
