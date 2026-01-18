// lib/features/booking/slot_booking_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/data/parking_service.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_widgets.dart';

class SlotBookingScreen extends StatefulWidget {
  final Map<String, String> params;
  const SlotBookingScreen({super.key, required this.params});

  @override
  State<SlotBookingScreen> createState() => _SlotBookingScreenState();
}

class _SlotBookingScreenState extends State<SlotBookingScreen> {
  late String spotId;
  late double pricePerHour;
  late String priceType;
  
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int? _selectedHour;
  int _duration = 1;
  
  String? _conflictError;
  
  @override
  void initState() {
    super.initState();
    spotId = widget.params['spotId'] ?? '';
    pricePerHour = double.tryParse(widget.params['price'] ?? '0') ?? 0;
    priceType = widget.params['type'] ?? 'hour';
    _selectedDay = DateTime.now();
  }

  // Get day color based on availability
  Color _getDayColor(DateTime day) {
    if (day.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return Colors.grey.shade300; // Past days
    }
    
    final availability = ParkingService().getDayAvailability(spotId, day);
    switch (availability) {
      case 'full':
        return Colors.red.shade400;
      case 'partial':
        return Colors.orange.shade400;
      case 'available':
      default:
        return Colors.green.shade400;
    }
  }

  // Validate duration against slots
  void _validateDuration() {
    if (_selectedDay == null || _selectedHour == null) {
      setState(() => _conflictError = null);
      return;
    }
    
    final startTime = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
      _selectedHour!,
    );
    
    final error = ParkingService().isTimeRangeAvailable(spotId, startTime, _duration);
    setState(() => _conflictError = error);
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedHour = null; // Reset hour selection when day changes
      _conflictError = null;
    });
  }

  void _onHourSelected(int hour) {
    setState(() {
      _selectedHour = hour;
    });
    _validateDuration();
  }

  void _updateDuration(int newDuration) {
    setState(() {
      _duration = newDuration.clamp(1, 8);
    });
    _validateDuration();
  }

  bool get _canProceed => 
    _selectedDay != null && 
    _selectedHour != null && 
    _conflictError == null;

  double get _totalPrice => pricePerHour * _duration;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Επιλογή Ημερομηνίας & Ώρας',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                // Calendar Section
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Calendar Legend
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _LegendItem(color: Colors.green.shade400, label: 'Διαθέσιμο'),
                            const SizedBox(width: 16),
                            _LegendItem(color: Colors.orange.shade400, label: 'Περιορισμένο'),
                            const SizedBox(width: 16),
                            _LegendItem(color: Colors.red.shade400, label: 'Πλήρες'),
                          ],
                        ),
                      ),
                      
                      // TableCalendar
                      TableCalendar(
                        firstDay: DateTime.now(),
                        lastDay: DateTime.now().add(const Duration(days: 90)),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                        onDaySelected: _onDaySelected,
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                        },
                        calendarStyle: CalendarStyle(
                          outsideDaysVisible: false,
                          weekendTextStyle: const TextStyle(color: Colors.black87),
                          todayDecoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.primary),
                          rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.primary),
                        ),
                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, day, focusedDay) {
                            return _buildDayCell(day, isSelected: false);
                          },
                          todayBuilder: (context, day, focusedDay) {
                            return _buildDayCell(day, isToday: true);
                          },
                          selectedBuilder: (context, day, focusedDay) {
                            return _buildDayCell(day, isSelected: true);
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Hourly Slots Section
                if (_selectedDay != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Διαθέσιμες Ώρες - ${_selectedDay!.day}/${_selectedDay!.month}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _HourlySlotGrid(
                          spotId: spotId,
                          selectedDay: _selectedDay!,
                          selectedHour: _selectedHour,
                          onHourSelected: _onHourSelected,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Duration Picker
                  if (_selectedHour != null) ...[
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Διάρκεια Στάθμευσης',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _CircleButton(
                                icon: Icons.remove,
                                onTap: () => _updateDuration(_duration - 1),
                              ),
                              const SizedBox(width: 24),
                              Text(
                                '$_duration ${_duration == 1 ? 'ώρα' : 'ώρες'}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 24),
                              _CircleButton(
                                icon: Icons.add,
                                onTap: () => _updateDuration(_duration + 1),
                              ),
                            ],
                          ),
                          if (_selectedHour != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Center(
                                child: Text(
                                  '${_selectedHour!.toString().padLeft(2, '0')}:00 - ${(_selectedHour! + _duration).toString().padLeft(2, '0')}:00',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    // Error Message
                    if (_conflictError != null)
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _conflictError!,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
                
                const SizedBox(height: 100), // Space for bottom bar
              ],
            ),
          ),
          
          // Bottom Bar (Airbnb style)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '€${_totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '€${pricePerHour.toStringAsFixed(0)} × $_duration ${_duration == 1 ? 'ώρα' : 'ώρες'}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: 150,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _canProceed ? _proceedToConfirm : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Συνέχεια',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(DateTime day, {bool isSelected = false, bool isToday = false}) {
    final color = _getDayColor(day);
    final isPast = day.isBefore(DateTime.now().subtract(const Duration(days: 1)));
    
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: isToday ? Border.all(color: AppColors.primary, width: 2) : null,
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: isSelected 
              ? Colors.white 
              : (isPast ? Colors.grey : Colors.black87),
            fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _proceedToConfirm() {
    if (_selectedDay == null || _selectedHour == null) return;
    
    final startTime = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
      _selectedHour!,
    );
    
    final params = Map<String, String>.from(widget.params);
    params['date'] = startTime.toIso8601String();
    params['duration'] = _duration.toString();
    
    context.push(Uri(path: '/booking-confirm', queryParameters: params).toString());
  }
}

// Legend Item Widget
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  
  const _LegendItem({required this.color, required this.label});
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

// Hourly Slot Grid Widget
class _HourlySlotGrid extends StatelessWidget {
  final String spotId;
  final DateTime selectedDay;
  final int? selectedHour;
  final Function(int) onHourSelected;
  
  const _HourlySlotGrid({
    required this.spotId,
    required this.selectedDay,
    required this.selectedHour,
    required this.onHourSelected,
  });
  
  @override
  Widget build(BuildContext context) {
    final availability = ParkingService().getHourlyAvailability(spotId, selectedDay);
    final now = DateTime.now();
    final isToday = selectedDay.year == now.year && 
                    selectedDay.month == now.month && 
                    selectedDay.day == now.day;
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(14, (index) {
        final hour = 8 + index; // 08:00 to 21:00
        final isAvailable = availability[hour] ?? false;
        final isPast = isToday && hour <= now.hour;
        final isSelected = selectedHour == hour;
        
        return _HourSlot(
          hour: hour,
          isAvailable: isAvailable && !isPast,
          isSelected: isSelected,
          onTap: (isAvailable && !isPast) ? () => onHourSelected(hour) : null,
        );
      }),
    );
  }
}

// Individual Hour Slot Widget (styled as ChoiceChip alternative)
class _HourSlot extends StatelessWidget {
  final int hour;
  final bool isAvailable;
  final bool isSelected;
  final VoidCallback? onTap;
  
  const _HourSlot({
    required this.hour,
    required this.isAvailable,
    required this.isSelected,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final hourStr = '${hour.toString().padLeft(2, '0')}:00';
    
    Color bgColor;
    Color textColor;
    Color borderColor;
    
    if (isSelected) {
      bgColor = AppColors.primary;
      textColor = Colors.white;
      borderColor = AppColors.primary;
    } else if (isAvailable) {
      bgColor = Colors.green.shade50;
      textColor = Colors.green.shade700;
      borderColor = Colors.green.shade300;
    } else {
      bgColor = Colors.red.shade50;
      textColor = Colors.red.shade400;
      borderColor = Colors.red.shade200;
    }
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 72,
        height: 44,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Center(
          child: Text(
            hourStr,
            style: TextStyle(
              color: textColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

// Circle Button for Duration Control
class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  
  const _CircleButton({required this.icon, required this.onTap});
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade400, width: 1.5),
        ),
        child: Icon(icon, size: 20, color: Colors.grey.shade700),
      ),
    );
  }
}
