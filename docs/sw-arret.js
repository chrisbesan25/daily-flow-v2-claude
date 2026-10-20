// Version « d'arrêt » du service worker de Daily Flow (20/10/2026). Secours, à n'utiliser que si
// la désactivation normale (SW_ACTIF=false dans index.html) ne suffit pas.
// Emploi : remplacer le contenu de sw.js (à la racine du dépôt) par celui de ce fichier, puis déposer.
// À la prochaine ouverture avec réseau, chaque appareil installe cette version, qui efface les caches
// « daily-flow-v3-sw-* » (jamais ceux de Budget perso) puis se désinscrit. Aucune donnée de l'app n'est touchée.
// Tant que index.html garde SW_ACTIF=true, la page la réinscrit à chaque ouverture, sans effet :
// mettre aussi SW_ACTIF=false pour un arrêt complet.

const PREFIXE = 'daily-flow-v3-sw-';
self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', e => {
    e.waitUntil((async () => {
        for (const k of await caches.keys()) if (k.startsWith(PREFIXE)) await caches.delete(k);
        await self.registration.unregister();
    })());
});
