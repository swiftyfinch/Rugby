// swiftlint:disable identifier_name type_body_length trailing_comma file_length line_length

/// Enumeration describing available software keyboards in the system.
public enum SoftwareKeyboard: String, LaunchArgumentValue {

    /// Automatically generated value for software keyboard Arabic.
    case Arabic = "ar@sw=Arabic"

    /// Automatically generated value for software keyboard Armenian.
    case Armenian = "hy@sw=Armenian"

    /// Automatically generated value for software keyboard AzerbaijaniLatin.
    case AzerbaijaniLatin = "az_Latn@sw=QWERTY-Azeri"

    /// Automatically generated value for software keyboard Bangla.
    case Bangla = "bn@sw=Bengali"

    /// Automatically generated value for software keyboard Belarusian.
    case Belarusian = "be@sw=Belarusian"

    /// Automatically generated value for software keyboard BulgarianBulgaria.
    case BulgarianBulgaria = "bg_BG@sw=Bulgarian"

    /// Automatically generated value for software keyboard CatalanSpain.
    case CatalanSpain = "ca_ES@sw=QWERTY-Catalan"

    /// Automatically generated value for software keyboard Cherokee.
    case Cherokee = "chr@sw=Cherokee"

    /// Automatically generated value for software keyboard ChineseChinamainland.
    case ChineseChinamainland = "zh_CN@sw=Pinyin-Simplified"

    /// Automatically generated value for software keyboard ChineseSimplifiedHWR.
    case ChineseSimplifiedHWR = "zh_Hans-HWR@sw=HWR-Simplified"

    /// Automatically generated value for software keyboard ChineseSimplifiedPinyinRomanization.
    case ChineseSimplifiedPinyinRomanization = "zh_Hans-Pinyin@sw=Pinyin-Simplified"

    /// Automatically generated value for software keyboard ChineseSimplifiedSHUANGPIN.
    case ChineseSimplifiedSHUANGPIN = "zh_Hans-Shuangpin@sw=Pinyin-Simplified"

    /// Automatically generated value for software keyboard ChineseSimplifiedWUBIHUA.
    case ChineseSimplifiedWUBIHUA = "zh_Hans-Wubihua@sw=Wubihua-Simplified"

    /// Automatically generated value for software keyboard ChineseTaiwan.
    case ChineseTaiwan = "zh_TW@sw=Zhuyin"

    /// Automatically generated value for software keyboard ChineseTraditionalCANGJIE.
    case ChineseTraditionalCANGJIE = "zh_Hant-Cangjie@sw=Cangjie"

    /// Automatically generated value for software keyboard ChineseTraditionalHWR.
    case ChineseTraditionalHWR = "zh_Hant-HWR@sw=HWR-Traditional"

    /// Automatically generated value for software keyboard ChineseTraditionalPinyinRomanization.
    case ChineseTraditionalPinyinRomanization = "zh_Hant-Pinyin@sw=Pinyin-Traditional"

    /// Automatically generated value for software keyboard ChineseTraditionalSHUANGPIN.
    case ChineseTraditionalSHUANGPIN = "zh_Hant-Shuangpin@sw=Pinyin-Traditional"

    /// Automatically generated value for software keyboard ChineseTraditionalSUCHENG.
    case ChineseTraditionalSUCHENG = "zh_Hant-Sucheng@sw=Sucheng"

    /// Automatically generated value for software keyboard ChineseTraditionalWUBIHUA.
    case ChineseTraditionalWUBIHUA = "zh_Hant-Wubihua@sw=Wubihua-Traditional"

    /// Automatically generated value for software keyboard ChineseTraditionalZHUYIN.
    case ChineseTraditionalZHUYIN = "zh_Hant-Zhuyin@sw=Zhuyin"

    /// Automatically generated value for software keyboard CroatianCroatia.
    case CroatianCroatia = "hr_HR@sw=QWERTZ"

    /// Automatically generated value for software keyboard CzechCzechia.
    case CzechCzechia = "cs_CZ@sw=Czech-Slovak"

    /// Automatically generated value for software keyboard DanishDenmark.
    case DanishDenmark = "da_DK@sw=QWERTY-Danish"

    /// Automatically generated value for software keyboard DutchBelgium.
    case DutchBelgium = "nl_BE@sw=AZERTY"

    /// Automatically generated value for software keyboard DutchNetherlands.
    case DutchNetherlands = "nl_NL@sw=QWERTY"

    /// Automatically generated value for software keyboard EnglishAustralia.
    case EnglishAustralia = "en_AU@sw=QWERTY"

    /// Automatically generated value for software keyboard EnglishCanada.
    case EnglishCanada = "en_CA@sw=QWERTY"

    /// Automatically generated value for software keyboard EnglishIndia.
    case EnglishIndia = "en_IN@sw=QWERTY"

    /// Automatically generated value for software keyboard EnglishJapan.
    case EnglishJapan = "en_JP@sw=QWERTY"

    /// Automatically generated value for software keyboard EnglishSingapore.
    case EnglishSingapore = "en_SG@sw=QWERTY"

    /// Automatically generated value for software keyboard EnglishUnitedKingdom.
    case EnglishUnitedKingdom = "en_GB@sw=QWERTY"

    /// Automatically generated value for software keyboard EnglishUnitedStates.
    case EnglishUnitedStates = "en_US@sw=QWERTY"

    /// Automatically generated value for software keyboard EstonianEstonia.
    case EstonianEstonia = "et_EE@sw=QWERTY"

    /// Automatically generated value for software keyboard FinnishFinland.
    case FinnishFinland = "fi_FI@sw=QWERTY-Swedish-Finnish"

    /// Automatically generated value for software keyboard FrenchBelgium.
    case FrenchBelgium = "fr_BE@sw=AZERTY-French"

    /// Automatically generated value for software keyboard FrenchCanada.
    case FrenchCanada = "fr_CA@sw=QWERTY-Accents"

    /// Automatically generated value for software keyboard FrenchFrance.
    case FrenchFrance = "fr_FR@sw=AZERTY-French"

    /// Automatically generated value for software keyboard FrenchSwitzerland.
    case FrenchSwitzerland = "fr_CH@sw=QWERTZ-Accents"

    /// Automatically generated value for software keyboard Georgian.
    case Georgian = "ka@sw=Georgian-Phonetic"

    /// Automatically generated value for software keyboard GermanAustria.
    case GermanAustria = "de_AT@sw=QWERTZ-German"

    /// Automatically generated value for software keyboard GermanGermany.
    case GermanGermany = "de_DE@sw=QWERTZ-German"

    /// Automatically generated value for software keyboard GermanSwitzerland.
    case GermanSwitzerland = "de_CH@sw=QWERTZ-German"

    /// Automatically generated value for software keyboard GreekGreece.
    case GreekGreece = "el_GR@sw=Greek"

    /// Automatically generated value for software keyboard Gujarati.
    case Gujarati = "gu@sw=Gujarati"

    /// Automatically generated value for software keyboard Hawaiian.
    case Hawaiian = "haw@sw=QWERTY-Hawaiian"

    /// Automatically generated value for software keyboard HebrewIsrael.
    case HebrewIsrael = "he_IL@sw=Hebrew"

    /// Automatically generated value for software keyboard Hindi.
    case Hindi = "hi@sw=Devanagari-Hindi"

    /// Automatically generated value for software keyboard HindiLatin.
    case HindiLatin = "hi_Latn@sw=QWERTY"

    /// Automatically generated value for software keyboard HindiTRANSLIT.
    case HindiTRANSLIT = "hi-Translit@sw=QWERTY-Hindi"

    /// Automatically generated value for software keyboard HungarianHungary.
    case HungarianHungary = "hu_HU@sw=QWERTZ"

    /// Automatically generated value for software keyboard IcelandicIceland.
    case IcelandicIceland = "is_IS@sw=Icelandic"

    /// Automatically generated value for software keyboard IndonesianIndonesia.
    case IndonesianIndonesia = "id_ID@sw=QWERTY"

    /// Automatically generated value for software keyboard IrishIreland.
    case IrishIreland = "ga_IE@sw=QWERTY"

    /// Automatically generated value for software keyboard ItalianItaly.
    case ItalianItaly = "it_IT@sw=QWERTY"

    /// Automatically generated value for software keyboard JapaneseJapan.
    case JapaneseJapan = "ja_JP@sw=Kana"

    /// Automatically generated value for software keyboard JapaneseJapanKANA.
    case JapaneseJapanKANA = "ja_JP-Kana@sw=Kana"

    /// Automatically generated value for software keyboard JapaneseJapanROMAJI.
    case JapaneseJapanROMAJI = "ja_JP-Romaji@sw=QWERTY-Japanese"

    /// Automatically generated value for software keyboard Kannada.
    case Kannada = "kn@sw=Kannada"

    /// Automatically generated value for software keyboard KoreanSouthKorea.
    case KoreanSouthKorea = "ko_KR@sw=Korean"

    /// Automatically generated value for software keyboard LatvianLatvia.
    case LatvianLatvia = "lv_LV@sw=QWERTY"

    /// Automatically generated value for software keyboard LithuanianLithuania.
    case LithuanianLithuania = "lt_LT@sw=QWERTY"

    /// Automatically generated value for software keyboard MacedonianMacedonia.
    case MacedonianMacedonia = "mk_MK@sw=Macedonian"

    /// Automatically generated value for software keyboard MalayMalaysia.
    case MalayMalaysia = "ms_MY@sw=QWERTY"

    /// Automatically generated value for software keyboard Malayalam.
    case Malayalam = "ml@sw=Malayalam"

    /// Automatically generated value for software keyboard Maori.
    case Maori = "mi@sw=QWERTY"

    /// Automatically generated value for software keyboard Marathi.
    case Marathi = "mr@sw=Devanagari-Marathi"

    /// Automatically generated value for software keyboard NajdiArabic.
    case NajdiArabic = "ars@sw=Arabic"

    /// Automatically generated value for software keyboard NorwegianBokmålNorway.
    case NorwegianBokmålNorway = "nb_NO@sw=QWERTY-Norwegian"

    /// Automatically generated value for software keyboard Odia.
    case Odia = "or@sw=Oriya"

    /// Automatically generated value for software keyboard Persian.
    case Persian = "fa@sw=Persian"

    /// Automatically generated value for software keyboard PolishPoland.
    case PolishPoland = "pl_PL@sw=QWERTY"

    /// Automatically generated value for software keyboard PortugueseBrazil.
    case PortugueseBrazil = "pt_BR@sw=QWERTY"

    /// Automatically generated value for software keyboard PortuguesePortugal.
    case PortuguesePortugal = "pt_PT@sw=QWERTY"

    /// Automatically generated value for software keyboard Punjabi.
    case Punjabi = "pa@sw=Punjabi-Phonetic"

    /// Automatically generated value for software keyboard RomanianRomania.
    case RomanianRomania = "ro_RO@sw=QWERTY"

    /// Automatically generated value for software keyboard RussianRussia.
    case RussianRussia = "ru_RU@sw=Russian"

    /// Automatically generated value for software keyboard SerbianCyrillic.
    case SerbianCyrillic = "sr_Cyrl@sw=Serbian-Cyrillic"

    /// Automatically generated value for software keyboard SerbianLatin.
    case SerbianLatin = "sr_Latn@sw=QWERTY"

    /// Automatically generated value for software keyboard SlovakSlovakia.
    case SlovakSlovakia = "sk_SK@sw=Czech-Slovak"

    /// Automatically generated value for software keyboard SlovenianSlovenia.
    case SlovenianSlovenia = "sl_SI@sw=QWERTZ"

    /// Automatically generated value for software keyboard SpanishLatinAmerica.
    case SpanishLatinAmerica = "es_419@sw=QWERTY-Spanish"

    /// Automatically generated value for software keyboard SpanishMexico.
    case SpanishMexico = "es_MX@sw=QWERTY-Spanish"

    /// Automatically generated value for software keyboard SpanishSpain.
    case SpanishSpain = "es_ES@sw=QWERTY-Spanish"

    /// Automatically generated value for software keyboard Swahili.
    case Swahili = "sw@sw=QWERTY"

    /// Automatically generated value for software keyboard SwedishSweden.
    case SwedishSweden = "sv_SE@sw=QWERTY-Swedish-Finnish"

    /// Automatically generated value for software keyboard TagalogPhilippines.
    case TagalogPhilippines = "tl_PH@sw=QWERTY"

    /// Automatically generated value for software keyboard Tamil.
    case Tamil = "ta@sw=Tamil"

    /// Automatically generated value for software keyboard Telugu.
    case Telugu = "te@sw=Telugu"

    /// Automatically generated value for software keyboard ThaiThailand.
    case ThaiThailand = "th_TH@sw=Thai"

    /// Automatically generated value for software keyboard Tibetan.
    case Tibetan = "bo@sw=Tibetan"

    /// Automatically generated value for software keyboard TurkishTurkey.
    case TurkishTurkey = "tr_TR@sw=Turkish-Q"

    /// Automatically generated value for software keyboard UkrainianUkraine.
    case UkrainianUkraine = "uk_UA@sw=Ukrainian"

    /// Automatically generated value for software keyboard Urdu.
    case Urdu = "ur@sw=Urdu"

    /// Automatically generated value for software keyboard VietnameseVietnam.
    case VietnameseVietnam = "vi_VN@sw=QWERTY"

    /// Automatically generated value for software keyboard WelshUnitedKingdom.
    case WelshUnitedKingdom = "cy_GB@sw=QWERTY"
}
