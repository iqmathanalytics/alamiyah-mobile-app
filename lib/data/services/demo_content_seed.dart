import '../../features/library/library_catalog.dart';
import '../models/models.dart';

/// Shared demo library used after a wipe — long text, images, and a tiny playable mp4.
class DemoContentSeed {
  DemoContentSeed._();

  /// Small public sample (~seconds) that plays in [video_player].
  static const sampleVideoUrl =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';

  static const sampleVideoThumb =
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=1200&q=80';

  static List<ContentItem> build({DateTime? now}) {
    final t = now ?? DateTime.now().toUtc();
    return [
      ContentItem(
        id: 'demo_featured_morning',
        type: ContentType.text,
        title: 'Morning light — a long adhkar for a quiet start',
        category: 'invocations',
        section: collectionById('invocations')!.entries[1].title,
        tags: const ['morning', 'adhkar', 'calm', 'featured'],
        arabicText:
            'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ. رَبِّ أَسْأَلُكَ خَيْرَ مَا فِي هَذَا الْيَوْمِ وَخَيْرَ مَا بَعْدَهُ، وَأَعُوذُ بِكَ مِنْ شَرِّ مَا فِي هَذَا الْيَوْمِ وَشَرِّ مَا بَعْدَهُ، رَبِّ أَعُوذُ بِكَ مِنَ الْكَسَلِ وَسُوءِ الْكِبَرِ، رَبِّ أَعُوذُ بِكَ مِنْ عَذَابٍ فِي النَّارِ وَعَذَابٍ فِي الْقَبْرِ.',
        transliteration:
            'Asbahna wa asbahal-mulku lillah, walhamdu lillah, la ilaha illallahu wahdahu la sharika lah, lahul-mulku walahul-hamdu wa huwa ala kulli shay\'in qadir. Rabbi as\'aluka khayra ma fi hadhal-yawmi wa khayra ma ba\'dahu, wa a\'udhu bika min sharri ma fi hadhal-yawmi wa sharri ma ba\'dahu...',
        translation:
            'We have entered the morning and the dominion belongs to Allah, and all praise is for Allah. There is no god but Allah alone, without partner. To Him belongs the kingdom and to Him belongs praise, and He is over all things competent.\n\n'
            'My Lord, I ask You for the good of this day and the good that follows it, and I seek refuge in You from the evil of this day and the evil that follows it. My Lord, I seek refuge in You from laziness and the evil of old age. My Lord, I seek refuge in You from the punishment of the Fire and the punishment of the grave.\n\n'
            'Sit with this for a few breaths. Let the words land before the day rushes in. If your mind wanders, return gently — the point is presence, not perfection. Repeat slowly until the chest softens. Then step into the morning with a quieter heart, remembering that every hour ahead is held by the One you just remembered.',
        sourceReference: 'Muslim; morning remembrances',
        authorId: 'demo',
        authorName: 'Alamiyah',
        status: ContentStatus.published,
        createdAt: t.subtract(const Duration(hours: 2)),
        featured: true,
      ),
      ContentItem(
        id: 'demo_long_anxiety',
        type: ContentType.text,
        title: 'When the chest feels tight — a dua and reflection',
        category: 'invocations',
        section: collectionById('invocations')!.entries[0].title,
        tags: const ['anxiety', 'peace', 'dua', 'long'],
        arabicText:
            'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَالْعَجْزِ وَالْكَسَلِ، وَالْجُبْنِ وَالْبُخْلِ، وَضَلَعِ الدَّيْنِ، وَغَلَبَةِ الرِّجَالِ.\n\n'
            'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ.',
        transliteration:
            'Allahumma inni a\'udhu bika minal-hammi wal-hazan, wal-\'ajzi wal-kasal, wal-jubni wal-bukhl, wa dala\'id-dayni wa ghalabatir-rijal. Hasbunallahu wa ni\'mal-wakeel.',
        translation:
            'O Allah, I seek refuge in You from worry and grief, from incapacity and laziness, from cowardice and miserliness, from being heavily in debt and from being overpowered by people.\n\n'
            'Allah is sufficient for us, and He is the best Disposer of affairs.\n\n'
            'Anxiety often arrives as a story about tomorrow. Dhikr does not erase every fear at once; it gives you a place to stand while the wave passes. Read the Arabic if you can, or sit with the meaning. Place a hand on your chest. Breathe in for four counts, out for six. Whisper the dua again.\n\n'
            'If the tightness remains, that does not mean the dua “failed.” It means you are human, and you brought your heart to Allah anyway. Return to this page tonight. Return tomorrow. The quiet work of remembrance is slow, and that is mercy — because a calm that is forced rarely lasts, but a calm that is practiced becomes a companion.\n\n'
            'End with gratitude for one small safe thing in this moment: a breath that still comes, a roof, a friend, a prayer you can still say. Then close the app if you need rest. Allah is near.',
        sourceReference: 'Bukhari; situational remembrances',
        authorId: 'demo',
        authorName: 'Alamiyah',
        status: ContentStatus.published,
        createdAt: t.subtract(const Duration(hours: 5)),
      ),
      ContentItem(
        id: 'demo_evening_long',
        type: ContentType.text,
        title: 'Evening settle — closing the day with remembrance',
        category: 'invocations',
        section: collectionById('invocations')!.entries[4].title,
        tags: const ['evening', 'adhkar', 'sleep'],
        arabicText:
            'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ.\n\n'
            'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا.',
        transliteration:
            'Amsayna wa amsal-mulku lillah… Bismika Allahumma amutu wa ahya.',
        translation:
            'We have entered the evening and the dominion belongs to Allah… In Your name, O Allah, I die and I live.\n\n'
            'Let the day end without arguing with every unfinished task. Name three mercies from today — even tiny ones. Recite slowly. If sleep comes mid-dua, know that resting is also an act of trust. Tomorrow’s adhkar will wait for you; tonight, soft closing is enough.\n\n'
            'Stay with the last line until the room feels quieter. Dim the lights. Put the phone face-down after you finish. May Allah gather what scattered in you today and return it whole in the morning.',
        sourceReference: 'Muslim; evening remembrances',
        authorId: 'demo',
        authorName: 'Alamiyah',
        status: ContentStatus.published,
        createdAt: t.subtract(const Duration(hours: 8)),
      ),
      ContentItem(
        id: 'demo_names_long',
        type: ContentType.text,
        title: 'Ar-Rahman, Ar-Rahim — sitting with mercy',
        category: 'names',
        section: collectionById('names')!.entries[0].title,
        tags: const ['names', 'rahman', 'rahim', 'reflection'],
        arabicText: 'الرَّحْمَٰنُ · الرَّحِيمُ',
        transliteration: 'Ar-Rahman · Ar-Rahim',
        translation:
            'The Most Merciful · The Especially Merciful.\n\n'
            'Rahman is vast mercy that touches everything that exists. Rahim is intimate mercy that meets you in your particular need. Say each Name aloud. Then whisper them. Then sit in silence and let the meanings arrive without forcing insight.\n\n'
            'When you feel unworthy of softness, these Names answer before you finish the thought. Mercy is not a prize for the polished; it is the atmosphere of the One who created you knowing your cracks.\n\n'
            'Write one place you need mercy today. Hold it gently under these Names. Do not solve it yet. Just rest it there. Long remembrance is not about length for its own sake — it is about giving the heart enough time to believe what the tongue already said.',
        sourceReference: 'Qur\'an 1:1–3 — reflection',
        authorId: 'demo',
        authorName: 'Alamiyah',
        status: ContentStatus.published,
        createdAt: t.subtract(const Duration(hours: 12)),
      ),
      ContentItem(
        id: 'demo_image_calm_sky',
        type: ContentType.image,
        title: 'Look up — a visual pause before dhikr',
        category: 'teachings',
        section: collectionById('teachings')!.entries[2].title,
        tags: const ['image', 'calm', 'sky', 'pause'],
        translation:
            'Before you scroll further, stay with this sky for twenty seconds. Soften the jaw. Unclench the hands. Then choose one short dhikr — Subhanallah, Alhamdulillah, or Allahu Akbar — and say it thirty-three times while the image is still in mind.\n\n'
            'Visual quiet is not empty. It is a doorway. Many of us arrive to remembrance already noisy. An image like this slows the entrance so the words have somewhere to land.\n\n'
            'If tears come, let them. If nothing comes, that is also fine. The point is arriving, not performing feeling. When you are ready, open a text dua and continue. Carry a piece of this calm into the next screen.',
        mediaUrl:
            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=1400&q=80',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80',
        sourceReference: 'Visual reflection — Alamiyah demo',
        authorId: 'demo',
        authorName: 'Alamiyah',
        status: ContentStatus.published,
        createdAt: t.subtract(const Duration(hours: 15)),
      ),
      ContentItem(
        id: 'demo_image_masjid_light',
        type: ContentType.image,
        title: 'Light on stone — patience in still frames',
        category: 'teachings',
        section: collectionById('teachings')!.entries[2].title,
        tags: const ['image', 'masjid', 'patience'],
        arabicText: 'وَاصْبِرْ وَمَا صَبْرُكَ إِلَّا بِاللَّهِ',
        transliteration: 'Wasbir wa ma sabruka illa billah',
        translation:
            'And be patient, and your patience is not but through Allah. (16:127)\n\n'
            'Architecture teaches what hurry forgets: beauty is built slowly. Look at the lines of light. Imagine the hands that carved and cleaned and called to prayer here across years you will never meet.\n\n'
            'Patience is not passive waiting. It is active trust with a quiet face. Pair this image with the ayah above. Read it once for meaning, once for sound, once for the place in your life that needs sabr most.\n\n'
            'Then leave the phone for two minutes. Return only when the breath has lengthened. That small gap is the real content of this card.',
        mediaUrl:
            'https://images.unsplash.com/photo-1564760055775-d63b17a55c44?w=1400&q=80',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1564760055775-d63b17a55c44?w=800&q=80',
        sourceReference: 'Qur\'an 16:127 — visual pairing',
        authorId: 'demo',
        authorName: 'Alamiyah',
        status: ContentStatus.published,
        createdAt: t.subtract(const Duration(hours: 18)),
      ),
      ContentItem(
        id: 'demo_image_ramadan_table',
        type: ContentType.image,
        title: 'Dates and dusk — a Ramadan mood board for the heart',
        category: 'teachings',
        section: collectionById('teachings')!.entries[1].title,
        tags: const ['ramadan', 'image', 'iftar', 'gratitude'],
        translation:
            'Ramadan is not only hunger and schedule. It is the soft hour when a table becomes a place of thanks. Stay with this image and name who you would invite if distance were nothing — living or passed — and make dua for them by name.\n\n'
            'Gratitude deepens when it is specific. Not “alhamdulillah for everything,” but alhamdulillah for this bread, this water, this chance to break a fast again.\n\n'
            'If it is not Ramadan where you are, borrow the mood anyway. Fasting of the tongue and the eyes can begin on any calendar. Let the picture remind you that worship also looks like shared warmth.',
        mediaUrl:
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=1400&q=80',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&q=80',
        authorId: 'demo',
        authorName: 'Alamiyah',
        status: ContentStatus.published,
        createdAt: t.subtract(const Duration(hours: 22)),
      ),
      ContentItem(
        id: 'demo_video_bee',
        type: ContentType.video,
        title: 'A tiny reminder — watch, then breathe',
        category: 'poems',
        section: collectionById('poems')!.entries[0].title,
        tags: const ['video', 'short', 'presence'],
        translation:
            'This is a very small sample clip so you can test in-app playback. Watch once without multitasking. When it ends, close your eyes for three breaths and say: Subhanallahi wa bihamdihi.\n\n'
            'Short video can still be deep if you treat it as a ritual rather than a feed. After playback, return to a long text dua and stay there longer than the clip lasted. Let the moving image be a doorway, not the destination.\n\n'
            'If the video fails to load, check your connection and open again. The point of this card is presence practice paired with motion — a contrast to static reading.',
        mediaUrl: sampleVideoUrl,
        thumbnailUrl: sampleVideoThumb,
        sourceReference: 'Flutter sample asset (demo)',
        authorId: 'demo',
        authorName: 'Alamiyah',
        status: ContentStatus.published,
        createdAt: t.subtract(const Duration(hours: 26)),
      ),
      ContentItem(
        id: 'demo_daily_dhikr_long',
        type: ContentType.text,
        title: 'Daily dhikr — Subhanallah, Alhamdulillah, Allahu Akbar',
        category: 'invocations',
        section: collectionById('invocations')!.entries[1].title,
        tags: const ['daily', 'dhikr', 'tasbih'],
        arabicText: 'سُبْحَانَ اللهِ · الْحَمْدُ لِلَّهِ · اللهُ أَكْبَرُ',
        transliteration: 'Subhanallah · Alhamdulillah · Allahu Akbar',
        translation:
            'Glory be to Allah. All praise is for Allah. Allah is the Greatest.\n\n'
            'Count thirty-three of each, or use your fingers the way you were taught. Slow beats fast. If you lose count, start the current set again without frustration — the goal is rhythm with meaning.\n\n'
            'Subhanallah clears the mind of cluttered claims. Alhamdulillah turns the day into a gift again. Allahu Akbar puts every worry in its right size.\n\n'
            'Do a second round if the first felt mechanical. The second round is often where the heart wakes. End by sending salawat upon the Prophet ﷺ, then sit for ten quiet seconds before you stand.',
        sourceReference: 'Common daily remembrances',
        authorId: 'demo',
        authorName: 'Alamiyah',
        status: ContentStatus.published,
        createdAt: t.subtract(const Duration(hours: 30)),
      ),
      ContentItem(
        id: 'demo_quote_long',
        type: ContentType.text,
        title: 'A quiet line for heavy days',
        category: 'teachings',
        section: collectionById('teachings')!.entries[0].title,
        tags: const ['quote', 'hope', 'long'],
        arabicText: 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا · إِنَّ مَعَ الْعُسْرِ يُسْرًا',
        transliteration:
            'Fa inna ma\'al-\'usri yusra. Inna ma\'al-\'usri yusra.',
        translation:
            'For indeed, with hardship comes ease. Indeed, with hardship comes ease. (94:5–6)\n\n'
            'Notice the ayah says with hardship, not after it. Ease can walk beside difficulty — a kindness in the middle of the trial, a friend who texts, a prayer that lands, a night of sleep you did not expect.\n\n'
            'Read the pair of lines twice. The repetition is intentional: so the heart does not dismiss the promise as poetry. If today is hard, look for the “with” — the ease already present — even if it is small.\n\n'
            'Write that small ease somewhere. Then make dua for the larger ease you still wait for. Both belong in the same sentence of faith.',
        sourceReference: 'Qur\'an 94:5–6',
        authorId: 'demo',
        authorName: 'Alamiyah',
        status: ContentStatus.published,
        createdAt: t.subtract(const Duration(hours: 34)),
      ),
    ];
  }
}
