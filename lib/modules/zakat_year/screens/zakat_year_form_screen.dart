import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/zakat_year_controller.dart';
import '../../../models/zakat_record_model.dart';
import '../../../common/widgets/custom_text_field.dart';
import '../../../common/utils/validators.dart';
import '../../../common/utils/error_handler.dart';
import '../../../common/utils/date_formatter.dart';

class ZakatYearFormScreen extends StatefulWidget {
  final ZakatRecordModel? zakatYear;

  const ZakatYearFormScreen({super.key, this.zakatYear});

  @override
  State<ZakatYearFormScreen> createState() => _ZakatYearFormScreenState();
}

class _ZakatYearFormScreenState extends State<ZakatYearFormScreen> {
  final controller = Get.put(ZakatYearController());
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _startDate = DateTime(DateTime.now().year, 1, 1);
  DateTime _endDate = DateTime(DateTime.now().year, 12, 31, 23, 59, 59);
  bool _isCurrent = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.zakatYear != null) {
      _nameController.text = widget.zakatYear!.name;
      _startDate = widget.zakatYear!.zakatYearStart;
      _endDate = widget.zakatYear!.zakatYearEnd;
      _isCurrent = widget.zakatYear!.isCurrent;
      _notesController.text = widget.zakatYear!.notes ?? '';
    } else {
      // Default to current year
      final now = DateTime.now();
      _nameController.text = 'Zakat Year ${now.year}';
      _startDate = DateTime(now.year, 1, 1);
      _endDate = DateTime(now.year, 12, 31, 23, 59, 59);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        // Auto-update name if it's still the default
        if (_nameController.text.isEmpty || 
            _nameController.text.startsWith('Zakat Year ')) {
          _nameController.text = 'Zakat Year ${picked.year}';
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    // Ensure initialDate is not before firstDate
    final initialDate = _endDate.isBefore(_startDate) ? _startDate : _endDate;
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: _startDate,
      lastDate: DateTime(2100, 12, 31),
    );
    if (picked != null) {
      setState(() {
        _endDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          23,
          59,
          59,
        );
      });
    }
  }

  Future<void> _saveZakatYear() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate dates
    if (_endDate.isBefore(_startDate)) {
      ErrorHandler.showWarning('End date must be after start date');
      return;
    }

    // Validate name
    if (_nameController.text.trim().isEmpty) {
      ErrorHandler.showWarning('Please enter a name for the zakat year');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      bool success = false;

      if (widget.zakatYear == null) {
        // Create new zakat year
        success = await controller.createZakatYear(
          name: _nameController.text.trim(),
          startDate: _startDate,
          endDate: _endDate,
          isCurrent: _isCurrent,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );

        // isCurrent is already handled in createZakatYear
      } else {
        // Update existing zakat year
        final updated = widget.zakatYear!.copyWith(
          name: _nameController.text.trim(),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          isCurrent: _isCurrent,
        );

        // If setting as current, unmark others
        if (_isCurrent && !widget.zakatYear!.isCurrent) {
          success = await controller.setAsCurrent(widget.zakatYear!.id);
        } else if (!_isCurrent && widget.zakatYear!.isCurrent) {
          // Unmark current
          final unmarked = widget.zakatYear!.copyWith(isCurrent: false);
          success = await controller.updateZakatYear(unmarked);
        } else {
          success = await controller.updateZakatYear(updated);
        }
      }

      setState(() {
        _isSaving = false;
      });

      if (success) {
        Get.back();
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      ErrorHandler.handleError(e, context: 'Failed to save zakat year');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.zakatYear != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Zakat Year' : 'Add Zakat Year'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Name Input
            CustomTextField(
              controller: _nameController,
              labelText: 'Zakat Year Name *',
              hintText: 'e.g., 2025 Zakat Year, Hijri 1446',
              prefixIcon: Icons.label,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Start Date
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Start Date *'),
                subtitle: Text(DateFormat('MMM dd, yyyy').format(_startDate)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _selectStartDate(context),
              ),
            ),
            const SizedBox(height: 16),
            // End Date
            Card(
              child: ListTile(
                leading: const Icon(Icons.event),
                title: const Text('End Date *'),
                subtitle: Text(DateFormat('MMM dd, yyyy').format(_endDate)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _selectEndDate(context),
              ),
            ),
            const SizedBox(height: 16),
            // Year Period Display (read-only when editing)
            if (isEditing)
              Card(
                color: Get.theme.colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Year Period',
                        style: Get.theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${DateFormat('MMM dd, yyyy').format(_startDate)} - ${DateFormat('MMM dd, yyyy').format(_endDate)}',
                        style: Get.theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Duration: ${_endDate.difference(_startDate).inDays + 1} days',
                        style: Get.theme.textTheme.bodySmall?.copyWith(
                          color: Get.theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (isEditing) const SizedBox(height: 16),
            // Is Current Switch
            Card(
              child: SwitchListTile(
                title: const Text('Set as Current Year'),
                subtitle: Text(
                  _isCurrent
                      ? 'This year will be marked as the current zakat year'
                      : 'This year will not be marked as current',
                  style: Get.theme.textTheme.bodySmall,
                ),
                value: _isCurrent,
                onChanged: (value) {
                  setState(() {
                    _isCurrent = value;
                  });
                },
                secondary: Icon(
                  _isCurrent ? Icons.star : Icons.star_border,
                  color: _isCurrent
                      ? Get.theme.colorScheme.primary
                      : Get.theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Notes
            CustomTextField(
              controller: _notesController,
              labelText: 'Notes',
              hintText: 'Additional notes (optional)',
              prefixIcon: Icons.note,
              maxLines: 4,
            ),
            const SizedBox(height: 32),
            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveZakatYear,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isEditing ? 'Update Zakat Year' : 'Create Zakat Year'),
              ),
            ),
            if (isEditing) ...[
              const SizedBox(height: 16),
              // Recalculate Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _isSaving
                      ? null
                      : () async {
                          setState(() {
                            _isSaving = true;
                          });
                          final success = await controller.recalculateZakatYear(
                            name: widget.zakatYear!.name,
                            startDate: widget.zakatYear!.zakatYearStart,
                            endDate: widget.zakatYear!.zakatYearEnd,
                            notes: _notesController.text.trim().isEmpty
                                ? null
                                : _notesController.text.trim(),
                          );
                          setState(() {
                            _isSaving = false;
                          });
                          if (success) {
                            Get.back();
                          }
                        },
                  icon: const Icon(Icons.calculate),
                  label: const Text('Recalculate Zakat'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

