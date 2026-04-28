// lib/features/profile/presentation/cubit/profile_cubit.dart

import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/profile_repository.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repo;
  bool _isDisposed = false;
  Map<String, dynamic>? _cachedProfile;

  ProfileCubit(this._repo) : super(ProfileInitial());

  Future<void> load() async {
    if (isClosed || _isDisposed) return;

    emit(ProfileLoading());

    try {
      final r = await _repo.getProfile();

      if (isClosed || _isDisposed) return;

      r.fold(
        (f) {
          if (!isClosed && !_isDisposed) {
            emit(ProfileError(f.message));
          }
        },
        (d) {
          if (!isClosed && !_isDisposed) {
            _cachedProfile = Map<String, dynamic>.from(d);
            emit(ProfileLoaded(_cachedProfile!));
          }
        },
      );
    } catch (e) {
      if (!isClosed && !_isDisposed) {
        emit(ProfileError('حدث خطأ أثناء تحميل البيانات'));
      }
    }
  }

  Future<void> update(String email, String firstName, String lastName) async {
    if (isClosed || _isDisposed) return;

    emit(ProfileUpdating());

    try {
      final r = await _repo.updateProfile(email, firstName, lastName);

      if (isClosed || _isDisposed) return;

      r.fold(
        (f) {
          if (!isClosed && !_isDisposed) {
            emit(ProfileError(f.message));
          }
        },
        (_) {
          if (!isClosed && !_isDisposed) {
            emit(const ProfileUpdateSuccess());
          }
        },
      );
    } catch (e) {
      if (!isClosed && !_isDisposed) {
        emit(ProfileError('حدث خطأ أثناء التحديث'));
      }
    }
  }

  Future<void> changePassword(String oldPass, String newPass) async {
    if (isClosed || _isDisposed) return;

    emit(ProfileUpdating());

    try {
      final r = await _repo.updatePassword(oldPass, newPass);

      if (isClosed || _isDisposed) return;

      r.fold(
        (f) {
          if (!isClosed && !_isDisposed) {
            emit(ProfileError(f.message));
          }
        },
        (_) {
          if (!isClosed && !_isDisposed) {
            emit(const ProfileUpdateSuccess());
          }
        },
      );
    } catch (e) {
      if (!isClosed && !_isDisposed) {
        emit(ProfileError('حدث خطأ أثناء تغيير كلمة المرور'));
      }
    }
  }

  Future<void> uploadPhoto(File file) async {
    if (isClosed || _isDisposed) return;

    if (_cachedProfile != null && !isClosed && !_isDisposed) {
      emit(ProfileLoaded({
        ..._cachedProfile!,
        'localPhotoPath': file.path,
      }));
    } else {
      emit(ProfileUpdating());
    }

    try {
      final r = await _repo.uploadPhoto(file);

      if (isClosed || _isDisposed) return;

      r.fold(
        (f) {
          if (!isClosed && !_isDisposed) {
            emit(ProfileError(f.message));
          }
        },
        (_) {
          if (!isClosed && !_isDisposed) {
            load();
          }
        },
      );
    } catch (e) {
      if (!isClosed && !_isDisposed) {
        emit(ProfileError('حدث خطأ أثناء رفع الصورة'));
      }
    }
  }

  @override
  Future<void> close() {
    _isDisposed = true;
    return super.close();
  }
}