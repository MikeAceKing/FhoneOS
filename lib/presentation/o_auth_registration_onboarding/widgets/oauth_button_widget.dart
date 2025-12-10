import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/oauth_provider.dart';

class OAuthButtonWidget extends StatelessWidget {
  final OAuthProvider provider;
  final VoidCallback onPressed;

  const OAuthButtonWidget({
    super.key,
    required this.provider,
    required this.onPressed,
  });

  Color _getProviderColor() {
    switch (provider.id) {
      case 'google':
        return Color(0xFF4285F4);
      case 'microsoft':
        return Color(0xFF00A4EF);
      case 'apple':
        return Colors.black;
      case 'amazon':
        return Color(0xFFFF9900);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: provider.isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 2,
        shadowColor: Colors.black26,
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _getProviderColor(),
              shape: BoxShape.circle,
            ),
            padding: EdgeInsets.all(4),
            child: CachedNetworkImage(
              imageUrl: provider.iconUrl,
              color: Colors.white,
              width: 16,
              height: 16,
              placeholder: (context, url) => SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              errorWidget: (context, url, error) => Icon(
                Icons.account_circle,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              'Doorgaan met ${provider.name}',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
