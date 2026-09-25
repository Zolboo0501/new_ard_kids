import 'package:flutter/material.dart';

import 'entrance.dart';

/// Window-size rules shared by every screen.
///
/// The screens are designed for a phone. Phones of every size, Plus and
/// Pro Max included, keep that layout at full width. Wider windows (iPad,
/// Android tablets, a wide split view) restructure instead of stretching:
///
/// * from [tabletMin] the whole interface is drawn bigger ([AppScale]);
/// * page content uses the full width, up to [contentMax], clear of the
///   window's side insets ([AdaptiveListView]);
/// * from [splitMin] of available width, overview screens show two panes
///   side by side ([AdaptiveSplit]).
///
/// Decisions about content use the width actually available (a
/// [LayoutBuilder]), not the window, so a screen in split view lays out for
/// the space it really has.
abstract final class AppLayout {
  /// Shortest window side from which a device counts as a tablet.
  static const tabletMin = 600.0;

  /// Available width from which [AdaptiveSplit] shows two panes.
  static const splitMin = 800.0;

  /// Widest page content gets, one column or two panes. Unlimited: on iPad
  /// the content fills the width. Lower it to center a capped column.
  static const contentMax = double.infinity;

  /// Width of the leading (summary) pane of [AdaptiveSplit].
  static const leadingPane = 380.0;

  /// Space between the two panes.
  static const paneGap = 24.0;

  /// Bottom padding a shell tab's scroll view needs to clear the floating
  /// bottom bar.
  static double navClearance(BuildContext context) =>
      120 + MediaQuery.paddingOf(context).bottom;

  /// [base] with its horizontal padding grown so that, in [available] width,
  /// the content between is at most [maxWidth] wide and centered.
  ///
  /// [insets] are the window's side insets (a landscape notch): the content
  /// keeps clear of them and centers in what is left.
  static EdgeInsets centered(
    EdgeInsets base,
    double available, {
    double maxWidth = contentMax,
    EdgeInsets insets = EdgeInsets.zero,
  }) {
    base = base.copyWith(
      left: base.left + insets.left,
      right: base.right + insets.right,
    );
    final content = available - base.left - base.right;
    if (content <= maxWidth) return base;
    final extra = (content - maxWidth) / 2;
    return base.copyWith(left: base.left + extra, right: base.right + extra);
  }
}

/// Makes the whole interface bigger on tablets.
///
/// The screens are drawn for a phone held close; an iPad sits further away,
/// so at the same point sizes its text and controls read small. Under this
/// widget the app lays out in a smaller logical window (the real one divided
/// by [factorFor]) and is drawn scaled up to fill the screen. Text, icons,
/// spacing and touch targets all grow together, and every layout rule
/// ([AppLayout]) sees the scaled size. Phones get a factor of 1 and are left
/// alone.
///
/// Used as `MaterialApp.router(builder: AppScale.builder)`, so it wraps the
/// navigator and with it every route, sheet and dialog.
class AppScale extends StatelessWidget {
  const AppScale({super.key, required this.child});

  final Widget child;

  static Widget builder(BuildContext context, Widget? child) =>
      AppScale(child: child ?? const SizedBox.shrink());

  /// How much bigger the interface is drawn in a window of [size]: 1 on
  /// phones, 1.2 on iPad and tablets, 1.3 on the largest (iPad Pro 13").
  static double factorFor(Size size) {
    final side = size.shortestSide;
    if (side < AppLayout.tabletMin) return 1;
    return side >= 1000 ? 1.3 : 1.2;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final factor = factorFor(media.size);
    if (factor == 1) return child;
    final size = media.size / factor;
    // Fill the window even under loose constraints (the loader's fade
    // stack), or FittedBox would shrink to the unscaled layout and not
    // scale at all.
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.fill,
        alignment: Alignment.topLeft,
        child: SizedBox.fromSize(
          size: size,
          child: MediaQuery(
            data: media.copyWith(
              size: size,
              devicePixelRatio: media.devicePixelRatio * factor,
              padding: media.padding / factor,
              viewPadding: media.viewPadding / factor,
              viewInsets: media.viewInsets / factor,
              systemGestureInsets: media.systemGestureInsets / factor,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A [ListView] whose content sits in a centered column at most [maxWidth]
/// wide. The list itself stays full width, so it scrolls from anywhere and
/// the screen's background runs edge to edge.
class AdaptiveListView extends StatelessWidget {
  const AdaptiveListView({
    super.key,
    required this.padding,
    required this.children,
    this.maxWidth = AppLayout.contentMax,
    this.controller,
    this.physics,
  });

  final EdgeInsets padding;
  final List<Widget> children;
  final double maxWidth;
  final ScrollController? controller;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        controller: controller,
        physics: physics,
        padding: AppLayout.centered(
          padding,
          constraints.maxWidth,
          maxWidth: maxWidth,
          insets: _sideInsets(context),
        ),
        children: children,
      ),
    );
  }
}

/// Centers [child] at most [maxWidth] wide, for content outside a list
/// (a pinned footer button, a keypad).
class AdaptiveCenter extends StatelessWidget {
  const AdaptiveCenter({
    super.key,
    required this.child,
    this.maxWidth = AppLayout.contentMax,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// An overview screen's scroll body: one column on phones, two panes side by
/// side once there is [AppLayout.splitMin] of width.
///
/// [leading] is the summary (a balance, a card, a profile) and [trailing]
/// the detail (transactions, settings). Split, the leading pane has a fixed
/// width and each pane scrolls on its own, so the summary stays in view
/// while the detail scrolls. In one column [leading] comes first, then
/// [gap], then [trailing].
///
/// Both lists get [EntranceItem.list] here: pass the bare widgets.
class AdaptiveSplit extends StatelessWidget {
  const AdaptiveSplit({
    super.key,
    required this.padding,
    required this.leading,
    required this.trailing,
    this.gap = 16,
  });

  /// The whole body's padding; in two panes it frames both of them.
  final EdgeInsets padding;
  final List<Widget> leading;
  final List<Widget> trailing;

  /// Space between [leading] and [trailing] in one column.
  final double gap;

  /// Whether [available] width shows two panes.
  static bool isSplit(double available) => available >= AppLayout.splitMin;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final insets = _sideInsets(context);
        final available = constraints.maxWidth;
        if (!isSplit(available - insets.horizontal)) {
          return ListView(
            padding: AppLayout.centered(padding, available, insets: insets),
            children: EntranceItem.list([
              ...leading,
              SizedBox(height: gap),
              ...trailing,
            ]),
          );
        }
        final frame = AppLayout.centered(
          padding,
          available,
          maxWidth: AppLayout.contentMax,
          insets: insets,
        );
        final vertical = EdgeInsets.only(top: frame.top, bottom: frame.bottom);
        return Padding(
          padding: EdgeInsets.only(left: frame.left, right: frame.right),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: AppLayout.leadingPane,
                child: ListView(
                  padding: vertical,
                  children: EntranceItem.list(leading),
                ),
              ),
              const SizedBox(width: AppLayout.paneGap),
              Expanded(
                child: ListView(
                  padding: vertical,
                  children: EntranceItem.list(trailing),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// The window's left and right insets, which page content keeps clear of.
EdgeInsets _sideInsets(BuildContext context) {
  final padding = MediaQuery.paddingOf(context);
  return EdgeInsets.only(left: padding.left, right: padding.right);
}

/// A grid column count that grows with the available width: [compact]
/// columns on a phone, one more per [step] of extra width, up to [max].
int adaptiveColumns(
  double available, {
  required int compact,
  double phoneWidth = 390,
  double step = 160,
  int? max,
}) {
  final extra = ((available - phoneWidth) / step).floor();
  final count = compact + (extra > 0 ? extra : 0);
  return max == null ? count : count.clamp(compact, max);
}
