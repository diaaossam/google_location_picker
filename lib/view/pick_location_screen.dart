import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_location_picker/models/location_model.dart';
import 'package:google_location_picker/provider/location_provider.dart';
import 'package:google_location_picker/view/widgets/pin_widget.dart';
import 'package:google_location_picker/view/widgets/searchable_textfield.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

final location = Provider((ref) => Location());

class PickLocationScreen extends StatefulWidget {
  const PickLocationScreen({
    super.key,
    required this.googleKey,
    this.pinColor,
    this.resultContainer,
  });
  final String googleKey;
  final Color? pinColor;
  final Widget? resultContainer;
  @override
  State<PickLocationScreen> createState() => _PickLocationScreenState();
}

class _PickLocationScreenState extends State<PickLocationScreen> {
  late ChangeNotifierProvider<LocationProvider> locationProvider;
  @override
  void initState() {
    locationProvider = ChangeNotifierProvider((ref) => LocationProvider(
          ref.read(location),
          widget.googleKey,
        ));

    context.read(locationProvider).getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Consumer(
            builder: (_, watch, __) => GoogleMap(
              myLocationButtonEnabled: false,
              myLocationEnabled: true,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  watch(locationProvider).currentLocation.latitude,
                  watch(locationProvider).currentLocation.longitude,
                ),
                zoom: 15,
              ),
              onCameraMove: context.read(locationProvider).onCameraMove,
              onCameraIdle: context.read(locationProvider).onCameraId,
              onMapCreated: context.read(locationProvider).onMapCreated,
            ),
          ),
          PinWidget(
            pinColor: widget.pinColor,
          ),
          Positioned(
            bottom: 20,
            left: 10,
            right: 10,
            child: widget.resultContainer ??
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Consumer(
                          builder: (_, watch, __) => Text(
                            watch(locationProvider).currentLocation.address ??
                                (Localizations.localeOf(context).languageCode ==
                                        "en"
                                    ? "Not defined"
                                    : "موقع غير محدد"),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      FloatingActionButton(
                        elevation: 0,
                        backgroundColor: widget.pinColor ??
                            Theme.of(context).colorScheme.primary,
                        child: const Icon(
                          Icons.arrow_forward,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(
                              context.read(locationProvider).currentLocation);
                        },
                      )
                    ],
                  ),
                ),
          ),
          Positioned(
            top: 20,
            height: 150,
            width: MediaQuery.of(context).size.width,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    const BackButton(),
                    const SizedBox(
                      width: 10,
                    ),
                    Consumer(
                      builder: (_, watch, __) => Expanded(
                        child: SearchableTextField<LocationModel>(
                          items: watch(locationProvider).searchResult,
                          onSubmit: (locationModel) {
                            context
                                .read(locationProvider)
                                .onLocationPicked(locationModel);
                          },
                          itemToString: (location) => location.address ?? "",
                          onChanged: (query) {
                            context.read(locationProvider).search(query);
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
