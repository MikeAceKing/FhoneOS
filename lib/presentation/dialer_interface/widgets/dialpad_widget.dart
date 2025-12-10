import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Dialpad Widget
/// Numeric keypad for phone number entry
class DialpadWidget extends StatelessWidget {
  final Function(String) onDigitPressed;
  final VoidCallback onBackspacePressed;

  const DialpadWidget({
    super.key,
    required this.onDigitPressed,
    required this.onBackspacePressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<Map<String, String>> dialpadButtons = [
      {'number': '1', 'letters': ''},
      {'number': '2', 'letters': 'ABC'},
      {'number': '3', 'letters': 'DEF'},
      {'number': '4', 'letters': 'GHI'},
      {'number': '5', 'letters': 'JKL'},
      {'number': '6', 'letters': 'MNO'},
      {'number': '7', 'letters': 'PQRS'},
      {'number': '8', 'letters': 'TUV'},
      {'number': '9', 'letters': 'WXYZ'},
      {'number': '*', 'letters': ''},
      {'number': '0', 'letters': '+'},
      {'number': '#', 'letters': ''},
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Dialpad grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 16.h,
              crossAxisSpacing: 16.w,
              childAspectRatio: 1.2,
            ),
            itemCount: dialpadButtons.length,
            itemBuilder: (context, index) {
              final button = dialpadButtons[index];
              return _buildDialpadButton(
                context,
                number: button['number']!,
                letters: button['letters']!,
                isDark: isDark,
              );
            },
          ),

          SizedBox(height: 24.h),

          // Backspace button
          InkWell(
            onTap: onBackspacePressed,
            borderRadius: BorderRadius.circular(50),
            child: Container(
              width: 56.w,
              height: 56.h,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2D2D3A) : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.backspace_outlined,
                color: theme.textTheme.bodyLarge?.color,
                size: 24.h,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialpadButton(
    BuildContext context, {
    required String number,
    required String letters,
    required bool isDark,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => onDigitPressed(number),
      borderRadius: BorderRadius.circular(50),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D2D3A) : Colors.grey[100],
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? const Color(0xFF3A3A4A) : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              number,
              style: GoogleFonts.inter(
                fontSize: 28.h,
                fontWeight: FontWeight.w400,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            if (letters.isNotEmpty)
              Text(
                letters,
                style: GoogleFonts.inter(
                  fontSize: 10.h,
                  fontWeight: FontWeight.w400,
                  color: theme.textTheme.bodySmall?.color,
                  letterSpacing: 1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
