import 'dart:io';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_app/features/service_boy/models/service_subcategory_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../providers/service_boy_provider.dart';
import '../models/service_category_model.dart';
import '../../../core/services/storage_service.dart';
import '../../auth/screens/login_screen.dart';
import '../../../core/models/user_type.dart';

class CreateServiceScreen extends StatefulWidget {
  const CreateServiceScreen({super.key});

  @override
  State<CreateServiceScreen> createState() => _CreateServiceScreenState();
}

class _CreateServiceScreenState extends State<CreateServiceScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _customSkillController = TextEditingController();

  String? _selectedCategoryId;
  String? _selectedSubcategoryId;
  List<String> _selectedAdditionalSkills = [];
  List<String> _customSkills = [];
  bool _isTrending = false;
  File? _serviceImage;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _checkUserType();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceBoyProvider>().fetchCategories();
    });
  }

  Future<void> _checkUserType() async {
    final userType = await StorageService.getUserType();
    if (userType != UserType.serviceBoy) {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _customSkillController.dispose();
    super.dispose();
  }

  void _addCustomSkill() {
    final skill = _customSkillController.text.trim();
    if (skill.isNotEmpty) {
      if (!_customSkills.contains(skill)) {
        setState(() {
          _customSkills.add(skill);
          _selectedAdditionalSkills.add(skill);
          _customSkillController.clear();
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Skill already added')));
      }
    }
  }

  Future<void> _submitFormat() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    print(_selectedCategoryId);
    print(_selectedSubcategoryId);
    print(_selectedAdditionalSkills);
    print(_customSkills);
    print(_descriptionController.text.trim());
    print(_isTrending);
    print(_serviceImage);
    print(" ===========");

    final provider = context.read<ServiceBoyProvider>();
    String? imageUrl;

    if (_serviceImage != null) {
      imageUrl = await provider.uploadServiceImage(_serviceImage!);
      if (imageUrl == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                provider.createServiceError ?? 'Failed to upload service image',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }
    }

    final serviceData = {
      'categoryId': _selectedCategoryId,
      if (_selectedSubcategoryId != null)
        'subcategoryId': _selectedSubcategoryId,
      'additionalSkills': _selectedAdditionalSkills,
      'description': _descriptionController.text.trim(),
      'price': 0,
      'duration': 0,
      'commission': 0,
      'isTrending': _isTrending,
      if (imageUrl != null) 'image': imageUrl,
    };

    final success = await provider.createService(serviceData);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.createServiceError ?? 'Failed to create service',
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
        title: Text('Create Service', style: AppTextStyles.h4),
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
          if (provider.isLoadingCategories) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.categoriesError != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading categories',
                    style: AppTextStyles.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () => provider.fetchCategories(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Picker
                  Text('Service Title Image', style: AppTextStyles.labelMedium),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child:
                          _serviceImage != null
                              ? Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.file(
                                      _serviceImage!,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() => _serviceImage = null);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                              : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Iconsax.image,
                                    size: 40,
                                    color: AppColors.textTertiary,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Add Service title Image ',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ),

                  const SizedBox(height: 20),

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
                        hintText: "Select Category",
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
                      setState(() {
                        _selectedCategoryId = selected?.id;
                        _selectedSubcategoryId = null;
                        _selectedAdditionalSkills = [];
                      });

                      if (selected != null) {
                        provider.fetchSubcategories(selected.id);
                      } else {
                        provider.clearSubcategories();
                      }
                    },
                    dropdownBuilder: (context, selectedItem) {
                      if (selectedItem == null) {
                        return Text(
                          "Select Category",
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
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
                  if (_selectedCategoryId != null) ...[
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
                              provider.isLoadingSubcategories
                                  ? 'Loading...'
                                  : 'Select Subcategory',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                        ),
                      ),
                      onChanged:
                          provider.isLoadingSubcategories
                              ? null
                              : (ServiceSubcategoryModel? selected) {
                                setState(() {
                                  _selectedSubcategoryId = selected?.id;
                                  if (selected != null) {
                                    _nameController.text = selected.name;
                                    if (!_selectedAdditionalSkills.contains(
                                      selected.name,
                                    )) {
                                      _selectedAdditionalSkills.add(
                                        selected.name,
                                      );
                                    }
                                  }
                                });
                              },
                      dropdownBuilder: (context, selectedItem) {
                        if (selectedItem == null) {
                          return Text(
                            provider.isLoadingSubcategories
                                ? 'Loading...'
                                : 'Select Subcategory',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
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
                  ],

                  if (_selectedCategoryId != null) ...[
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
                              // Predefined Subcategories
                              ...provider.subcategories.map((sub) {
                                final isSelected = _selectedAdditionalSkills
                                    .contains(sub.name);
                                return CheckboxListTile(
                                  title: Text(
                                    sub.name,
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                  value: isSelected,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        if (!_selectedAdditionalSkills.contains(
                                          sub.name,
                                        )) {
                                          _selectedAdditionalSkills.add(
                                            sub.name,
                                          );
                                        }
                                      } else {
                                        _selectedAdditionalSkills.remove(
                                          sub.name,
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

                              // Custom Added Skills
                              ..._customSkills.map((skill) {
                                final isSelected = _selectedAdditionalSkills
                                    .contains(skill);
                                return CheckboxListTile(
                                  title: Text(
                                    skill,
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                  value: isSelected,
                                  onChanged: (bool? value) {
                                    print(value);
                                    print(skill);
                                    print("===");
                                    setState(() {
                                      if (value == true) {
                                        if (!_selectedAdditionalSkills.contains(
                                          skill,
                                        )) {
                                          _selectedAdditionalSkills.add(skill);
                                        }
                                      } else {
                                        _selectedAdditionalSkills.remove(skill);
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

                              const Divider(height: 1),

                              // Input for new custom skill
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _customSkillController,
                                        decoration: InputDecoration(
                                          hintText: 'Add custom skill...',
                                          hintStyle: AppTextStyles.bodySmall,
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8,
                                              ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: const BorderSide(
                                              color: AppColors.border,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: _addCustomSkill,
                                      icon: const Icon(
                                        Iconsax.add_circle,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Service Name
                  _buildTextField(
                    controller: _nameController,
                    label: 'Service Title',
                    hint: 'e.g. Expert AC Repair',
                    icon: Iconsax.briefcase,
                    validator:
                        (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),

                  const SizedBox(height: 16),

                  // Description
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    hint: 'Describe your service...',
                    icon: Iconsax.document_text,
                    maxLines: 4,
                    validator:
                        (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),

                  const SizedBox(height: 20),

                  // isTrending Toggle
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            _isTrending
                                ? AppColors.primary.withOpacity(0.3)
                                : AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Iconsax.trend_up,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mark as Trending',
                                style: AppTextStyles.labelMedium,
                              ),
                              Text(
                                'Boost visibility of this service',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isTrending,
                          onChanged: (v) => setState(() => _isTrending = v),
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  if (provider.isCreatingService)
                    const Center(child: CircularProgressIndicator())
                  else
                    GradientButton(
                      text: 'Create Service',
                      onPressed: _submitFormat,
                      width: double.infinity,
                    ),

                  // Submit Button
                  // SizedBox(
                  //   width: double.infinity,
                  //   height: 56,
                  //   child: ElevatedButton(
                  //     onPressed:
                  //         provider.isCreatingService ? null : _submitFormat,
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: AppColors.primary,
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(16),
                  //       ),
                  //       elevation: 0,
                  //     ),
                  //     child:
                  //         provider.isCreatingService
                  //             ? const CircularProgressIndicator(
                  //               color: Colors.white,
                  //             )
                  //             : Text(
                  //               'Create Service',
                  //               style: AppTextStyles.labelLarge.copyWith(
                  //                 color: Colors.white,
                  //               ),
                  //             ),
                  //   ),
                  // ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image != null) {
        setState(() => _serviceImage = File(image.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
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
            fillColor: Theme.of(context).colorScheme.surface,
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
}
