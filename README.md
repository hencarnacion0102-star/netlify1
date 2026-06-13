# AccesoPRO — Sistema de Control de Acceso

Sistema completo de control de asistencia de empleados con ponche por PIN.

## Estructura del proyecto

```
accesopro/
├── backend/          → API REST (Node.js + Express + Supabase)
├── frontend/         → App HTML (un solo archivo)
└── docs/
    ├── supabase_schema.sql   → Ejecutar en Supabase SQL Editor
    └── GUIA_DESPLIEGUE.md    → Pasos completos de despliegue
```

## Pasos de despliegue

1. **Supabase** — Ejecuta `docs/supabase_schema.sql` en el SQL Editor
2. **Railway** — Sube la carpeta `backend/` y configura las variables de entorno
3. **Vercel** — Sube la carpeta `frontend/` con las URLs configuradas

## Stack tecnológico

- **Frontend**: HTML + CSS + JavaScript vanilla + jsPDF + Supabase Realtime
- **Backend**: Node.js + Express + JWT + bcryptjs
- **Base de datos**: PostgreSQL via Supabase
- **Tiempo real**: Supabase Realtime (WebSockets)

## Credenciales por defecto
- Usuario admin: `admin`
- Contraseña: `admin123`
