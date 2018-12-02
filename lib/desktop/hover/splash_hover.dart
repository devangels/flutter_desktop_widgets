

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_desktop_widgets/desktop/hover/hoverable_element.dart';



/// An experiment to combine the ripple effect with the hover events.
///
/// Might be removed in the future.
class SplashHover extends StatefulWidget {

  const SplashHover({Key key, this.child}) : super(key: key);

  final Widget child;

  @override
  _SplashHoverState createState() => new _SplashHoverState();
}


class _SplashHoverState<T extends SplashHover> extends State<T> with AutomaticKeepAliveClientMixin<T> {
  Set<InteractiveInkFeature> _splashes;
  InteractiveInkFeature _currentSplash;
  InkHighlight _lastHighlight;

  @override
  bool get wantKeepAlive => _lastHighlight != null || (_splashes != null && _splashes.isNotEmpty);

  void updateHighlight(bool value) {
    if (value == (_lastHighlight != null && _lastHighlight.active))
      return;
    if (value) {
      if (_lastHighlight == null) {
        final RenderBox referenceBox = context.findRenderObject();
        _lastHighlight = InkHighlight(
          controller: Material.of(context),
          referenceBox: referenceBox,
          color: Theme.of(context).highlightColor,
          onRemoved: _handleInkHighlightRemoval,
          textDirection: Directionality.of(context),
        );
        updateKeepAlive();
      } else {
        _lastHighlight.activate();
      }
    } else {
      _lastHighlight.deactivate();
    }
    assert(value == (_lastHighlight != null && _lastHighlight.active));

  }

  void _handleInkHighlightRemoval() {
    assert(_lastHighlight != null);
    _lastHighlight = null;
    updateKeepAlive();
  }

  InteractiveInkFeature _createInkFeature(TapDownDetails details) {
    final MaterialInkController inkController = Material.of(context);
    final RenderBox referenceBox = context.findRenderObject();
    final Offset position = referenceBox.globalToLocal(details.globalPosition);
    final Color color = Theme.of(context).splashColor;

    InteractiveInkFeature splash;
    void onRemoved() {
      if (_splashes != null) {
        assert(_splashes.contains(splash));
        _splashes.remove(splash);
        if (_currentSplash == splash)
          _currentSplash = null;
        updateKeepAlive();
      } // else we're probably in deactivate()
    }

    splash = InkRipple(
      controller: inkController,
      referenceBox: referenceBox,
      position: position,
      color: color,
      onRemoved: onRemoved,
      textDirection: Directionality.of(context),
    );

    return splash;
  }

  void _handleTapDown(TapDownDetails details) {
    final InteractiveInkFeature splash = _createInkFeature(details);
    _splashes ??= HashSet<InteractiveInkFeature>();
    _splashes.add(splash);
    _currentSplash = splash;

    updateKeepAlive();
    updateHighlight(true);
  }

  void _handleTapCancel() {
    _currentSplash?.cancel();
    _currentSplash = null;

    updateHighlight(false);
  }



  @override
  void deactivate() {
    if (_splashes != null) {
      final Set<InteractiveInkFeature> splashes = _splashes;
      _splashes = null;
      for (InteractiveInkFeature splash in splashes)
        splash.dispose();
      _currentSplash = null;
    }
    assert(_currentSplash == null);
    _lastHighlight?.dispose();
    _lastHighlight = null;
    super.deactivate();
  }


  @override
  Widget build(BuildContext context) {
    return HoveringBuilder(
      builder: (context, hover) => widget.child,
      onHoverStart: (pos) {
        TapDownDetails details = TapDownDetails(
          globalPosition: pos.pos,
        );
        _handleTapDown(details);
      },
      onHoverEnd: _handleTapCancel,

    );
  }

}
