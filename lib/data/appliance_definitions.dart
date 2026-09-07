import '../models/appliance.dart';
import '../models/personnel_type.dart';

class ApplianceDefinitions {
  static List<Appliance> getAppliances() {
    return [
      Appliance(
        code: 'A421',
        vehicleNumber: 'QX1239U',
        positions: [
          Position(role: 'PM', personnelType: PersonnelType.alpha),
          Position(role: 'AD', personnelType: PersonnelType.alpha),
        ],
      ),
      Appliance(
        code: 'PL421',
        vehicleNumber: 'XF826T',
        positions: [
          Position(role: 'DO', personnelType: PersonnelType.firefighter),
          Position(role: 'ADO', personnelType: PersonnelType.firefighter),
          Position(role: 'PO', personnelType: PersonnelType.firefighter),
          Position(role: 'SC', personnelType: PersonnelType.firefighter),
          Position(role: 'P1', personnelType: PersonnelType.firefighter),
          Position(role: 'P2', personnelType: PersonnelType.firefighter),
          Position(role: 'P3', personnelType: PersonnelType.firefighter),
          Position(role: 'P4', personnelType: PersonnelType.firefighter),
        ],
      ),
      Appliance(
        code: 'PL422E',
        vehicleNumber: 'XE5303H',
        positions: [
          Position(role: 'PO', personnelType: PersonnelType.firefighter),
          Position(role: 'EMT SC', personnelType: PersonnelType.firefighter),
          Position(role: 'P1', personnelType: PersonnelType.firefighter),
          Position(role: 'P2', personnelType: PersonnelType.firefighter),
          Position(role: 'P3', personnelType: PersonnelType.firefighter),
          Position(role: 'P4', personnelType: PersonnelType.firefighter),
        ],
      ),
      Appliance(
        code: 'LF421',
        vehicleNumber: 'GBF3111M',
        positions: [
          Position(role: 'PO', personnelType: PersonnelType.firefighter),
          Position(role: 'SC', personnelType: PersonnelType.firefighter),
          Position(role: 'P1', personnelType: PersonnelType.firefighter),
          Position(role: 'P2', personnelType: PersonnelType.firefighter),
          Position(role: 'P3', personnelType: PersonnelType.firefighter),
          Position(role: 'P4', personnelType: PersonnelType.firefighter),
        ],
      ),
      Appliance(
        code: 'CP421',
        vehicleNumber: 'XE4478T',
        positions: [
          Position(role: 'PO', personnelType: PersonnelType.firefighter),
          Position(role: 'P1', personnelType: PersonnelType.firefighter),
          Position(role: 'P2', personnelType: PersonnelType.firefighter),
          Position(role: 'P3', personnelType: PersonnelType.firefighter),
          Position(role: 'P4', personnelType: PersonnelType.firefighter),
        ],
      ),
      Appliance(
        code: 'UFM421',
        vehicleNumber: 'YP4661K',
        positions: [
          Position(role: 'FP421M', personnelType: PersonnelType.firefighter),
          Position(role: 'P1', personnelType: PersonnelType.firefighter),
          Position(role: 'P2', personnelType: PersonnelType.firefighter),
          Position(role: 'P3', personnelType: PersonnelType.firefighter),
          Position(role: 'P4', personnelType: PersonnelType.firefighter),
        ],
      ),
      Appliance(
        code: 'FT421',
        vehicleNumber: 'XD8531B',
        positions: [
          Position(role: 'PO', personnelType: PersonnelType.firefighter),
          Position(role: 'P1', personnelType: PersonnelType.firefighter),
          Position(role: 'P2', personnelType: PersonnelType.firefighter),
          Position(role: 'P3', personnelType: PersonnelType.firefighter),
          Position(role: 'P4', personnelType: PersonnelType.firefighter),
        ],
      ),
      Appliance(
        code: 'HSV421',
        vehicleNumber: 'YP9815B',
        positions: [
          Position(
            role: 'SC (DO SC)',
            personnelType: PersonnelType.firefighter,
            isAutoAssigned: true,
            autoAssignRole: 'SC',
            autoAssignAppliance: 'PL421',
          ),
          Position(role: 'P1', personnelType: PersonnelType.firefighter),
          Position(role: 'P2', personnelType: PersonnelType.firefighter),
        ],
      ),
      Appliance(
        code: 'HMV421',
        vehicleNumber: 'YP1824C',
        positions: [
          Position(
            role: 'PO (LF PO)',
            personnelType: PersonnelType.firefighter,
            isAutoAssigned: true,
            autoAssignRole: 'PO',
            autoAssignAppliance: 'LF421',
          ),
          Position(role: 'P1', personnelType: PersonnelType.firefighter),
          Position(role: 'P2', personnelType: PersonnelType.firefighter),
        ],
      ),
      Appliance(
        code: 'IV421',
        vehicleNumber: 'QX1176S',
        positions: [
          Position(role: 'CFS', personnelType: PersonnelType.cfs),
        ],
      ),
      Appliance(
        code: 'FP421M',
        positions: [
          Position(
            role: 'PO (UFM PO)',
            personnelType: PersonnelType.firefighter,
            isAutoAssigned: true,
            autoAssignRole: 'FP421M',
            autoAssignAppliance: 'UFM421',
          ),
          Position(role: 'P1', personnelType: PersonnelType.firefighter),
          Position(role: 'P2', personnelType: PersonnelType.firefighter),
        ],
      ),
      Appliance(
        code: 'FP422M',
        positions: [
          Position(
            role: 'PO (UFM PO)',
            personnelType: PersonnelType.firefighter,
            isAutoAssigned: true,
            autoAssignRole: 'FP421M',
            autoAssignAppliance: 'UFM421',
          ),
          Position(role: 'P1', personnelType: PersonnelType.firefighter),
          Position(role: 'P2', personnelType: PersonnelType.firefighter),
        ],
      ),
      Appliance(
        code: 'FP421',
        positions: [
          Position(
            role: 'PO (CP PO)',
            personnelType: PersonnelType.firefighter,
            isAutoAssigned: true,
            autoAssignRole: 'PO',
            autoAssignAppliance: 'CP421',
          ),
          Position(role: 'P1', personnelType: PersonnelType.firefighter),
          Position(role: 'P2', personnelType: PersonnelType.firefighter),
        ],
      ),
      Appliance(
        code: 'FP422',
        positions: [
          Position(
            role: 'PO (CP PO)',
            personnelType: PersonnelType.firefighter,
            isAutoAssigned: true,
            autoAssignRole: 'PO',
            autoAssignAppliance: 'CP421',
          ),
          Position(role: 'P1', personnelType: PersonnelType.firefighter),
          Position(role: 'P2', personnelType: PersonnelType.firefighter),
        ],
      ),
    ];
  }
}