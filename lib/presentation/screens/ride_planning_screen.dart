import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/utils/responsive_layout.dart';
import '../blocs/auth_bloc/auth_bloc.dart';
import '../blocs/auth_bloc/auth_state.dart';
import '../blocs/ride_bloc/ride_bloc.dart';
import '../blocs/ride_bloc/ride_event.dart';
import '../blocs/ride_bloc/ride_state.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/ride_entity.dart';
import '../widgets/glass_card.dart';
import '../../domain/entities/payment_method_entity.dart';
import 'dart:math';

class RidePlanningScreen extends StatefulWidget {
  final LatLng pickupLocation;
  const RidePlanningScreen({super.key, required this.pickupLocation});

  @override
  State<RidePlanningScreen> createState() => _RidePlanningScreenState();
}

class _RidePlanningScreenState extends State<RidePlanningScreen> {
  final _destinationController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isWomenSafe = false;
  PaymentMethodEntity? _selectedPaymentMethod;

  double get _basePrice => 25.0; // Prix de base en CAD
  double get _tps => _basePrice * AppConstants.tpsRate;
  double get _tvq => _basePrice * AppConstants.tvqRate;
  double get _totalPrice => _basePrice + _tps + _tvq;

  @override
  Widget build(BuildContext context) {
    final bool isTablet = ResponsiveLayout.isTablet(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planification Premium'),
      ),
      body: BlocListener<RideBloc, RideState>(
        listener: (context, state) {
          if (state is RideRequestSuccess) {
            context.go('/active-ride/${state.ride.id}');
          }
        },
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: isTablet ? 600 : double.infinity),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderDesign(colorScheme),
                  const SizedBox(height: 32),
                  _buildLocationCard(colorScheme),
                  const SizedBox(height: 32),
                  _buildOptionWomenSafe(colorScheme),
                  const SizedBox(height: 32),
                  Text('Horaire de départ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colorScheme.onSurface)),
                  const SizedBox(height: 16),
                  _buildTimeSelectors(colorScheme),
                  const SizedBox(height: 32),
                  Text('Paiement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colorScheme.onSurface)),
                  const SizedBox(height: 16),
                  _buildPaymentSelector(colorScheme),
                  const SizedBox(height: 32),
                  _buildPriceBreakdown(colorScheme),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _confirmBooking,
                      child: Text('RÉSERVER POUR ${_totalPrice.toStringAsFixed(2)} ${AppConstants.currencyCode}', style: const TextStyle(letterSpacing: 1.2, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceBreakdown(ColorScheme colorScheme) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _priceRow('Prix de base', _basePrice),
          const SizedBox(height: 8),
          _priceRow('TPS (5%)', _tps),
          const SizedBox(height: 8),
          _priceRow('TVQ (9.975%)', _tvq),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL ESTIVAL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              Text(
                '${_totalPrice.toStringAsFixed(2)} ${AppConstants.currencyCode}',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: colorScheme.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Text('${amount.toStringAsFixed(2)} ${AppConstants.currencyCode}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildHeaderDesign(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 50,
          height: 5,
          decoration: BoxDecoration(color: colorScheme.secondary, borderRadius: BorderRadius.circular(10)),
        ),
        const SizedBox(height: 12),
        Text(
          'Où allons-nous aujourd\'hui ?',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: colorScheme.primary, letterSpacing: -1),
        ),
      ],
    );
  }

  Widget _buildLocationCard(ColorScheme colorScheme) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.my_location, color: colorScheme.primary),
            title: const Text('Domicile (Prise en charge)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            subtitle: Text('Ma position GPS actuelle', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6))),
          ),
          Divider(indent: 70, color: colorScheme.onSurface.withValues(alpha: 0.1)),
          ListTile(
            leading: Icon(Icons.location_on, color: colorScheme.error),
            title: TextField(
              controller: _destinationController,
              style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Saisir destination...',
                hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.3)),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionWomenSafe(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isWomenSafe ? Colors.pink.withValues(alpha: 0.05) : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _isWomenSafe ? Colors.pink : Colors.transparent),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: _isWomenSafe ? Colors.pink : colorScheme.onSurface.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(Icons.female, color: _isWomenSafe ? Colors.white : colorScheme.onSurface.withValues(alpha: 0.4), size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SafeRide Women', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                Text('Priorité aux conductrices vérifiées', style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withValues(alpha: 0.6))),
              ],
            ),
          ),
          Switch(
            value: _isWomenSafe,
            onChanged: (val) => setState(() => _isWomenSafe = val),
            activeThumbColor: Colors.pink,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelectors(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _selectDate(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 24, color: colorScheme.primary),
                  const SizedBox(height: 12),
                  Text('${_selectedDate.day}/${_selectedDate.month}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InkWell(
            onTap: () => _selectTime(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  Icon(Icons.access_time_filled_rounded, size: 24, color: colorScheme.primary),
                  const SizedBox(height: 12),
                  Text(_selectedTime.format(context), style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSelector(ColorScheme colorScheme) {
    return InkWell(
      onTap: () => context.push('/payment-methods'),
      child: GlassCard(
        child: ListTile(
          leading: Icon(
            _selectedPaymentMethod?.brand == 'visa' ? Icons.credit_card : Icons.payment,
            color: colorScheme.primary,
          ),
          title: Text(
            _selectedPaymentMethod != null 
              ? '${_selectedPaymentMethod!.brand.toUpperCase()} •••• ${_selectedPaymentMethod!.last4}'
              : 'Choisir un mode de paiement',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }

  void _confirmBooking() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final scheduledDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final otp = (1000 + Random().nextInt(9000)).toString();

      final ride = RideEntity(
        id: '',
        passengerId: authState.user.id,
        pickupLocation: widget.pickupLocation,
        destinationLocation: LatLng(widget.pickupLocation.latitude + 0.02, widget.pickupLocation.longitude + 0.02),
        pickupAddress: 'Mon Domicile',
        destinationAddress: _destinationController.text,
        scheduledTime: scheduledDateTime,
        estimatedPrice: _totalPrice,
        status: RideStatus.pending,
        otp: otp,
        isWomenSafe: _isWomenSafe,
      );

      context.read<RideBloc>().add(RequestRideEvent(ride));
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }
}
