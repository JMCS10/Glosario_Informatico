# 📘 Glosario Informático

Aplicación móvil desarrollada en **Flutter** para consultar, registrar y gestionar un glosario de términos informáticos.

---

## 🚀 Instalación

1. Clona el repositorio:
   ```bash
   git clone https://github.com/JMCS10/Glosario_Informatico.git
   ```

2. Entra en la carpeta del proyecto:
   ```bash
   cd Glosario_Informatico
   ```

3. Instala las dependencias:
   ```bash
   flutter pub get
   ```

4. Ejecuta la aplicación:
   ```bash
   flutter run
   ```

---

## 🧩 Tecnologías utilizadas
- **Flutter**
- **Dart**
- **Supabase** (Base de datos y backend)
- **Git / GitHub** (Control de versiones)

---

## 🤝 Guía de colaboración — Flujo de ramas Git

Para mantener el proyecto ordenado y evitar conflictos, seguimos el siguiente flujo de trabajo en equipo:

### 🔹 Ramas principales
- **`main`** → Rama estable / producción.  
  Solo se actualiza cuando todo en `developer` ha sido probado.
- **`developer`** → Rama base de desarrollo.  
  Aquí se integran todas las nuevas funcionalidades mediante Pull Requests.

### 🔹 Ramas de trabajo (features)
Cada integrante debe crear su rama personal **a partir de `developer`**, nunca desde `main`.

**Pasos para crear tu rama:**
```bash
git checkout developer
git pull origin developer
git checkout -b feature/nombre-descriptivo
git push -u origin feature/nombre-descriptivo
```

Ejemplo:
```bash
git checkout -b feature/id-dispositivo
```

### 🔹 Commits
Usamos mensajes de commit con el formato **[tipo]: descripción corta**

Ejemplos:
- `feat: registrar id de dispositivo con Supabase`
- `fix: corregir error al iniciar sesión`
- `refactor: reorganizar estructura de servicios`

### 🔹 Pull Requests (PR)
Cuando termines tu trabajo:

1. Asegúrate de estar en tu rama feature.
2. Sube tus últimos cambios:
   ```bash
   git add .
   git commit -m "feat: descripción corta"
   git push
   ```
3. Crea un **Pull Request desde tu rama → developer**.
4. Espera revisión antes de hacer merge.

### 🔹 Actualizar tu rama con los últimos cambios de developer
Si otro compañero ya subió código a `developer`, actualiza así:
```bash
git checkout feature/tu-rama
git fetch origin
git merge origin/developer
# o si prefieres historial limpio:
# git rebase origin/developer
```

---

### 💡 Reglas básicas
✅ No hacer commits directamente en `main`.  
✅ No hacer merges entre ramas de otros compañeros.  
✅ Siempre crear ramas desde `developer`.  
✅ Usar nombres en minúsculas y descriptivos (`feature/`, `fix/`, etc.).  
✅ Hacer PRs claros, con descripción del cambio.

---

### 👨‍💻 Equipo de desarrollo
| Integrante | Rol | Rama personal |
|-------------|------|----------------|
| Fidel | Services / BD | `feature/id-dispositivo` |
| Mijael| | |

---

### 📄 Licencia
Proyecto académico - Universidad Mayor de San Simón/ Materia de Programación Móvil.