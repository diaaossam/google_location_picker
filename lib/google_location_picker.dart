import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_location_picker/models/location_model.dart';
import 'package:google_location_picker/view/pick_location_screen.dart';

Future<LocationModel?> showLocationPicker(BuildContext context, String key,
    {Color? pinColor, Widget? resultContainer}) async {
  final result = await Navigator.of(context).push<LocationModel?>(
    MaterialPageRoute(
      builder: (_) => ProviderScope(
        child: EasyLocalization(
          supportedLocales: const [Locale('en'), Locale('ar')],
          path: "assets/translations",
          startLocale: Localizations.localeOf(context),
          child: PickLocationScreen(
            googleKey: key,
            pinColor: pinColor,
            resultContainer: resultContainer,
          ),
        ),
      ),
    ),
  );
  log(result?.address ?? "");
  return result;
}
