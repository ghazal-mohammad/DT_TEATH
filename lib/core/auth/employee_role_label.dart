
import 'package:flutter/widgets.dart';
import '../l10n/build_context_l10n.dart';
import 'auth_models.dart';
import 'current_user.dart';

extension EmployeeRoleLabel on EmployeeRole {
  String displayLabel(BuildContext context) => switch (this) {
        EmployeeRole.labManager => context.l10n.roleLabManager,
        EmployeeRole.warehouseManager => context.l10n.roleWarehouseManager,
        EmployeeRole.admin => context.l10n.roleAdmin,
        EmployeeRole.secretary => context.l10n.roleSecretary,
        EmployeeRole.dentist => context.l10n.roleDentist,
        EmployeeRole.unknown => '—',
      };
}

String currentUserRoleLabel(BuildContext context, {required String fallback}) {
  final role = CurrentUser.instance.role;
  return role == null ? fallback : role.displayLabel(context);
}
