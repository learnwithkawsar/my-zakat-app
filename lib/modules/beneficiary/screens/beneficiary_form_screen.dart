import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/beneficiary_controller.dart';
import '../../../models/beneficiary_model.dart';
import '../../../services/database_service.dart';
import '../../../common/widgets/custom_text_field.dart';
import '../../../common/utils/validators.dart';

class BeneficiaryFormScreen extends StatefulWidget {
  final BeneficiaryModel? beneficiary;

  const BeneficiaryFormScreen({super.key, this.beneficiary});

  @override
  State<BeneficiaryFormScreen> createState() => _BeneficiaryFormScreenState();
}

class _BeneficiaryFormScreenState extends State<BeneficiaryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _percentageController = TextEditingController();
  final _notesController = TextEditingController();
  final controller = Get.put(BeneficiaryController());
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.beneficiary != null) {
      _nameController.text = widget.beneficiary!.name;
      _contactController.text = widget.beneficiary!.contactInfo ?? '';
      _percentageController.text = widget.beneficiary!.percentageShare != null
          ? widget.beneficiary!.percentageShare.toString()
          : '';
      _notesController.text = widget.beneficiary!.notes ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _percentageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveBeneficiary() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final percentage = _percentageController.text.isNotEmpty
        ? double.tryParse(_percentageController.text)
        : null;

    if (percentage != null && (percentage < 0 || percentage > 100)) {
      Get.snackbar(
        'Error',
        'Percentage share must be between 0 and 100',
        snackPosition: SnackPosition.BOTTOM,
      );
      setState(() {
        _isSaving = false;
      });
      return;
    }

    final beneficiary = BeneficiaryModel(
      id: widget.beneficiary?.id ?? DatabaseService.generateId(),
      name: _nameController.text,
      contactInfo: _contactController.text.isEmpty
          ? null
          : _contactController.text,
      percentageShare: percentage,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    final success = widget.beneficiary == null
        ? await controller.addBeneficiary(beneficiary)
        : await controller.updateBeneficiary(beneficiary);

    setState(() {
      _isSaving = false;
    });

    if (success) {
      Get.back();
      Get.snackbar(
        'Success',
        widget.beneficiary == null
            ? 'Beneficiary added successfully'
            : 'Beneficiary updated successfully',
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
        title: Text(widget.beneficiary == null
            ? 'Add Beneficiary'
            : 'Edit Beneficiary'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              controller: _nameController,
              labelText: 'Name *',
              hintText: 'Enter beneficiary name',
              prefixIcon: Icons.person,
              validator: (value) =>
                  Validators.validateRequired(value, fieldName: 'Name'),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _contactController,
              labelText: 'Contact Info',
              hintText: 'Phone, email, or address (optional)',
              prefixIcon: Icons.contact_phone,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _percentageController,
              labelText: 'Percentage Share',
              hintText: 'Enter percentage (0-100)',
              prefixIcon: Icons.percent,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final percentage = double.tryParse(value);
                  if (percentage == null) {
                    return 'Please enter a valid number';
                  }
                  if (percentage < 0 || percentage > 100) {
                    return 'Percentage must be between 0 and 100';
                  }
                }
                return null;
              },
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
                onPressed: _isSaving ? null : _saveBeneficiary,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.beneficiary == null
                        ? 'Add Beneficiary'
                        : 'Update Beneficiary'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

