# CORS Configuration para Flutter
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",      # React (si lo usas)
    "http://localhost:8080",      # Flutter Web
    "http://10.0.2.2:8000",       # Android Emulator
    "http://localhost:8000",      # iOS Simulator
]

# En desarrollo, puedes permitir todo:
CORS_ALLOW_ALL_ORIGINS = True  # ⚠️ Solo en desarrollo

# Permitir credenciales
CORS_ALLOW_CREDENTIALS = True