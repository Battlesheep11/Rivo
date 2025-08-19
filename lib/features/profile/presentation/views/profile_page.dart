import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rivo_app_beta/design_system/exports.dart';
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

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final ProfileService _profileService = ProfileService();
  late final TabController _tabController;
  String? _userId;

  StreamSubscription<Map<String, dynamic>>? _profileSubscription;

  Profile? _profile;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Safely get current user ID, handle case where user might be signed out
    _userId = Supabase.instance.client.auth.currentUser?.id;
    _tabController = TabController(length: 2, vsync: this);
    
    // Only subscribe to profile updates if user is logged in
    if (_userId != null) {
      _subscribeToProfileUpdates();
    }
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _subscribeToProfileUpdates() {
    // If no user yet, show a friendly state instead of crashing.
    final uid = _userId;
    if (uid == null || uid.isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'Not logged in';
      });
      return;
    }

    _loadProfile();

    _profileSubscription =
        _profileService.watchProfileData(uid)?.listen((profileData) {
      if (!mounted) return;
      setState(() {
        // Accepts either joined payload or plain row.
        final parsed = Profile.tryParse(profileData);
        if (parsed == null) {
          _profile = null; // e.g., row deleted or not created yet
        } else {
          _profile = parsed;
        }
        _isLoading = false;
        _error = null;
      });
    }, onError: (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }, cancelOnError: false);
  }

  Future<void> _loadProfile() async {
    final uid = _userId;
    if (uid == null || uid.isEmpty) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Not logged in';
      });
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final profileData = await _profileService.getProfileData(uid);
      if (!mounted) return;
      setState(() {
        final parsed = Profile.tryParse(profileData);
        _profile = parsed; // can be null if not found
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
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
                tabs: const [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.grid_view_rounded),
                        SizedBox(width: 8),
                        Text('My Style'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}
