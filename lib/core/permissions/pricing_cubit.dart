import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qualif_ai/core/permissions/pricing_repository.dart';
import 'pricing_state.dart';

class PricingCubit extends Cubit<PricingState> {
  final PricingRepository _repository;

  PricingCubit(this._repository) : super(PricingInitial());

  Future<void> loadPlans() async {
    emit(PricingLoading());
    final result = await _repository.getPlans();
    result.fold(
      (failure) => emit(PricingError(failure.message)),
      (plans) => emit(PricingLoaded(plans)),
    );
  }

  Future<void> subscribe(Map<String, dynamic> data) async {
    emit(PricingSubscribeLoading());
    final result = await _repository.subscribe(data);
    result.fold(
      (failure) => emit(PricingError(failure.message)),
      (_) {
        emit(const PricingActionSuccess('تم الاشتراك في الباقة بنجاح!'));
        loadPlans(); // إعادة تحميل الباقات لتحديث "خطتك الحالية"
      },
    );
  }
}
