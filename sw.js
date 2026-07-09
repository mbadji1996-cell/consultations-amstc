/* Service worker AMSTC — cache l'app shell pour un fonctionnement hors ligne.
   Incrémente CACHE_VERSION à chaque mise à jour de index.html pour forcer
   le rafraîchissement du cache chez les utilisateurs. */
const CACHE_VERSION = "amstc-v18";
const APP_SHELL = [
  "./",
  "./index.html",
  "https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2",
  "https://cdn.jsdelivr.net/npm/chart.js@4.4.4/dist/chart.umd.min.js",
];

self.addEventListener("install", (e) => {
  e.waitUntil(
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
  // Les appels vers Supabase passent toujours par le réseau (jamais de cache)
  if (url.hostname.endsWith(".supabase.co")) return;

  // App shell : cache d'abord, réseau en secours (rapide + hors ligne)
  if (APP_SHELL.some((p) => req.url.endsWith(p.replace("./", "")) || req.url === p)) {
    e.respondWith(
      caches.match(req).then((cached) => cached || fetch(req))
    );
    return;
  }

  // Reste : réseau d'abord, cache en secours
  e.respondWith(
    fetch(req).then((res) => {
      const copy = res.clone();
      caches.open(CACHE_VERSION).then((c) => c.put(req, copy)).catch(() => {});
      return res;
    }).catch(() => caches.match(req))
  );
});
