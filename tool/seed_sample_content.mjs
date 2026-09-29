/**
 * One-off seeder — run from project root:
 *   node tool/seed_sample_content.mjs
 * Pass credentials via env (do not commit passwords):
 *   $env:SEED_EMAIL="..."; $env:SEED_PASSWORD="..."; node tool/seed_sample_content.mjs
 */
const apiKey = 'AIzaSyASXizCHJeLYd2qJkBP94bmXJ8T8KknRYM';
const projectId = 'alamiyah';
const email = process.env.SEED_EMAIL;
const password = process.env.SEED_PASSWORD;

if (!email || !password) {
  console.error('Set SEED_EMAIL and SEED_PASSWORD env vars.');
  process.exit(1);
}

async function signIn() {
  const res = await fetch(
    `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${apiKey}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password, returnSecureToken: true }),
    },
  );
  const data = await res.json();
  if (!res.ok) throw new Error(JSON.stringify(data));
  return data;
}

function firestoreValue(value) {
  if (value === null || value === undefined) return { nullValue: null };
  if (typeof value === 'string') return { stringValue: value };
  if (typeof value === 'boolean') return { booleanValue: value };
  if (typeof value === 'number') {
    return Number.isInteger(value)
      ? { integerValue: String(value) }
      : { doubleValue: value };
  }
  if (Array.isArray(value)) {
    return { arrayValue: { values: value.map(firestoreValue) } };
  }
  if (typeof value === 'object') {
    const fields = {};
    for (const [k, v] of Object.entries(value)) fields[k] = firestoreValue(v);
    return { mapValue: { fields } };
  }
  return { stringValue: String(value) };
}

async function upsertDoc(idToken, collection, id, data) {
  const url = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/${collection}/${id}`;
  const fields = {};
  for (const [k, v] of Object.entries(data)) fields[k] = firestoreValue(v);
  const res = await fetch(url, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${idToken}`,
    },
    body: JSON.stringify({ fields }),
  });
  const body = await res.json();
  if (!res.ok) throw new Error(`${collection}/${id}: ${JSON.stringify(body)}`);
  return body;
}

const now = new Date();
const iso = (daysAgo) =>
  new Date(now.getTime() - daysAgo * 86400000).toISOString();

const categories = [
  { id: 'morning', name: 'Morning Adhkar', iconRef: 'wb_sunny_outlined', colorHint: '#7BA882', sortOrder: 1 },
  { id: 'evening', name: 'Evening Adhkar', iconRef: 'nights_stay_outlined', colorHint: '#3D6B5A', sortOrder: 2 },
  { id: 'situational', name: 'Situational Duas', iconRef: 'favorite_border', colorHint: '#C4A35A', sortOrder: 3 },
  { id: 'names', name: 'Names of Allah', iconRef: 'auto_awesome_outlined', colorHint: '#5A8F7B', sortOrder: 4 },
  { id: 'reflections', name: 'Reflections', iconRef: 'menu_book_outlined', colorHint: '#8FA894', sortOrder: 5 },
  { id: 'video', name: 'Video Reminders', iconRef: 'play_circle_outline', colorHint: '#2F5D4A', sortOrder: 6 },
  { id: 'ramadan', name: 'Ramadan Specials', iconRef: 'brightness_2_outlined', colorHint: '#B8956A', sortOrder: 7 },
];

async function main() {
  const auth = await signIn();
  const uid = auth.localId;
  const token = auth.idToken;
  const authorName = auth.displayName || 'Alamiyah Editors';

  console.log('Signed in as', auth.email, uid);

  for (const cat of categories) {
    await upsertDoc(token, 'categories', cat.id, cat);
    console.log('category', cat.id);
  }

  const samples = [
    {
      id: 'seed_featured_gratitude',
      type: 'text',
      title: 'Dua of the Day — Gratitude',
      category: 'situational',
      tags: ['gratitude', 'daily'],
      arabicText: "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ",
      transliteration: "Alhamdu lillahi rabbil 'alamin",
      translation: 'All praise is for Allah, Lord of the worlds.',
      sourceReference: 'Qur’an 1:2',
      mediaUrl: null,
      thumbnailUrl: null,
      featured: true,
      status: 'published',
      createdAt: iso(0),
      scheduledAt: null,
    },
    {
      id: 'seed_morning_kursi',
      type: 'text',
      title: 'Morning — Ayat al-Kursi',
      category: 'morning',
      tags: ['protection', 'morning'],
      arabicText: "اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ",
      transliteration: "Allahu la ilaha illa huwa al-hayyul-qayyum",
      translation:
        'Allah — there is no deity except Him, the Ever-Living, the Sustainer of existence.',
      sourceReference: 'Qur’an 2:255',
      mediaUrl: null,
      thumbnailUrl: null,
      featured: false,
      status: 'published',
      createdAt: iso(1),
      scheduledAt: null,
    },
    {
      id: 'seed_evening_refuge',
      type: 'text',
      title: 'Evening — Seeking Refuge',
      category: 'evening',
      tags: ['evening', 'refuge'],
      arabicText: "أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ",
      transliteration: "A'udhu bi kalimatillahi at-tammati min sharri ma khalaq",
      translation:
        'I seek refuge in the perfect words of Allah from the evil of what He has created.',
      sourceReference: 'Muslim',
      mediaUrl: null,
      thumbnailUrl: null,
      featured: false,
      status: 'published',
      createdAt: iso(2),
      scheduledAt: null,
    },
    {
      id: 'seed_name_rahman',
      type: 'text',
      title: 'Ar-Rahman — The Most Merciful',
      category: 'names',
      tags: ['asma', 'mercy'],
      arabicText: "الرَّحْمَٰنُ",
      transliteration: 'Ar-Rahman',
      translation: 'The Most Merciful — whose mercy embraces all creation.',
      sourceReference: 'Asma ul Husna',
      mediaUrl: null,
      thumbnailUrl: null,
      featured: false,
      status: 'published',
      createdAt: iso(3),
      scheduledAt: null,
    },
    {
      id: 'seed_reflection_image',
      type: 'image',
      title: 'Quiet Dawn — Reflection',
      category: 'reflections',
      tags: ['visual', 'calm'],
      arabicText: null,
      transliteration: null,
      translation: 'Soft light before dawn — a reminder that every day begins with mercy.',
      sourceReference: null,
      mediaUrl:
        'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
      thumbnailUrl:
        'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
      featured: false,
      status: 'published',
      createdAt: iso(4),
      scheduledAt: null,
    },
    {
      id: 'seed_video_reminder',
      type: 'video',
      title: 'Short Reminder: Softness of the Heart',
      category: 'video',
      tags: ['reminder', 'heart'],
      arabicText: null,
      transliteration: null,
      translation: 'A brief reflection on softening the heart through consistent dhikr.',
      sourceReference: null,
      mediaUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      thumbnailUrl:
        'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=400',
      featured: false,
      status: 'published',
      createdAt: iso(5),
      scheduledAt: null,
    },
    {
      id: 'seed_ramadan_intention',
      type: 'text',
      title: 'Ramadan Intention — Sincerity',
      category: 'ramadan',
      tags: ['ramadan', 'intention'],
      arabicText: "إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ",
      transliteration: "Innama al-a'malu bin-niyyat",
      translation: 'Actions are but by intentions.',
      sourceReference: 'Bukhari & Muslim',
      mediaUrl: null,
      thumbnailUrl: null,
      featured: false,
      status: 'published',
      createdAt: iso(6),
      scheduledAt: null,
    },
    {
      id: 'seed_draft_example',
      type: 'text',
      title: 'Draft — Coming soon dua',
      category: 'situational',
      tags: ['draft'],
      arabicText: "رَبِّ زِدْنِي عِلْمًا",
      transliteration: "Rabbi zidni 'ilma",
      translation: 'My Lord, increase me in knowledge.',
      sourceReference: 'Qur’an 20:114',
      mediaUrl: null,
      thumbnailUrl: null,
      featured: false,
      status: 'draft',
      createdAt: iso(0),
      scheduledAt: null,
    },
  ];

  for (const item of samples) {
    const payload = {
      ...item,
      authorId: uid,
      authorName,
    };
    await upsertDoc(token, 'content', item.id, payload);
    console.log('content', item.id, item.status);
  }

  console.log('Seed complete.');
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
