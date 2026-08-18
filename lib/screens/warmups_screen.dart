import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_log/screens/upper_body_warmup_screen.dart';
import 'package:gym_log/screens/lower_body_warmup_screen.dart';
import 'package:gym_log/widgets/glass_app_bar.dart';
import 'package:gym_log/utils/transitions.dart';
import 'package:gym_log/widgets/animated_background.dart';

class WarmupsScreen extends StatelessWidget {
  const WarmupsScreen({super.key});

  Widget _buildOptionCard({required String title, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                gradient: LinearGradient(colors: [Color(0xFF00E676), Color(0xFF00B248)]),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey.shade600, size: 18),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(
        title: 'warmups'.tr(),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
body: AnimatedBackground(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Column(
            children: [
              _buildOptionCard(title: 'upper_body'.tr(), icon: Icons.arrow_upward, onTap: () {
                Navigator.push(context, slideRoute(const UpperBodyWarmupScreen()));
              }),
              _buildOptionCard(title: 'lower_body'.tr(), icon: Icons.arrow_downward, onTap: () {
                Navigator.push(context, slideRoute(const LowerBodyWarmupScreen()));
              }),
            ],
          ),
        ),
      ),
    );
  }
}