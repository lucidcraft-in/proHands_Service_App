import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/service_model.dart';
import '../providers/service_boy_provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../models/service_category_model.dart';
import '../models/service_subcategory_model.dart';

class EditServiceScreen extends StatefulWidget {
  final ServiceModel service;

  const EditServiceScreen({super.key, required this.service});

  @override
  State<EditServiceScreen> createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  String? _selectedCategoryId;
  String? _selectedSubcategoryId;
  List<String> _selectedAdditionalSkills = [];
  late bool _isTrending;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.service.name);
    _descriptionController = TextEditingController(
      text: widget.service.description,
    );
    _selectedCategoryId =
        widget.service.categoryId.isNotEmpty ? widget.service.categoryId : null;
    _selectedSubcategoryId =
        widget.service.subcategoryId.isNotEmpty
            ? widget.service.subcategoryId
            : null;
    _isTrending = widget.service.isTrending;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ServiceBoyProvider>();
      provider.fetchCategories();
      if (_selectedCategoryId != null) {
        provider.fetchSubcategories(_selectedCategoryId!);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    // Build only the changed fields
    final Map<String, dynamic> updatedFields = {};

    if (_nameController.text.trim() != widget.service.name) {
      updatedFields['name'] = _nameController.text.trim();
    }
    if (_descriptionController.text.trim() != widget.service.description) {
      updatedFields['description'] = _descriptionController.text.trim();
    }
    if (_selectedCategoryId != null &&
        _selectedCategoryId != widget.service.categoryId) {
      updatedFields['categoryId'] = _selectedCategoryId;
    }
    if (_selectedSubcategoryId != null &&
        _selectedSubcategoryId != widget.service.subcategoryId) {
      updatedFields['subcategoryId'] = _selectedSubcategoryId;
    }
    if (_selectedAdditionalSkills.isNotEmpty) {
      updatedFields['additionalSkills'] = _selectedAdditionalSkills;
    }
    if (_isTrending != widget.service.isTrending) {
      updatedFields['isTrending'] = _isTrending;
    }

    if (updatedFields.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No changes to save')));
      return;
    }

    final provider = context.read<ServiceBoyProvider>();
    final success = await provider.updateService(
      widget.service.id,
      updatedFields,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.updateServiceError ?? 'Failed to update service',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Edit Service', style: AppTextStyles.h4),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<ServiceBoyProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Selector
                  Text('Category', style: AppTextStyles.labelMedium),
                  const SizedBox(height: 8),
                  DropdownSearch<ServiceCategoryModel>(
                    items: provider.categories,
                    itemAsString: (ServiceCategoryModel c) => c.name,
                    selectedItem:
                        _selectedCategoryId == null
                            ? null
                            : provider.categories
                                .cast<ServiceCategoryModel?>()
                                .firstWhere(
                                  (e) => e?.id == _selectedCategoryId,
                                  orElse: () => null,
                                ),
                    popupProps: const PopupProps.menu(showSearchBox: true),
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        hintText:
                            widget.service.categoryName.isNotEmpty
                                ? widget.service.categoryName
                                : "Select Category",
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    onChanged: (ServiceCategoryModel? selected) {
                      if (selected?.id != _selectedCategoryId) {
                        setState(() {
                          _selectedCategoryId = selected?.id;
                          _selectedSubcategoryId = null;
                        });

                        if (selected != null) {
                          provider.fetchSubcategories(selected.id);
                        } else {
                          provider.clearSubcategories();
                        }
                      }
                    },
                    dropdownBuilder: (context, selectedItem) {
                      if (selectedItem == null) {
                        return Text(
                          widget.service.categoryName.isNotEmpty
                              ? widget.service.categoryName
                              : "Select Category",
                          style: AppTextStyles.bodyMedium,
                        );
                      }

                      return Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: _getColor(
                                selectedItem.color,
                              ).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Text(selectedItem.icon),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            selectedItem.name,
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Subcategory Selector
                  Text('Subcategory', style: AppTextStyles.labelMedium),
                  const SizedBox(height: 8),
                  DropdownSearch<ServiceSubcategoryModel>(
                    items: provider.subcategories,
                    itemAsString: (ServiceSubcategoryModel s) => s.name,
                    selectedItem:
                        _selectedSubcategoryId == null
                            ? null
                            : provider.subcategories
                                .cast<ServiceSubcategoryModel?>()
                                .firstWhere(
                                  (e) => e?.id == _selectedSubcategoryId,
                                  orElse: () => null,
                                ),
                    popupProps: const PopupProps.menu(showSearchBox: true),
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        hintText:
                            widget.service.subcategoryName.isNotEmpty
                                ? widget.service.subcategoryName
                                : provider.isLoadingSubcategories
                                ? 'Loading...'
                                : 'Select Subcategory',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                    onChanged: (ServiceSubcategoryModel? selected) {
                      setState(() {
                        _selectedSubcategoryId = selected?.id;
                        if (selected != null &&
                            !_selectedAdditionalSkills.contains(selected.id)) {
                          _selectedAdditionalSkills.add(selected.id);
                        }
                      });
                    },
                    dropdownBuilder: (context, selectedItem) {
                      if (selectedItem == null) {
                        return Text(
                          widget.service.subcategoryName.isNotEmpty
                              ? widget.service.subcategoryName
                              : provider.isLoadingSubcategories
                              ? 'Loading...'
                              : 'Select Subcategory',
                          style: AppTextStyles.bodyMedium,
                        );
                      }

                      return Row(
                        children: [
                          if (selectedItem.icon.isNotEmpty) ...[
                            Text(
                              selectedItem.icon,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Text(
                            selectedItem.name,
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  if (_selectedCategoryId != null &&
                      provider.subcategories.isNotEmpty) ...[
                    // Additional Skills checklist
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Additional Skills',
                          style: AppTextStyles.labelMedium,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              ...provider.subcategories.map((sub) {
                                final isSelected = _selectedAdditionalSkills
                                    .contains(sub.id);
                                return CheckboxListTile(
                                  title: Text(
                                    sub.name,
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                  value: isSelected,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        _selectedAdditionalSkills.add(sub.id);
                                      } else {
                                        _selectedAdditionalSkills.remove(
                                          sub.id,
                                        );
                                      }
                                    });
                                  },
                                  activeColor: AppColors.primary,
                                  checkColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  controlAffinity:
                                      ListTileControlAffinity.trailing,
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ],

                  const SizedBox(height: 20),

                  _buildTextField(
                    controller: _nameController,
                    label: 'Service Name',
                    hint: 'e.g. Expert AC Repair',
                    icon: Iconsax.briefcase,
                    validator:
                        (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),

                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    hint: 'Describe your service...',
                    icon: Iconsax.document_text,
                    maxLines: 4,
                    validator:
                        (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),

                  // const SizedBox(height: 20),

                  // // isTrending Toggle
                  // Container(
                  //   padding: const EdgeInsets.all(16),
                  //   decoration: BoxDecoration(
                  //     color: AppColors.white,
                  //     borderRadius: BorderRadius.circular(16),
                  //     border: Border.all(
                  //       color:
                  //           _isTrending
                  //               ? AppColors.primary.withOpacity(0.3)
                  //               : AppColors.border,
                  //     ),
                  //   ),
                  //   child: Row(
                  //     children: [
                  //       Container(
                  //         padding: const EdgeInsets.all(10),
                  //         decoration: BoxDecoration(
                  //           color: AppColors.primary.withOpacity(0.08),
                  //           borderRadius: BorderRadius.circular(12),
                  //         ),
                  //         child: const Icon(
                  //           Iconsax.trend_up,
                  //           color: AppColors.primary,
                  //           size: 20,
                  //         ),
                  //       ),
                  //       // const SizedBox(width: 16),
                  //       // Expanded(
                  //       //   child: Column(
                  //       //     crossAxisAlignment: CrossAxisAlignment.start,
                  //       //     children: [
                  //       //       Text(
                  //       //         'Mark as Trending',
                  //       //         style: AppTextStyles.labelMedium,
                  //       //       ),
                  //       //       Text(
                  //       //         'Boost visibility of this service',
                  //       //         style: AppTextStyles.caption.copyWith(
                  //       //           color: AppColors.textSecondary,
                  //       //         ),
                  //       //       ),
                  //       //     ],
                  //       //   ),
                  //       // ),
                  //       Switch(
                  //         value: _isTrending,
                  //         onChanged: (v) => setState(() => _isTrending = v),
                  //         activeColor: AppColors.primary,
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  const SizedBox(height: 32),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed:
                          provider.isUpdatingService ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child:
                          provider.isUpdatingService
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : Text(
                                'Save Changes',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'yellow':
        return Colors.yellow;
      case 'blue':
        return Colors.blue;
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      default:
        return AppColors.primary;
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
            prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }
}
