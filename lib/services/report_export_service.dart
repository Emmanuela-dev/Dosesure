import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/medication.dart';
import '../models/dose_log.dart';
import '../models/side_effect.dart';

class ReportExportService {
  Future<File> generatePdfReport({
    required String patientName,
    required String patientId,
    required List<Medication> medications,
    required List<DoseLog> doseLogs,
    required List<SideEffect> sideEffects,
    required double selfReportedAdherence,
    required double verifiedAdherence,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('DawaTrack Medication Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 20),
          _buildPatientInfo(patientName, patientId, startDate, endDate),
          pw.SizedBox(height: 20),
          _buildAdherenceSummary(selfReportedAdherence, verifiedAdherence, doseLogs),
          pw.SizedBox(height: 20),
          _buildMedicationList(medications),
          pw.SizedBox(height: 20),
          _buildDoseHistory(doseLogs, medications),
          pw.SizedBox(height: 20),
          _buildSideEffects(sideEffects, medications),
          pw.SizedBox(height: 20),
          _buildDisclaimer(),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/dawatrack_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  pw.Widget _buildPatientInfo(String name, String id, DateTime start, DateTime end) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(border: pw.Border.all()),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Patient Information', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Text('Name: $name'),
          pw.Text('Patient ID: $id'),
          pw.Text('Report Period: ${_formatDate(start)} to ${_formatDate(end)}'),
          pw.Text('Generated: ${_formatDate(DateTime.now())}'),
        ],
      ),
    );
  }

  pw.Widget _buildAdherenceSummary(double selfReported, double verified, List<DoseLog> logs) {
    final totalDoses = logs.length;
    final takenDoses = logs.where((l) => l.taken).length;
    final verifiedDoses = logs.where((l) => l.taken && l.isVerified).length;

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(border: pw.Border.all()),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Adherence Summary', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Text('Total Scheduled Doses: $totalDoses'),
          pw.Text('Self-Reported Doses Taken: $takenDoses (${selfReported.toStringAsFixed(1)}%)'),
          pw.Text('Photo-Verified Doses: $verifiedDoses (${verified.toStringAsFixed(1)}%)'),
          pw.SizedBox(height: 5),
          pw.Text('Note: Self-reported adherence may overestimate by 20-30% (Shi et al., 2010)', style: const pw.TextStyle(fontSize: 9)),
        ],
      ),
    );
  }

  pw.Widget _buildMedicationList(List<Medication> medications) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Current Medications', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Table.fromTextArray(
          headers: ['Medication', 'Dosage', 'Frequency', 'Times', 'Prescribed By'],
          data: medications.map((m) => [
            m.name,
            m.dosage,
            m.frequency,
            m.times.join(', '),
            m.prescribedByName ?? 'N/A',
          ]).toList(),
        ),
      ],
    );
  }

  pw.Widget _buildDoseHistory(List<DoseLog> logs, List<Medication> medications) {
    final recentLogs = logs.take(20).toList();
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Recent Dose History (Last 20)', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Table.fromTextArray(
          headers: ['Date', 'Medication', 'Scheduled', 'Taken', 'Verified'],
          data: recentLogs.map((log) {
            final med = medications.firstWhere((m) => m.id == log.medicationId, orElse: () => medications.first);
            return [
              _formatDate(log.scheduledTime),
              med.name,
              _formatTime(log.scheduledTime),
              log.taken ? 'Yes' : 'No',
              log.isVerified ? 'Photo' : 'Self-report',
            ];
          }).toList(),
        ),
      ],
    );
  }

  pw.Widget _buildSideEffects(List<SideEffect> effects, List<Medication> medications) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Reported Side Effects', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        if (effects.isEmpty)
          pw.Text('No side effects reported')
        else
          pw.Table.fromTextArray(
            headers: ['Date', 'Medication', 'Description', 'Severity', 'Triage'],
            data: effects.map((e) {
              final med = medications.firstWhere((m) => m.id == e.medicationId, orElse: () => medications.first);
              return [
                _formatDate(e.reportedDate),
                med.name,
                e.description,
                '${e.severity}/5',
                e.triageLevel.toUpperCase(),
              ];
            }).toList(),
          ),
      ],
    );
  }

  pw.Widget _buildDisclaimer() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey)),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Disclaimer', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 5),
          pw.Text(
            'This report is generated from DawaTrack, an mHealth medication tracking application. '
            'It is intended as a supplementary tool to support clinical decision-making and should not replace '
            'professional medical judgment. Data is patient-reported and may contain inaccuracies. '
            'This is NOT an Electronic Health Record (EHR) and does not comply with HL7/FHIR standards.',
            style: const pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<String> generateCsvReport({
    required String patientName,
    required List<Medication> medications,
    required List<DoseLog> doseLogs,
    required List<SideEffect> sideEffects,
  }) async {
    final buffer = StringBuffer();
    
    buffer.writeln('DawaTrack Medication Report - CSV Export');
    buffer.writeln('Patient: $patientName');
    buffer.writeln('Generated: ${DateTime.now()}');
    buffer.writeln('');
    
    buffer.writeln('MEDICATIONS');
    buffer.writeln('Name,Dosage,Frequency,Times,Prescribed By,Start Date,End Date');
    for (var med in medications) {
      buffer.writeln('${med.name},${med.dosage},${med.frequency},"${med.times.join('; ')}",${med.prescribedByName ?? 'N/A'},${med.startDate},${med.endDate ?? 'Ongoing'}');
    }
    buffer.writeln('');
    
    buffer.writeln('DOSE HISTORY');
    buffer.writeln('Date,Time,Medication,Scheduled Time,Taken,Verified,Taken Time');
    for (var log in doseLogs) {
      final med = medications.firstWhere((m) => m.id == log.medicationId, orElse: () => medications.first);
      buffer.writeln('${_formatDate(log.scheduledTime)},${_formatTime(log.scheduledTime)},${med.name},${_formatTime(log.scheduledTime)},${log.taken},${log.isVerified},${log.takenTime != null ? _formatTime(log.takenTime!) : 'N/A'}');
    }
    buffer.writeln('');
    
    buffer.writeln('SIDE EFFECTS');
    buffer.writeln('Date,Medication,Description,Severity,Triage Level,Notes');
    for (var effect in sideEffects) {
      final med = medications.firstWhere((m) => m.id == effect.medicationId, orElse: () => medications.first);
      buffer.writeln('${_formatDate(effect.reportedDate)},${med.name},"${effect.description}",${effect.severity},${effect.triageLevel},"${effect.notes ?? ''}"');
    }
    
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/dawatrack_report_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(buffer.toString());
    return file.path;
  }

  Future<void> shareReport(File file, String format) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'DawaTrack Medication Report',
      text: 'Medication adherence report from DawaTrack mHealth app',
    );
  }
}
