/// Questions the coach must not answer with generated text: possible medical
/// emergencies and topics that need a professional. Answered with a fixed,
/// safe reply instead of the model.
enum CannedReply { emergency, professional }

abstract final class CoachSafety {
  // English plus common Hindi/Marathi phrasings, since the coach is asked in
  // the app's language.
  static final _emergency = RegExp(
    r'chest pain|can.?t breathe|cannot breathe|short(ness)? of breath|'
    r'faint(ed|ing)?|pass(ed)? out|heart attack|stroke|suicid|kill myself|'
    r'self.?harm|severe pain|'
    r'सीने में दर्द|छाती में दर्द|छातीत दुख|छातीत वेदना|सांस नहीं|'
    r'श्वास घेता येत नाही|बेहोश|शुद्ध हरपल|हार्ट अटैक|हृदयविकाराचा झटका|'
    r'आत्महत्या|खुद को नुकसान|जीव द्यावा|तेज़ दर्द|तीव्र वेदना',
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

  /// Which fixed reply [question] needs, or null when the model may answer.
  static CannedReply? classify(String question) {
    if (_emergency.hasMatch(question)) return CannedReply.emergency;
    if (_professional.hasMatch(question)) return CannedReply.professional;
    return null;
  }

  /// The English fixed reply for [question], or null.
  static String? cannedReply(String question) => switch (classify(question)) {
    CannedReply.emergency => emergencyReply,
    CannedReply.professional => professionalReply,
    null => null,
  };
}
