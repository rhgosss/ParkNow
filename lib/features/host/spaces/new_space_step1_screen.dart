// lib/features/host/spaces/new_space_step1_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../shared/widgets/app_widgets.dart';

class NewSpaceStep1Screen extends StatefulWidget {
  const NewSpaceStep1Screen({super.key});

  @override
  State<NewSpaceStep1Screen> createState() => _NewSpaceStep1ScreenState();
}

class _NewSpaceStep1ScreenState extends State<NewSpaceStep1Screen> {
  final titleCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  
  // Athens Center Default
  LatLng _selectedPos = const LatLng(37.9838, 23.7275);
  bool _hasSelectedLocation = false;

  @override
  void dispose() {
    titleCtrl.dispose();
    addressCtrl.dispose();
    priceCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickLocation() async {
    final result = await showDialog<LatLng>(
      context: context,
      builder: (ctx) => _LocationPickerDialog(initialPos: _selectedPos),
    );

    if (result != null) {
      setState(() {
        _selectedPos = result;
        _hasSelectedLocation = true;
        // Optionally update address text if we had geocoding
        if (addressCtrl.text.isEmpty) {
          addressCtrl.text = 'Επιλεγμένη τοποθεσία στο χάρτη';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Νέος Χώρος')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          children: [
            const _Progress(step: 1),
            const SizedBox(height: 18),
            const Text('Βασικές Πληροφορίες', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),

            AppTextField(label: 'Τίτλος', hint: 'π.χ. Στεγασμένη θέση στο κέντρο', controller: titleCtrl),
            const SizedBox(height: 10),
            
            // Address & Map Picker
            const Text('Διεύθυνση', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: '', // Label handled above
                    hint: 'Οδός, Αριθμός, Περιοχή', 
                    controller: addressCtrl
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _pickLocation,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF4FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF2563EB)),
                    ),
                    child: const Icon(Icons.map_outlined, color: Color(0xFF2563EB)),
                  ),
                ),
              ],
            ),
            if (_hasSelectedLocation)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 14, color: Color(0xFF16A34A)),
                    const SizedBox(width: 4),
                    Text(
                      'Τοποθεσία επιλέχθηκε: ${_selectedPos.latitude.toStringAsFixed(4)}, ${_selectedPos.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF16A34A)),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 10),
            AppTextField(label: 'Τιμή ανά ώρα (€)', hint: '0.00', keyboardType: TextInputType.number, controller: priceCtrl),
            const SizedBox(height: 10),
            AppTextField(label: 'Περιγραφή', hint: 'Περιγράψτε τον χώρο σας...', maxLines: 4, controller: descCtrl),

            const SizedBox(height: 14),
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Center(
                child: Icon(Icons.cloud_upload_outlined, size: 34, color: Color(0xFF6B7280)),
              ),
            ),

            const SizedBox(height: 18),
            PrimaryButton(
              text: 'Επόμενο Βήμα',
              onPressed: () {
                context.push(Uri(path: '/host/access', queryParameters: {
                  'title': titleCtrl.text,
                  'addr': addressCtrl.text,
                  'price': priceCtrl.text,
                  'desc': descCtrl.text,
                  'lat': _selectedPos.latitude.toString(),
                  'lng': _selectedPos.longitude.toString(),
                }).toString());
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationPickerDialog extends StatefulWidget {
  final LatLng initialPos;
  const _LocationPickerDialog({required this.initialPos});

  @override
  State<_LocationPickerDialog> createState() => _LocationPickerDialogState();
}

class _LocationPickerDialogState extends State<_LocationPickerDialog> {
  late LatLng _currentPos;
  final Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    super.initState();
    _currentPos = widget.initialPos;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Επίλεξε Τοποθεσία',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(
            height: 400,
            width: double.infinity,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: widget.initialPos,
                    zoom: 14,
                  ),
                  onMapCreated: (controller) => _controller.complete(controller),
                  onCameraMove: (position) {
                    _currentPos = position.target;
                  },
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                ),
                const Center(
                  child: Icon(Icons.location_on, size: 40, color: Color(0xFF2563EB)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Ακύρωση'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, _currentPos),
                    child: const Text('Επιλογή'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  final int step;
  const _Progress({required this.step});

  @override
  Widget build(BuildContext context) {
    Widget bar(bool active) => Expanded(
      child: Container(
        height: 4,
        decoration: BoxDecoration(
          color: active ? const Color(0xFF2563EB) : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );

    return Row(
      children: [
        bar(step >= 1),
        const SizedBox(width: 8),
        bar(step >= 2),
        const SizedBox(width: 8),
        bar(step >= 3),
      ],
    );
  }
}
