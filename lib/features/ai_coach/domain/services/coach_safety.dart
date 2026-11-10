/// Questions the coach must not answer with generated text: possible medical
/// emergencies and topics that need a professional. Answered with a fixed,
/// safe reply instead of the model.
abstract final class CoachSafety {
  static final _emergency = RegExp(
    r'chest pain|can.?t breathe|cannot breathe|short(ness)? of breath|'
    r'faint(ed|ing)?|pass(ed)? out|heart attack|stroke|suicid|kill myself|'
    r'self.?harm|severe pain',
    caseSensitive: false,
  );

  static final _professional = RegExp(
    r'steroid|anabolic|\bsarms?\b|insulin dose|diabet(es|ic) medication|'
    r'starv(e|ing)|purg(e|ing)|bulimi|anorexi|eating disorder|'
    r'pregnan|broken bone|fracture',
    caseSensitive: false,
  );

  static const emergencyReply =
      "This could be serious, so please don't rely on an app for it. Stop "
      'exercising and contact a doctor or your local emergency number (112 in '
      'India) right away. If you are thinking about harming yourself, please '
      'reach out to someone you trust or a helpline such as Tele-MANAS '
      '(14416) now.';

  static const professionalReply =
      "That's a topic where advice needs to fit your health history, so I "
      "can't give guidance on it. Please talk to a doctor or a registered "
      'dietitian. I can still help with general training, steps, water and '
      'balanced eating.';

  /// A fixed reply for [question], or null when the model may answer.
  static String? cannedReply(String question) {
    if (_emergency.hasMatch(question)) return emergencyReply;
    if (_professional.hasMatch(question)) return professionalReply;
    return null;
  }
}
