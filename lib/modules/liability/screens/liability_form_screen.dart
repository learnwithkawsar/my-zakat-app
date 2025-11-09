import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/liability_controller.dart';
import '../../../models/liability_model.dart';
import '../../../services/database_service.dart';
import '../../../common/widgets/custom_text_field.dart';
import '../../../common/utils/validators.dart';
import '../../../common/utils/date_formatter.dart';

class LiabilityFormScreen extends StatefulWidget {
  final LiabilityModel? liability;

  const LiabilityFormScreen({super.key, this.liability});

  @override
  State<LiabilityFormScreen> createState() => _LiabilityFormScreenState();
}

class _LiabilityFormScreenState extends State<LiabilityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _creditorNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final controller = Get.put(LiabilityController());

  LiabilityType _selectedType = LiabilityType.shortTerm;
  DateTime? _dueDate;
  bool _includeInZakat = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.liability != null) {
      _creditorNameController.text = widget.liability!.creditorName;
      _descriptionController.text = widget.liability!.description ?? '';
      _amountController.text = widget.liability!.amount.toString();
      _selectedType = widget.liability!.type;
      _dueDate = widget.liability!.dueDate;
      _includeInZakat = widget.liability!.includeInZakat;
      _notesController.text = widget.liability!.notes ?? '';
    }
  }

  @override
  void dispose() {
    _creditorNameController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 years
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _saveLiability() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final settings = DatabaseService.getSettings();
    final amount = double.parse(_amountController.text);

    final liability = LiabilityModel(
      id: widget.liability?.id ?? DatabaseService.generateId(),
      creditorName: _creditorNameController.text,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      amount: amount,
      currency: settings.currency,
      dueDate: _dueDate,
      type: _selectedType,
      includeInZakat: _includeInZakat,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    final success = widget.liability == null
        ? await controller.addLiability(liability)
        : await controller.updateLiability(liability);

    setState(() {
      _isSaving = false;
    });

    if (success) {
      Get.back();
      Get.snackbar(
        'Success',
        widget.liability == null
            ? 'Liability added successfully'
            : 'Liability updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.liability == null ? 'Add Liability' : 'Edit Liability'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              controller: _creditorNameController,
              labelText: 'Creditor Name *',
              hintText: 'Enter creditor name',
              prefixIcon: Icons.person,
              validator: (value) =>
                  Validators.validateRequired(value, fieldName: 'Creditor name'),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _descriptionController,
              labelText: 'Description',
              hintText: 'Brief description (optional)',
              prefixIcon: Icons.description,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _amountController,
              labelText: 'Amount *',
              hintText: 'Enter liability amount',
              prefixIcon: Icons.attach_money,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) => Validators.validateAmount(value),
            ),
            const SizedBox(height: 16),
            // Liability Type
            Card(
              child: ListTile(
                leading: const Icon(Icons.category),
                title: const Text('Liability Type *'),
                subtitle: Text(_selectedType == LiabilityType.shortTerm
                    ? 'Short-term'
                    : 'Long-term'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Get.bottomSheet(
                    Container(
                      decoration: BoxDecoration(
                        color: Get.theme.scaffoldBackgroundColor,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 12, bottom: 8),
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Get.theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              'Select Liability Type',
                              style: Get.theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Divider(),
                          ListTile(
                            leading: Icon(
                              Icons.schedule,
                              color: _selectedType == LiabilityType.shortTerm
                                  ? Get.theme.colorScheme.primary
                                  : Get.theme.colorScheme.onSurface,
                            ),
                            title: Text(
                              'Short-term',
                              style: TextStyle(
                                fontWeight: _selectedType == LiabilityType.shortTerm
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: _selectedType == LiabilityType.shortTerm
                                    ? Get.theme.colorScheme.primary
                                    : Get.theme.colorScheme.onSurface,
                              ),
                            ),
                            trailing: _selectedType == LiabilityType.shortTerm
                                ? Icon(
                                    Icons.check_circle,
                                    color: Get.theme.colorScheme.primary,
                                  )
                                : null,
                            onTap: () {
                              setState(() {
                                _selectedType = LiabilityType.shortTerm;
                              });
                              Get.back();
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.calendar_today,
                              color: _selectedType == LiabilityType.longTerm
                                  ? Get.theme.colorScheme.primary
                                  : Get.theme.colorScheme.onSurface,
                            ),
                            title: Text(
                              'Long-term',
                              style: TextStyle(
                                fontWeight: _selectedType == LiabilityType.longTerm
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: _selectedType == LiabilityType.longTerm
                                    ? Get.theme.colorScheme.primary
                                    : Get.theme.colorScheme.onSurface,
                              ),
                            ),
                            trailing: _selectedType == LiabilityType.longTerm
                                ? Icon(
                                    Icons.check_circle,
                                    color: Get.theme.colorScheme.primary,
                                  )
                                : null,
                            onTap: () {
                              setState(() {
                                _selectedType = LiabilityType.longTerm;
                              });
                              Get.back();
                            },
                          ),
                          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                        ],
                      ),
                    ),
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Due Date
            Card(
              child: ListTile(
                leading: const Icon(Icons.event),
                title: const Text('Due Date (Optional)'),
                subtitle: Text(_dueDate != null
                    ? DateFormatter.formatDisplay(_dueDate!)
                    : 'Not set'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_dueDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _dueDate = null;
                          });
                        },
                      ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () => _selectDate(context),
              ),
            ),
            const SizedBox(height: 16),
            // Include in Zakat
            Card(
              child: SwitchListTile(
                title: const Text('Include in Zakat Calculation'),
                subtitle: const Text(
                    'If excluded, this liability will not be deducted from your zakatable assets'),
                value: _includeInZakat,
                onChanged: (value) {
                  setState(() {
                    _includeInZakat = value;
                  });
                },
                secondary: Icon(
                  _includeInZakat ? Icons.check_circle : Icons.block,
                  color: _includeInZakat
                      ? Get.theme.colorScheme.primary
                      : Colors.orange,
                ),
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _notesController,
              labelText: 'Notes',
              hintText: 'Additional notes (optional)',
              prefixIcon: Icons.note,
              maxLines: 4,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveLiability,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.liability == null
                        ? 'Add Liability'
                        : 'Update Liability'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

