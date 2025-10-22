class Language {
  final String label;
  final String code;

  const Language({required this.label, required this.code});
}

const Map<String, String> tongiLanguages = {
  "Español": "es",
  "Inglés": "en",
  "Alemán": "de",
  "Italiano": "it",
  "Frances": "fr",
};

const List<Language> availableLanguages = [
  Language(label: "Español", code: "es"),
  Language(label: "Inglés", code: "en"),
  Language(label: "Alemán", code: "de"),
  Language(label: "Italiano", code: "it"),
  Language(label: "Frances", code: "fr"),
];