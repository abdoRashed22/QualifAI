import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../data/models/permission_model.dart';

abstract class PermissionsRepository {
  Future<Either<Failure, List<PermissionModel>>> getPermissions();
}
