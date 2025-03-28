import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';
import 'package:path/path.dart' as path;
import '../models/user.dart';
import 'pocketbase_client.dart';
import 'dart:io';

class UsersService {
  String _getAvatarUrl(PocketBase pb, RecordModel userModel) {
    final avatarName = userModel.getStringValue('avatar');
    return avatarName.isNotEmpty
        ? pb.files.getUrl(userModel, avatarName).toString()
        : '';
  }

  Future<User?> fetchUser() async {
    try {
      final pb = await getPocketbaseInstance();
      final userId = pb!.authStore.record?.id;
      if (userId == null) {
        print('No authenticated user found');
        return null;
      }
      final userModel = await pb.collection('users').getOne(userId);
      final userJson = userModel.toJson();
      print('❤️❤️❤️ Fetched user data from PocketBase: $userJson');
      return User.fromJson({
        ...userJson,
        'avatar': _getAvatarUrl(pb, userModel),
        'email': userModel.getStringValue('email'),
      });
    } catch (error) {
      print('Error fetching user: $error');
      return null;
    }
  }

  Future<User?> updateUser(User user, {File? avatarFile}) async {
    try {
      final pb = await getPocketbaseInstance();
      final userId = pb!.authStore.record?.id;
      if (userId == null) {
        print('No authenticated user found');
        return null;
      }
      final updateData = {
        'username': user.username,
        'phone': user.phone,
        'address': user.address,
        'updated': DateTime.now().toIso8601String(),
      };

      final List<http.MultipartFile> files = avatarFile != null
          ? [
              http.MultipartFile.fromBytes(
                'avatar',
                await avatarFile.readAsBytes(),
                filename: path.basename(avatarFile.path),
              ),
            ]
          : [];

      final updatedUserModel = await pb.collection('users').update(
            userId,
            body: updateData,
            files: files,
          );

      return User.fromJson({
        ...updatedUserModel.toJson(),
        'avatar': _getAvatarUrl(pb, updatedUserModel),
        'email': updatedUserModel.getStringValue('email'),
      });
    } catch (error) {
      print('❌ Error updating user: $error');
      return null;
    }
  }

  Future<User?> addUser(User user, {File? avatarFile}) async {
    try {
      final pb = await getPocketbaseInstance();
      final userId = pb!.authStore.record?.id;
      if (userId == null) {
        print('No authenticated user found');
        return null;
      }

      final userData = {
        'email': user.email,
        'username': user.username,
        'created': DateTime.now().toIso8601String(),
        'updated': DateTime.now().toIso8601String(),
      };

      final List<http.MultipartFile> files = avatarFile != null
          ? [
              http.MultipartFile.fromBytes(
                'avatar',
                await avatarFile.readAsBytes(),
                filename: path.basename(avatarFile.path),
              ),
            ]
          : [];

      final userModel = await pb.collection('users').create(
            body: userData,
            files: files,
          );

      return User.fromJson({
        ...userModel.toJson(),
        'avatar': _getAvatarUrl(pb, userModel),
        'email': userModel.getStringValue('email'),
      });
    } catch (error) {
      return null;
    }
  }

  Future<bool> deleteUser() async {
    try {
      final pb = await getPocketbaseInstance();
      final userId = pb!.authStore.record?.id;
      if (userId == null) {
        return false;
      }
      await pb.collection('users').delete(userId);
      return true;
    } catch (error) {
      return false;
    }
  }

// ***************************************************Admin******************************************
  String _getFeaturedImageUrl(PocketBase pb, RecordModel userModel) {
    final avatar = userModel.getStringValue('avatar');
    return pb.files.getUrl(userModel, avatar).toString();
  }

  Future<List<User>> adminFetchUsers({bool filteredByUser = false}) async {
    final List<User> users = [];
    try {
      final pb = await getPocketbaseInstance();
      final userId = pb!.authStore.record?.id;
      final filter = filteredByUser
          ? "id='$userId' && urole='customer'"
          : "urole='customer'";
      final userModels = await pb.collection('users').getFullList(
            filter: filter,
          );

      for (final userModel in userModels) {
        final userJson = userModel.toJson();
        users.add(User.fromJson({
          ...userJson,
          'avatar': _getFeaturedImageUrl(pb, userModel),
        }));
      }
      print('Fetched ${users.length} customers');
      return users;
    } catch (error) {
      print('🔴🔴🔴 Error fetching users: $error');
      return users;
    }
  }
}
