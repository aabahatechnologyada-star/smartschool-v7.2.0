import 'package:flutter/material.dart';
import 'api_config.dart';
import 'riyo_theme.dart';

/// X-style skeleton loader for feed cards
class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: RiyoTheme.gray800,
        borderRadius: borderRadius ?? BorderRadius.circular(RiyoTheme.radiusMd),
      ),
      child: const _ShimmerEffect(),
    );
  }
}

class _ShimmerEffect extends StatefulWidget {
  const _ShimmerEffect();

  @override
  State<_ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<_ShimmerEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: RiyoTheme.gray800,
            borderRadius: BorderRadius.circular(RiyoTheme.radiusMd),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  RiyoTheme.gray800,
                  RiyoTheme.gray700.withOpacity(_animation.value),
                  RiyoTheme.gray800,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(RiyoTheme.radiusMd),
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton for a feed card (avatar + 3 lines of text)
class FeedCardSkeleton extends StatelessWidget {
  const FeedCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: RiyoTheme.space4,
        vertical: RiyoTheme.space2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: avatar + name + handle + time
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: RiyoTheme.gray800,
                  shape: BoxShape.circle,
                ),
                child: const _ShimmerEffect(),
              ),
              const SizedBox(width: RiyoTheme.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(width: 120, height: 20, borderRadius: BorderRadius.circular(RiyoTheme.radiusFull)),
                    const SizedBox(height: RiyoTheme.space1),
                    SkeletonLoader(width: 80, height: 14, borderRadius: BorderRadius.circular(RiyoTheme.radiusFull)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: RiyoTheme.space3),
          // Content lines
          SkeletonLoader(width: double.infinity, height: 20, borderRadius: BorderRadius.circular(RiyoTheme.radiusFull)),
          const SizedBox(height: RiyoTheme.space2),
          SkeletonLoader(width: double.infinity, height: 20, borderRadius: BorderRadius.circular(RiyoTheme.radiusFull)),
          const SizedBox(height: RiyoTheme.space2),
          SkeletonLoader(width: 200, height: 20, borderRadius: BorderRadius.circular(RiyoTheme.radiusFull)),
          const SizedBox(height: RiyoTheme.space3),
          // Media placeholder
          SkeletonLoader(
            width: double.infinity,
            height: 200,
            borderRadius: BorderRadius.circular(RiyoTheme.radiusLg),
          ),
          const SizedBox(height: RiyoTheme.space3),
          // Action bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(4, (index) => SkeletonLoader(
              width: 28,
              height: 28,
              borderRadius: BorderRadius.circular(RiyoTheme.radiusFull),
            )),
          ),
        ],
      ),
    );
  }
}

/// Generic loading widget (centered spinner with optional message).
class LoadingView extends StatelessWidget {
  final String? message;
  const LoadingView({super.key, this.message});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(RiyoTheme.white),
            ),
            if (message != null) ...[
              const SizedBox(height: RiyoTheme.space3),
              Text(message!, style: RiyoTheme.bodyMedium.copyWith(color: RiyoTheme.gray400)),
            ],
          ],
        ),
      );
}

/// Generic empty-state widget.
class EmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final VoidCallback? onAction;
  final String? actionLabel;

  EmptyView({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(RiyoTheme.space6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: RiyoTheme.gray600),
              const SizedBox(height: RiyoTheme.space4),
              Text(title, style: RiyoTheme.titleLarge, textAlign: TextAlign.center),
              if (message != null) ...[
                const SizedBox(height: RiyoTheme.space2),
                Text(message!, textAlign: TextAlign.center, style: RiyoTheme.bodyMedium.copyWith(color: RiyoTheme.gray400)),
              ],
              if (onAction != null && actionLabel != null) ...[
                const SizedBox(height: RiyoTheme.space4),
                ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ],
          ),
        ),
      );

/// Generic error widget. Shows the [friendlyError] message and an optional
/// retry button. If [onRetry] is null the retry button is hidden.
class ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;
  ErrorView({super.key, required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(RiyoTheme.space6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_iconFor(error), size: 56, color: RiyoTheme.gray400),
              const SizedBox(height: RiyoTheme.space3),
              Text(
                friendlyError(error),
                textAlign: TextAlign.center,
                style: RiyoTheme.bodyMedium,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: RiyoTheme.space4),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Try again'),
                ),
              ],
            ],
          ),
        ),
      );

  IconData _iconFor(Object e) {
    if (e is ApiException) {
      switch (e.code) {
        case ApiError.noNetwork:
          return Icons.wifi_off_rounded;
        case ApiError.timeout:
          return Icons.timer_off_rounded;
        case ApiError.unauthorized:
          return Icons.lock_outline_rounded;
        case ApiError.forbidden:
          return Icons.block_rounded;
        case ApiError.notFound:
          return Icons.search_off_rounded;
        case ApiError.invalidResponse:
          return Icons.warning_amber_rounded;
        case ApiError.serverError:
        case ApiError.badRequest:
        case ApiError.unknown:
          return Icons.error_outline_rounded;
      }
    }
    return Icons.error_outline_rounded;
  }
}

/// Convenience: a single widget that switches between loading / error / empty /
/// real content based on the supplied [AsyncSnapshot]-like state.
class StateBody<T> extends StatelessWidget {
  StateBody({
    Key? key,
    required this.loading,
    required this.error,
    required this.data,
    required this.isEmpty,
    required this.builder,
    this.onRetry,
    this.emptyTitle,
    this.emptyMessage,
    this.emptyIcon = Icons.inbox_outlined,
    this.skeleton,
  }) : super(key: key);

  final bool loading;
  final Object? error;
  final T? data;
  final bool Function(T data) isEmpty;
  final Widget Function(T data) builder;
  final String? emptyTitle;
  final String? emptyMessage;
  final IconData emptyIcon;
  final VoidCallback? onRetry;
  final Widget? skeleton;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return skeleton ?? const LoadingView();
    }
    if (error != null) return ErrorView(error: error!, onRetry: onRetry);
    if (data == null || isEmpty(data as T)) {
      return EmptyView(
        icon: emptyIcon,
        title: emptyTitle ?? 'Nothing here yet',
        message: emptyMessage,
      );
    }
    return builder(data as T);
  }
}

/// Pull-to-refresh indicator with X-style
class XRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;
  final Color? backgroundColor;

  const XRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? RiyoTheme.white,
      backgroundColor: backgroundColor ?? RiyoTheme.gray900,
      strokeWidth: 2.5,
      displacement: 40,
      child: child,
    );
  }
}

/// Page transition for X-style navigation
PageRouteBuilder<T> xPageRoute<T>({
  required Widget page,
  RouteSettings? settings,
  Duration duration = const Duration(milliseconds: 250),
  Curve curve = Curves.easeOutCubic,
}) {
  return PageRouteBuilder<T>(
    settings: settings,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: curve)),
        child: child,
      );
    },
  );
}