import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


/// Call Button Widget
/// Primary action button to initiate phone calls
class CallButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isEnabled;
  final bool isLoading;

  const CallButtonWidget({
    super.key,
    required this.onPressed,
    this.isEnabled = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: isEnabled && !isLoading ? onPressed : null,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 72.w,
        height: 72.h,
        decoration: BoxDecoration(
          gradient: isEnabled
              ? const LinearGradient(
                  colors: [Color(0xFF00D4AA), Color(0xFF00B894)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isEnabled ? null : Colors.grey[600],
          shape: BoxShape.circle,
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: const Color(0xFF00D4AA).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: isLoading
            ? Padding(
                padding: EdgeInsets.all(20.w),
                child: const CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(
                Icons.phone,
                color: Colors.white,
                size: 32.h,
              ),
      ),
    );
  }
}
