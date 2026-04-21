// lib/features/profile/presentation/cubit/profile_cubit.dart
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/profile_repository.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repo;
  ProfileCubit(this._repo) : super(ProfileInitial());

  Future<void> load() async {
    emit(ProfileLoading());
    final r = await _repo.getProfile();
    r.fold((f) => emit(ProfileError(f.message)), (d) => emit(ProfileLoaded(d)));
  }

  Future<void> update(String email, String firstName, String lastName) async {
    emit(ProfileUpdating());
    final r = await _repo.updateProfile(email, firstName, lastName);
    r.fold((f) => emit(ProfileError(f.message)), (_) => emit(const ProfileUpdateSuccess()));
  }

  Future<void> changePassword(String oldPass, String newPass) async {
    emit(ProfileUpdating());
    final r = await _repo.updatePassword(oldPass, newPass);
    r.fold((f) => emit(ProfileError(f.message)), (_) => emit(const ProfileUpdateSuccess()));
  }

  Future<void> uploadPhoto(File file) async {
    emit(ProfileUpdating());
    final r = await _repo.uploadPhoto(file);
    r.fold((f) => emit(ProfileError(f.message)), (_) { load(); });
  }
}
