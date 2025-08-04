import 'dart:async';

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
  final ProfileService _profileService = ProfileService();
  late final TabController _tabController;
  late final String _userId;
  
  // Stream subscription for profile updates
  StreamSubscription<Map<String, dynamic>>? _profileSubscription;
  
  // Profile state
  Profile? _profile;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _userId = Supabase.instance.client.auth.currentUser!.id;
    _tabController = TabController(length: 2, vsync: this);
    _subscribeToProfileUpdates();
  }
  
  @override
  void dispose() {
    _profileSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }
  
  void _subscribeToProfileUpdates() {
    // Initial load
    _loadProfile();
    
    // Subscribe to updates
    _profileSubscription = _profileService.watchProfileData(_userId)?.listen(
      (profileData) {
        if (mounted) {
          setState(() {
            _profile = Profile.fromData(profileData);
            _isLoading = false;
            _error = null;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _error = error.toString();
            _isLoading = false;
          });
        }
      },
      cancelOnError: false,
    );
  }
  
  Future<void> _loadProfile() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }
    
    try {
      final profileData = await _profileService.getProfileData(_userId);
      if (mounted) {
        setState(() {
          _profile = Profile.fromData(profileData);
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error loading profile',
                style: TextStyle(color: AppColors.error, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loadProfile,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_profile == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text(
            'Profile not found',
            style: TextStyle(color: AppColors.onSurface, fontSize: 16),
          ),
        ),
      );
    }

    final profile = _profile!;

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            backgroundColor: AppColors.surface,
            title: Text(
              profile.username,
              style: const TextStyle(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            pinned: true,
            floating: true,
            actions: [
              IconButton(
                onPressed: () => context.push('/settings'),
                icon: const Icon(
                  Icons.settings_outlined,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(child: ProfileHeader(profile: profile)),
          const SliverToBoxAdapter(child: SpotlightSection()),
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
