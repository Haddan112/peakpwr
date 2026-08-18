import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_log/widgets/glass_app_bar.dart';
import 'package:gym_log/widgets/animated_background.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Widget _buildInfoCard(String title, String content, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00E676).withValues(alpha: 0.15),
            const Color(0xFF00B248).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF00E676), Color(0xFF00B248)],
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: Colors.grey.shade300,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(
        title: 'about_developer'.tr(),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
body: AnimatedBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
          children: [
            _buildInfoCard('app_name'.tr(), 'gym_log'.tr(), Icons.apps),
            _buildInfoCard('version'.tr(), '1.0.0', Icons.info_outline),
            _buildInfoCard('developer'.tr(), 'mohamed_haddan'.tr(), Icons.person),
            _buildInfoCard('technologies'.tr(), 'about_technologies'.tr(), Icons.code),
            _buildInfoCard('description'.tr(), 'about_description'.tr(), Icons.description),
          ],
        ),
      ),
    );
  }
}