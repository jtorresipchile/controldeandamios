# Control Andamios SEPCO (Integral / Soinsa)

## Puesta en marcha (PowerShell)
```powershell
cd "C:\Users\joset\OneDrive\Escritorio\ControlAndamiosSoinsa"
# 1) Copia aquÃ­ pubspec.yaml, lib\ y sql\ de este proyecto
flutter create --org cl.civtek --project-name control_andamios_soinsa .
# (flutter create no pisa lib/ ni pubspec si ya los copiaste despuÃ©s; copia de nuevo si los sobrescribe)
flutter pub get
flutter run -d windows     # o -d chrome / un Android
```

## Base de datos externa (Supabase)
1. Crea proyecto en supabase.com. En Authentication > Providers > Email desactiva "Confirm email".
2. Ejecuta `sql/schema.sql` en SQL Editor y crea el primer admin (instrucciones al final del archivo).
3. Pega URL y anon key en `lib/config.dart`.

## GitHub
```powershell
git init
git add .
git commit -m "Version inicial"
git branch -M main
git remote add origin https://github.com/jtorresipchile/controldeandamios.git
git push -u origin main
```