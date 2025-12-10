import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConnectionStatusWidget extends StatefulWidget {
  const ConnectionStatusWidget({Key? key}) : super(key: key);

  @override
  State<ConnectionStatusWidget> createState() => _ConnectionStatusWidgetState();
}

class _ConnectionStatusWidgetState extends State<ConnectionStatusWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  final List<ServiceConnection> _services = [
    ServiceConnection('Twilio', Icons.phone, true),
    ServiceConnection('Stripe', Icons.credit_card, true),
    ServiceConnection('Cloud Sync', Icons.cloud_done, true),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(13),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(26), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withAlpha(128),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              Text(
                'Always Connected',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children:
                _services
                    .map((service) => _buildServiceBadge(service))
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceBadge(ServiceConnection service) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(13),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              service.isConnected
                  ? const Color(0xFF10B981).withAlpha(77)
                  : Colors.white.withAlpha(51),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            service.icon,
            size: 14,
            color:
                service.isConnected ? const Color(0xFF10B981) : Colors.white70,
          ),
          const SizedBox(width: 6),
          Text(
            service.name,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: service.isConnected ? Colors.white : Colors.white70,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.check_circle,
            size: 14,
            color:
                service.isConnected ? const Color(0xFF10B981) : Colors.white30,
          ),
        ],
      ),
    );
  }
}

class ServiceConnection {
  final String name;
  final IconData icon;
  final bool isConnected;

  ServiceConnection(this.name, this.icon, this.isConnected);
}
