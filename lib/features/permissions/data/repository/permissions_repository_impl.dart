import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../data/models/permission_mapper.dart';
import '../../data/models/permission_model.dart';
import '../../data/remote/permissions_remote_ds.dart';
import '../../domain/repositories/permissions_repository.dart';

class PermissionsRepositoryImpl implements PermissionsRepository {
  final PermissionsRemoteDs remoteDs;
  final _mapper = const PermissionMapper();

  PermissionsRepositoryImpl(this.remoteDs);

  @override
  Future<Either<Failure, List<PermissionModel>>> getPermissions() async {
    try {
      final data = await remoteDs.getPermissions();
      final permissions = data
          .whereType<Map>()
          .map((e) => _mapper.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      return Right(permissions);
    } catch (e) {
      return Left(e is Failure ? e : ServerFailure(e.toString()));
    }
  }
}
