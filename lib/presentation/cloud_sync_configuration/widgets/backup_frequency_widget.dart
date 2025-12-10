import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/sync_configuration.dart';

class BackupFrequencyWidget extends StatefulWidget {
  final BackupSchedule? backupSchedule;
  final Function(String) onFrequencyChanged;

  const BackupFrequencyWidget({
    Key? key,
    required this.backupSchedule,
    required this.onFrequencyChanged,
  }) : super(key: key);

  @override
  State<BackupFrequencyWidget> createState() => _BackupFrequencyWidgetState();
}

class _BackupFrequencyWidgetState extends State<BackupFrequencyWidget> {
  String _selectedFrequency = 'daily';

  @override
  void initState() {
    super.initState();
    _selectedFrequency = widget.backupSchedule?.frequency ?? 'daily';
  }

  @override
  Widget build(BuildContext context) {
    final schedule = widget.backupSchedule;
    final storagePercent = schedule != null
        ? (schedule.storageUsedMb / schedule.storageQuotaMb) * 100
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.backup, color: Colors.indigo[700], size: 24),
              const SizedBox(width: 12),
              Text(
                'Backup Configuration',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Backup Frequency',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFrequencyChip('realtime', 'Real-time'),
              _buildFrequencyChip('hourly', 'Hourly'),
              _buildFrequencyChip('daily', 'Daily'),
              _buildFrequencyChip('weekly', 'Weekly'),
              _buildFrequencyChip('manual', 'Manual'),
            ],
          ),
          if (schedule != null) ...[
            const Divider(height: 24),
            _buildInfoRow(
              icon: Icons.schedule,
              label: 'Last Backup',
              value: schedule.lastBackupAt != null
                  ? _formatDate(schedule.lastBackupAt!)
                  : 'Never',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.access_time,
              label: 'Next Backup',
              value: schedule.nextBackupAt != null
                  ? _formatDate(schedule.nextBackupAt!)
                  : 'Not scheduled',
            ),
            const Divider(height: 24),
            Row(
              children: [
                Icon(Icons.storage, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Storage Usage',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: storagePercent / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          storagePercent > 80 ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${storagePercent.toStringAsFixed(0)}%',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: storagePercent > 80 ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${schedule.storageUsedMb.toStringAsFixed(1)} MB / ${schedule.storageQuotaMb} MB',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFrequencyChip(String value, String label) {
    final isSelected = _selectedFrequency == value;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedFrequency = value);
          widget.onFrequencyChanged(value);
        }
      },
      selectedColor: Colors.indigo,
      backgroundColor: Colors.grey[100],
      labelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: isSelected ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}