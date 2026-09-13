import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

export default defineConfig({
    base: "/bolt-and-bahi/",
    plugins: [react()],
});
