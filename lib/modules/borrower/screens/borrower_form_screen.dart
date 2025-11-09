import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/borrower_controller.dart';
import '../../../models/borrower_model.dart';
import '../../../common/widgets/custom_text_field.dart';
import '../../../common/utils/validators.dart';

class BorrowerFormScreen extends StatefulWidget {
  final BorrowerModel? borrower;

  const BorrowerFormScreen({super.key, this.borrower});

  @override
  State<BorrowerFormScreen> createState() => _BorrowerFormScreenState();
}

class _BorrowerFormScreenState extends State<BorrowerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final controller = Get.find<BorrowerController>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.borrower != null) {
      _nameController.text = widget.borrower!.name;
      _contactController.text = widget.borrower!.contactInfo ?? '';
      _addressController.text = widget.borrower!.address ?? '';
      _notesController.text = widget.borrower!.notes ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveBorrower() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final success = widget.borrower == null
        ? await controller.addBorrower(
            name: _nameController.text,
            contactInfo: _contactController.text.isEmpty
                ? null
                : _contactController.text,
            address: _addressController.text.isEmpty
                ? null
                : _addressController.text,
            notes: _notesController.text.isEmpty ? null : _notesController.text,
          )
        : await controller.updateBorrower(
            widget.borrower!.copyWith(
              name: _nameController.text,
              contactInfo: _contactController.text.isEmpty
                  ? null
                  : _contactController.text,
              address: _addressController.text.isEmpty
                  ? null
                  : _addressController.text,
              notes: _notesController.text.isEmpty
                  ? null
                  : _notesController.text,
            ),
          );

    setState(() {
      _isSaving = false;
    });

    if (success) {
      Get.back();
      Get.snackbar(
        'Success',
        widget.borrower == null
            ? 'Borrower added successfully'
            : 'Borrower updated successfully',
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
        title: Text(widget.borrower == null ? 'Add Borrower' : 'Edit Borrower'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              controller: _nameController,
              labelText: 'Name *',
              hintText: 'Enter borrower name',
              prefixIcon: Icons.person,
              textCapitalization: TextCapitalization.words,
              validator: (value) => Validators.validateRequired(value, fieldName: 'Name'),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _contactController,
              labelText: 'Contact Info',
              hintText: 'Phone, email, etc.',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _addressController,
              labelText: 'Address',
              hintText: 'Enter address',
              prefixIcon: Icons.location_on,
              textCapitalization: TextCapitalization.words,
              maxLines: 2,
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
                onPressed: _isSaving ? null : _saveBorrower,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.borrower == null ? 'Add Borrower' : 'Update Borrower'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

