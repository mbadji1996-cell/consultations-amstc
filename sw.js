/* Service worker AMSTC - cache l'app shell pour un fonctionnement hors ligne.
   Incrémente CACHE_VERSION à chaque mise à jour de index.html pour purger les
   caches obsolètes chez les utilisateurs (voir aussi la stratégie réseau
   ci-dessous, qui limite déjà fortement le risque de rester bloqué sur une
   ancienne version même sans y penser). */
const CACHE_VERSION="amstc-v72";
// Toutes les bibliothèques CDN utilisées par l'app y figurent : sans elles, un utilisateur
// qui rouvre l'app hors connexion sans les avoir jamais chargées perdrait les graphiques et
// surtout les exports PDF/Word et l'import/export Excel (fonctions clés sur le terrain).
const APP_SHELL = [
  "./",
  "./index.html",
  "https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2",
  "https://cdn.jsdelivr.net/npm/chart.js@4.4.4/dist/chart.umd.min.js",
  "https://cdn.jsdelivr.net/npm/jspdf@2.5.2/dist/jspdf.umd.min.js",
  "https://cdn.jsdelivr.net/npm/jspdf-autotable@3.8.4/dist/jspdf.plugin.autotable.min.js",
  "https://cdn.jsdelivr.net/npm/docx@8.5.0/build/index.umd.js",
  "https://cdn.jsdelivr.net/npm/xlsx@0.18.5/dist/xlsx.full.min.js",
  "https://cdn.jsdelivr.net/npm/qrious@4.0.2/dist/qrious.min.js",
];
// Uniquement les ressources dont l'URL fige la version (ex. "@2", "@4.4.4") : leur contenu ne
// change jamais pour une même URL, donc les servir depuis le cache sans repasser par le réseau
// est sûr. Volontairement, "./" et "./index.html" N'EN FONT PAS PARTIE - c'est l'app elle-même,
// modifiée en continu ; la traiter en "cache d'abord" ferait qu'un téléphone qui l'a déjà visitée
// resterait bloqué sur l'ancienne version jusqu'à une purge manuelle du cache, indépendamment de
// toute mise à jour effectuée entre-temps.
const IMMUTABLE_CACHE_FIRST = [
  "https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2",
  "https://cdn.jsdelivr.net/npm/chart.js@4.4.4/dist/chart.umd.min.js",
  "https://cdn.jsdelivr.net/npm/jspdf@2.5.2/dist/jspdf.umd.min.js",
  "https://cdn.jsdelivr.net/npm/jspdf-autotable@3.8.4/dist/jspdf.plugin.autotable.min.js",
  "https://cdn.jsdelivr.net/npm/docx@8.5.0/build/index.umd.js",
  "https://cdn.jsdelivr.net/npm/xlsx@0.18.5/dist/xlsx.full.min.js",
  "https://cdn.jsdelivr.net/npm/qrious@4.0.2/dist/qrious.min.js",
];

self.addEventListener("install", (e) => {
  e.waitUntil(
    // Pré-remplit le cache dès l'installation, y compris index.html : donne une capacité hors
    // ligne immédiate après la toute première visite, sans attendre un second chargement en ligne.
    caches.open(CACHE_VERSION).then((c) => c.addAll(APP_SHELL)).then(() => self.skipWaiting())
  );
});

self.addEventListener("activate", (e) => {
  e.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((k) => k !== CACHE_VERSION).map((k) => caches.delete(k)))
    ).then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", (e) => {
  const req = e.request;
  if (req.method !== "GET") return; // ne jamais mettre en cache les requêtes API Supabase

  const url = new URL(req.url);
  // Les appels vers Supabase passent toujours par le réseau (jamais de cache) -
  // y compris l'instance auto-hébergée : mettre en cache des réponses API
  // exposerait des données patients dans le cache du navigateur.
  if (url.hostname.endsWith(".supabase.co") || url.hostname === "api.consultations-amstc.org") return;

  // Ressources versionnées (CDN) : cache d'abord, réseau en secours - rapide, et sûr puisque
  // leur URL ne change jamais de contenu.
  if (IMMUTABLE_CACHE_FIRST.some((p) => req.url === p)) {
    e.respondWith(
      caches.match(req).then((cached) => cached || fetch(req))
    );
    return;
  }

  // Tout le reste, y compris index.html : réseau d'abord (toujours la dernière version dès
  // qu'une connexion existe), cache en secours (permet de rouvrir l'app hors connexion).
  e.respondWith(
    fetch(req).then((res) => {
      const copy = res.clone();
      caches.open(CACHE_VERSION).then((c) => c.put(req, copy)).catch(() => {});
      return res;
    }).catch(() => caches.match(req))
  );
});
