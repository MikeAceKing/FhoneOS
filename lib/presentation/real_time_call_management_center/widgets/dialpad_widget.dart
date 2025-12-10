import 'package:flutter/material.dart';

class DialpadWidget extends StatelessWidget {
  final Function(String) onNumberInput;
  final VoidCallback onBackspace;

  const DialpadWidget({
    super.key,
    required this.onNumberInput,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildRow(['1', '2', '3']),
          const SizedBox(height: 16),
          _buildRow(['4', '5', '6']),
          const SizedBox(height: 16),
          _buildRow(['7', '8', '9']),
          const SizedBox(height: 16),
          _buildRow(['*', '0', '#']),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((digit) => _buildButton(digit)).toList(),
    );
  }

  Widget _buildButton(String digit) {
    final letters = _getLetters(digit);

    return InkWell(
      onTap: () => onNumberInput(digit),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              digit,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (letters != null)
              Text(
                letters,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  letterSpacing: 2,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String? _getLetters(String digit) {
    const Map<String, String> letterMap = {
      '2': 'ABC',
      '3': 'DEF',
      '4': 'GHI',
      '5': 'JKL',
      '6': 'MNO',
      '7': 'PQRS',
      '8': 'TUV',
      '9': 'WXYZ',
    };
    return letterMap[digit];
  }
}
