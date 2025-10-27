class Language {
  final String label;
  final String code;

  const Language({required this.label, required this.code});
}

const Map<String, String> tongiLanguages = {
  "es": "Español",
  "en": "Inglés",
  "fr": "Francés",
  "de": "Alemán",
  "it": "Italiano",
  "pt": "Portugués",
  "zh-Hans": "Chino Simplificado",
  "zh-Hant": "Chino Tradicional",
  "ja": "Japonés",
  "ko": "Coreano",
  "ar": "Árabe",
  "ru": "Ruso",
  "hi": "Hindi",
};

const List<Language> availableLanguages = [
  Language(label: "Español", code: "es"),
  Language(label: "Inglés", code: "en"),
  Language(label: "Francés", code: "fr"),
  Language(label: "Alemán", code: "de"),
  Language(label: "Italiano", code: "it"),
  Language(label: "Portugués", code: "pt"),
  Language(label: "Chino Simplificado", code: "zh-Hans"),
  Language(label: "Chino Tradicional", code: "zh-Hant"),
  Language(label: "Japonés", code: "ja"),
  Language(label: "Coreano", code: "ko"),
  Language(label: "Árabe", code: "ar"),
  Language(label: "Ruso", code: "ru"),
  Language(label: "Hindi", code: "hi"),
];
