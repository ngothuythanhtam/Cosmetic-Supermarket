import 'package:pocketbase/pocketbase.dart';
import 'pocketbase_client.dart';
import '../models/user.dart';

class AuthService {
  void Function(User? user)? onAuthChange;

  AuthService({this.onAuthChange}) {
    _initPocketBase();
  }

  Future<void> _initPocketBase() async {
    try {
      final pb = await getPocketbaseInstance();
      if (pb == null) {
        print('Error: PocketBase instance is null!');
        return;
      }
      pb.authStore.onChange.listen((event) {
        if (onAuthChange != null) {
          onAuthChange!(event.record == null
              ? null
              : User.fromJson(event.record!.toJson()));
        }
      });
    } catch (error) {
      print('Error initializing PocketBase: $error');
    }
  }

  Future<User> signup(
      String username, String email, String phone, String password) async {
    final pb = await getPocketbaseInstance();
    if (pb == null) {
      throw Exception("PocketBase not initialized. Please restart the app.");
    }

    try {
      // Check if the email already exists
      final existingEmailUsers = await pb.collection('users').getList(
            filter: 'email = "$email"',
          );
      if (existingEmailUsers.items.isNotEmpty) {
        throw Exception(
            "This email is already registered. Please use a different one.");
      }

      // Check if the phone number already exists
      final existingPhoneUsers = await pb.collection('users').getList(
            filter: 'phone = "$phone"',
          );
      if (existingPhoneUsers.items.isNotEmpty) {
        throw Exception(
            "This phone number is already in use. Please use a different one.");
      }

      print('Creating user: $email');

      final record = await pb.collection('users').create(body: {
        'username': username,
        'email': email,
        'phone': phone,
        'password': password,
        'passwordConfirm': password,
        'urole': 'customer',
        'emailVisibility': true,
      });

      print('PocketBase response: ${record.toJson()}');

      Map<String, dynamic> userData = record.toJson();
      userData['email'] = email;

      return User.fromJson(userData);
    } catch (error) {
      print('Signup error details: $error');
      if (error is ClientException) {
        print('PocketBase error response: ${error.response}');
        final errorMessage = error.response['message'] ?? 'Registration failed';
        throw Exception(errorMessage);
      }
      if (error is Exception) {
        String errorMessage = error.toString();
        if (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.substring('Exception: '.length);
        }
        throw Exception(errorMessage);
      }
      throw Exception(error.toString());
    }
  }

  Future<User> login(String email, String password) async {
    final pb = await getPocketbaseInstance();
    if (pb == null) {
      throw Exception("PocketBase not initialized. Please restart the app.");
    }

    try {
      final authRecord =
          await pb.collection('users').authWithPassword(email, password);
      return User.fromJson(authRecord.record.toJson());
    } catch (error) {
      if (error is ClientException) {
        throw Exception(error.response['message']);
      }
      throw Exception('An error occurred during login');
    }
  }

  Future<void> logout() async {
    final pb = await getPocketbaseInstance();
    if (pb != null) {
      pb.authStore.clear();
    }
  }

  Future<User?> getUserFromStore() async {
    final pb = await getPocketbaseInstance();
    if (pb == null) {
      return null;
    }

    final model = pb.authStore.record;
    if (model == null) {
      return null;
    }
    return User.fromJson(model.toJson());
  }
}
