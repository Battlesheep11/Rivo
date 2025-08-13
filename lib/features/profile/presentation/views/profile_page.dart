import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rivo_app_beta/core/design_system/design_system.dart';
import 'package:rivo_app_beta/features/profile/data/models/profile_model.dart';
import 'package:rivo_app_beta/features/profile/data/profile_service.dart';
import 'package:rivo_app_beta/features/profile/presentation/widgets/profile_header.dart';
import 'package:rivo_app_beta/features/profile/presentation/widgets/spotlight_section.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

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
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _userId = Supabase.instance.client.auth.currentUser?.id;
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

  Future<void> _deleteUser() async {
    final accessToken =
        Supabase.instance.client.auth.currentSession?.accessToken;

    if (accessToken == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not logged in')),
      );
      return;
    }

    setState(() => _isDeleting = true);

    try {
      final response = await http.post(
        Uri.parse(
            'https://nbrqyxsxsokrwkhpdvov.supabase.co/functions/v1/delete_user_self'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (!mounted) return;

      if (response.statusCode >= 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.body}')),
        );
        setState(() => _isDeleting = false);
      } else {
        await Supabase.instance.client.auth.signOut();
        if (!mounted) return;
        context.go('/');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exception: $e')),
      );
      setState(() => _isDeleting = false);
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _isDeleting ? null : _deleteUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withOpacity(0.15),
                  foregroundColor: Colors.red[800],
                ),
                child: _isDeleting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Delete My Account'),
              ),
            ),
          ),
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
