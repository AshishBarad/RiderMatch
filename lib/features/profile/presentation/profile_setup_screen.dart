import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../auth/domain/entities/user.dart';
import 'profile_providers.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../../core/config/bike_config.dart';
import 'widgets/username_field.dart';
import '../../../core/presentation/theme/app_colors.dart';
import '../../../core/presentation/theme/app_typography.dart';
import '../../../core/presentation/widgets/gradient_button.dart';
import '../../../core/presentation/widgets/animated_chip.dart';
import '../../../core/presentation/widgets/profile_avatar.dart';
import '../../../core/presentation/widgets/animated_dropdown.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  final User? userToEdit;
  const ProfileSetupScreen({super.key, this.userToEdit});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _ageController;
  late TextEditingController _vehicleRegController;
  late TextEditingController _emergencyNameController;
  late TextEditingController _emergencyPhoneController;

  String? _selectedGender;
  String? _selectedManufacturer;
  String? _selectedModel;
  String? _selectedBloodGroup;
  String? _emergencyRelation;

  List<String> _selectedPreferences = [];
  String? _photoUrl;
  String? _coverUrl;
  double _selectedRideDistance = 50.0;
  int _currentStep = 0;

  final List<String> _ridingPreferencesOptions = [
    'Fast Riding',
    'Easy Going',
    'Touring',
    'Off-road',
    'City Rides',
    'Weekend Rides',
    'Long Distance',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers(widget.userToEdit);
  }

  void _initializeControllers(User? user) {
    _nameController = TextEditingController(text: user?.fullName);
    _usernameController = TextEditingController(text: user?.username);
    _ageController = TextEditingController(text: user?.age?.toString() ?? '');
    _vehicleRegController = TextEditingController(text: user?.vehicleRegNo);
    _emergencyNameController = TextEditingController(
      text: user?.emergencyContactName,
    );
    _emergencyPhoneController = TextEditingController(
      text: user?.emergencyContactNumber,
    );

    _selectedGender = user?.gender;
    _selectedManufacturer = user?.vehicleManufacturer;
    _selectedModel = user?.vehicleModel;
    _selectedBloodGroup = user?.bloodGroup;
    _emergencyRelation = user?.emergencyContactRelationship;
    _selectedPreferences = List.from(user?.ridingPreferences ?? []);
    _photoUrl = user?.photoUrl;
    _coverUrl = user?.coverImageUrl;
    _selectedRideDistance = user?.rideDistancePreference ?? 50.0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _ageController.dispose();
    _vehicleRegController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  void _onUploadPhoto() {
    setState(() {
      _photoUrl =
          'https://i.pravatar.cc/300?u=user_${DateTime.now().millisecondsSinceEpoch}';
    });
  }

  void _onUploadCover() {
    setState(() {
      _coverUrl =
          'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/800/400';
    });
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_photoUrl == null) {
      _showError('Profile photo is mandatory');
      return;
    }

    final authState = ref.read(authControllerProvider);
    final userId = widget.userToEdit?.id ?? authState.value?.id;

    if (userId == null) return;

    final user = User(
      id: userId,
      phoneNumber: widget.userToEdit?.phoneNumber ?? '9876543210',
      username:
          widget.userToEdit?.username ??
          (_usernameController.text.trim().isNotEmpty
              ? _usernameController.text.trim()
              : null),
      fullName: _nameController.text,
      age: int.tryParse(_ageController.text),
      gender: _selectedGender,
      vehicleManufacturer: _selectedManufacturer,
      vehicleModel: _selectedModel,
      vehicleRegNo: _vehicleRegController.text.toUpperCase(),
      bloodGroup: _selectedBloodGroup,
      emergencyContactName: _emergencyNameController.text,
      emergencyContactRelationship: _emergencyRelation,
      emergencyContactNumber: _emergencyPhoneController.text,
      ridingPreferences: _selectedPreferences,
      photoUrl: _photoUrl,
      coverImageUrl: _coverUrl,
      isProfileComplete: true,
      rideDistancePreference: _selectedRideDistance,
    );

    await ref.read(profileControllerProvider.notifier).updateProfile(user);
    if (mounted) {
      context.go('/home');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          widget.userToEdit != null ? 'Edit Profile' : 'Profile Setup',
          style: AppTypography.title,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentStep + 1) / 4,
              backgroundColor: AppColors.primaryAqua.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation(AppColors.primaryAqua),
            ),
            Expanded(
              child: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.primaryAqua,
                  ),
                ),
                child: Stepper(
                  type: StepperType.vertical,
                  currentStep: _currentStep,
                  onStepTapped: (step) => setState(() => _currentStep = step),
                  onStepContinue: () {
                    if (_currentStep < 3) {
                      setState(() => _currentStep += 1);
                    } else {
                      _onSubmit();
                    }
                  },
                  onStepCancel: () {
                    if (_currentStep > 0) setState(() => _currentStep -= 1);
                  },
                  controlsBuilder: (context, details) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: GradientButton(
                              text: _currentStep == 3 ? 'Finish' : 'Continue',
                              onPressed: details.onStepContinue!,
                              height: 48,
                              gradient: AppColors.primaryGradient,
                            ),
                          ),
                          if (_currentStep > 0) ...[
                            const SizedBox(width: 12),
                            TextButton(
                              onPressed: details.onStepCancel,
                              child: const Text(
                                'Back',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                  steps: [
                    _buildBasicInfoStep(),
                    _buildVehicleStep(),
                    _buildPreferencesStep(),
                    _buildEmergencyStep(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Step _buildBasicInfoStep() {
    return Step(
      title: const Text('Basic Info'),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      content: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: AppColors.primaryAqua.withValues(alpha: 0.1),
                  image: _coverUrl != null
                      ? DecorationImage(
                          image: NetworkImage(_coverUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _coverUrl == null
                    ? const Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 40,
                          color: AppColors.primaryAqua,
                        ),
                      )
                    : null,
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 18,
                  child: IconButton(
                    icon: const Icon(
                      Icons.camera_alt,
                      size: 18,
                      color: AppColors.primaryAqua,
                    ),
                    onPressed: _onUploadCover,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: -40,
                child: Center(
                  child: ProfileAvatar(
                    imageUrl: _photoUrl,
                    radius: 45,
                    onTap: _onUploadPhoto,
                  ),
                ),
              ),
            ],
          ).animate().fadeIn().scale(),
          const SizedBox(height: 50),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Full Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (v) => v!.isEmpty ? 'Enter name' : null,
          ).animate().slideX(),
          const SizedBox(height: 16),
          UsernameField(
            controller: _usernameController,
            initialUsername: widget.userToEdit?.username,
            enabled: widget.userToEdit?.username == null,
          ).animate().slideX(delay: 100.ms),
          const SizedBox(height: 16),
          TextFormField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Age',
              prefixIcon: Icon(Icons.cake_outlined),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Enter age';
              final age = int.tryParse(v);
              if (age == null) return 'Invalid age';
              if (age < 18) return 'Must be 18 or older';
              return null;
            },
          ).animate().slideX(delay: 150.ms),
          const SizedBox(height: 16),
          AnimatedDropdown<String>(
            hintText: 'Blood Group',
            prefixIcon: const Icon(Icons.bloodtype_outlined),
            value: _selectedBloodGroup,
            items: BikeConfig.bloodGroups,
            itemLabelBuilder: (val) => val,
            onChanged: (v) => setState(() => _selectedBloodGroup = v),
            validator: (v) => v == null ? 'Select blood group' : null,
          ).animate().slideX(delay: 200.ms),
          const SizedBox(height: 16),
          _buildGenderSelector().animate().slideX(delay: 250.ms),
        ],
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Row(
      children: ['Male', 'Female', 'Other']
          .map(
            (g) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: AnimatedChip(
                  label: g,
                  isSelected: _selectedGender == g,
                  enabled: widget.userToEdit?.gender == null,
                  onSelected: () => setState(() => _selectedGender = g),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Step _buildVehicleStep() {
    return Step(
      title: const Text('Vehicle Details'),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      content: Column(
        children: [
          AnimatedDropdown<String>(
            hintText: 'Manufacturer',
            prefixIcon: const Icon(Icons.directions_bike),
            value: _selectedManufacturer,
            items: BikeConfig.manufacturers.keys.toList(),
            itemLabelBuilder: (val) => val,
            onChanged: (v) => setState(() {
              _selectedManufacturer = v;
              _selectedModel = null;
            }),
            validator: (v) => v == null ? 'Select manufacturer' : null,
          ),
          const SizedBox(height: 16),
          AnimatedDropdown<String>(
            hintText: 'Model',
            prefixIcon: const Icon(Icons.settings),
            value: _selectedModel,
            items: _selectedManufacturer == null
                ? []
                : BikeConfig.manufacturers[_selectedManufacturer]!,
            itemLabelBuilder: (val) => val,
            onChanged: (v) => setState(() => _selectedModel = v),
            validator: (v) => v == null ? 'Select model' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _vehicleRegController,
            decoration: const InputDecoration(
              hintText: 'Registration Number',
              prefixIcon: Icon(Icons.numbers),
            ),
            textCapitalization: TextCapitalization.characters,
            validator: (v) => v!.isEmpty ? 'Enter registration number' : null,
          ),
        ],
      ),
    );
  }

  Step _buildPreferencesStep() {
    return Step(
      title: const Text('Riding Preferences'),
      isActive: _currentStep >= 2,
      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _ridingPreferencesOptions.map((pref) {
              final isSelected = _selectedPreferences.contains(pref);
              return AnimatedChip(
                label: pref,
                isSelected: isSelected,
                onSelected: () {
                  setState(() {
                    isSelected
                        ? _selectedPreferences.remove(pref)
                        : _selectedPreferences.add(pref);
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text(
            'Search Radius: ${_selectedRideDistance.round()} km',
            style: AppTypography.body,
          ),
          Slider(
            value: _selectedRideDistance,
            min: 5,
            max: 200,
            onChanged: (v) => setState(() => _selectedRideDistance = v),
          ),
        ],
      ),
    );
  }

  Step _buildEmergencyStep() {
    return Step(
      title: const Text('Emergency Contact'),
      isActive: _currentStep >= 3,
      state: _currentStep > 3 ? StepState.complete : StepState.indexed,
      content: Column(
        children: [
          TextFormField(
            controller: _emergencyNameController,
            decoration: const InputDecoration(
              hintText: 'Contact Name',
              prefixIcon: Icon(Icons.contact_phone_outlined),
            ),
            validator: null,
          ),
          const SizedBox(height: 16),
          AnimatedDropdown<String>(
            hintText: 'Relationship',
            prefixIcon: const Icon(Icons.people_outline),
            value: _emergencyRelation,
            items: const ['Spouse', 'Parent/Guardian', 'Friend'],
            itemLabelBuilder: (val) => val,
            onChanged: (v) => setState(() => _emergencyRelation = v),
            validator: null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emergencyPhoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: 'Phone Number',
              prefixIcon: Icon(Icons.phone_android),
            ),
            maxLength: 10,
            validator: (v) {
              if (v == null || v.isEmpty) return null;
              if (v.length != 10) return 'Enter 10-digit number';
              return null;
            },
          ),
        ],
      ),
    );
  }
}
