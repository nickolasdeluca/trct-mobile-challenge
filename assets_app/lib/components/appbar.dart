import 'package:assets_app/constants/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

Widget _title({String? title}) {
  return title != null
      ? Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        )
      : SvgPicture.asset(
          Assets.svg.tractianLogo,
          height: 20,
          colorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ),
        );
}

class AssetsAppBar extends AppBar {
  AssetsAppBar({
    super.key,
    String? title,
  }) : super(
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          backgroundColor: Colors.black,
          title: _title(title: title),
        );
}
