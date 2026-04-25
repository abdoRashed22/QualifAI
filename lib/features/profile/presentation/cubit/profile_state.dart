part of 'profile_cubit.dart';

// ============================================================================
// PROFILE STATES (MERGED CLEAN VERSION)
// ============================================================================

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileUpdating extends ProfileState {
  const ProfileUpdating();
}

// ✔ unified naming kept (profile instead of data)
class ProfileLoaded extends ProfileState {
  final Map<String, dynamic> profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

// ✅ ADDED (from NEW)
class ProfileImageUploadSuccess extends ProfileState {
  final String imageUrl;

  const ProfileImageUploadSuccess(this.imageUrl);

  @override
  List<Object?> get props => [imageUrl];
}

class ProfileUpdateSuccess extends ProfileState {
  const ProfileUpdateSuccess();
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}