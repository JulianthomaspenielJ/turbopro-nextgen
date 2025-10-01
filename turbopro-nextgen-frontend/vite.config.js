import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  build: {
    outDir: 'aiturbobuild', // Set output folder to aiturbobuild 
  },
})
