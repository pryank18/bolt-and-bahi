// Polyfills window.storage (a Claude.ai-artifact-only API) with a real
// implementation backed by localStorage, matching the exact same shape:
//   get(key)        -> Promise<{ value: string } | null>
//   set(key, value) -> Promise<{ value: string } | null>
//
// The app's own code (App.jsx) was written against this exact contract
// and needs no changes — it already handles JSON.stringify/parse itself
// at each call site. This file only needs to exist and run before the
// app mounts.

function installStoragePolyfill() {
  if (window.storage) return; // already provided by a real host environment — don't override it

  window.storage = {
    async get(key) {
      try {
        const raw = localStorage.getItem(key);
        return raw === null ? null : { value: raw };
      } catch (e) {
        // localStorage can throw in some contexts (private browsing quota,
        // disabled storage). Treat as "nothing stored" rather than crash.
        return null;
      }
    },
    async set(key, value) {
      try {
        localStorage.setItem(key, value);
        return { value };
      } catch (e) {
        return null;
      }
    },
  };
}

export { installStoragePolyfill };
