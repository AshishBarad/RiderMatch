import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/domain/entities/user.dart';
import 'profile_providers.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../../core/config/app_config.dart';
import '../../../core/config/bike_config.dart';
import 'widgets/username_field.dart';
import '../../../core/utils/error_handler.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  final User? userToEdit; // Added for edit mode
  const ProfileSetupScreen({super.key, this.userToEdit});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _ageController;
  late TextEditingController _bikeModelController;
  late TextEditingController _vehicleRegController;
  late TextEditingController _emergencyNameController;
  late TextEditingController _emergencyRelationController;
  late TextEditingController _emergencyPhoneController;

  String? _selectedGender;
  String? _selectedManufacturer;
  String? _selectedModel;
  String? _selectedBloodGroup;

  List<String> _selectedPreferences = [];
  String? _photoUrl; // To store uploaded photo URL
  double _selectedRideDistance = 50.0;
  bool _isLoadingProfile = false;

  final List<String> _miningPreferencesOptions = [
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
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    // If we have a user ID but incomplete data, fetch full profile
    if (widget.userToEdit != null && widget.userToEdit!.fullName == null) {
      setState(() {
        _isLoadingProfile = true;
      });

      try {
        final fullProfile = await ref.read(getUserProfileUseCaseProvider)(
          widget.userToEdit!.id,
        );

        if (fullProfile != null && mounted) {
          _initializeControllers(fullProfile);
        } else {
          _initializeControllers(widget.userToEdit);
        }
      } catch (e) {
        debugPrint('Error loading profile: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${ErrorHandler.getErrorMessage(e)}'),
            ),
          );
        }
        _initializeControllers(widget.userToEdit);
      } finally {
        if (mounted) {
          setState(() {
            _isLoadingProfile = false;
          });
        }
      }
    } else {
      _initializeControllers(widget.userToEdit);
    }
  }

  void _initializeControllers(User? user) {
    _nameController = TextEditingController(text: user?.fullName);
    _usernameController = TextEditingController(text: user?.username);
    _ageController = TextEditingController(
      text: user?.age != null ? user!.age.toString() : '',
    );
    _bikeModelController = TextEditingController(text: user?.vehicleModel);
    _vehicleRegController = TextEditingController(text: user?.vehicleRegNo);
    _emergencyNameController = TextEditingController(
      text: user?.emergencyContactName,
    );
    _emergencyRelationController = TextEditingController(
      text: user?.emergencyContactRelationship,
    );
    _emergencyPhoneController = TextEditingController(
      text: user?.emergencyContactNumber,
    );

    _selectedGender = user?.gender;
    _selectedManufacturer = user?.vehicleManufacturer;
    _selectedModel = user?.vehicleModel;
    _selectedBloodGroup = user?.bloodGroup;

    _selectedPreferences = List.from(user?.ridingPreferences ?? []);
    _photoUrl = user?.photoUrl;
    _selectedRideDistance = user?.rideDistancePreference ?? 50.0;

    // Ensure initial values for dropdowns are valid
    if (_emergencyRelationController.text.isNotEmpty &&
        ![
          'Spouse',
          'Parent/Guardian',
          'Friend',
        ].contains(_emergencyRelationController.text)) {
      _emergencyRelationController.text = '';
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _ageController.dispose();
    _bikeModelController.dispose();
    _vehicleRegController.dispose();
    _emergencyNameController.dispose();
    _emergencyRelationController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  void _onUploadPhoto() {
    // Simulate photo upload
    setState(() {
      _photoUrl =
          'https://i.pravatar.cc/300?u=mock_user_${DateTime.now().millisecondsSinceEpoch}';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo uploaded successfully!')),
    );
  }

  Future<void> _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (_photoUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo is mandatory')),
        );
        return;
      }
      if (_selectedGender == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please select a gender')));
        return;
      }
      if (_selectedPreferences.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one riding preference'),
          ),
        );
        return;
      }

      // Use existing ID if editing, or current Auth ID
      final authState = ref.read(authControllerProvider);
      final userId = widget.userToEdit?.id ?? authState.value?.id;

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No authenticated user found')),
        );
        return;
      }

      debugPrint('🔍 SAVING PROFILE: ID=$userId, Name=${_nameController.text}');

      // Reserve username if provided
      final username = _usernameController.text.trim();
      if (username.isNotEmpty) {
        try {
          await ref.read(reserveUsernameUseCaseProvider)(userId, username);
          debugPrint('✅ Username reserved: $username');
        } catch (e) {
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Username error: ${ErrorHandler.getErrorMessage(e)}',
                ),
              ),
            );
          }
          return;
        }
      }

      final user = User(
        id: userId,
        phoneNumber: widget.userToEdit?.phoneNumber ?? '9876543210',
        username: username.isNotEmpty ? username : null,
        email: widget.userToEdit?.email,
        fullName: _nameController.text,
        age: int.tryParse(_ageController.text),
        gender: _selectedGender,
        vehicleManufacturer: _selectedManufacturer,
        vehicleModel: _selectedModel,
        vehicleRegNo: _vehicleRegController.text.toUpperCase(),
        bloodGroup: _selectedBloodGroup,
        emergencyContactName: _emergencyNameController.text,
        emergencyContactRelationship: _emergencyRelationController.text,
        emergencyContactNumber: _emergencyPhoneController.text,
        ridingPreferences: _selectedPreferences,
        photoUrl: _photoUrl,
        isProfileComplete: true,
        followers: widget.userToEdit?.followers ?? [],
        following: widget.userToEdit?.following ?? [],
        rideDistancePreference: _selectedRideDistance,
      );

      ref.read(profileControllerProvider.notifier).updateProfile(user).then((
        _,
      ) {
        final state = ref.read(profileControllerProvider);
        if (!state.hasError && mounted) {
          // Force refresh of the user profile everywhere
          ref.invalidate(userProfileProvider(user.id));

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Profile saved!')));
          if (widget.userToEdit != null) {
            context.pop(); // Go back if editing
          } else {
            context.go('/home'); // Go to home if onboarding
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);
    final isEditing = widget.userToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'My Profile' : 'Complete Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _onUploadPhoto,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _photoUrl != null
                            ? NetworkImage(_photoUrl!)
                            : null,
                        child: _photoUrl == null
                            ? const Icon(Icons.person, size: 60)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: _onUploadPhoto,
                  child: const Text('Upload Photo'),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Tell us about yourself',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  helperText: 'Alphabets only, max 2 spaces',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  // Validation: Only alphabets and maximum 2 spaces
                  // ^[a-zA-Z]+( [a-zA-Z]+){0,2}$
                  final RegExp nameRegExp = RegExp(
                    r'^[a-zA-Z]+( [a-zA-Z]+){0,2}$',
                  );
                  if (!nameRegExp.hasMatch(value)) {
                    return 'Letters only, no special chars/numbers, max 2 spaces';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Username display (read-only) - only if editing existing profile with username
              if (widget.userToEdit?.username != null &&
                  widget.userToEdit!.username!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.grey.shade50,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.alternate_email, color: Colors.blue),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Username',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '@${widget.userToEdit!.username}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              else
                UsernameField(
                  controller: _usernameController,
                  initialUsername: widget.userToEdit?.username,
                ),
              const SizedBox(height: 16),
              Stack(
                alignment: Alignment.centerRight,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _selectedGender,
                    items: ['Male', 'Female', 'Other']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged:
                        (widget.userToEdit?.gender != null &&
                            widget.userToEdit!.gender!.isNotEmpty)
                        ? null // Disable if already set
                        : (value) => setState(() => _selectedGender = value),
                    validator: (value) =>
                        value == null ? 'Please select a gender' : null,
                  ),
                  if (widget.userToEdit?.gender != null &&
                      widget.userToEdit!.gender!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 40.0),
                      child: Tooltip(
                        message:
                            'To change gender, please contact admin at ${AppConfig.adminEmail}',
                        triggerMode: TooltipTriggerMode.tap,
                        child: Icon(
                          Icons.info_outline,
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter age';
                  }
                  final age = int.tryParse(value);
                  if (age == null) {
                    return 'Invalid age';
                  }
                  if (age < 18 || age > 100) {
                    return 'Age must be between 18 and 100';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Vehicle Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Manufacturer',
                  border: OutlineInputBorder(),
                ),
                initialValue: _selectedManufacturer,
                items: BikeConfig.manufacturers.keys
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedManufacturer = value;
                    _selectedModel =
                        null; // Reset model when manufacturer changes
                  });
                },
                validator: (value) =>
                    value == null ? 'Select manufacturer' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Model',
                  border: OutlineInputBorder(),
                ),
                initialValue: _selectedModel,
                items: (_selectedManufacturer == null)
                    ? []
                    : BikeConfig.manufacturers[_selectedManufacturer]!
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                onChanged: _selectedManufacturer == null
                    ? null
                    : (value) => setState(() => _selectedModel = value),
                validator: (value) => value == null ? 'Select model' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _vehicleRegController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Registration Number',
                  hintText: 'e.g. MH12HY8888 or 26BH1234M',
                  helperText: 'Format: MH12HY8888 or 26BH1234M',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter reg number';
                  }
                  final upperVal = value.toUpperCase();
                  // Standard: ^[A-Z]{2}[0-9]{2}[A-Z]{1,2}[0-9]{4}$
                  // BH Series: ^[0-9]{2}BH[0-9]{4}[A-Z]{1,2}$
                  // Combined Regex
                  final RegExp regPattern = RegExp(
                    r'^([A-Z]{2}[0-9]{2}[A-Z]{1,2}[0-9]{4}|[0-9]{2}BH[0-9]{4}[A-Z]{1,2})$',
                  );
                  if (!regPattern.hasMatch(upperVal)) {
                    return 'Invalid format. Use MH12HY8888 or 26BH1234M';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Health & Safety',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Blood Group',
                  border: OutlineInputBorder(),
                ),
                initialValue: _selectedBloodGroup,
                items: BikeConfig.bloodGroups
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedBloodGroup = value),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Text(
                    'Emergency Contact',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message:
                        'Visible to ride organizers for safety coordination during rides.',
                    triggerMode: TooltipTriggerMode.tap,
                    child: Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Colors.blue[300],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emergencyNameController,
                decoration: const InputDecoration(
                  labelText: 'Contact Person Name',
                  border: OutlineInputBorder(),
                  helperText: 'Alphabets only, max 2 spaces',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter contact name';
                  }
                  // Validation: same as Full Name
                  final RegExp nameRegExp = RegExp(
                    r'^[a-zA-Z]+( [a-zA-Z]+){0,2}$',
                  );
                  if (!nameRegExp.hasMatch(value)) {
                    return 'Letters only, no special chars/numbers';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Relationship (e.g. Spouse, Parent)',
                  border: OutlineInputBorder(),
                ),
                initialValue: _emergencyRelationController.text.isEmpty
                    ? null
                    : [
                        'Spouse',
                        'Parent/Guardian',
                        'Friend',
                      ].contains(_emergencyRelationController.text)
                    ? _emergencyRelationController.text
                    : null,
                items: ['Spouse', 'Parent/Guardian', 'Friend']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    _emergencyRelationController.text = value;
                  }
                },
                validator: (value) =>
                    value == null ? 'Select relationship' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emergencyPhoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixText: '+91 ',
                  counterText: '',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter phone number';
                  }
                  if (value.length != 10) {
                    return 'Must be 10 digits';
                  }
                  // Starts with 6-9
                  if (!['6', '7', '8', '9'].contains(value[0])) {
                    return 'Invalid mobile number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Riding Preferences',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _miningPreferencesOptions.map((pref) {
                  final isSelected = _selectedPreferences.contains(pref);
                  return FilterChip(
                    label: Text(pref),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedPreferences.add(pref);
                        } else {
                          _selectedPreferences.remove(pref);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text(
                'Ride Distance Radius',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _selectedRideDistance,
                      min: 1.0,
                      max: 200.0,
                      divisions: 199,
                      label: '${_selectedRideDistance.round()} km',
                      onChanged: (value) {
                        setState(() {
                          _selectedRideDistance = value;
                        });
                      },
                    ),
                  ),
                  Text(
                    '${_selectedRideDistance.round()} km',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              if (state.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _onSubmit,
                    child: Text(isEditing ? 'Save Changes' : 'Save Profile'),
                  ),
                ),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'Error: ${state.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
