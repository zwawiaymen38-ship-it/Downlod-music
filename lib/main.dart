

<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>ABDOU MUSIC</title>
<style>
:root {
  --bg: #10111a;
  --card: #1b1d2b;
  --text: #ffffff;
  --accent: #8b5cf6;
}
body.light {
  --bg: #f4f5fb;
  --card: #ffffff;
  --text: #171827;
}
* { box-sizing: border-box; }
body {
  margin: 0;
  font-family: Arial, sans-serif;
  background: var(--bg);
  color: var(--text);
  transition: .25s;
}
header {
  padding: 24px 16px;
  text-align: center;
  background: linear-gradient(135deg,#7c3aed,#ec4899);
  border-radius: 0 0 25px 25px;
}
header h1 { margin: 0; font-size: 27px; }
header p { margin-bottom: 0; }
.controls {
  display: flex;
  gap: 8px;
  padding: 15px;
}
input, select, button {
  font: inherit;
  border: 0;
  border-radius: 12px;
  padding: 12px;
}
input {
  min-width: 0;
  flex: 1;
  background: var(--card);
  color: var(--text);
}
button {
  background: var(--accent);
  color: white;
  cursor: pointer;
}
button:disabled { opacity: .5; }
h2 { padding: 0 16px; }
#status { padding: 0 16px; }
#results {
  display: grid;
  grid-template-columns: repeat(2,minmax(0,1fr));
  gap: 12px;
  padding: 12px;
  padding-bottom: 180px;
}
.song {
  background: var(--card);
  border-radius: 16px;
  overflow: hidden;
  padding-bottom: 12px;
}
.song img {
  width: 100%;
  aspect-ratio: 1;
  object-fit: cover;
}
.song h3 {
  font-size: 14px;
  margin: 10px;
  line-height: 1.5;
}
.song p {
  font-size: 12px;
  margin: 0 10px 10px;
  opacity: .75;
}
.song button { margin: 0 10px; }
#player {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 14px;
  background: var(--card);
  border-top: 1px solid #7773;
}
#now { font-size: 14px; margin-bottom: 8px; }
audio { width: 100%; }
#playerActions {
  display: flex;
  gap: 8px;
  margin-top: 8px;
}
#playerActions button { flex: 1; }
footer { text-align:center; padding:15px; opacity:.65; }
</style>
</head>
<body>

<header>
  <h1>🎵 ABDOU MUSIC</h1>
  <p>اكتشف موسيقاك المفضلة في مكان واحد</p>
</header>

<div class="controls">
  <input id="query" placeholder="اكتب اسم الأغنية أو الفنان...">
  <button id="searchBtn" onclick="searchMusic()">بحث</button>
</div>

<div class="controls">
  <button onclick="toggleTheme()">🌙 / ☀️ المظهر</button>
  <select id="language" onchange="changeLanguage()">
    <option value="ar">العربية</option>
    <option value="fr">Français</option>
    <option value="en">English</option>
  </select>
</div>

<h2 id="sectionTitle">🎧 اكتشف الأغاني</h2>
<p id="status">ابحث باسم أغنية أو فنان للبدء.</p>
<div id="results"></div>

<footer>ABDOU MUSIC · Developed by ABDOU</footer>

<div id="player">
  <div id="now">اختَر أغنية للاستماع إليها</div>
  <audio id="audio" controls preload="none"></audio>
  <div id="playerActions">
    <button onclick="downloadPreview()">تنزيل المعاينة المتاحة</button>
    <button onclick="document.getElementById('localFile').click()">
      تشغيل ملف من الهاتف
    </button>
    <input type="file" id="localFile" accept="audio/*"
           hidden onchange="playLocalFile(event)">
  </div>
</div>

<script>
const API = "https://itunes.apple.com/search";
const queryInput = document.getElementById("query");
const results = document.getElementById("results");
const statusBox = document.getElementById("status");
const audio = document.getElementById("audio");
const now = document.getElementById("now");
const searchBtn = document.getElementById("searchBtn");

let currentSong = null;
let requestNumber = 0;

queryInput.addEventListener("keydown", e => {
  if (e.key === "Enter") searchMusic();
});

async function searchMusic() {
  const term = queryInput.value.trim();

  if (!term) {
    statusBox.textContent = "اكتب اسم الأغنية أو الفنان أولًا.";
    return;
  }

  const requestId = ++requestNumber;
  searchBtn.disabled = true;
  results.innerHTML = "";
  statusBox.textContent = "جارٍ البحث عن الأغاني...";

  try {
    const url = API + "?term=" + encodeURIComponent(term) +
                "&entity=song&limit=30&country=DZ";

    const response = await fetch(url);

    if (!response.ok) {
      throw new Error("تعذر الاتصال بخدمة البحث");
    }

    const data = await response.json();

    if (requestId !== requestNumber) return;

    const songs = data.results || [];

    if (!songs.length) {
      statusBox.textContent = "لم نعثر على نتائج. جرّب اسمًا آخر.";
      return;
    }

    statusBox.textContent = "عدد النتائج: " + songs.length;

    songs.forEach(song => {
      const card = document.createElement("article");
      card.className = "song";

      const img = document.createElement("img");
      img.src = song.artworkUrl100
        ? song.artworkUrl100.replace("100x100", "300x300")
        : "";
      img.alt = "غلاف الأغنية";
      img.loading = "lazy";

      const title = document.createElement("h3");
      title.textContent = song.trackName || "اسم غير متوفر";

      const artist = document.createElement("p");
      artist.textContent =
        (song.artistName || "فنان غير معروف") +
        (song.collectionName ? " · " + song.collectionName : "");

      const play = document.createElement("button");
      play.textContent = song.previewUrl
        ? "▶ استمع"
        : "المعاينة غير متاحة";

      play.disabled = !song.previewUrl;
      play.onclick = () => playSong(song);

      card.append(img, title, artist, play);
      results.appendChild(card);
    });

  } catch (error) {
    if (requestId === requestNumber) {
      statusBox.textContent =
        "تعذر البحث. تحقق من الإنترنت وحاول مجددًا.";
    }
  } finally {
    if (requestId === requestNumber) {
      searchBtn.disabled = false;
    }
  }
}

function playSong(song) {
  if (!song.previewUrl) return;

  currentSong = song;
  audio.src = song.previewUrl;
  now.textContent = song.trackName + " — " + song.artistName;
  audio.play().catch(() => {
    statusBox.textContent = "اضغط زر التشغيل داخل مشغل الموسيقى.";
  });
}

async function downloadPreview() {
  if (!currentSong || !currentSong.previewUrl) {
    statusBox.textContent = "اختر أغنية تتوفر لها معاينة أولًا.";
    return;
  }

  try {
    const response = await fetch(currentSong.previewUrl);
    if (!response.ok) throw new Error("Download failed");

    const blob = await response.blob();
    const objectURL = URL.createObjectURL(blob);
    const a = document.createElement("a");

    a.href = objectURL;
    a.download = (currentSong.trackName || "music") + "-preview.m4a";
    document.body.appendChild(a);
    a.click();
    a.remove();

    setTimeout(() => URL.revokeObjectURL(objectURL), 30000);
    statusBox.textContent =
      "تم طلب تنزيل المعاينة. قد تمنع قيود المصدر تنزيلها.";
  } catch (error) {
    statusBox.textContent =
      "تعذر تنزيل المعاينة. يمكنك الاستماع إليها من المصدر.";
  }
}

function playLocalFile(event) {
  const file = event.target.files[0];
  if (!file) return;

  if (audio.dataset.localURL) {
    URL.revokeObjectURL(audio.dataset.localURL);
  }

  const url = URL.createObjectURL(file);
  audio.dataset.localURL = url;
  audio.src = url;
  now.textContent = file.name;
  audio.play().catch(() => {});
}

function toggleTheme() {
  document.body.classList.toggle("light");
}

const translations = {
  ar: {
    title: "🎧 اكتشف الأغاني",
    placeholder: "اكتب اسم الأغنية أو الفنان...",
    search: "بحث"
  },
  fr: {
    title: "🎧 Découvrir la musique",
    placeholder: "Nom de la chanson ou de l'artiste...",
    search: "Rechercher"
  },
  en: {
    title: "🎧 Discover Music",
    placeholder: "Song title or artist...",
    search: "Search"
  }
};

function changeLanguage() {
  const lang = document.getElementById("language").value;
  const t = translations[lang];

  document.documentElement.lang = lang;
  document.documentElement.dir = lang === "ar" ? "rtl" : "ltr";
  document.getElementById("sectionTitle").textContent = t.title;
  queryInput.placeholder = t.placeholder;
  searchBtn.textContent = t.search;

  localStorage.setItem("abdou-language", lang);
}

const savedLanguage = localStorage.getItem("abdou-language");
if (savedLanguage && translations[savedLanguage]) {
  document.getElementById("language").value = savedLanguage;
  changeLanguage();
}
</script>
</body>
</html>