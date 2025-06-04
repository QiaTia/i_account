import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i_account/store/theme.dart';
import 'package:i_account/themes/multiple_theme_mode.dart';

class ChangeThemeWidget extends StatelessWidget {
  const ChangeThemeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // final currentTheme = ref.watch(currentThemeProvider);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      children: [
        /// 主题外观设置
         Padding(
          padding: const EdgeInsets.only(left: 6, top: 6, bottom: 14),
          child: const Text(
            'mine.theme_appearance',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ).tr(),
        ),

        const DarkThemeBody(),
        const SizedBox(height: 36),
        /// 多主题设置-可浅色、深色模式独立配色方案
        Padding(
          padding: const EdgeInsets.only(left: 6, top: 6, bottom: 14),
          child: const Text(
            'mine.theme_themes',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ).tr(),
        ),
        const MultipleThemeBody(),
        const SizedBox(height: 48),
      ],
    );
  }
}


/// 主题外观设置
class DarkThemeBody extends ConsumerWidget {
  const DarkThemeBody({super.key});

  @override
  Widget build(context, ref) {
    final currentThemeMode = ref.watch(currentThemeModeProvider);
    final themeModeProvider = ref.read(currentThemeModeProvider.notifier);
    /// 是否深色模式
    final isDark = themeModeProvider.isDarkMode;
    void toggleDarkMode(ThemeMode mode) {
      themeModeProvider.setTheme(mode);
    }
    return Wrap(
      alignment: WrapAlignment.center,
      direction: Axis.horizontal,
      runSpacing: 16,
      spacing: 16,
      children: [
        ThemeCard(
          title: 'mine.theme_appearance_system'.tr(),
          selected: currentThemeMode == ThemeMode.system,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  color: isDark? const Color(0xFFF6F8FA) : const Color(0xFF111315),
                  child: Text(
                    'Aa',
                    style: TextStyle(
                      color: isDark ? Colors.black87 : const Color(0xFFEFEFEF),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  color: isDark ? const Color(0xFF111315) : const Color(0xFFF6F8FA),
                  child: Text(
                    'Aa',
                    style: TextStyle(
                      color: isDark ? const Color(0xFFEFEFEF) : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
          onTap: () => toggleDarkMode(ThemeMode.system),
        ),
        ThemeCard(
          title: 'mine.theme_appearance_light'.tr(),
          selected: currentThemeMode == ThemeMode.light,
          child: Container(
            alignment: Alignment.center,
            color: const Color(0xFFF6F8FA),
            child: const Text(
              'Aa',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          onTap: () => toggleDarkMode(ThemeMode.light),
        ),
        ThemeCard(
          title: 'mine.theme_appearance_dark'.tr(),
          selected: currentThemeMode == ThemeMode.dark,
          child: Container(
            alignment: Alignment.center,
            color: const Color(0xFF111315),
            child: const Text(
              'Aa',
              style: TextStyle(
                color: Color(0xFFEFEFEF),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          onTap: () => themeModeProvider.setTheme(ThemeMode.dark),
        ),
      ],
    );
  }
}

/// 多主题设置
class MultipleThemeBody extends ConsumerWidget {
  const MultipleThemeBody({super.key});

  @override
  Widget build(context, ref) {
    /// 获取多主题
    const multipleThemeModeList = MultipleThemeMode.values;

    final multipleThemeMode = ref.watch(currentThemeProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(
        alignment: WrapAlignment.center,
        direction: Axis.horizontal,
        runSpacing: 16,
        spacing: 16,
        children: List.generate(multipleThemeModeList.length, (index) {
          final appMultipleThemeMode = multipleThemeModeList[index];
          final primaryColor = appMultipleThemeMode.state.lightTheme().primaryColor;
          return MultipleThemeCard(
            key: Key('widget_multiple_theme_card_${appMultipleThemeMode.name}'),
            selected: multipleThemeMode == appMultipleThemeMode,
            child: Container(alignment: Alignment.center, color: primaryColor),
            onTap: () {
              print('当前选择主题：${appMultipleThemeMode.name}');
              ref.read(currentThemeProvider.notifier).setTheme(appMultipleThemeMode);
            },
          );
        }),
      ),
    );
  
  }
}

/// 多主题卡片
class MultipleThemeCard extends ConsumerWidget {
  const MultipleThemeCard({
    super.key,
    this.child,
    this.selected,
    this.onTap, // dart format
  });

  /// 卡片内容
  final Widget? child;

  /// 是否选中
  final bool? selected;

  /// 点击触发
  final VoidCallback? onTap;

  @override
  Widget build(context, ref) {
    final isDark  = ref.read(currentThemeModeProvider.notifier).isDarkMode;
    final isSelected = selected ?? false;
    final borderSelected = Border.all(width: 3, color: isDark ? Colors.white : Colors.black);
    final borderUnselected = Border.all(width: 3, color: isDark ? Colors.white12 : Colors.black12);
    final borderStyle = isSelected ? borderSelected : borderUnselected;

    return AnimatedPress(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: borderStyle,
                  ),
                  child: ClipRRect(borderRadius: BorderRadius.circular(50), child: child),
                ),
                Builder(
                  builder: (_) {
                    if (!isSelected) {
                      return const SizedBox();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(right: 12, bottom: 12),
                      child: Icon(
                        Icons.check,
                        // Remix.checkbox_circle_fill,
                        size: 20,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 主题模式卡片
class ThemeCard extends ConsumerWidget {
  const ThemeCard({
    super.key,
    this.child,
    this.title,
    this.selected,
    this.onTap, // dart format
  });

  /// 卡片内容
  final Widget? child;

  /// 卡片标题
  final String? title;

  /// 是否选中
  final bool? selected;

  /// 点击触发
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, ref) {
    final isDark = ref.read(currentThemeModeProvider.notifier).isDarkMode;
    final isSelected = selected ?? false;
    final borderSelected = Border.all(width: 3, color: isDark ? Colors.white : Colors.black);
    final borderUnselected = Border.all(width: 3, color: isDark ? Colors.white12 : Colors.black12);
    final borderStyle = isSelected ? borderSelected : borderUnselected;

    return AnimatedPress(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                Container(
                  width: 100,
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: borderStyle,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: ExcludeSemantics(child: child),
                  ),
                ),
                Builder(
                  builder: (_) {
                    if (!isSelected) {
                      return const SizedBox();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(right: 8, bottom: 8),
                      child: Icon(
                        // Remix.checkbox_circle_fill,
                        Icons.check_circle,
                        size: 20,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    );
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                title ?? '',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 动画

/// 动画-按下
class AnimatedPress extends StatefulWidget {
  const AnimatedPress({super.key, required this.child, this.scaleEnd = 0.9});

  final Widget child;

  /// 按下结束后缩放的比例，最大[1.0]
  final double scaleEnd;

  @override
  State<AnimatedPress> createState() => _AnimatedPressState();
}

class _AnimatedPressState extends State<AnimatedPress> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late CurvedAnimation curve;
  late Animation<double> scale;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300))
      ..addListener(() {});
    curve = CurvedAnimation(
      parent: controller,
      curve: Curves.decelerate,
      reverseCurve: Curves.easeIn,
    );
    scale = Tween(begin: 1.0, end: widget.scaleEnd).animate(curve);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  /// 开始动画
  void controllerForward() {
    final status = controller.status;
    if (status != AnimationStatus.forward && status != AnimationStatus.completed) {
      controller.forward();
    }
  }

  /// 结束动画
  void controllerReverse() {
    controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => controllerForward(),
      onPointerHover: (_) => controllerForward(),
      onPointerMove: (_) => controllerForward(),
      onPointerCancel: (_) => controllerReverse(),
      onPointerUp: (_) => controllerReverse(),
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) => Transform.scale(scale: scale.value, child: child),
        child: widget.child,
      ),
    );
  }
}
