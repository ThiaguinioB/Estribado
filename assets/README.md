# NOTA SOBRE EL LOGO

Para que el PDF de Recetario funcione correctamente, necesitas colocar un archivo de imagen llamado `logo.jpg` en la carpeta `assets/`.

Si no tienes un logo todavía, puedes:
1. Crear uno y colocarlo en `assets/logo.jpg`
2. O comentar la sección del logo en el archivo `lib/features/recetario/data/datasources/recetario_remote_datasource.dart`

El código del PDF está preparado para funcionar con o sin logo, mostrando un texto alternativo si no se encuentra la imagen.
