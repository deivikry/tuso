# 🐍 TUSO Backend - Guía de Configuración Django REST

Esta guía te ayudará a configurar el backend Django REST API para la app TUSO Flutter.

## 📋 Requisitos

- Python 3.8+
- PostgreSQL 12+ (recomendado) o SQLite
- pip
- virtualenv

## 🚀 Setup Inicial

### 1. Crear Proyecto Django

```bash
# Crear directorio del proyecto
mkdir tuso-backend
cd tuso-backend

# Crear entorno virtual
python -m venv venv
source venv/bin/activate  # En Windows: venv\Scripts\activate

# Instalar Django y dependencias
pip install django djangorestframework
pip install djangorestframework-simplejwt
pip install django-cors-headers
pip install pillow
pip install django-filter
pip install psycopg2-binary  # Para PostgreSQL

# Crear proyecto
django-admin startproject tuso_api .

# Crear apps
python manage.py startapp usuarios
python manage.py startapp lugares
python manage.py startapp posts
python manage.py startapp calificaciones
```

### 2. Configurar `settings.py`

```python
# tuso_api/settings.py

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    
    # Third party
    'rest_framework',
    'rest_framework_simplejwt',
    'corsheaders',
    'django_filters',
    
    # Local apps
    'usuarios',
    'lugares',
    'posts',
    'calificaciones',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'corsheaders.middleware.CorsMiddleware',  # CORS
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

# CORS Configuration
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",  # React dev
    "http://localhost:8080",  # Flutter web
]

# En desarrollo, puedes usar:
# CORS_ALLOW_ALL_ORIGINS = True

# REST Framework Configuration
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ),
    'DEFAULT_PERMISSION_CLASSES': (
        'rest_framework.permissions.IsAuthenticatedOrReadOnly',
    ),
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20,
    'DEFAULT_FILTER_BACKENDS': [
        'django_filters.rest_framework.DjangoFilterBackend',
        'rest_framework.filters.SearchFilter',
        'rest_framework.filters.OrderingFilter',
    ],
}

# JWT Configuration
from datetime import timedelta

SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(days=1),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=7),
    'ROTATE_REFRESH_TOKENS': True,
}

# Media Files
MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'

# Database (PostgreSQL recomendado)
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'tuso_db',
        'USER': 'tuso_user',
        'PASSWORD': 'tu_password',
        'HOST': 'localhost',
        'PORT': '5432',
    }
}

# O SQLite para desarrollo
# DATABASES = {
#     'default': {
#         'ENGINE': 'django.db.backends.sqlite3',
#         'NAME': BASE_DIR / 'db.sqlite3',
#     }
# }
```

## 📊 Modelos de Base de Datos

### Usuario (usuarios/models.py)

```python
from django.contrib.auth.models import AbstractUser
from django.db import models

class Usuario(AbstractUser):
    telefono = models.CharField(max_length=20, blank=True, null=True)
    avatar = models.ImageField(upload_to='avatars/', blank=True, null=True)
    puntos = models.IntegerField(default=0)
    fecha_registro = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'usuarios'
        verbose_name = 'Usuario'
        verbose_name_plural = 'Usuarios'
    
    def __str__(self):
        return self.username
```

### Lugar (lugares/models.py)

```python
from django.db import models
from usuarios.models import Usuario

class Lugar(models.Model):
    TIPO_CHOICES = [
        ('gastronomico', 'Gastronómico'),
        ('natural', 'Natural'),
        ('cultural', 'Cultural'),
        ('aventura', 'Aventura'),
        ('historico', 'Histórico'),
    ]
    
    PRESUPUESTO_CHOICES = [
        ('bajo', 'Bajo'),
        ('medio', 'Medio'),
        ('alto', 'Alto'),
    ]
    
    nombre = models.CharField(max_length=200)
    tipo = models.CharField(max_length=20, choices=TIPO_CHOICES)
    descripcion = models.TextField()
    presupuesto = models.CharField(max_length=10, choices=PRESUPUESTO_CHOICES)
    distancia = models.FloatField(help_text='Distancia en km desde el centro')
    imagen = models.URLField()
    puntos = models.IntegerField(default=10)
    rating = models.FloatField(default=0.0)
    
    # Geolocalización
    latitud = models.FloatField(null=True, blank=True)
    longitud = models.FloatField(null=True, blank=True)
    
    # Detalles específicos
    tipo_comida = models.CharField(max_length=100, blank=True)
    comidas = models.CharField(max_length=100, blank=True)
    
    fecha_creacion = models.DateTimeField(auto_now_add=True)
    fecha_actualizacion = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'lugares'
        verbose_name = 'Lugar'
        verbose_name_plural = 'Lugares'
        ordering = ['-rating', 'nombre']
    
    def __str__(self):
        return self.nombre
```

### Calificación (calificaciones/models.py)

```python
from django.db import models
from django.core.validators import MinValueValidator, MaxValueValidator
from usuarios.models import Usuario
from lugares.models import Lugar

class Calificacion(models.Model):
    usuario = models.ForeignKey(Usuario, on_delete=models.CASCADE)
    lugar = models.ForeignKey(Lugar, on_delete=models.CASCADE, related_name='calificaciones')
    
    comida = models.IntegerField(
        validators=[MinValueValidator(0), MaxValueValidator(5)],
        default=0
    )
    servicio = models.IntegerField(
        validators=[MinValueValidator(0), MaxValueValidator(5)],
        default=0
    )
    calidad_precio = models.IntegerField(
        validators=[MinValueValidator(0), MaxValueValidator(5)],
        default=0
    )
    comentario = models.TextField(blank=True)
    
    fecha_creacion = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'calificaciones'
        unique_together = ['usuario', 'lugar']
        verbose_name = 'Calificación'
        verbose_name_plural = 'Calificaciones'
    
    def __str__(self):
        return f'{self.usuario.username} - {self.lugar.nombre}'
```

### Visita (lugares/models.py)

```python
class Visita(models.Model):
    usuario = models.ForeignKey(Usuario, on_delete=models.CASCADE)
    lugar = models.ForeignKey(Lugar, on_delete=models.CASCADE, related_name='visitas')
    fecha_visita = models.DateTimeField(auto_now_add=True)
    puntos_ganados = models.IntegerField(default=0)
    
    class Meta:
        db_table = 'visitas'
        unique_together = ['usuario', 'lugar']
        verbose_name = 'Visita'
        verbose_name_plural = 'Visitas'
        ordering = ['-fecha_visita']
    
    def __str__(self):
        return f'{self.usuario.username} visitó {self.lugar.nombre}'
```

### Favorito (lugares/models.py)

```python
class Favorito(models.Model):
    usuario = models.ForeignKey(Usuario, on_delete=models.CASCADE)
    lugar = models.ForeignKey(Lugar, on_delete=models.CASCADE)
    fecha_agregado = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'favoritos'
        unique_together = ['usuario', 'lugar']
        verbose_name = 'Favorito'
        verbose_name_plural = 'Favoritos'
    
    def __str__(self):
        return f'{self.usuario.username} - {self.lugar.nombre}'
```

### Post (posts/models.py)

```python
from django.db import models
from usuarios.models import Usuario
from lugares.models import Lugar

class Post(models.Model):
    usuario = models.ForeignKey(Usuario, on_delete=models.CASCADE)
    lugar = models.ForeignKey(Lugar, on_delete=models.SET_NULL, null=True, blank=True)
    imagen = models.ImageField(upload_to='posts/')
    descripcion = models.TextField()
    likes = models.ManyToManyField(Usuario, related_name='posts_liked', blank=True)
    
    fecha_creacion = models.DateTimeField(auto_now_add=True)
    fecha_actualizacion = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'posts'
        verbose_name = 'Post'
        verbose_name_plural = 'Posts'
        ordering = ['-fecha_creacion']
    
    def __str__(self):
        return f'Post de {self.usuario.username}'
    
    @property
    def total_likes(self):
        return self.likes.count()
```

## 🔐 Serializers

### Lugar Serializer (lugares/serializers.py)

```python
from rest_framework import serializers
from .models import Lugar, Visita, Favorito
from calificaciones.models import Calificacion

class CalificacionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Calificacion
        fields = ['comida', 'servicio', 'calidad_precio']

class LugarSerializer(serializers.ModelSerializer):
    detalles = serializers.SerializerMethodField()
    
    class Meta:
        model = Lugar
        fields = [
            'id', 'nombre', 'tipo', 'descripcion', 'presupuesto',
            'distancia', 'imagen', 'puntos', 'rating', 'detalles',
            'latitud', 'longitud'
        ]
    
    def get_detalles(self, obj):
        # Obtener calificación promedio
        calificaciones = obj.calificaciones.all()
        if calificaciones.exists():
            comida_avg = calificaciones.aggregate(models.Avg('comida'))['comida__avg'] or 0
            servicio_avg = calificaciones.aggregate(models.Avg('servicio'))['servicio__avg'] or 0
            calidad_avg = calificaciones.aggregate(models.Avg('calidad_precio'))['calidad_precio__avg'] or 0
        else:
            comida_avg = servicio_avg = calidad_avg = 0
        
        return {
            'tipoComida': obj.tipo_comida,
            'comidas': obj.comidas,
            'calificaciones': {
                'comida': round(comida_avg),
                'servicio': round(servicio_avg),
                'calidadPrecio': round(calidad_avg),
            }
        }
```

## 🛣️ Views y URLs

### Lugares Views (lugares/views.py)

```python
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticatedOrReadOnly
from django_filters.rest_framework import DjangoFilterBackend
from .models import Lugar, Visita, Favorito
from .serializers import LugarSerializer

class LugarViewSet(viewsets.ModelViewSet):
    queryset = Lugar.objects.all()
    serializer_class = LugarSerializer
    permission_classes = [IsAuthenticatedOrReadOnly]
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['tipo', 'presupuesto']
    
    @action(detail=False, methods=['get'])
    def buscar(self, request):
        """Buscar lugares con filtros"""
        tipo = request.query_params.get('tipo')
        presupuesto = request.query_params.get('presupuesto')
        distancia_max = request.query_params.get('distancia_max')
        
        lugares = self.get_queryset()
        
        if tipo:
            lugares = lugares.filter(tipo=tipo)
        if presupuesto:
            lugares = lugares.filter(presupuesto=presupuesto)
        if distancia_max:
            lugares = lugares.filter(distancia__lte=float(distancia_max))
        
        serializer = self.get_serializer(lugares, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def recomendados(self, request):
        """Obtener lugares recomendados"""
        limit = int(request.query_params.get('limit', 10))
        lugares = self.get_queryset().order_by('-rating', '?')[:limit]
        serializer = self.get_serializer(lugares, many=True)
        return Response(serializer.data)
    
    @action(detail=True, methods=['post'])
    def visitar(self, request, pk=None):
        """Marcar lugar como visitado"""
        lugar = self.get_object()
        usuario = request.user
        
        visita, created = Visita.objects.get_or_create(
            usuario=usuario,
            lugar=lugar,
            defaults={'puntos_ganados': lugar.puntos}
        )
        
        if created:
            # Agregar puntos al usuario
            usuario.puntos += lugar.puntos
            usuario.save()
            
            return Response({
                'message': 'Lugar marcado como visitado',
                'puntos_ganados': lugar.puntos,
                'puntos_totales': usuario.puntos
            }, status=status.HTTP_201_CREATED)
        else:
            return Response({
                'message': 'Ya has visitado este lugar'
            }, status=status.HTTP_200_OK)
    
    @action(detail=True, methods=['post'])
    def favorito(self, request, pk=None):
        """Toggle favorito"""
        lugar = self.get_object()
        usuario = request.user
        
        favorito = Favorito.objects.filter(usuario=usuario, lugar=lugar)
        
        if favorito.exists():
            favorito.delete()
            return Response({
                'is_favorito': False,
                'message': 'Eliminado de favoritos'
            })
        else:
            Favorito.objects.create(usuario=usuario, lugar=lugar)
            return Response({
                'is_favorito': True,
                'message': 'Agregado a favoritos'
            }, status=status.HTTP_201_CREATED)
    
    @action(detail=True, methods=['post'])
    def calificar(self, request, pk=None):
        """Calificar un lugar"""
        from calificaciones.models import Calificacion
        
        lugar = self.get_object()
        usuario = request.user
        
        calificacion, created = Calificacion.objects.update_or_create(
            usuario=usuario,
            lugar=lugar,
            defaults={
                'comida': request.data.get('comida', 0),
                'servicio': request.data.get('servicio', 0),
                'calidad_precio': request.data.get('calidad_precio', 0),
                'comentario': request.data.get('comentario', '')
            }
        )
        
        # Actualizar rating promedio del lugar
        calificaciones = lugar.calificaciones.all()
        if calificaciones.exists():
            from django.db.models import Avg
            promedio = (
                calificaciones.aggregate(Avg('comida'))['comida__avg'] +
                calificaciones.aggregate(Avg('servicio'))['servicio__avg'] +
                calificaciones.aggregate(Avg('calidad_precio'))['calidad_precio__avg']
            ) / 3
            lugar.rating = round(promedio, 1)
            lugar.save()
        
        return Response({
            'message': 'Calificación registrada',
            'rating_actualizado': lugar.rating
        }, status=status.HTTP_201_CREATED if created else status.HTTP_200_OK)
```

### URLs (tuso_api/urls.py)

```python
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
    TokenVerifyView,
)
from lugares.views import LugarViewSet
from usuarios.views import UsuarioViewSet
from posts.views import PostViewSet

router = DefaultRouter()
router.register(r'lugares', LugarViewSet, basename='lugar')
router.register(r'usuarios', UsuarioViewSet, basename='usuario')
router.register(r'posts', PostViewSet, basename='post')

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include(router.urls)),
    
    # JWT Authentication
    path('api/auth/login/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/auth/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('api/auth/verify/', TokenVerifyView.as_view(), name='token_verify'),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
```

## 🗄️ Migraciones

```bash
# Crear migraciones
python manage.py makemigrations

# Aplicar migraciones
python manage.py migrate

# Crear superusuario
python manage.py createsuperuser
```

## 📝 Admin Panel

### Lugares Admin (lugares/admin.py)

```python
from django.contrib import admin
from .models import Lugar, Visita, Favorito

@admin.register(Lugar)
class LugarAdmin(admin.ModelAdmin):
    list_display = ['nombre', 'tipo', 'presupuesto', 'rating', 'puntos']
    list_filter = ['tipo', 'presupuesto']
    search_fields = ['nombre', 'descripcion']
    ordering = ['-rating']

@admin.register(Visita)
class VisitaAdmin(admin.ModelAdmin):
    list_display = ['usuario', 'lugar', 'fecha_visita', 'puntos_ganados']
    list_filter = ['fecha_visita']
    search_fields = ['usuario__username', 'lugar__nombre']

@admin.register(Favorito)
class FavoritoAdmin(admin.ModelAdmin):
    list_display = ['usuario', 'lugar', 'fecha_agregado']
    list_filter = ['fecha_agregado']
    search_fields = ['usuario__username', 'lugar__nombre']
```

## 🌱 Datos Iniciales (Seed)

Crear archivo `lugares/management/commands/seed_lugares.py`:

```python
from django.core.management.base import BaseCommand
from lugares.models import Lugar

class Command(BaseCommand):
    help = 'Seed lugares data'

    def handle(self, *args, **kwargs):
        lugares_data = [
            {
                'nombre': 'Restaurante Don Pedro Típico',
                'tipo': 'gastronomico',
                'descripcion': 'Auténtica comida típica tolimense en un ambiente tradicional y acogedor.',
                'presupuesto': 'medio',
                'distancia': 3,
                'imagen': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800',
                'puntos': 12,
                'rating': 4.5,
                'tipo_comida': 'Típica colombiana',
                'comidas': 'Almuerzo, cena',
                'latitud': 4.4389,
                'longitud': -75.2322,
            },
            {
                'nombre': 'Cañón del Combeima',
                'tipo': 'natural',
                'descripcion': 'Hermoso cañón con ríos cristalinos y senderos ecológicos.',
                'presupuesto': 'bajo',
                'distancia': 15,
                'imagen': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
                'puntos': 15,
                'rating': 4.8,
                'tipo_comida': 'N/A',
                'comidas': 'N/A',
                'latitud': 4.5389,
                'longitud': -75.3322,
            },
        ]
        
        for data in lugares_data:
            lugar, created = Lugar.objects.get_or_create(
                nombre=data['nombre'],
                defaults=data
            )
            if created:
                self.stdout.write(
                    self.style.SUCCESS(f'Lugar creado: {lugar.nombre}')
                )
```

Ejecutar:
```bash
python manage.py seed_lugares
```

## 🚀 Ejecutar Servidor

```bash
# Modo desarrollo
python manage.py runserver

# Especificar puerto
python manage.py runserver 8000

# Acceder desde otros dispositivos (Flutter en dispositivo físico)
python manage.py runserver 0.0.0.0:8000
```

## 🧪 Testing

### Test Example (lugares/tests.py)

```python
from django.test import TestCase
from django.contrib.auth import get_user_model
from rest_framework.test import APIClient
from .models import Lugar

User = get_user_model()

class LugarTestCase(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            username='testuser',
            password='testpass123'
        )
        self.lugar = Lugar.objects.create(
            nombre='Test Lugar',
            tipo='natural',
            descripcion='Test description',
            presupuesto='medio',
            distancia=10,
            imagen='http://test.com/image.jpg',
            puntos=10,
            rating=4.5
        )
    
    def test_listar_lugares(self):
        response = self.client.get('/api/lugares/')
        self.assertEqual(response.status_code, 200)
    
    def test_marcar_visitado(self):
        self.client.force_authenticate(user=self.user)
        response = self.client.post(f'/api/lugares/{self.lugar.id}/visitar/')
        self.assertEqual(response.status_code, 201)
        self.user.refresh_from_db()
        self.assertEqual(self.user.puntos, 10)
```

Ejecutar tests:
```bash
python manage.py test
```

## 📦 Deployment

### Requirements.txt

```txt
Django==4.2.7
djangorestframework==3.14.0
djangorestframework-simplejwt==5.3.0
django-cors-headers==4.3.0
django-filter==23.3
pillow==10.1.0
psycopg2-binary==2.9.9
gunicorn==21.2.0
python-decouple==3.8
whitenoise==6.6.0
```

### Producción (con Gunicorn)

```bash
# Instalar gunicorn
pip install gunicorn

# Recolectar archivos estáticos
python manage.py collectstatic

# Ejecutar con gunicorn
gunicorn tuso_api.wsgi:application --bind 0.0.0.0:8000
```

### Docker (Opcional)

```dockerfile
# Dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["gunicorn", "tuso_api.wsgi:application", "--bind", "0.0.0.0:8000"]
```

```yaml
# docker-compose.yml
version: '3.8'

services:
  db:
    image: postgres:15
    environment:
      POSTGRES_DB: tuso_db
      POSTGRES_USER: tuso_user
      POSTGRES_PASSWORD: tuso_password
    volumes:
      - postgres_data:/var/lib/postgresql/data

  web:
    build: .
    command: gunicorn tuso_api.wsgi:application --bind 0.0.0.0:8000
    volumes:
      - .:/app
    ports:
      - "8000:8000"
    depends_on:
      - db
    environment:
      - DATABASE_URL=postgresql://tuso_user:tuso_password@db:5432/tuso_db

volumes:
  postgres_data:
```

## 🔒 Seguridad

### Variables de Entorno (.env)

```env
SECRET_KEY=tu-secret-key-muy-segura-aqui
DEBUG=False
ALLOWED_HOSTS=localhost,127.0.0.1,tu-dominio.com

DATABASE_URL=postgresql://usuario:password@localhost:5432/tuso_db

# CORS
CORS_ALLOWED_ORIGINS=https://tu-app.com
```

Usar `python-decouple`:

```python
# settings.py
from decouple import config

SECRET_KEY = config('SECRET_KEY')
DEBUG = config('DEBUG', default=False, cast=bool)
ALLOWED_HOSTS = config('ALLOWED_HOSTS', cast=lambda v: [s.strip() for s in v.split(',')])
```

## 📊 Endpoints Disponibles

```
GET    /api/lugares/                    # Listar lugares
GET    /api/lugares/:id/                # Detalle lugar
GET    /api/lugares/buscar/             # Buscar con filtros
GET    /api/lugares/recomendados/       # Recomendados
POST   /api/lugares/:id/visitar/        # Marcar visitado
POST   /api/lugares/:id/favorito/       # Toggle favorito
POST   /api/lugares/:id/calificar/      # Calificar lugar

POST   /api/auth/login/                 # Login (JWT)
POST   /api/auth/refresh/               # Refresh token
POST   /api/auth/verify/                # Verificar token

GET    /api/usuarios/perfil/            # Perfil usuario
PATCH  /api/usuarios/:id/               # Actualizar perfil

GET    /api/posts/                      # Listar posts
POST   /api/posts/                      # Crear post
POST   /api/posts/:id/like/             # Like post
```

## 🎯 Próximos Pasos

1. ✅ Implementar autenticación JWT
2. ✅ Crear endpoints CRUD completos
3. ⏳ Agregar sistema de notificaciones
4. ⏳ Implementar búsqueda geoespacial avanzada
5. ⏳ Agregar caché con Redis
6. ⏳ Implementar sistema de recomendaciones con ML
7. ⏳ Agregar WebSockets para chat en tiempo real

## 📚 Recursos

- [Django REST Framework Docs](https://www.django-rest-framework.org/)
- [Django JWT Docs](https://django-rest-framework-simplejwt.readthedocs.io/)
- [PostgreSQL Docs](https://www.postgresql.org/docs/)

---

**Nota**: Este backend está diseñado para integrarse perfectamente con la app Flutter TUSO. Todos los endpoints y estructuras de datos coinciden con los modelos de Flutter.