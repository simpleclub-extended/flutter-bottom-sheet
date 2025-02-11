// Copyright (c) 2019-present,  SurfStudio LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:bottom_sheet/src/widgets/flexible_draggable_scrollable_sheet.dart';
import 'package:flutter/material.dart';

/// Start scrolling.
typedef ScrollStartCallback = bool Function(ScrollStartNotification);

/// Scrolling.
typedef ScrollCallback = bool Function(FlexibleDraggableScrollableNotification);

/// Scroll finished.
typedef ScrollEndCallback = bool Function(ScrollEndNotification);

/// Listens to drag notifications.
class FlexibleScrollNotifier extends StatelessWidget {
  final Widget child;

  final ScrollStartCallback scrollStartCallback;
  final ScrollCallback scrollCallback;
  final ScrollEndCallback scrollEndCallback;

  const FlexibleScrollNotifier({
    required this.child,
    required this.scrollStartCallback,
    required this.scrollCallback,
    required this.scrollEndCallback,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollStartNotification>(
      onNotification: scrollStartCallback,
      child: NotificationListener<ScrollEndNotification>(
        onNotification: scrollEndCallback,
        child: NotificationListener<FlexibleDraggableScrollableNotification>(
          onNotification: scrollCallback,
          child: child,
        ),
      ),
    );
  }
}
