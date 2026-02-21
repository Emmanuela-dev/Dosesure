class SymptomTriage {
  static const List<String> emergencySymptoms = [
    'difficulty breathing',
    'chest pain',
    'severe allergic reaction',
    'anaphylaxis',
    'swelling of face',
    'swelling of throat',
    'severe rash',
    'blistering',
    'peeling skin',
    'stevens-johnson',
    'seizure',
    'loss of consciousness',
    'severe bleeding',
    'blood in stool',
    'blood in urine',
    'severe abdominal pain',
    'confusion',
    'slurred speech',
    'paralysis',
    'severe headache',
    'vision loss',
    'irregular heartbeat',
    'fainting',
  ];

  static const List<String> urgentSymptoms = [
    'persistent vomiting',
    'severe diarrhea',
    'high fever',
    'severe dizziness',
    'persistent headache',
    'unusual bleeding',
    'severe nausea',
    'jaundice',
    'dark urine',
    'severe fatigue',
    'rapid weight loss',
    'severe pain',
  ];

  static TriageLevel classifySymptom(String description) {
    final lowerDesc = description.toLowerCase();
    
    for (var symptom in emergencySymptoms) {
      if (lowerDesc.contains(symptom)) {
        return TriageLevel.emergency;
      }
    }
    
    for (var symptom in urgentSymptoms) {
      if (lowerDesc.contains(symptom)) {
        return TriageLevel.urgent;
      }
    }
    
    return TriageLevel.routine;
  }

  static String getEmergencyMessage() {
    return '⚠️ EMERGENCY: These symptoms require immediate medical attention.\n\n'
        'CALL EMERGENCY SERVICES (911) or go to the nearest emergency room NOW.\n\n'
        'Do not wait for your doctor to respond.';
  }

  static String getUrgentMessage() {
    return '⚠️ URGENT: These symptoms need prompt medical evaluation.\n\n'
        'Contact your healthcare provider within 24 hours.\n'
        'If symptoms worsen, seek emergency care immediately.';
  }

  static String getRoutineMessage() {
    return 'Your report has been logged and will be reviewed by your healthcare provider.\n\n'
        'If symptoms worsen or you develop new concerning symptoms, report them immediately.';
  }
}

enum TriageLevel {
  emergency,  // Immediate emergency care required
  urgent,     // Contact provider within 24 hours
  routine,    // Dashboard notification only
}

class TriageResult {
  final TriageLevel level;
  final String message;
  final bool requiresEmergencyAction;
  final bool notifyClinician;

  TriageResult({
    required this.level,
    required this.message,
    required this.requiresEmergencyAction,
    required this.notifyClinician,
  });
}
