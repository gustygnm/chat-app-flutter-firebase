import 'package:chat_app_flutter_firebase/widgets/containers.dart';
import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final String _barTitle;
  Widget? primaryAction;
  Widget? secondaryAction;
  double? fontSize;
  
  late double _deviceWidth;

  TopBar(
    this._barTitle, {super.key,
    this.primaryAction,
    this.secondaryAction,
    this.fontSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    _deviceWidth = MediaQuery.sizeOf(context).width;
    return _buildUI();
  }

  Widget _buildUI() {
    return SizedBox(
      width: _deviceWidth,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (secondaryAction != null) secondaryAction!,
          _titleBar(),
          if (primaryAction != null) primaryAction!,
        ],
      ).topPadded(8),
    );
  }

  Widget _titleBar() {
    return Expanded(
      child: Center(
        child: Text(
          _barTitle,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.black,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
