import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../utils/app_color.dart';

class ProfileDetailsCard extends StatelessWidget {
  final UserProfile? profile;
  final bool isDark;
  final bool isOwnProfile;
  final VoidCallback onEditProfile;

  const ProfileDetailsCard({
    Key? key,
    required this.profile,
    required this.isDark,
    required this.isOwnProfile,
    required this.onEditProfile,
  }) : super(key: key);

  bool get hasDetails =>
      profile?.job != null ||
          profile?.location != null ||
          profile?.phoneNumber != null ||
          profile?.gender != null ||
          profile?.socialSituation != null ||
          profile?.dateOfBirth != null;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 16),
            if (!hasDetails && isOwnProfile)
              _buildAddDetailsPrompt()
            else if (!hasDetails && !isOwnProfile)
              _buildNoDetailsMessage()
            else
              _buildDetailsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddDetailsPrompt() {
    return InkWell(
      onTap: onEditProfile,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Add Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Share more about yourself',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDetailsMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'No details available',
          style: TextStyle(
            fontSize: 14,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsList() {
    return Column(
      children: [
        if (profile?.job != null && profile!.job!.isNotEmpty)
          _buildDetailItem(
            Icons.work_outline,
            'Job',
            profile!.job!,
          ),
        if (profile?.location != null && profile!.location!.isNotEmpty)
          _buildDetailItem(
            Icons.location_on_outlined,
            'Location',
            profile!.location!,
          ),
        if (profile?.phoneNumber != null && profile!.phoneNumber!.isNotEmpty)
          _buildDetailItem(
            Icons.phone_outlined,
            'Phone',
            profile!.phoneNumber!,
          ),
        if (profile?.gender != null && profile!.gender!.isNotEmpty)
          _buildDetailItem(
            Icons.wc_outlined,
            'Gender',
            profile!.gender!,
          ),
        if (profile?.socialSituation != null &&
            profile!.socialSituation!.isNotEmpty)
          _buildDetailItem(
            Icons.favorite_outline,
            'Status',
            profile!.socialSituation!,
          ),
        if (profile?.dateOfBirth != null && profile!.dateOfBirth!.isNotEmpty)
          _buildDetailItem(
            Icons.cake_outlined,
            'Birthday',
            _formatDate(profile!.dateOfBirth!),
          ),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr.split('T')[0]);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}