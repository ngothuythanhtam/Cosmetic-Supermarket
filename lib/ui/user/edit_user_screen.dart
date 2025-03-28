import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/user.dart';
import '../../ui/shared/dialog_utils.dart';
import 'users_manager.dart';
import '../shared/app_drawer.dart';
import 'package:ct312h_project/ui/admin/auth/auth_manager.dart';
import 'package:ct312h_project/ui/admin/auth/auth_screen.dart';
import 'dart:io';

class EditUserScreen extends StatefulWidget {
  static const routeName = '/edit_user';

  const EditUserScreen(
    this.user, {
    super.key,
  });

  final User? user;

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _editForm = GlobalKey<FormState>();
  late User _editedUser;
  File? _selectedAvatar;
  late UsersManager _usersManager;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _usersManager = Provider.of<UsersManager>(context, listen: false);
    _editedUser = widget.user?.id.isEmpty ?? true
        ? User(
            id: '',
            username: '',
            email: '',
            avatar: '',
            phone: '',
            address: '',
          )
        : widget.user!;
    _usernameController.text = _editedUser.username;
    _emailController.text = _editedUser.email;
    _phoneController.text = _editedUser.phone;
    _addressController.text = _editedUser.address ?? '';
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      await _usersManager.fetchUser();
      if (_usersManager.currentUser != null) {
        setState(() {
          _editedUser = _usersManager.currentUser!;
          print('❤️❤️❤️ Updated _editedUser: ${_editedUser.toJson()}');
          _usernameController.text = _editedUser.username;
          _emailController.text = _editedUser.email;
          _phoneController.text = _editedUser.phone;
          _addressController.text = _editedUser.address ?? '';
          _isLoading = false;
        });
      } else {
        if (mounted) {
          await showErrorDialog(context, 'No user data found.');
        }
      }
    } catch (error) {
      if (mounted) {
        await showErrorDialog(context, 'Failed to load user data: $error');
      }
    }
  }

  Future<void> _saveForm() async {
    final isValid = _editForm.currentState!.validate();
    if (!isValid) {
      return;
    }
    _editForm.currentState!.save();

    try {
      if (_editedUser.id.isNotEmpty) {
        await _usersManager.updateUser(_editedUser,
            avatarFile: _selectedAvatar);
        if (mounted) {
          await showSuccessDialog(context, 'User updated successfully!');
        }
      } else {
        await _usersManager.addUser(_editedUser, avatarFile: _selectedAvatar);
        if (mounted) {
          await showSuccessDialog(context, 'User added successfully!');
        }
      }
    } catch (error) {
      if (mounted) {
        await showErrorDialog(context, 'Failed to save user: $error');
      }
    }
  }

  Future<void> _deleteUser() async {
    final confirmDelete = await showConfirmDialog(
      context,
      'Are you sure you want to delete this user? This action cannot be undone.',
    );
    if (confirmDelete != true) {
      return;
    }

    try {
      print('Starting deletion process...');
      await _usersManager.deleteUser();
      print('User deleted, logging out...');
      await Provider.of<AuthManager>(context, listen: false).logout();
      if (mounted) {
        print('Closing all screens and navigating to /auth...');
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.of(context).pushReplacementNamed(AuthScreen.routeName);
      } else {
        print('Widget not mounted, skipping navigation.');
      }
    } catch (error) {
      print('Error during deletion: $error');
      if (mounted) {
        await showErrorDialog(context, 'Failed to delete user: $error');
      }
    }
  }

  @override
  void dispose() {
    // Dispose of all controllers to prevent memory leaks
    _emailController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authManager = Provider.of<AuthManager>(context);
    const Color laranaPink = Color.fromARGB(255, 255, 158, 158);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: laranaPink),
      ),
      drawer: AppDrawer(isAdmin: authManager.isStaff),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: laranaPink))
          : Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 30.0, vertical: 20.0),
                child: Column(
                  children: [
                    _buildAvatarPreview(),
                    const SizedBox(height: 30),
                    Expanded(
                      child: Form(
                        key: _editForm,
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          children: <Widget>[
                            _buildUsernameField(),
                            const SizedBox(height: 20),
                            _buildEmailField(),
                            const SizedBox(height: 20),
                            _buildPhoneField(),
                            const SizedBox(height: 20),
                            _buildAddressField(),
                            const SizedBox(height: 30),
                            _buildActionButtons(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAvatarPreview() {
    const Color laranaPink = Color.fromARGB(255, 255, 158, 158);
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: laranaPink.withOpacity(0.5), width: 3),
              boxShadow: [
                BoxShadow(
                  color: laranaPink.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipOval(
              child: _selectedAvatar == null &&
                      (_editedUser.avatar?.isEmpty ?? true)
                  ? const Center(
                      child: Icon(Icons.person, size: 60, color: laranaPink))
                  : FittedBox(
                      fit: BoxFit.cover,
                      child: _selectedAvatar == null
                          ? Image.network(
                              _editedUser.avatar!,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: laranaPink,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                print('Error loading avatar: $error');
                                return const Center(
                                    child: Icon(Icons.person,
                                        size: 60, color: laranaPink));
                              },
                            )
                          : Image.file(
                              _selectedAvatar!,
                              fit: BoxFit.cover,
                            ),
                    ),
            ),
          ),
          Positioned(
            right: 5,
            bottom: 0,
            child: Container(
              margin: const EdgeInsets.all(4),
              child: CircleAvatar(
                backgroundColor: laranaPink,
                radius: 20,
                child: IconButton(
                  icon: const Icon(Icons.camera_alt,
                      color: Colors.white, size: 20),
                  padding: EdgeInsets.zero,
                  onPressed: () async {
                    final imagePicker = ImagePicker();
                    try {
                      final imageFile = await imagePicker.pickImage(
                          source: ImageSource.gallery);
                      if (imageFile == null) {
                        return;
                      }
                      setState(() {
                        _selectedAvatar = File(imageFile.path);
                        _editedUser =
                            _editedUser.copyWith(avatar: imageFile.path);
                      });
                    } catch (error) {
                      if (mounted) {
                        showErrorDialog(
                            context, 'Failed to pick image: $error');
                      }
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsernameField() {
    const Color laranaPink = Color.fromARGB(255, 255, 158, 158);
    return TextFormField(
      controller: _usernameController,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.account_circle, color: laranaPink),
        hintText: 'Username',
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color.fromARGB(255, 255, 240, 240),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      ),
      textInputAction: TextInputAction.next,
      style: const TextStyle(fontSize: 16, color: Colors.black87),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please provide a username.';
        }
        if (value.length < 3) {
          return 'Username must be at least 3 characters long.';
        }
        return null;
      },
      onSaved: (value) {
        _editedUser = _editedUser.copyWith(username: value);
      },
    );
  }

  Widget _buildEmailField() {
    const Color laranaPink = Color.fromARGB(255, 255, 158, 158);
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.email, color: laranaPink),
        hintText: 'Email',
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color.fromARGB(255, 255, 240, 240),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      ),
      enabled: false,
      style: const TextStyle(fontSize: 16, color: Colors.black87),
    );
  }

  Widget _buildPhoneField() {
    const Color laranaPink = Color.fromARGB(255, 255, 158, 158);
    return TextFormField(
      controller: _phoneController,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.phone, color: laranaPink),
        hintText: 'Phone (e.g., 0123456789)',
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color.fromARGB(255, 255, 240, 240),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      ),
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.phone,
      style: const TextStyle(fontSize: 16, color: Colors.black87),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please provide a phone number.';
        }
        if (!RegExp(r'^0\d{9}$').hasMatch(value)) {
          return 'Please enter a valid Vietnamese phone number (e.g., 0123456789).';
        }
        return null;
      },
      onSaved: (value) {
        _editedUser = _editedUser.copyWith(phone: value);
      },
    );
  }

  Widget _buildAddressField() {
    const Color laranaPink = Color.fromARGB(255, 255, 158, 158);
    return TextFormField(
      controller: _addressController,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.location_on, color: laranaPink),
        hintText: 'Address',
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color.fromARGB(255, 255, 240, 240),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      ),
      textInputAction: TextInputAction.next,
      style: const TextStyle(fontSize: 16, color: Colors.black87),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please provide an address.';
        }
        return null;
      },
      onSaved: (value) {
        _editedUser = _editedUser.copyWith(address: value);
      },
    );
  }

  Widget _buildActionButtons() {
    const Color laranaPink = Color.fromARGB(255, 255, 158, 158);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _saveForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: laranaPink,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              padding: const EdgeInsets.symmetric(vertical: 18),
              elevation: 0,
            ),
            child: const Text(
              'Save',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: _editedUser.id.isNotEmpty ? _deleteUser : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              padding: const EdgeInsets.symmetric(vertical: 18),
              elevation: 0,
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
