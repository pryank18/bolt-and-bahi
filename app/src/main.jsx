import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { installStoragePolyfill } from "./storagePolyfill.js";
import App from "./App.jsx";

// Installed before render. App.jsx only touches window.storage inside
// React effects and event handlers (never at module-evaluation time), so
// a synchronous install here, before the first render, is sufficient —
// no need for a dynamic import or top-level await.
installStoragePolyfill();

createRoot(document.getElementById("root")).render(
  <StrictMode>
    <App />
  </StrictMode>
);
