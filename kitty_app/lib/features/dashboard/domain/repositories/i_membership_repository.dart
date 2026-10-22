import '../entities/membership_entity.dart';

/// Pure domain repository interface for scheme enrollment and memberships.
abstract interface class IMembershipRepository {
  /// Enrolls the user into a specific gold kitty savings scheme.
  Future<MembershipEntity> joinScheme({required String schemeId});

  /// Retrieves a specific membership by ID.
  Future<MembershipEntity> getMembershipById(String membershipId);
}
