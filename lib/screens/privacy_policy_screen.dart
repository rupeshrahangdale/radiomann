import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../constants/app_constants.dart';
import '../services/api_service.dart';
import '../utils/app_utils.dart';
import '../widgets/custom_app_bar.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  final ApiService _apiService = ApiService();
  String _privacyPolicy = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrivacyPolicy();
  }

  Future<void> _loadPrivacyPolicy() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final policy = await _apiService.getPrivacyPolicy();
      setState(() {
        _privacyPolicy = policy;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      AppUtils.showToast('Error loading privacy policy: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Privacy Policy',
      ),
      body: _isLoading
          ? Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: AppConstants.primaryColor,
                size: 50,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadPrivacyPolicy,
              color: AppConstants.primaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Privacy Policy',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _privacyPolicy.isEmpty
                        ? const Center(
                            child: Text(
                              'No privacy policy available at the moment.',
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        : Text(
                            _privacyPolicy,
                            style: const TextStyle(fontSize: 16),
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}