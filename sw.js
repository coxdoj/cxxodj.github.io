
const CACHE_NAME='cwl-v1';
const CORE=['/','/index.html','/assets/css/style.css','/assets/js/app.js','/subscriptions.html','/about.html','/contact.html','/privacy.html','/terms.html'];
self.addEventListener('install',e=>{e.waitUntil(caches.open(CACHE_NAME).then(c=>c.addAll(CORE)))});
self.addEventListener('activate',e=>{e.waitUntil(caches.keys().then(keys=>Promise.all(keys.filter(k=>k!==CACHE_NAME).map(k=>caches.delete(k)))))});
self.addEventListener('fetch',e=>{
  const req=e.request;
  e.respondWith(caches.match(req).then(r=> r || fetch(req).then(resp=>{ if(req.method==='GET' && resp.ok){ const copy=resp.clone(); caches.open(CACHE_NAME).then(c=>c.put(req, copy)); } return resp; }).catch(()=>caches.match('/index.html')) ));
});
