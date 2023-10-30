import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig({
    server: {
        proxy: {
            '/contact': 'http://0.0.0.0:9090/'
        },
    },
    plugins: [react()],
})
