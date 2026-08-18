import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_log/widgets/glass_app_bar.dart';
import 'about_screen.dart';
import 'days_screen.dart';
import 'history_screen.dart';
import 'warmups_screen.dart';
import 'package:gym_log/utils/transitions.dart';
import 'package:gym_log/widgets/animated_background.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _buildLargeCard(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 100),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF00E676).withValues(alpha: 0.25),
              const Color(0xFF00B248).withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: const Color(0xFF00E676).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF00E676), Color(0xFF00B248)],
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white70,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(
        title: 'app_title'.tr(),
        leading: IconButton(
          icon: const Icon(Icons.language, color: Colors.white),
          tooltip: 'change_language'.tr(),
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: const Color(0xFF1E1E2E),
                title: Text('change_language'.tr(), style: const TextStyle(color: Colors.white)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.language, color: Colors.white70),
                      title: Text('english'.tr(), style: const TextStyle(color: Colors.white)),
                      onTap: () {
                        context.setLocale(const Locale('en'));
                        Navigator.pop(ctx);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.language, color: Colors.white70),
                      title: Text('arabic'.tr(), style: const TextStyle(color: Colors.white)),
                      onTap: () {
                        context.setLocale(const Locale('ar'));
                        Navigator.pop(ctx);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            tooltip: 'history'.tr(),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
          ),
        ],
      ),
body: AnimatedBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const Spacer(flex: 1),
                Expanded(
                  flex: 2,
                  child: _buildLargeCard(
                    'my_programme'.tr(),
                    Icons.fitness_center,
                    () => Navigator.push(context, slideRoute(const DaysScreen()))
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  flex: 2,
                  child: _buildLargeCard(
                    'warmups'.tr(),
                    Icons.local_fire_department,
                    () => Navigator.push(context, slideRoute(const WarmupsScreen()))
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  flex: 2,
                  child: _buildLargeCard(
                    'about_developer'.tr(),
                    Icons.person,
                    () => Navigator.push(context, slideRoute(const AboutScreen()))
                  ),
                ),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}