// Service worker de Daily Flow : démarrage hors connexion (20/10/2026).
// Portée : le seul dossier de l'app (/daily-flow-v2-claude/).
// Gardés en cache : la page, la bibliothèque supabase-js 2.117.0 (jsdelivr, avec les modules
// qu'elle importe) et les polices Google Fonts.
// Aucune autre requête n'est interceptée : les appels à Supabase (données, connexion, temps réel)
// passent directement par le navigateur, comme sans service worker.
// Site partagé avec Budget perso : ce fichier ne crée et ne supprime que des caches « daily-flow-v3-sw-* ».
// Mise à jour : changer VERSION ; l'activation efface alors les anciens caches de Daily Flow seulement.

const VERSION = 'v2';
const PREFIXE = 'daily-flow-v3-sw-';
const CACHE = PREFIXE + VERSION;
const PORTEE = self.registration.scope;              // https://chrisbesan25.github.io/daily-flow-v2-claude/
const PAGE = PORTEE;                                  // clé unique de la page dans le cache
const CHEMINS_PAGE = [new URL(PORTEE).pathname, new URL(PORTEE).pathname + 'index.html'];
const DELAI_RESEAU = 4000;                            // au-delà, la dernière copie enregistrée est servie
const JSDELIVR = 'https://cdn.jsdelivr.net';
const BIBLIO = JSDELIVR + '/npm/@supabase/supabase-js@2.117.0/+esm';   // même adresse que l'import de la page
const POLICES = 'https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:wght@500;700;800&family=Schibsted+Grotesk:wght@400;500;600;700&display=swap';
const HOTES_POLICES = ['https://fonts.googleapis.com', 'https://fonts.gstatic.com'];

// Installation : la page et la bibliothèque sont obligatoires. En cas d'échec (réseau coupé pendant
// l'installation, jsdelivr injoignable), l'installation échoue : la version déjà en place et son cache
// restent en service, et le navigateur réessaiera à une ouverture suivante (audit du 20/10/2026, C1).
// Polices : au mieux.
self.addEventListener('install', e => {
    e.waitUntil((async () => {
        const cache = await caches.open(CACHE);
        const res = await fetch(PAGE, { cache: 'no-cache' });
        if (!res.ok) throw new Error('page : ' + res.status);
        await cache.put(PAGE, res);
        await garderModule(cache, BIBLIO, new Set());
        await garderPolices(cache).catch(err => console.warn('sw polices :', err));
        await self.skipWaiting();
    })());
});

// Module jsdelivr et, de proche en proche, les modules qu'il importe. Seules les adresses jsdelivr
// en /npm/... sont suivies : la bibliothèque contient aussi, dans un message, le texte d'un import
// qui n'en est pas un (audit, C2). Un module déjà présent dans une version précédente de NOS caches
// est repris tel quel, sans réseau (contenu immuable : l'adresse porte la version).
async function garderModule(cache, url, vus) {
    if (vus.has(url) || vus.size > 40) return;
    vus.add(url);
    let res = await cache.match(url, { ignoreVary: true });
    if (!res) {
        res = (await dansAnciensCaches(url)) || await fetch(url);
        if (!res.ok) throw new Error(url + ' : ' + res.status);
        await cache.put(url, res.clone());
    }
    const texte = await res.text();
    const imports = [...texte.matchAll(/(?:from|import)\s*\(?\s*["']((?:https:\/\/cdn\.jsdelivr\.net)?\/npm\/[^"']+)["']/g)]
        .map(m => new URL(m[1], JSDELIVR).href);
    await Promise.all(imports.map(u => garderModule(cache, u, vus)));
}

async function dansAnciensCaches(url) {
    for (const k of await caches.keys()) {
        if (!k.startsWith(PREFIXE) || k === CACHE) continue;
        const r = await (await caches.open(k)).match(url, { ignoreVary: true });
        if (r) return r;
    }
    return null;
}

// Feuille de style Google Fonts et fichiers de polices qu'elle désigne
async function garderPolices(cache) {
    const res = await fetch(POLICES);
    if (!res.ok) throw new Error('polices : ' + res.status);
    await cache.put(POLICES, res.clone());
    const fichiers = [...(await res.text()).matchAll(/url\((https:\/\/fonts\.gstatic\.com\/[^)]+)\)/g)].map(m => m[1]);
    await Promise.all(fichiers.map(async u => { const f = await fetch(u); if (f.ok) await cache.put(u, f); }));
}

// Activation : suppression des anciennes versions de NOS caches, jamais de ceux de Budget
self.addEventListener('activate', e => {
    e.waitUntil((async () => {
        for (const k of await caches.keys()) {
            if (k.startsWith(PREFIXE) && k !== CACHE) await caches.delete(k);
        }
        await self.clients.claim();
    })());
});

self.addEventListener('fetch', e => {
    const req = e.request;
    if (req.method !== 'GET') return;
    const url = new URL(req.url);
    if (req.mode === 'navigate') {
        if (url.origin === location.origin && CHEMINS_PAGE.includes(url.pathname)) e.respondWith(pageReseauDabord(e));
        return;
    }
    if (url.origin === JSDELIVR && url.pathname.startsWith('/npm/')) e.respondWith(cacheDabord(e, false));
    else if (HOTES_POLICES.includes(url.origin)) e.respondWith(cacheDabord(e, true));
    // Tout le reste (Supabase compris) : pas d'interception
});

// Page en « réseau d'abord » : la version en ligne (revalidée auprès de GitHub Pages), sinon,
// sans réseau ou après DELAI_RESEAU, la dernière copie enregistrée. Une réponse arrivée en retard
// met quand même la copie à jour pour la prochaine ouverture.
async function pageReseauDabord(e) {
    const cache = await caches.open(CACHE);
    const enLigne = fetch(PAGE, { cache: 'no-cache' }).then(async res => {
        if (!res.ok || res.redirected) return null;
        await cache.put(PAGE, res.clone()).catch(() => {});      // stockage plein : la page est servie quand même
        return res;
    }).catch(() => null);
    e.waitUntil(enLigne);
    const copie = await cache.match(PAGE);
    if (!copie) return (await enLigne) || fetch(e.request);    // pas de copie : comportement normal
    const delai = new Promise(r => setTimeout(() => r(null), DELAI_RESEAU));
    return (await Promise.race([enLigne, delai])) || copie;
}

// Bibliothèque (adresse à version fixe, donc contenu immuable) et polices : copie enregistrée
// d'abord, sans attendre le réseau. Polices : rafraîchies en arrière-plan, demandées en CORS pour
// voir le vrai statut : une réponse en erreur ne remplace jamais la bonne copie (audit, C6).
async function cacheDabord(e, polices) {
    const req = e.request;
    const cache = await caches.open(CACHE);
    const copie = await cache.match(req, { ignoreVary: true });
    if (copie && !polices) return copie;
    const reseau = fetch(polices ? new Request(req.url, { mode: 'cors', credentials: 'omit' }) : req).then(async res => {
        if (res.ok) await cache.put(req, res.clone()).catch(() => {});   // stockage plein : réponse servie quand même
        return res;
    });
    if (copie) { e.waitUntil(reseau.catch(() => {})); return copie; }
    return reseau;
}
