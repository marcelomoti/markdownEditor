import { defineConfig } from 'vite'
import { resolve } from 'path'

export default defineConfig({
  root: '.',
  base: './',
  build: {
    outDir: resolve(process.cwd(), '../assets/milkdown-dist'),
    emptyOutDir: true,
  },
})
