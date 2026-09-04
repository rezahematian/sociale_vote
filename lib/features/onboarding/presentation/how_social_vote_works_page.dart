import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/shared/widgets/content_directionality.dart';

class HowSocialVoteWorksPage extends StatelessWidget {
  const HowSocialVoteWorksPage({super.key});

  static const double _productProgress = 0.33;
  static const String _principlesVersion = '0.3';
  static const String _posterAssetIt =
      'assets/vision/social_vote_regole_del_gioco_33.png';

  String _posterAssetForLocale(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode.toLowerCase();
    return switch (language) {
      'it' => _posterAssetIt,
      'de' => 'assets/vision/social_vote_rules_vision_de.jpg',
      'fa' => 'assets/vision/social_vote_rules_vision_fa.jpg',
      'es' => 'assets/vision/social_vote_rules_vision_es.jpg',
      'pt' => 'assets/vision/social_vote_rules_vision_pt.jpg',
      'fr' => 'assets/vision/social_vote_rules_vision_fr.jpg',
      'ar' => 'assets/vision/social_vote_rules_vision_ar.jpg',
      'ro' => 'assets/vision/social_vote_rules_vision_ro.jpg',
      'ru' => 'assets/vision/social_vote_rules_vision_ru.jpg',
      'zh' => 'assets/vision/social_vote_rules_vision_zh.jpg',
      _ => 'assets/vision/social_vote_rules_vision_en.jpg',
    };
  }

  String _text(
    BuildContext context, {
    required String it,
    required String en,
    required String de,
    String? fa,
    String? es,
    String? pt,
    String? fr,
    String? ar,
    String? ro,
    String? ru,
    String? zh,
  }) {
    final language = Localizations.localeOf(context).languageCode.toLowerCase();
    return switch (language) {
      'it' => it,
      'de' => de,
      'fa' => fa ?? en,
      'es' => es ?? en,
      'pt' => pt ?? en,
      'fr' => fr ?? en,
      'ar' => ar ?? en,
      'ro' => ro ?? en,
      'ru' => ru ?? en,
      'zh' => zh ?? en,
      _ => en,
    };
  }

  Future<void> _shareVision(BuildContext context) async {
    final message = _text(
      context,
      it: 'Regole del gioco · Social Vote — una persona, una voce. '
          'Scopri la visione e lo stato del prodotto.',
      en: 'Rules of the game · Social Vote — one person, one voice. '
          'Discover the vision and current product status.',
      de: 'Spielregeln · Social Vote — eine Person, eine Stimme. '
          'Entdecke die Vision und den aktuellen Produktstatus.',
      fa: 'قواعد بازی · Social Vote — هر شخص، یک صدا. چشم‌انداز و وضعیت فعلی محصول را ببینید.',
      es: 'Reglas del juego · Social Vote — una persona, una voz. Descubre la visión y el estado actual del producto.',
      pt: 'Regras do jogo · Social Vote — uma pessoa, uma voz. Descubra a visão e o estado atual do produto.',
      fr: 'Règles du jeu · Social Vote — une personne, une voix. Découvrez la vision et l’état actuel du produit.',
      ar: 'قواعد اللعبة · Social Vote — شخص واحد، صوت واحد. اكتشف الرؤية وحالة المنتج الحالية.',
      ro: 'Regulile jocului · Social Vote — o persoană, o voce. Descoperă viziunea și stadiul actual al produsului.',
    
      ru: 'Правила игры · Social Vote — один человек, один голос. Узнайте о концепции и текущем состоянии продукта.',
      zh: '游戏规则 · Social Vote — 一人一票。了解产品愿景和当前状态。',
);
    await Share.share('$message\n${AppRouter.publicHowItWorksUrl()}');
  }

  void _goHome(BuildContext context) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    navigator.pushNamedAndRemoveUntil(AppRouter.home, (_) => false);
  }

  List<_RuleData> _buildRules(BuildContext context) {
    return [
      _RuleData(
        number: 1,
        icon: Icons.person_outline_rounded,
        title: _text(context, it: 'Una persona, una voce', en: 'One person, one voice', de: 'Eine Person, eine Stimme', fa: 'هر شخص، یک صدا', es: 'Una persona, una voz', pt: 'Uma pessoa, uma voz', fr: 'Une personne, une voix', ar: 'شخص واحد، صوت واحد', ro: 'O persoană, o voce',
      ru: 'Один человек, один голос',
      zh: '一人一票',
),
        body: _text(context, it: 'Il modello di identità punta a una persona reale per account e aumenta il livello di verifica solo quando una funzione lo richiede.', en: 'The identity model aims for one real person per account and raises verification only when a feature requires it.', de: 'Das Identitätsmodell zielt auf eine reale Person pro Konto und erhöht die Verifizierung nur, wenn eine Funktion sie benötigt.', fa: 'مدل هویت به یک شخص واقعی برای هر حساب متکی است و فقط زمانی سطح تأیید را بالا می‌برد که یک قابلیت به آن نیاز داشته باشد.', es: 'El modelo de identidad busca una persona real por cuenta y aumenta la verificación solo cuando una función lo requiere.', pt: 'O modelo de identidade procura uma pessoa real por conta e aumenta a verificação apenas quando uma funcionalidade o exige.', fr: 'Le modèle d’identité vise une personne réelle par compte et renforce la vérification uniquement lorsqu’une fonction l’exige.', ar: 'يهدف نموذج الهوية إلى شخص حقيقي واحد لكل حساب، ولا يرفع مستوى التحقق إلا عندما تتطلبه ميزة معينة.', ro: 'Modelul de identitate urmărește o persoană reală per cont și crește nivelul de verificare doar când o funcție o cere.',
      ru: 'Модель идентификации ориентирована на одного реального человека на аккаунт и повышает уровень проверки только тогда, когда этого требует функция.',
      zh: '身份模型以每个账户对应一个真实人为目标，仅在功能需要时提高验证级别。',
),
      ),
      _RuleData(
        number: 2,
        icon: Icons.search_rounded,
        title: _text(context, it: 'Verità e trasparenza', en: 'Truth and transparency', de: 'Wahrheit und Transparenz', fa: 'حقیقت و شفافیت', es: 'Verdad y transparencia', pt: 'Verdade e transparência', fr: 'Vérité et transparence', ar: 'الحقيقة والشفافية', ro: 'Adevăr și transparență',
      ru: 'Правда и прозрачность',
      zh: '真实与透明',
),
        body: _text(context, it: 'Fatti, fonti e opinioni devono essere distinguibili. La provenienza delle informazioni importanti deve essere leggibile.', en: 'Facts, sources and opinions should be distinguishable. The provenance of important information should be readable.', de: 'Fakten, Quellen und Meinungen sollen unterscheidbar sein. Die Herkunft wichtiger Informationen soll nachvollziehbar sein.', fa: 'واقعیت‌ها، منابع و نظرها باید از هم قابل تشخیص باشند و منشأ اطلاعات مهم روشن باشد.', es: 'Hechos, fuentes y opiniones deben distinguirse. La procedencia de la información importante debe ser legible.', pt: 'Factos, fontes e opiniões devem ser distinguíveis. A origem da informação importante deve ser legível.', fr: 'Faits, sources et opinions doivent pouvoir être distingués. La provenance des informations importantes doit être lisible.', ar: 'يجب أن يكون من الممكن التمييز بين الحقائق والمصادر والآراء، وأن يكون مصدر المعلومات المهمة واضحًا.', ro: 'Faptele, sursele și opiniile trebuie să poată fi diferențiate, iar proveniența informațiilor importante să fie clară.',
      ru: 'Факты, источники и мнения должны быть различимы. Происхождение важной информации должно быть понятно.',
      zh: '事实、来源和观点应当可以区分。重要信息的来源应当清晰可查。',
),
      ),
      _RuleData(
        number: 3,
        icon: Icons.forum_outlined,
        title: _text(context, it: 'Opinioni diverse, rispetto obbligatorio', en: 'Different opinions, mandatory respect', de: 'Unterschiedliche Meinungen, verbindlicher Respekt', fa: 'نظرهای متفاوت، احترام الزامی', es: 'Opiniones distintas, respeto obligatorio', pt: 'Opiniões diferentes, respeito obrigatório', fr: 'Opinions différentes, respect obligatoire', ar: 'آراء مختلفة، واحترام إلزامي', ro: 'Opinii diferite, respect obligatoriu',
      ru: 'Разные мнения, обязательное уважение',
      zh: '观点可以不同，尊重必须做到',
),
        body: _text(context, it: 'Il dissenso è parte del prodotto. Attacchi personali, minacce, odio e manipolazioni non sono strumenti di partecipazione.', en: 'Disagreement is part of the product. Personal attacks, threats, hate and manipulation are not participation tools.', de: 'Widerspruch gehört zum Produkt. Persönliche Angriffe, Drohungen, Hass und Manipulation sind keine Mittel der Teilhabe.', fa: 'اختلاف نظر بخشی از محصول است؛ حمله شخصی، تهدید، نفرت و دستکاری ابزار مشارکت نیستند.', es: 'El desacuerdo forma parte del producto. Los ataques personales, amenazas, odio y manipulación no son herramientas de participación.', pt: 'A discordância faz parte do produto. Ataques pessoais, ameaças, ódio e manipulação não são ferramentas de participação.', fr: 'Le désaccord fait partie du produit. Les attaques personnelles, menaces, haine et manipulations ne sont pas des outils de participation.', ar: 'الاختلاف جزء من المنتج. الهجمات الشخصية والتهديدات والكراهية والتلاعب ليست أدوات للمشاركة.', ro: 'Dezacordul face parte din produs. Atacurile personale, amenințările, ura și manipularea nu sunt instrumente de participare.',
      ru: 'Несогласие — часть продукта. Личные нападки, угрозы, ненависть и манипуляции не являются инструментами участия.',
      zh: '分歧是产品的一部分。人身攻击、威胁、仇恨和操纵不是参与工具。',
),
      ),
      _RuleData(
        number: 4,
        icon: Icons.bar_chart_rounded,
        title: _text(context, it: 'La maggioranza decide nei Vote', en: 'The majority decides in Vote', de: 'Die Mehrheit entscheidet in Vote', fa: 'اکثریت در Vote تصمیم می‌گیرد', es: 'La mayoría decide en Vote', pt: 'A maioria decide no Vote', fr: 'La majorité décide dans Vote', ar: 'الأغلبية تقرر في Vote', ro: 'Majoritatea decide în Vote',
      ru: 'В Vote решает большинство',
      zh: 'Vote 中由多数决定',
),
        body: _text(context, it: 'Il risultato riflette i voti validi secondo le regole dichiarate. Le opinioni di minoranza non devono essere cancellate dal dibattito.', en: 'The result reflects valid votes under the declared rules. Minority views should not be erased from the discussion.', de: 'Das Ergebnis spiegelt die gültigen Stimmen nach den erklärten Regeln wider. Minderheitsmeinungen sollen nicht aus der Debatte verschwinden.', fa: 'نتیجه بر اساس رأی‌های معتبر و قوانین اعلام‌شده شکل می‌گیرد و دیدگاه اقلیت نباید از گفت‌وگو حذف شود.', es: 'El resultado refleja los votos válidos según las reglas declaradas. Las opiniones minoritarias no deben borrarse del debate.', pt: 'O resultado reflete os votos válidos segundo as regras declaradas. As opiniões minoritárias não devem ser apagadas do debate.', fr: 'Le résultat reflète les votes valides selon les règles annoncées. Les opinions minoritaires ne doivent pas être effacées du débat.', ar: 'تعكس النتيجة الأصوات الصحيحة وفق القواعد المعلنة، ولا ينبغي محو آراء الأقلية من النقاش.', ro: 'Rezultatul reflectă voturile valide conform regulilor declarate. Opiniile minoritare nu trebuie șterse din dezbatere.',
      ru: 'Результат отражает действительные голоса по объявленным правилам. Мнения меньшинства не должны исчезать из обсуждения.',
      zh: '结果反映按已公布规则计算的有效投票。少数意见不应被从讨论中抹去。',
),
      ),
      _RuleData(
        number: 5,
        icon: Icons.refresh_rounded,
        title: _text(context, it: 'Puoi cambiare idea', en: 'You can change your mind', de: 'Du kannst deine Meinung ändern', fa: 'می‌توانی نظرت را عوض کنی', es: 'Puedes cambiar de idea', pt: 'Podes mudar de ideia', fr: 'Vous pouvez changer d’avis', ar: 'يمكنك تغيير رأيك', ro: 'Îți poți schimba opinia',
      ru: 'Вы можете изменить своё мнение',
      zh: '你可以改变想法',
),
        body: _text(context, it: 'Quando un Vote consente di modificare la scelta prima della chiusura, questa possibilità deve essere dichiarata chiaramente prima di partecipare.', en: 'When a Vote allows changing a choice before closing, that possibility must be declared clearly before participation.', de: 'Wenn ein Vote eine Änderung der Wahl vor dem Ende erlaubt, muss dies vor der Teilnahme klar angegeben werden.', fa: 'اگر یک Vote اجازه تغییر انتخاب تا پیش از بسته‌شدن را بدهد، این امکان باید پیش از مشارکت به‌روشنی اعلام شود.', es: 'Cuando un Vote permite cambiar la elección antes del cierre, esa posibilidad debe declararse claramente antes de participar.', pt: 'Quando um Vote permite alterar a escolha antes do fecho, essa possibilidade deve ser declarada claramente antes da participação.', fr: 'Lorsqu’un Vote permet de modifier son choix avant la clôture, cette possibilité doit être annoncée clairement avant la participation.', ar: 'عندما يسمح Vote بتغيير الاختيار قبل الإغلاق، يجب توضيح ذلك بوضوح قبل المشاركة.', ro: 'Când un Vote permite schimbarea opțiunii înainte de închidere, această posibilitate trebuie declarată clar înainte de participare.',
      ru: 'Если Vote позволяет изменить выбор до закрытия, это должно быть ясно указано до участия.',
      zh: '如果 Vote 允许在结束前修改选择，必须在参与前明确说明。',
),
      ),
      _RuleData(
        number: 6,
        icon: Icons.rule_folder_outlined,
        title: _text(context, it: 'Regole chiare prima di ogni Vote', en: 'Clear rules before every Vote', de: 'Klare Regeln vor jedem Vote', fa: 'قوانین روشن پیش از هر Vote', es: 'Reglas claras antes de cada Vote', pt: 'Regras claras antes de cada Vote', fr: 'Des règles claires avant chaque Vote', ar: 'قواعد واضحة قبل كل Vote', ro: 'Reguli clare înainte de fiecare Vote',
      ru: 'Чёткие правила перед каждым Vote',
      zh: '每个 Vote 开始前都要有清晰规则',
),
        body: _text(context, it: 'Partecipazione, durata, area geografica, possibilità di modifica e modalità dei risultati devono essere visibili prima del voto.', en: 'Participation, duration, geographic scope, editability and result rules must be visible before voting.', de: 'Teilnahme, Dauer, geografischer Geltungsbereich, Änderbarkeit und Ergebnisregeln müssen vor der Abstimmung sichtbar sein.', fa: 'شرایط مشارکت، مدت، محدوده جغرافیایی، امکان تغییر و نحوه نتایج باید پیش از رأی‌دادن مشخص باشند.', es: 'Participación, duración, ámbito geográfico, posibilidad de cambio y reglas de resultados deben ser visibles antes de votar.', pt: 'Participação, duração, âmbito geográfico, possibilidade de alteração e regras de resultados devem estar visíveis antes da votação.', fr: 'Participation, durée, périmètre géographique, possibilité de modification et règles de résultat doivent être visibles avant le vote.', ar: 'يجب أن تكون المشاركة والمدة والنطاق الجغرافي وإمكانية التعديل وقواعد النتائج واضحة قبل التصويت.', ro: 'Participarea, durata, aria geografică, posibilitatea de modificare și regulile rezultatului trebuie să fie vizibile înainte de vot.',
      ru: 'Условия участия, длительность, географический охват, возможность изменения и правила результатов должны быть видны до голосования.',
      zh: '参与条件、持续时间、地理范围、是否可修改以及结果规则必须在投票前可见。',
),
      ),
      _RuleData(
        number: 7,
        icon: Icons.verified_user_outlined,
        title: _text(context, it: 'Risultati verificabili', en: 'Verifiable results', de: 'Überprüfbare Ergebnisse', fa: 'نتایج قابل‌بررسی', es: 'Resultados verificables', pt: 'Resultados verificáveis', fr: 'Résultats vérifiables', ar: 'نتائج قابلة للتحقق', ro: 'Rezultate verificabile',
      ru: 'Проверяемые результаты',
      zh: '可验证的结果',
),
        body: _text(context, it: 'I risultati devono essere coerenti con lo stato chiuso della consultazione e, quando previsto, supportare verifiche di integrità tecnica.', en: 'Results should remain consistent with a closed consultation and, where provided, support technical integrity checks.', de: 'Ergebnisse sollen mit dem geschlossenen Zustand der Konsultation konsistent bleiben und, wo vorgesehen, technische Integritätsprüfungen unterstützen.', fa: 'نتایج باید با وضعیت بسته‌شده مشورت سازگار بمانند و در صورت پیش‌بینی، امکان بررسی تمامیت فنی را فراهم کنند.', es: 'Los resultados deben mantenerse coherentes con una consulta cerrada y, cuando esté previsto, admitir verificaciones de integridad técnica.', pt: 'Os resultados devem permanecer coerentes com uma consulta encerrada e, quando previsto, permitir verificações de integridade técnica.', fr: 'Les résultats doivent rester cohérents avec une consultation clôturée et, lorsque prévu, permettre des contrôles d’intégrité technique.', ar: 'يجب أن تظل النتائج متسقة مع الاستشارة المغلقة، وأن تدعم عند الحاجة فحوصات السلامة التقنية.', ro: 'Rezultatele trebuie să rămână coerente cu o consultare închisă și, unde este prevăzut, să permită verificări de integritate tehnică.',
      ru: 'Результаты должны оставаться согласованными с закрытой консультацией и, где предусмотрено, поддерживать технические проверки целостности.',
      zh: '结果应与已结束的咨询保持一致，并在适用时支持技术完整性检查。',
),
      ),
      _RuleData(
        number: 8,
        icon: Icons.groups_outlined,
        title: _text(context, it: 'Più responsabilità, più trasparenza', en: 'More responsibility, more transparency', de: 'Mehr Verantwortung, mehr Transparenz', fa: 'مسئولیت بیشتر، شفافیت بیشتر', es: 'Más responsabilidad, más transparencia', pt: 'Mais responsabilidade, mais transparência', fr: 'Plus de responsabilité, plus de transparence', ar: 'مسؤولية أكبر، شفافية أكبر', ro: 'Mai multă responsabilitate, mai multă transparență',
      ru: 'Больше ответственности, больше прозрачности',
      zh: '责任越大，透明度越高',
),
        body: _text(context, it: 'Persone, organizzazioni, enti e ruoli pubblici devono essere riconoscibili quando agiscono in qualità ufficiale.', en: 'People, organizations, institutions and public roles should be recognizable when acting in an official capacity.', de: 'Personen, Organisationen, Institutionen und öffentliche Rollen sollen erkennbar sein, wenn sie offiziell handeln.', fa: 'افراد، سازمان‌ها، نهادها و نقش‌های عمومی هنگام فعالیت رسمی باید قابل شناسایی باشند.', es: 'Personas, organizaciones, instituciones y cargos públicos deben ser reconocibles cuando actúan oficialmente.', pt: 'Pessoas, organizações, instituições e cargos públicos devem ser reconhecíveis quando atuam oficialmente.', fr: 'Les personnes, organisations, institutions et fonctions publiques doivent être identifiables lorsqu’elles agissent officiellement.', ar: 'يجب أن يكون الأشخاص والمنظمات والمؤسسات والأدوار العامة قابلين للتعرّف عند التصرف بصفة رسمية.', ro: 'Persoanele, organizațiile, instituțiile și rolurile publice trebuie să fie recognoscibile atunci când acționează oficial.',
      ru: 'Люди, организации, учреждения и публичные должности должны быть узнаваемы, когда действуют в официальном качестве.',
      zh: '个人、组织、机构和公共角色以官方身份行动时应当可识别。',
),
      ),
      _RuleData(
        number: 9,
        icon: Icons.lock_outline_rounded,
        title: _text(context, it: 'Privacy e sicurezza', en: 'Privacy and security', de: 'Datenschutz und Sicherheit', fa: 'حریم خصوصی و امنیت', es: 'Privacidad y seguridad', pt: 'Privacidade e segurança', fr: 'Confidentialité et sécurité', ar: 'الخصوصية والأمان', ro: 'Confidențialitate și securitate',
      ru: 'Конфиденциальность и безопасность',
      zh: '隐私与安全',
),
        body: _text(context, it: 'Verificare chi può partecipare non significa rendere pubblica l’identità o la scelta di voto. I dati devono essere limitati allo scopo necessario.', en: 'Verifying who may participate does not mean making identity or vote choice public. Data should be limited to the necessary purpose.', de: 'Zu prüfen, wer teilnehmen darf, bedeutet nicht, Identität oder Stimmwahl öffentlich zu machen. Daten sollen auf den notwendigen Zweck begrenzt sein.', fa: 'تأیید اینکه چه کسی می‌تواند مشارکت کند به معنی عمومی‌کردن هویت یا انتخاب رأی نیست؛ داده‌ها باید به هدف لازم محدود شوند.', es: 'Verificar quién puede participar no significa hacer pública la identidad ni la elección de voto. Los datos deben limitarse al fin necesario.', pt: 'Verificar quem pode participar não significa tornar pública a identidade ou a escolha de voto. Os dados devem limitar-se ao objetivo necessário.', fr: 'Vérifier qui peut participer ne signifie pas rendre publique l’identité ou le choix de vote. Les données doivent être limitées au besoin nécessaire.', ar: 'التحقق من أهلية المشاركة لا يعني نشر الهوية أو اختيار التصويت. يجب حصر البيانات في الغرض الضروري.', ro: 'Verificarea eligibilității pentru participare nu înseamnă publicarea identității sau a opțiunii de vot. Datele trebuie limitate la scopul necesar.',
      ru: 'Проверка права на участие не означает публикацию личности или выбора в голосовании. Данные должны ограничиваться необходимой целью.',
      zh: '验证谁可以参与并不意味着公开身份或投票选择。数据应仅限于必要目的。',
),
      ),
      _RuleData(
        number: 10,
        icon: Icons.block_rounded,
        title: _text(context, it: 'Niente frodi', en: 'No fraud', de: 'Kein Betrug', fa: 'بدون تقلب', es: 'Sin fraude', pt: 'Sem fraude', fr: 'Aucune fraude', ar: 'لا احتيال', ro: 'Fără fraudă',
      ru: 'Никакого мошенничества',
      zh: '禁止欺诈',
),
        body: _text(context, it: 'Account falsi, automazioni abusive e tentativi di manipolare partecipazione o risultati sono vietati e possono portare a restrizioni o rimozione.', en: 'Fake accounts, abusive automation and attempts to manipulate participation or results are prohibited and may lead to restrictions or removal.', de: 'Gefälschte Konten, missbräuchliche Automatisierung und Manipulationsversuche bei Teilnahme oder Ergebnissen sind verboten und können zu Einschränkungen oder Entfernung führen.', fa: 'حساب‌های جعلی، خودکارسازی سوءاستفاده‌گرانه و تلاش برای دستکاری مشارکت یا نتایج ممنوع است و می‌تواند به محدودیت یا حذف منجر شود.', es: 'Las cuentas falsas, la automatización abusiva y los intentos de manipular la participación o los resultados están prohibidos y pueden causar restricciones o eliminación.', pt: 'Contas falsas, automação abusiva e tentativas de manipular a participação ou os resultados são proibidos e podem levar a restrições ou remoção.', fr: 'Les faux comptes, l’automatisation abusive et les tentatives de manipulation de la participation ou des résultats sont interdits et peuvent entraîner des restrictions ou une suppression.', ar: 'الحسابات المزيفة والأتمتة المسيئة ومحاولات التلاعب بالمشاركة أو النتائج محظورة وقد تؤدي إلى قيود أو إزالة.', ro: 'Conturile false, automatizarea abuzivă și încercările de manipulare a participării sau rezultatelor sunt interzise și pot duce la restricții sau eliminare.',
      ru: 'Поддельные аккаунты, злоупотребление автоматизацией и попытки манипулировать участием или результатами запрещены и могут привести к ограничениям или удалению.',
      zh: '虚假账户、滥用自动化以及操纵参与或结果的行为均被禁止，并可能导致限制或移除。',
),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final loggedIn = AppDI.instance.currentUserId != null;
    final pilotText = _text(
      context,
      it: 'Durante il pilot Business, billing e pagamenti restano disattivati.',
      en: 'During the Business pilot, billing and payments remain disabled.',
      de: 'Während des Business-Piloten bleiben Abrechnung und Zahlungen deaktiviert.',
      fa: 'در دوره آزمایشی Business، صورتحساب و پرداخت‌ها غیرفعال می‌مانند.',
      es: 'Durante el piloto Business, la facturación y los pagos permanecen desactivados.',
      pt: 'Durante o piloto Business, a faturação e os pagamentos permanecem desativados.',
      fr: 'Pendant le pilote Business, la facturation et les paiements restent désactivés.',
      ar: 'خلال برنامج Business التجريبي، تظل الفوترة والمدفوعات معطلة.',
      ro: 'În timpul pilotului Business, facturarea și plățile rămân dezactivate.',
    
      ru: 'Во время Business-пилота billing и платежи остаются отключены.',
      zh: 'Business 试点期间，计费和付款保持关闭。',
);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _text(
            context,
            it: 'Come funziona Social Vote',
            en: 'How Social Vote works',
            de: 'So funktioniert Social Vote',
            fa: 'Social Vote چگونه کار می‌کند',
            es: 'Cómo funciona Social Vote',
            pt: 'Como funciona o Social Vote',
            fr: 'Comment fonctionne Social Vote',
            ar: 'كيف يعمل Social Vote',
            ro: 'Cum funcționează Social Vote',
          
            ru: 'Как работает Social Vote',
            zh: 'Social Vote 如何运作',
),
          textDirection: socialVoteLocaleTextDirection(context),
          textAlign: socialVoteLocaleTextAlign(context),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 36),
            children: [
              _GuideSectionTitle(
                icon: Icons.info_outline_rounded,
                title: _text(
                  context,
                  it: 'Come funziona Social Vote',
                  en: 'How Social Vote works',
                  de: 'So funktioniert Social Vote',
                  fa: 'Social Vote چگونه کار می‌کند',
                  es: 'Cómo funciona Social Vote',
                  pt: 'Como funciona o Social Vote',
                  fr: 'Comment fonctionne Social Vote',
                  ar: 'كيف يعمل Social Vote',
                  ro: 'Cum funcționează Social Vote',
                
                  ru: 'Как работает Social Vote',
                  zh: 'Social Vote 如何运作',
),
              ),
              const SizedBox(height: 10),
              _GuideHero(
                title: _text(
                  context,
                  it: 'Partecipazione per le persone. Strumenti professionali per le organizzazioni.',
                  en: 'Participation for people. Professional tools for organizations.',
                  de: 'Teilhabe für Menschen. Professionelle Werkzeuge für Organisationen.',
                  fa: 'مشارکت برای مردم. ابزارهای حرفه‌ای برای سازمان‌ها.',
                  es: 'Participación para las personas. Herramientas profesionales para las organizaciones.',
                  pt: 'Participação para as pessoas. Ferramentas profissionais para as organizações.',
                  fr: 'Participation pour les personnes. Outils professionnels pour les organisations.',
                  ar: 'مشاركة للناس. أدوات احترافية للمنظمات.',
                  ro: 'Participare pentru oameni. Instrumente profesionale pentru organizații.',
                
                  ru: 'Участие для людей. Профессиональные инструменты для организаций.',
                  zh: '为个人提供参与，为组织提供专业工具。',
),
                body: _text(
                  context,
                  it: 'Social Vote è una piattaforma di partecipazione: scopri cosa succede, esprimi la tua Voce e partecipa ai Vote. Le organizzazioni possono usare un Workspace dedicato per comunicare, consultare e gestire Sessions.',
                  en: 'Social Vote is a participation platform: discover what is happening, share your Voce and take part in Vote. Organizations can use a dedicated Workspace to communicate, consult and run Sessions.',
                  de: 'Social Vote ist eine Plattform für Teilhabe: Entdecke, was passiert, teile deine Voce und nimm an Vote teil. Organisationen können einen eigenen Workspace für Kommunikation, Konsultationen und Sessions nutzen.',
                  fa: 'Social Vote یک پلتفرم مشارکت است: آنچه در جریان است را ببینید، Voce خود را به اشتراک بگذارید و در Vote شرکت کنید. سازمان‌ها می‌توانند از Workspace اختصاصی برای ارتباط، مشورت و برگزاری Sessions استفاده کنند.',
                  es: 'Social Vote es una plataforma de participación: descubre lo que ocurre, comparte tu Voce y participa en Vote. Las organizaciones pueden usar un Workspace dedicado para comunicar, consultar y gestionar Sessions.',
                  pt: 'O Social Vote é uma plataforma de participação: descubra o que está a acontecer, partilhe a sua Voce e participe em Vote. As organizações podem usar um Workspace dedicado para comunicar, consultar e gerir Sessions.',
                  fr: 'Social Vote est une plateforme de participation : découvrez ce qui se passe, partagez votre Voce et participez à Vote. Les organisations peuvent utiliser un Workspace dédié pour communiquer, consulter et gérer des Sessions.',
                  ar: 'Social Vote منصة للمشاركة: اكتشف ما يحدث، وشارك Voce الخاصة بك، وشارك في Vote. ويمكن للمنظمات استخدام Workspace مخصص للتواصل والتشاور وإدارة Sessions.',
                  ro: 'Social Vote este o platformă de participare: descoperă ce se întâmplă, publică Voce și participă la Vote. Organizațiile pot folosi un Workspace dedicat pentru comunicare, consultare și gestionarea Sessions.',
                
                  ru: 'Social Vote — платформа участия: узнавайте, что происходит, делитесь своей Voce и участвуйте в Vote. Организации могут использовать отдельный Workspace для коммуникации, консультаций и проведения Sessions.',
                  zh: 'Social Vote 是一个参与平台：了解正在发生的事情、分享你的 Voce 并参与 Vote。组织可以使用专属 Workspace 进行沟通、咨询和运行 Sessions。',
),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 760;
                  final people = _AudienceCard(
                    icon: Icons.person_outline_rounded,
                    title: _text(
                      context,
                      it: 'Per te',
                      en: 'For you',
                      de: 'Für dich',
                      fa: 'برای شما',
                      es: 'Para ti',
                      pt: 'Para você',
                      fr: 'Pour vous',
                      ar: 'لك',
                      ro: 'Pentru tine',
                    
                      ru: 'Для вас',
                      zh: '为你',
),
                    badge: _text(
                      context,
                      it: 'GRATUITO',
                      en: 'FREE',
                      de: 'KOSTENLOS',
                      fa: 'رایگان',
                      es: 'GRATIS',
                      pt: 'GRÁTIS',
                      fr: 'GRATUIT',
                      ar: 'مجانًا',
                      ro: 'GRATUIT',
                    
                      ru: 'БЕСПЛАТНО',
                      zh: '免费',
),
                    body: _text(
                      context,
                      it: 'L’uso personale resta gratuito. Nessuna pubblicità e nessun vantaggio di visibilità acquistabile.',
                      en: 'Personal use stays free. No advertising and no visibility advantage that can be bought.',
                      de: 'Die persönliche Nutzung bleibt kostenlos. Keine Werbung und kein käuflicher Sichtbarkeitsvorteil.',
                      fa: 'استفاده شخصی رایگان می‌ماند. تبلیغاتی وجود ندارد و هیچ برتری در دیده‌شدن قابل خرید نیست.',
                      es: 'El uso personal sigue siendo gratuito. Sin publicidad y sin ventajas de visibilidad que puedan comprarse.',
                      pt: 'O uso pessoal continua gratuito. Sem publicidade e sem vantagens de visibilidade que possam ser compradas.',
                      fr: 'L’usage personnel reste gratuit. Pas de publicité et aucun avantage de visibilité achetable.',
                      ar: 'يبقى الاستخدام الشخصي مجانيًا. لا إعلانات ولا ميزة في الظهور يمكن شراؤها.',
                      ro: 'Utilizarea personală rămâne gratuită. Fără publicitate și fără avantaje de vizibilitate care pot fi cumpărate.',
                    
                      ru: 'Личное использование остаётся бесплатным. Без рекламы и без преимущества в видимости, которое можно купить.',
                      zh: '个人使用保持免费。没有广告，也没有可购买的曝光优势。',
),
                    items: [
                      _text(
                        context,
                        it: 'Pulse: contenuti rilevanti per te',
                        en: 'Pulse: content relevant to you',
                        de: 'Pulse: für dich relevante Inhalte',
                        fa: 'Pulse: محتوای مرتبط با شما',
                        es: 'Pulse: contenido relevante para ti',
                        pt: 'Pulse: conteúdo relevante para você',
                        fr: 'Pulse : du contenu pertinent pour vous',
                        ar: 'Pulse: محتوى مناسب لك',
                        ro: 'Pulse: conținut relevant pentru tine',
                      
                        ru: 'Pulse: релевантный для вас контент',
                        zh: 'Pulse：与你相关的内容',
),
                      _text(
                        context,
                        it: 'Pulse Now: ciò che si muove adesso',
                        en: 'Pulse Now: what is moving now',
                        de: 'Pulse Now: was gerade Aufmerksamkeit erhält',
                        fa: 'Pulse Now: آنچه اکنون در حال حرکت است',
                        es: 'Pulse Now: lo que se mueve ahora',
                        pt: 'Pulse Now: o que está em movimento agora',
                        fr: 'Pulse Now : ce qui évolue maintenant',
                        ar: 'Pulse Now: ما يتحرك الآن',
                        ro: 'Pulse Now: ce se mișcă acum',
                      
                        ru: 'Pulse Now: что набирает движение сейчас',
                        zh: 'Pulse Now：当前正在升温的内容',
),
                      _text(
                        context,
                        it: 'Civic Map: esplora attraverso i luoghi',
                        en: 'Civic Map: explore through places',
                        de: 'Civic Map: über Orte entdecken',
                        fa: 'Civic Map: از طریق مکان‌ها کاوش کنید',
                        es: 'Civic Map: explora a través de los lugares',
                        pt: 'Civic Map: explore através dos lugares',
                        fr: 'Civic Map : explorez à travers les lieux',
                        ar: 'Civic Map: استكشف عبر الأماكن',
                        ro: 'Civic Map: explorează prin locuri',
                      
                        ru: 'Civic Map: исследуйте через места',
                        zh: 'Civic Map：通过地点探索',
),
                      _text(
                        context,
                        it: 'Voce: pubblica un pensiero, una proposta o un aggiornamento',
                        en: 'Voce: publish a thought, proposal or update',
                        de: 'Voce: Gedanken, Vorschläge oder Updates veröffentlichen',
                        fa: 'Voce: یک فکر، پیشنهاد یا به‌روزرسانی منتشر کنید',
                        es: 'Voce: publica una idea, propuesta o actualización',
                        pt: 'Voce: publique uma ideia, proposta ou atualização',
                        fr: 'Voce : publiez une idée, une proposition ou une mise à jour',
                        ar: 'Voce: انشر فكرة أو اقتراحًا أو تحديثًا',
                        ro: 'Voce: publică o idee, o propunere sau o actualizare',
                      
                        ru: 'Voce: опубликуйте мысль, предложение или обновление',
                        zh: 'Voce：发布想法、提案或动态',
),
                      _text(
                        context,
                        it: 'Vote: crea o partecipa a una consultazione',
                        en: 'Vote: create or join a consultation',
                        de: 'Vote: Konsultationen erstellen oder daran teilnehmen',
                        fa: 'Vote: یک مشورت ایجاد کنید یا در آن شرکت کنید',
                        es: 'Vote: crea o participa en una consulta',
                        pt: 'Vote: crie ou participe numa consulta',
                        fr: 'Vote : créez ou rejoignez une consultation',
                        ar: 'Vote: أنشئ استشارة أو شارك فيها',
                        ro: 'Vote: creează sau participă la o consultare',
                      
                        ru: 'Vote: создайте консультацию или участвуйте в ней',
                        zh: 'Vote：创建或参与咨询',
),
                      _text(
                        context,
                        it: 'Segui persone, luoghi e organizzazioni',
                        en: 'Follow people, places and organizations',
                        de: 'Menschen, Orte und Organisationen folgen',
                        fa: 'افراد، مکان‌ها و سازمان‌ها را دنبال کنید',
                        es: 'Sigue a personas, lugares y organizaciones',
                        pt: 'Siga pessoas, lugares e organizações',
                        fr: 'Suivez des personnes, des lieux et des organisations',
                        ar: 'تابع الأشخاص والأماكن والمنظمات',
                        ro: 'Urmărește persoane, locuri și organizații',
                      
                        ru: 'Подписывайтесь на людей, места и организации',
                        zh: '关注个人、地点和组织',
),
                    ],
                  );

                  final business = _AudienceCard(
                    icon: Icons.apartment_rounded,
                    title: _text(
                      context,
                      it: 'Per organizzazioni',
                      en: 'For organizations',
                      de: 'Für Organisationen',
                      fa: 'برای سازمان‌ها',
                      es: 'Para organizaciones',
                      pt: 'Para organizações',
                      fr: 'Pour les organisations',
                      ar: 'للمنظمات',
                      ro: 'Pentru organizații',
                    
                      ru: 'Для организаций',
                      zh: '面向组织',
),
                    badge: 'BUSINESS',
                    body: _text(
                      context,
                      it: 'Il tuo account personale resta l’accesso. Se gestisci un’organizzazione, il tuo ruolo ti permette di amministrare la sua identità pubblica separata.',
                      en: 'Your personal account remains your login. If you manage an organization, your role lets you administer its separate public identity.',
                      de: 'Dein persönliches Konto bleibt deine Anmeldung. Wenn du eine Organisation verwaltest, kannst du über deine Rolle ihre getrennte öffentliche Identität administrieren.',
                      fa: 'حساب شخصی شما همچنان راه ورود شماست. اگر سازمانی را مدیریت می‌کنید، نقش شما امکان مدیریت هویت عمومی مستقل آن را می‌دهد.',
                      es: 'Tu cuenta personal sigue siendo tu acceso. Si gestionas una organización, tu rol te permite administrar su identidad pública separada.',
                      pt: 'A sua conta pessoal continua a ser o seu acesso. Se gerir uma organização, a sua função permite administrar a identidade pública separada da organização.',
                      fr: 'Votre compte personnel reste votre accès. Si vous gérez une organisation, votre rôle vous permet d’administrer son identité publique distincte.',
                      ar: 'يبقى حسابك الشخصي هو وسيلة الدخول. وإذا كنت تدير منظمة، يتيح لك دورك إدارة هويتها العامة المنفصلة.',
                      ro: 'Contul personal rămâne metoda ta de autentificare. Dacă gestionezi o organizație, rolul tău îți permite să administrezi identitatea publică separată a acesteia.',
                    
                      ru: 'Ваш личный аккаунт остаётся вашим логином. Если вы управляете организацией, ваша роль позволяет администрировать её отдельную публичную идентичность.',
                      zh: '你的个人账户仍然用于登录。如果你管理某个组织，你的角色允许你管理该组织独立的公开身份。',
),
                    items: [
                      _text(
                        context,
                        it: 'Voce ufficiale come organizzazione',
                        en: 'Official Voce as the organization',
                        de: 'Offizielle Voce als Organisation',
                        fa: 'Voce رسمی به نام سازمان',
                        es: 'Voce oficial como organización',
                        pt: 'Voce oficial como organização',
                        fr: 'Voce officielle au nom de l’organisation',
                        ar: 'Voce رسمية باسم المنظمة',
                        ro: 'Voce oficială ca organizație',
                      
                        ru: 'Официальные Voce от имени организации',
                        zh: '以组织身份发布官方 Voce',
),
                      _text(
                        context,
                        it: 'Vote ufficiale per consultazioni pubbliche',
                        en: 'Official Vote for public consultations',
                        de: 'Offizielle Vote für öffentliche Konsultationen',
                        fa: 'Vote رسمی برای مشورت‌های عمومی',
                        es: 'Vote oficial para consultas públicas',
                        pt: 'Vote oficial para consultas públicas',
                        fr: 'Vote officiel pour les consultations publiques',
                        ar: 'Vote رسمي للاستشارات العامة',
                        ro: 'Vote oficial pentru consultări publice',
                      
                        ru: 'Официальные Vote для публичных консультаций',
                        zh: '用于公众咨询的官方 Vote',
),
                      _text(
                        context,
                        it: 'Sessions con QR e partecipazione live',
                        en: 'Sessions with QR and live participation',
                        de: 'Sessions mit QR und Live-Teilnahme',
                        fa: 'Sessions با QR و مشارکت زنده',
                        es: 'Sessions con QR y participación en directo',
                        pt: 'Sessions com QR e participação em direto',
                        fr: 'Sessions avec QR et participation en direct',
                        ar: 'Sessions مع QR ومشاركة مباشرة',
                        ro: 'Sessions cu QR și participare live',
                      
                        ru: 'Sessions с QR и участием в реальном времени',
                        zh: '带 QR 和实时参与的 Sessions',
),
                      _text(
                        context,
                        it: 'Stage e risultati durante la Session',
                        en: 'Stage and results during the Session',
                        de: 'Stage und Ergebnisse während der Session',
                        fa: 'Stage و نتایج در طول Session',
                        es: 'Stage y resultados durante la Session',
                        pt: 'Stage e resultados durante a Session',
                        fr: 'Stage et résultats pendant la Session',
                        ar: 'Stage والنتائج أثناء Session',
                        ro: 'Stage și rezultate în timpul Session',
                      
                        ru: 'Stage и результаты во время Session',
                        zh: 'Session 期间的 Stage 和结果',
),
                      _text(
                        context,
                        it: 'Verified Result con controllo di integrità',
                        en: 'Verified Result with integrity checking',
                        de: 'Verified Result mit Integritätsprüfung',
                        fa: 'Verified Result با بررسی تمامیت',
                        es: 'Verified Result con control de integridad',
                        pt: 'Verified Result com verificação de integridade',
                        fr: 'Verified Result avec contrôle d’intégrité',
                        ar: 'Verified Result مع فحص السلامة',
                        ro: 'Verified Result cu verificarea integrității',
                      
                        ru: 'Verified Result с проверкой целостности',
                        zh: '带完整性检查的 Verified Result',
),
                      _text(
                        context,
                        it: 'Workspace unico per gestire il flusso Business',
                        en: 'One Workspace for the Business workflow',
                        de: 'Ein Workspace für den Business-Ablauf',
                        fa: 'یک Workspace برای مدیریت جریان Business',
                        es: 'Un Workspace para gestionar el flujo Business',
                        pt: 'Um Workspace para gerir o fluxo Business',
                        fr: 'Un Workspace unique pour gérer le flux Business',
                        ar: 'Workspace واحد لإدارة مسار Business',
                        ro: 'Un singur Workspace pentru fluxul Business',
                      
                        ru: 'Один Workspace для рабочего процесса Business',
                        zh: '一个 Workspace 支持 Business 工作流',
),
                    ],
                  );

                  if (!wide) {
                    return Column(
                      children: [people, const SizedBox(height: 12), business],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: people),
                      const SizedBox(width: 12),
                      Expanded(child: business),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              _GuideSectionTitle(
                icon: Icons.tune_rounded,
                title: _text(
                  context,
                  it: 'Scegli lo strumento giusto',
                  en: 'Choose the right tool',
                  de: 'Wähle das passende Werkzeug',
                  fa: 'ابزار مناسب را انتخاب کنید',
                  es: 'Elige la herramienta adecuada',
                  pt: 'Escolha a ferramenta certa',
                  fr: 'Choisissez le bon outil',
                  ar: 'اختر الأداة المناسبة',
                  ro: 'Alege instrumentul potrivit',
                
                  ru: 'Выберите подходящий инструмент',
                  zh: '选择合适的工具',
),
              ),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 840 ? 3 : 1;
                  const spacing = 10.0;
                  final width = columns == 1
                      ? constraints.maxWidth
                      : (constraints.maxWidth - spacing * 2) / 3;
                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [
                      SizedBox(
                        width: width,
                        child: _ToolCard(
                          icon: Icons.forum_outlined,
                          title: 'Voce',
                          body: _text(
                            context,
                            it: 'Per comunicare, proporre, raccontare o aprire una discussione. Può essere personale oppure ufficiale di un’organizzazione.',
                            en: 'For communicating, proposing, sharing or opening a discussion. It can be personal or official from an organization.',
                            de: 'Zum Kommunizieren, Vorschlagen, Berichten oder Eröffnen einer Diskussion. Persönlich oder offiziell von einer Organisation.',
                            fa: 'برای ارتباط، پیشنهاد، روایت یا آغاز یک گفت‌وگو. می‌تواند شخصی یا رسمی از طرف یک سازمان باشد.',
                            es: 'Para comunicar, proponer, compartir o abrir un debate. Puede ser personal u oficial de una organización.',
                            pt: 'Para comunicar, propor, partilhar ou iniciar uma discussão. Pode ser pessoal ou oficial de uma organização.',
                            fr: 'Pour communiquer, proposer, partager ou ouvrir une discussion. Elle peut être personnelle ou officielle au nom d’une organisation.',
                            ar: 'للتواصل أو الاقتراح أو المشاركة أو فتح نقاش. ويمكن أن تكون شخصية أو رسمية باسم منظمة.',
                            ro: 'Pentru comunicare, propuneri, împărtășire sau deschiderea unei discuții. Poate fi personală sau oficială din partea unei organizații.',
                          
                            ru: 'Для общения, предложений, обмена или начала обсуждения. Может быть личным или официальным от организации.',
                            zh: '用于沟通、提议、分享或发起讨论。可以是个人内容，也可以是组织官方内容。',
),
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: _ToolCard(
                          icon: Icons.how_to_vote_outlined,
                          title: 'Vote',
                          body: _text(
                            context,
                            it: 'Per porre una domanda e raccogliere scelte nel tempo. Le regole di partecipazione e visibilità dipendono dal Vote.',
                            en: 'For asking a question and collecting choices over time. Participation and visibility rules depend on the Vote.',
                            de: 'Um eine Frage zu stellen und Entscheidungen über einen Zeitraum zu sammeln. Teilnahme- und Sichtbarkeitsregeln hängen vom Vote ab.',
                            fa: 'برای طرح یک پرسش و جمع‌آوری انتخاب‌ها در طول زمان. قوانین مشارکت و دیده‌شدن به همان Vote بستگی دارد.',
                            es: 'Para plantear una pregunta y recoger elecciones a lo largo del tiempo. Las reglas de participación y visibilidad dependen del Vote.',
                            pt: 'Para colocar uma pergunta e recolher escolhas ao longo do tempo. As regras de participação e visibilidade dependem do Vote.',
                            fr: 'Pour poser une question et recueillir des choix dans le temps. Les règles de participation et de visibilité dépendent du Vote.',
                            ar: 'لطرح سؤال وجمع الاختيارات مع مرور الوقت. تعتمد قواعد المشاركة والظهور على Vote نفسه.',
                            ro: 'Pentru a pune o întrebare și a colecta opțiuni în timp. Regulile de participare și vizibilitate depind de Vote.',
                          
                            ru: 'Для постановки вопроса и сбора вариантов выбора в течение времени. Правила участия и видимости зависят от конкретного Vote.',
                            zh: '用于提出问题并在一段时间内收集选择。参与和可见性规则取决于具体 Vote。',
),
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: _ToolCard(
                          icon: Icons.groups_2_outlined,
                          title: 'Session',
                          body: _text(
                            context,
                            it: 'Per riunioni, assemblee o consultazioni organizzate: domanda, QR, partecipazione, risultati e Verified Result.',
                            en: 'For meetings, assemblies or organized consultations: question, QR, participation, results and Verified Result.',
                            de: 'Für Sitzungen, Versammlungen oder organisierte Konsultationen: Frage, QR, Teilnahme, Ergebnisse und Verified Result.',
                            fa: 'برای نشست‌ها، مجامع یا مشورت‌های سازمان‌یافته: پرسش، QR، مشارکت، نتایج و Verified Result.',
                            es: 'Para reuniones, asambleas o consultas organizadas: pregunta, QR, participación, resultados y Verified Result.',
                            pt: 'Para reuniões, assembleias ou consultas organizadas: pergunta, QR, participação, resultados e Verified Result.',
                            fr: 'Pour les réunions, assemblées ou consultations organisées : question, QR, participation, résultats et Verified Result.',
                            ar: 'للاجتماعات أو الجمعيات أو الاستشارات المنظمة: سؤال وQR ومشاركة ونتائج وVerified Result.',
                            ro: 'Pentru întâlniri, adunări sau consultări organizate: întrebare, QR, participare, rezultate și Verified Result.',
                          
                            ru: 'Для встреч, собраний или организованных консультаций: вопрос, QR, участие, результаты и Verified Result.',
                            zh: '用于会议、集会或有组织的咨询：问题、QR、参与、结果和 Verified Result。',
),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              _GuideSectionTitle(
                icon: Icons.verified_user_outlined,
                title: _text(
                  context,
                  it: 'Verifica, fiducia e privacy',
                  en: 'Verification, trust and privacy',
                  de: 'Verifizierung, Vertrauen und Datenschutz',
                  fa: 'تأیید، اعتماد و حریم خصوصی',
                  es: 'Verificación, confianza y privacidad',
                  pt: 'Verificação, confiança e privacidade',
                  fr: 'Vérification, confiance et confidentialité',
                  ar: 'التحقق والثقة والخصوصية',
                  ro: 'Verificare, încredere și confidențialitate',
                
                  ru: 'Проверка, доверие и конфиденциальность',
                  zh: '验证、信任与隐私',
),
              ),
              const SizedBox(height: 10),
              _InfoCard(
                items: [
                  _text(
                    context,
                    it: 'La verifica serve a ridurre account duplicati, partecipazioni non autorizzate e abusi quando una funzione richiede maggiore affidabilità.',
                    en: 'Verification helps reduce duplicate accounts, unauthorized participation and abuse when a function requires greater assurance.',
                    de: 'Verifizierung hilft, doppelte Konten, unberechtigte Teilnahme und Missbrauch zu reduzieren, wenn eine Funktion mehr Sicherheit benötigt.',
                    fa: 'تأیید هویت به کاهش حساب‌های تکراری، مشارکت غیرمجاز و سوءاستفاده کمک می‌کند، زمانی که یک قابلیت به اطمینان بیشتری نیاز دارد.',
                    es: 'La verificación ayuda a reducir cuentas duplicadas, participación no autorizada y abusos cuando una función requiere mayor garantía.',
                    pt: 'A verificação ajuda a reduzir contas duplicadas, participação não autorizada e abusos quando uma funcionalidade exige maior garantia.',
                    fr: 'La vérification aide à réduire les comptes en double, les participations non autorisées et les abus lorsqu’une fonction exige davantage de garanties.',
                    ar: 'يساعد التحقق في تقليل الحسابات المكررة والمشاركة غير المصرح بها وإساءة الاستخدام عندما تتطلب ميزة مستوى أعلى من الثقة.',
                    ro: 'Verificarea ajută la reducerea conturilor duplicate, a participării neautorizate și a abuzurilor atunci când o funcție necesită un nivel mai ridicat de încredere.',
                  
                    ru: 'Проверка помогает уменьшить дублирование аккаунтов, несанкционированное участие и злоупотребления, когда функции требуется повышенная надёжность.',
                    zh: '当某项功能需要更高可信度时，验证有助于减少重复账户、未授权参与和滥用。',
),
                  _text(
                    context,
                    it: 'Social Vote deve chiedere solo il livello necessario e spiegare il motivo prima della richiesta.',
                    en: 'Social Vote should request only the necessary level and explain why before asking for it.',
                    de: 'Social Vote soll nur das notwendige Niveau verlangen und vorher erklären, warum es benötigt wird.',
                    fa: 'Social Vote باید فقط سطح لازم را درخواست کند و پیش از درخواست توضیح دهد چرا به آن نیاز است.',
                    es: 'Social Vote debe solicitar solo el nivel necesario y explicar el motivo antes de pedirlo.',
                    pt: 'O Social Vote deve pedir apenas o nível necessário e explicar o motivo antes de o solicitar.',
                    fr: 'Social Vote ne doit demander que le niveau nécessaire et expliquer pourquoi avant de le demander.',
                    ar: 'يجب على Social Vote طلب المستوى الضروري فقط وشرح السبب قبل طلبه.',
                    ro: 'Social Vote trebuie să solicite doar nivelul necesar și să explice motivul înainte de a-l cere.',
                  
                    ru: 'Social Vote должен запрашивать только необходимый уровень проверки и заранее объяснять причину.',
                    zh: 'Social Vote 应只请求必要的验证级别，并在请求前说明原因。',
),
                  _text(
                    context,
                    it: 'I dati di verifica non sono il modello pubblicitario di Social Vote. La partecipazione personale non viene finanziata vendendo maggiore visibilità.',
                    en: 'Verification data is not Social Vote’s advertising model. Personal participation is not funded by selling greater visibility.',
                    de: 'Verifizierungsdaten sind nicht das Werbemodell von Social Vote. Persönliche Teilhabe wird nicht durch den Verkauf zusätzlicher Sichtbarkeit finanziert.',
                    fa: 'داده‌های تأیید بخشی از مدل تبلیغاتی Social Vote نیستند. مشارکت شخصی با فروش دیده‌شدن بیشتر تأمین مالی نمی‌شود.',
                    es: 'Los datos de verificación no son el modelo publicitario de Social Vote. La participación personal no se financia vendiendo mayor visibilidad.',
                    pt: 'Os dados de verificação não são o modelo publicitário do Social Vote. A participação pessoal não é financiada pela venda de maior visibilidade.',
                    fr: 'Les données de vérification ne constituent pas le modèle publicitaire de Social Vote. La participation personnelle n’est pas financée par la vente d’une visibilité accrue.',
                    ar: 'بيانات التحقق ليست نموذجًا إعلانيًا لـ Social Vote. ولا تُموَّل المشاركة الشخصية عبر بيع مزيد من الظهور.',
                    ro: 'Datele de verificare nu reprezintă modelul publicitar al Social Vote. Participarea personală nu este finanțată prin vânzarea unei vizibilități mai mari.',
                  
                    ru: 'Данные проверки не являются рекламной моделью Social Vote. Личное участие не финансируется продажей большей видимости.',
                    zh: '验证数据不是 Social Vote 的广告模式。个人参与不会通过出售更多曝光来融资。',
),
                  _text(
                    context,
                    it: 'La verifica dell’account e la scelta espressa in un Vote sono concetti separati; anonimato e accesso dipendono dalle regole della specifica consultazione.',
                    en: 'Account verification and the choice made in a Vote are separate concepts; anonymity and access depend on the rules of the specific consultation.',
                    de: 'Kontoverifizierung und die in einem Vote getroffene Wahl sind getrennte Konzepte; Anonymität und Zugang hängen von den Regeln der jeweiligen Konsultation ab.',
                    fa: 'تأیید حساب و انتخاب ثبت‌شده در Vote دو مفهوم جدا هستند؛ ناشناس‌بودن و دسترسی به قوانین همان مشورت بستگی دارد.',
                    es: 'La verificación de la cuenta y la elección realizada en un Vote son conceptos separados; el anonimato y el acceso dependen de las reglas de la consulta concreta.',
                    pt: 'A verificação da conta e a escolha feita num Vote são conceitos separados; o anonimato e o acesso dependem das regras da consulta específica.',
                    fr: 'La vérification du compte et le choix exprimé dans un Vote sont deux notions distinctes ; l’anonymat et l’accès dépendent des règles de la consultation concernée.',
                    ar: 'التحقق من الحساب والاختيار المعبّر عنه في Vote مفهومان منفصلان؛ ويعتمد إخفاء الهوية والوصول على قواعد الاستشارة المحددة.',
                    ro: 'Verificarea contului și opțiunea exprimată într-un Vote sunt concepte separate; anonimatul și accesul depind de regulile consultării respective.',
                  
                    ru: 'Проверка аккаунта и выбор, сделанный в Vote, — разные понятия; анонимность и доступ зависят от правил конкретной консультации.',
                    zh: '账户验证与 Vote 中所作选择是不同概念；匿名性和访问权限取决于具体咨询的规则。',
),
                ],
              ),
              const SizedBox(height: 16),
              _NoticeCard(
                icon: Icons.verified_outlined,
                title: 'Verified Result',
                body: _text(
                  context,
                  it: 'Il Verified Result documenta il risultato prodotto dalla Session e consente di verificarne l’integrità tecnica. Non costituisce automaticamente certificazione notarile, elettorale o validità legale.',
                  en: 'Verified Result documents the result produced by a Session and allows its technical integrity to be checked. It does not automatically constitute notarization, electoral certification or legal validity.',
                  de: 'Verified Result dokumentiert das Ergebnis einer Session und ermöglicht die Prüfung seiner technischen Integrität. Es stellt nicht automatisch eine notarielle, wahlrechtliche oder rechtliche Zertifizierung dar.',
                  fa: 'Verified Result نتیجه تولیدشده توسط Session را ثبت می‌کند و امکان بررسی تمامیت فنی آن را می‌دهد. این مورد به‌طور خودکار به معنای گواهی محضری، انتخاباتی یا اعتبار قانونی نیست.',
                  es: 'Verified Result documenta el resultado producido por una Session y permite comprobar su integridad técnica. No constituye automáticamente una certificación notarial, electoral ni validez legal.',
                  pt: 'Verified Result documenta o resultado produzido por uma Session e permite verificar a sua integridade técnica. Não constitui automaticamente certificação notarial, eleitoral ou validade legal.',
                  fr: 'Verified Result documente le résultat produit par une Session et permet d’en vérifier l’intégrité technique. Il ne constitue pas automatiquement une certification notariale, électorale ou une validité juridique.',
                  ar: 'يوثّق Verified Result النتيجة التي تنتجها Session ويتيح التحقق من سلامتها التقنية. ولا يشكّل تلقائيًا توثيقًا قانونيًا أو اعتمادًا انتخابيًا أو صلاحية قانونية.',
                  ro: 'Verified Result documentează rezultatul produs de o Session și permite verificarea integrității tehnice. Nu reprezintă automat autentificare notarială, certificare electorală sau validitate juridică.',
                
                  ru: 'Verified Result документирует результат Session и позволяет проверить его техническую целостность. Он не является автоматически нотариальным заверением, электоральной сертификацией или юридической действительностью.',
                  zh: 'Verified Result 记录 Session 产生的结果，并允许检查其技术完整性。它不会自动构成公证、选举认证或法律效力。',
),
              ),
              const SizedBox(height: 16),
              _NoticeCard(
                icon: Icons.balance_outlined,
                title: _text(
                  context,
                  it: 'Il principio economico',
                  en: 'The economic principle',
                  de: 'Das wirtschaftliche Prinzip',
                  fa: 'اصل اقتصادی',
                  es: 'El principio económico',
                  pt: 'O princípio económico',
                  fr: 'Le principe économique',
                  ar: 'المبدأ الاقتصادي',
                  ro: 'Principiul economic',
                
                  ru: 'Экономический принцип',
                  zh: '经济原则',
),
                body: _text(
                  context,
                  it: 'Le persone partecipano gratuitamente. Gli strumenti professionali Business possono sostenere i costi della piattaforma. Pagare non compra verifica, peso nei Vote o priorità artificiale in Pulse/Pulse Now.',
                  en: 'People participate for free. Professional Business tools can support the platform’s costs. Paying does not buy verification, weight in Vote or artificial priority in Pulse/Pulse Now.',
                  de: 'Menschen nehmen kostenlos teil. Professionelle Business-Werkzeuge können die Plattformkosten tragen. Bezahlen kauft weder Verifizierung noch mehr Gewicht in Vote oder künstliche Priorität in Pulse/Pulse Now.',
                  fa: 'مردم رایگان مشارکت می‌کنند. ابزارهای حرفه‌ای Business می‌توانند به تأمین هزینه‌های پلتفرم کمک کنند. پرداخت پول تأیید هویت، وزن بیشتر در Vote یا اولویت مصنوعی در Pulse/Pulse Now نمی‌خرد.',
                  es: 'Las personas participan gratis. Las herramientas profesionales Business pueden sostener los costes de la plataforma. Pagar no compra verificación, peso en Vote ni prioridad artificial en Pulse/Pulse Now.',
                  pt: 'As pessoas participam gratuitamente. As ferramentas profissionais Business podem ajudar a suportar os custos da plataforma. Pagar não compra verificação, peso em Vote nem prioridade artificial em Pulse/Pulse Now.',
                  fr: 'Les personnes participent gratuitement. Les outils professionnels Business peuvent contribuer aux coûts de la plateforme. Payer n’achète ni vérification, ni poids dans Vote, ni priorité artificielle dans Pulse/Pulse Now.',
                  ar: 'يشارك الناس مجانًا. ويمكن لأدوات Business الاحترافية المساهمة في تكاليف المنصة. الدفع لا يشتري التحقق أو وزنًا أكبر في Vote أو أولوية مصطنعة في Pulse/Pulse Now.',
                  ro: 'Oamenii participă gratuit. Instrumentele profesionale Business pot susține costurile platformei. Plata nu cumpără verificare, greutate în Vote sau prioritate artificială în Pulse/Pulse Now.',
                
                  ru: 'Люди участвуют бесплатно. Профессиональные Business-инструменты могут покрывать расходы платформы. Оплата не покупает проверку, вес в Vote или искусственный приоритет в Pulse/Pulse Now.',
                  zh: '个人免费参与。专业 Business 工具可以支持平台成本。付费不会购买验证、Vote 权重或 Pulse/Pulse Now 中的人为优先级。',
),
              ),
              const SizedBox(height: 10),
              Text(
                pilotText,
                textDirection: socialVoteContentDirection(pilotText),
                textAlign: socialVoteContentTextAlign(pilotText),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: () => _goHome(context),
                    icon: const Icon(Icons.explore_outlined),
                    label: Text(
                      _text(
                        context,
                        it: 'Esplora Social Vote',
                        en: 'Explore Social Vote',
                        de: 'Social Vote entdecken',
                        fa: 'Social Vote را کاوش کنید',
                        es: 'Explora Social Vote',
                        pt: 'Explore o Social Vote',
                        fr: 'Explorer Social Vote',
                        ar: 'استكشف Social Vote',
                        ro: 'Explorează Social Vote',
                      
                        ru: 'Исследовать Social Vote',
                        zh: '探索 Social Vote',
),
                    ),
                  ),
                  if (loggedIn)
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context)
                          .pushNamed(AppRouter.organizationWorkspace),
                      icon: const Icon(Icons.dashboard_outlined),
                      label: Text(
                        _text(
                          context,
                          it: 'Apri Workspace Business',
                          en: 'Open Business Workspace',
                          de: 'Business Workspace öffnen',
                          fa: 'Workspace Business را باز کنید',
                          es: 'Abrir Workspace Business',
                          pt: 'Abrir Workspace Business',
                          fr: 'Ouvrir le Workspace Business',
                          ar: 'افتح Workspace Business',
                          ro: 'Deschide Workspace Business',
                        
                          ru: 'Открыть Business Workspace',
                          zh: '打开 Business Workspace',
),
                      ),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: () =>
                          Navigator.of(context).pushNamed(AppRouter.register),
                      icon: const Icon(Icons.person_add_alt_1_outlined),
                      label: Text(
                        _text(
                          context,
                          it: 'Inizia come persona',
                          en: 'Start as a person',
                          de: 'Als Person starten',
                          fa: 'به‌عنوان یک شخص شروع کنید',
                          es: 'Empieza como persona',
                          pt: 'Comece como pessoa',
                          fr: 'Commencer en tant que personne',
                          ar: 'ابدأ كشخص',
                          ro: 'Începe ca persoană',
                        
                          ru: 'Начать как человек',
                          zh: '以个人身份开始',
),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 28),
              const Divider(),
              const SizedBox(height: 22),
              _GuideSectionTitle(
                icon: Icons.rule_rounded,
                title: _text(
                  context,
                  it: 'Regole del gioco · Principles v0.3',
                  en: 'Rules of the game · Principles v0.3',
                  de: 'Spielregeln · Principles v0.3',
                  fa: 'قواعد بازی · Principles v0.3',
                  es: 'Reglas del juego · Principles v0.3',
                  pt: 'Regras do jogo · Principles v0.3',
                  fr: 'Règles du jeu · Principles v0.3',
                  ar: 'قواعد اللعبة · Principles v0.3',
                  ro: 'Regulile jocului · Principles v0.3',
                
                  ru: 'Правила игры · Principles v0.3',
                  zh: '游戏规则 · Principles v0.3',
),
              ),
              const SizedBox(height: 10),
              _VisionPosterCard(
                assetPath: _posterAssetForLocale(context),
                tapHint: _text(
                  context,
                  it: 'Tocca l’immagine per ingrandire',
                  en: 'Tap the image to enlarge',
                  de: 'Tippe auf das Bild zum Vergrößern',
                  fa: 'برای بزرگ‌نمایی روی تصویر بزنید',
                  es: 'Toca la imagen para ampliarla',
                  pt: 'Toque na imagem para ampliar',
                  fr: 'Touchez l’image pour l’agrandir',
                  ar: 'اضغط على الصورة لتكبيرها',
                  ro: 'Atinge imaginea pentru a o mări',
                
                  ru: 'Нажмите на изображение, чтобы увеличить',
                  zh: '点击图片放大',
),
              ),
              const SizedBox(height: 16),
              _ProgressVisionCard(
                progress: _productProgress,
                version: _principlesVersion,
                title: _text(
                  context,
                  it: 'Lavori in corso · 33% del prodotto',
                  en: 'Work in progress · 33% of the product',
                  de: 'In Arbeit · 33 % des Produkts',
                  fa: 'در حال توسعه · ۳۳٪ از محصول',
                  es: 'En desarrollo · 33% del producto',
                  pt: 'Em desenvolvimento · 33% do produto',
                  fr: 'En cours · 33 % du produit',
                  ar: 'قيد التطوير · 33٪ من المنتج',
                  ro: 'În lucru · 33% din produs',
                
                  ru: 'В разработке · 33% продукта',
                  zh: '开发中 · 产品完成度 33%',
),
                body: _text(
                  context,
                  it: 'Il 33% è un indicatore editoriale dello stato del prodotto: mostra quanto della visione complessiva consideriamo già costruito, non una promessa di data o una percentuale separata per Web e Android.',
                  en: '33% is an editorial indicator of product status: it shows how much of the overall vision we consider built, not a release-date promise or a separate percentage for Web and Android.',
                  de: '33 % ist ein redaktioneller Indikator des Produktstands: Er zeigt, wie viel der Gesamtvision wir als umgesetzt betrachten, nicht ein Veröffentlichungsversprechen oder getrennte Werte für Web und Android.',
                  fa: 'عدد ۳۳٪ یک شاخص توضیحی از وضعیت محصول است: نشان می‌دهد چه مقدار از چشم‌انداز کلی را ساخته‌شده می‌دانیم، نه وعده زمان انتشار یا درصد جداگانه برای وب و اندروید.',
                  es: 'El 33% es un indicador editorial del estado del producto: muestra cuánto de la visión global consideramos construido, no una promesa de fecha ni un porcentaje distinto para Web y Android.',
                  pt: 'Os 33% são um indicador editorial do estado do produto: mostram quanto da visão global consideramos construído, não uma promessa de data nem uma percentagem separada para Web e Android.',
                  fr: 'Les 33 % sont un indicateur éditorial de l’état du produit : ils montrent la part de la vision globale que nous considérons déjà construite, et non une promesse de date ni un pourcentage distinct pour le Web et Android.',
                  ar: 'نسبة 33٪ هي مؤشر تحريري لحالة المنتج: توضح مقدار ما نعتبره مبنيًا من الرؤية الكاملة، وليست وعدًا بموعد إصدار أو نسبة منفصلة للويب وأندرويد.',
                  ro: '33% este un indicator editorial al stadiului produsului: arată cât din viziunea generală considerăm construit, nu o promisiune de dată și nici procente separate pentru Web și Android.',
                
                  ru: '33% — редакционный индикатор состояния продукта: он показывает, какую часть общей концепции мы считаем реализованной, а не обещание даты релиза и не отдельный процент для Web и Android.',
                  zh: '33% 是产品状态的编辑性指标：它表示我们认为整体愿景中已有多少内容完成，并不是发布日期承诺，也不是 Web 和 Android 各自独立的完成百分比。',
),
              ),
              const SizedBox(height: 20),
              _GuideSectionTitle(
                icon: Icons.rule_rounded,
                title: _text(
                  context,
                  it: 'Le 10 regole del gioco',
                  en: 'The 10 rules of the game',
                  de: 'Die 10 Spielregeln',
                  fa: '۱۰ قانون بازی',
                  es: 'Las 10 reglas del juego',
                  pt: 'As 10 regras do jogo',
                  fr: 'Les 10 règles du jeu',
                  ar: 'قواعد اللعبة العشر',
                  ro: 'Cele 10 reguli ale jocului',
                
                  ru: '10 правил игры',
                  zh: '10 条游戏规则',
),
              ),
              const SizedBox(height: 10),
              _RulesGrid(rules: _buildRules(context)),
              const SizedBox(height: 16),
              _PlatformContractCard(
                title: _text(
                  context,
                  it: 'Stesse regole, interfacce diverse',
                  en: 'Same rules, different interfaces',
                  de: 'Gleiche Regeln, unterschiedliche Oberflächen',
                  fa: 'قواعد یکسان، رابط‌های متفاوت',
                  es: 'Mismas reglas, interfaces diferentes',
                  pt: 'Mesmas regras, interfaces diferentes',
                  fr: 'Mêmes règles, interfaces différentes',
                  ar: 'القواعد نفسها، وواجهات مختلفة',
                  ro: 'Aceleași reguli, interfețe diferite',
                
                  ru: 'Одни правила, разные интерфейсы',
                  zh: '相同规则，不同界面',
),
                body: _text(
                  context,
                  it: 'I principi fondamentali di Social Vote sono unici. Web e Android possono avere layout, tempi di rilascio o funzioni disponibili diversi durante lo sviluppo, ma non devono avere regole civiche contraddittorie.',
                  en: 'Social Vote has one set of core principles. Web and Android may differ in layout, rollout timing or feature availability during development, but they should not have contradictory civic rules.',
                  de: 'Social Vote hat einheitliche Grundprinzipien. Web und Android können sich während der Entwicklung bei Layout, Rollout oder Funktionsumfang unterscheiden, dürfen aber keine widersprüchlichen zivilen Regeln haben.',
                  fa: 'اصول بنیادی Social Vote یکسان هستند. وب و اندروید ممکن است در طراحی، زمان انتشار یا در دسترس بودن قابلیت‌ها تفاوت داشته باشند، اما نباید قواعد مدنی متناقضی داشته باشند.',
                  es: 'Social Vote tiene un único conjunto de principios básicos. Web y Android pueden diferir en diseño, calendario de despliegue o funciones disponibles durante el desarrollo, pero no deben tener reglas cívicas contradictorias.',
                  pt: 'O Social Vote tem um único conjunto de princípios fundamentais. Web e Android podem diferir no layout, calendário de lançamento ou funcionalidades disponíveis durante o desenvolvimento, mas não devem ter regras cívicas contraditórias.',
                  fr: 'Social Vote repose sur un seul ensemble de principes fondamentaux. Le Web et Android peuvent différer par leur interface, leur calendrier de déploiement ou les fonctions disponibles pendant le développement, mais pas par des règles civiques contradictoires.',
                  ar: 'لدى Social Vote مجموعة واحدة من المبادئ الأساسية. قد يختلف الويب وأندرويد في التصميم أو توقيت الإطلاق أو توفر الميزات أثناء التطوير، لكن لا ينبغي أن تكون لديهما قواعد مدنية متناقضة.',
                  ro: 'Social Vote are un singur set de principii fundamentale. Web și Android pot diferi ca interfață, ritm de lansare sau funcții disponibile în timpul dezvoltării, dar nu trebuie să aibă reguli civice contradictorii.',
                
                  ru: 'У Social Vote единый набор основных принципов. Web и Android в процессе разработки могут различаться интерфейсом, сроками rollout или доступностью функций, но гражданские правила не должны противоречить друг другу.',
                  zh: 'Social Vote 只有一套核心原则。开发期间 Web 和 Android 在界面、上线节奏或功能可用性上可能不同，但不应出现相互矛盾的公民参与规则。',
),
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: () => _shareVision(context),
                icon: const Icon(Icons.share_outlined),
                label: Text(
                  _text(
                    context,
                    it: 'Condividi questa visione',
                    en: 'Share this vision',
                    de: 'Diese Vision teilen',
                    fa: 'این چشم‌انداز را به اشتراک بگذارید',
                    es: 'Comparte esta visión',
                    pt: 'Partilhe esta visão',
                    fr: 'Partager cette vision',
                    ar: 'شارك هذه الرؤية',
                    ro: 'Distribuie această viziune',
                  
                    ru: 'Поделиться этой концепцией',
                    zh: '分享这一愿景',
),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RuleData {
  final int number;
  final IconData icon;
  final String title;
  final String body;

  const _RuleData({
    required this.number,
    required this.icon,
    required this.title,
    required this.body,
  });
}

class _VisionPosterCard extends StatelessWidget {
  final String assetPath;
  final String tapHint;

  const _VisionPosterCard({
    required this.assetPath,
    required this.tapHint,
  });

  void _showFullscreen(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.94),
      builder: (dialogContext) {
        return Dialog.fullscreen(
          backgroundColor: Colors.black,
          child: SafeArea(
            child: Stack(
              children: [
                Positioned.fill(
                  child: InteractiveViewer(
                    minScale: 0.7,
                    maxScale: 5,
                    child: Center(
                      child: Image.asset(
                        assetPath,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ),
                PositionedDirectional(
                  top: 8,
                  end: 8,
                  child: IconButton.filledTonal(
                    tooltip: MaterialLocalizations.of(dialogContext).closeButtonTooltip,
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showFullscreen(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1672 / 941,
              child: Image.asset(
                assetPath,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.zoom_in_rounded, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tapHint,
                      textDirection: socialVoteLocaleTextDirection(context),
                      textAlign: socialVoteLocaleTextAlign(context),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressVisionCard extends StatelessWidget {
  final double progress;
  final String version;
  final String title;
  final String body;

  const _ProgressVisionCard({
    required this.progress,
    required this.version,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final percent = (progress * 100).round();
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 640;
            final progressBlock = SizedBox(
              width: compact ? double.infinity : 190,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$percent%',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 9,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Principles v$version',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
            final textBlock = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  textDirection: socialVoteLocaleTextDirection(context),
                  textAlign: socialVoteLocaleTextAlign(context),
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  textDirection: socialVoteLocaleTextDirection(context),
                  textAlign: socialVoteLocaleTextAlign(context),
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                ),
              ],
            );
            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [progressBlock, const SizedBox(height: 16), textBlock],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                progressBlock,
                const SizedBox(width: 22),
                Expanded(child: textBlock),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RulesGrid extends StatelessWidget {
  final List<_RuleData> rules;

  const _RulesGrid({required this.rules});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 2 : 1;
        const spacing = 10.0;
        final width = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final rule in rules)
              SizedBox(width: width, child: _RuleCard(rule: rule)),
          ],
        );
      },
    );
  }
}

class _RuleCard extends StatelessWidget {
  final _RuleData rule;

  const _RuleCard({required this.rule});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(rule.icon, color: colors.onPrimaryContainer),
                  Positioned(
                    right: 2,
                    bottom: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${rule.number}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.onPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rule.title,
                    textDirection: socialVoteContentDirection(rule.title),
                    textAlign: socialVoteContentTextAlign(rule.title),
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    rule.body,
                    textDirection: socialVoteContentDirection(rule.body),
                    textAlign: socialVoteContentTextAlign(rule.body),
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlatformContractCard extends StatelessWidget {
  final String title;
  final String body;

  const _PlatformContractCard({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.devices_rounded, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    textDirection: socialVoteContentDirection(title),
                    textAlign: socialVoteContentTextAlign(title),
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    body,
                    textDirection: socialVoteContentDirection(body),
                    textAlign: socialVoteContentTextAlign(body),
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideHero extends StatelessWidget {
  final String title;
  final String body;

  const _GuideHero({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primaryContainer.withValues(alpha: 0.82),
            colors.surfaceContainerHighest.withValues(alpha: 0.82),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.primary.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.hub_outlined, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                'Social Vote',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textDirection: socialVoteContentDirection(title),
            textAlign: socialVoteContentTextAlign(title),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.08,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            textDirection: socialVoteContentDirection(body),
            textAlign: socialVoteContentTextAlign(body),
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _AudienceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String badge;
  final String body;
  final List<String> items;

  const _AudienceCard({
    required this.icon,
    required this.title,
    required this.badge,
    required this.body,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: colors.primaryContainer,
                  foregroundColor: colors.onPrimaryContainer,
                  child: Icon(icon),
                ),
                Text(
                  title,
                  textDirection: socialVoteContentDirection(title),
                  textAlign: socialVoteContentTextAlign(title),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text(
                    badge,
                    textDirection: socialVoteContentDirection(badge),
                    textAlign: socialVoteContentTextAlign(badge),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              body,
              textDirection: socialVoteContentDirection(body),
              textAlign: socialVoteContentTextAlign(body),
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
            const SizedBox(height: 12),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        size: 18, color: colors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        textDirection: socialVoteContentDirection(item),
                        textAlign: socialVoteContentTextAlign(item),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideSectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _GuideSectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            textDirection: socialVoteContentDirection(title),
            textAlign: socialVoteContentTextAlign(title),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _ToolCard(
      {required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(height: 10),
            Text(
              title,
              textDirection: socialVoteContentDirection(title),
              textAlign: socialVoteContentTextAlign(title),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              body,
              textDirection: socialVoteContentDirection(body),
              textAlign: socialVoteContentTextAlign(body),
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<String> items;

  const _InfoCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.shield_outlined,
                          size: 19, color: colors.primary),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          item,
                          textDirection: socialVoteContentDirection(item),
                          textAlign: socialVoteContentTextAlign(item),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _NoticeCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  textDirection: socialVoteContentDirection(title),
                  textAlign: socialVoteContentTextAlign(title),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  textDirection: socialVoteContentDirection(body),
                  textAlign: socialVoteContentTextAlign(body),
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
