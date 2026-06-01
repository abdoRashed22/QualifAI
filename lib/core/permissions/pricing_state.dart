import 'package:equatable/equatable.dart';

abstract class PricingState extends Equatable {
  const PricingState();

  @override
  List<Object?> get props => [];
}

class PricingInitial extends PricingState {}

class PricingLoading extends PricingState {}

class PricingLoaded extends PricingState {
  final List<dynamic> plans;
  const PricingLoaded(this.plans);

  @override
  List<Object?> get props => [plans];
}

class PricingError extends PricingState {
  final String message;
  const PricingError(this.message);

  @override
  List<Object?> get props => [message];
}

class PricingSubscribeLoading extends PricingState {}

class PricingActionSuccess extends PricingState {
  final String message;
  const PricingActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
