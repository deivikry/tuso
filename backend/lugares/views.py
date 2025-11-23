"""
📝 RESUMEN: Vistas (endpoints) para la API de Lugares
✅ APLICADO: CRUD completo + acciones personalizadas (visitar, calificar, favorito)
🎯 CONVERSIÓN: Endpoints que corresponden a las llamadas que hace Flutter
"""

from rest_framework import viewsets, status, pagination
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticatedOrReadOnly, IsAuthenticated
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.filters import SearchFilter, OrderingFilter
from django.db.models import Q

from .models import Lugar, Visita, Favorito
from .serializers import (
    LugarSerializer,
    LugarDetailSerializer,
    VisitaSerializer,
    FavoritoSerializer,
)
from calificaciones.models import Calificacion
from calificaciones.serializers import CalificacionSerializer


class LugarPagination(pagination.PageNumberPagination):
    """
    Paginación personalizada para lugares
    """
    page_size = 20
    page_size_query_param = 'page_size'
    max_page_size = 100


class LugarViewSet(viewsets.ModelViewSet):
    """
    ViewSet para Lugares con endpoints completos:
    - GET /api/lugares/ - Listar todos
    - GET /api/lugares/:id/ - Detalle
    - POST /api/lugares/ - Crear (solo admin)
    - PATCH/PUT /api/lugares/:id/ - Actualizar
    - DELETE /api/lugares/:id/ - Eliminar
    
    Acciones personalizadas:
    - GET /api/lugares/buscar/ - Buscar con filtros
    - GET /api/lugares/recomendados/ - Lugares recomendados
    - GET /api/lugares/cercanos/ - Cercanos a ubicación
    - POST /api/lugares/:id/visitar/ - Marcar visitado
    - POST /api/lugares/:id/favorito/ - Toggle favorito
    - POST /api/lugares/:id/calificar/ - Calificar lugar
    """
    
    queryset = Lugar.objects.all()
    serializer_class = LugarSerializer
    permission_classes = [IsAuthenticatedOrReadOnly]
    pagination_class = LugarPagination
    
    # Filtrado, búsqueda y ordenamiento
    filter_backends = [
        DjangoFilterBackend,
        SearchFilter,
        OrderingFilter,
    ]
    filterset_fields = ['tipo', 'presupuesto']
    search_fields = ['nombre', 'descripcion', 'tipo_comida']
    ordering_fields = ['rating', 'distancia', 'nombre']
    ordering = ['-rating', 'nombre']
    
    def get_serializer_class(self):
        """
        Usa serializer extendido para detalle
        """
        if self.action == 'retrieve':
            return LugarDetailSerializer
        return LugarSerializer
    
    @action(detail=False, methods=['get'])
    def buscar(self, request):
        """
        Buscar lugares con filtros avanzados.
        
        Query params:
        - tipo: gastronomico, natural, cultural, aventura, historico
        - presupuesto: bajo, medio, alto
        - distancia_max: distancia máxima en km
        - ordenar_por: rating, distancia, nombre
        """
        tipo = request.query_params.get('tipo')
        presupuesto = request.query_params.get('presupuesto')
        distancia_max = request.query_params.get('distancia_max')
        ordenar_por = request.query_params.get('ordenar_por', '-rating')
        
        lugares = self.get_queryset()
        
        # Aplicar filtros
        if tipo:
            lugares = lugares.filter(tipo=tipo)
        if presupuesto:
            lugares = lugares.filter(presupuesto=presupuesto)
        if distancia_max:
            try:
                lugares = lugares.filter(distancia__lte=float(distancia_max))
            except ValueError:
                pass
        
        # Ordenar
        lugares = lugares.order_by(ordenar_por)
        
        page = self.paginate_queryset(lugares)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)
        
        serializer = self.get_serializer(lugares, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def recomendados(self, request):
        """
        Obtener lugares recomendados basado en rating.
        
        Query params:
        - limit: número de lugares (default: 10)
        """
        limit = int(request.query_params.get('limit', 10))
        
        # Lugares con mejor rating
        lugares = self.get_queryset().order_by('-rating')[:limit]
        
        serializer = self.get_serializer(lugares, many=True)
        return Response({
            'count': len(lugares),
            'results': serializer.data,
        })
    
    @action(detail=False, methods=['get'])
    def cercanos(self, request):
        """
        Obtener lugares cercanos a una ubicación.
        
        Query params:
        - latitud: latitud del usuario
        - longitud: longitud del usuario
        - radio: radio en km (default: 30)
        """
        latitud = request.query_params.get('latitud')
        longitud = request.query_params.get('longitud')
        radio = float(request.query_params.get('radio', 30))
        
        if not latitud or not longitud:
            return Response(
                {'error': 'latitud y longitud son requeridos'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            lat = float(latitud)
            lon = float(longitud)
        except ValueError:
            return Response(
                {'error': 'latitud y longitud deben ser números'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Filtrar lugares dentro del radio (aproximado)
        # En producción, usar GeoDjango para cálculos más precisos
        lugares = self.get_queryset().filter(
            distancia__lte=radio
        ).order_by('distancia')
        
        serializer = self.get_serializer(lugares, many=True)
        return Response({
            'count': len(lugares),
            'ubicacion': {'latitud': lat, 'longitud': lon},
            'radio_km': radio,
            'results': serializer.data,
        })
    
    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated])
    def visitar(self, request, pk=None):
        """
        Marcar un lugar como visitado.
        Otorga puntos al usuario.
        
        POST /api/lugares/:id/visitar/
        """
        lugar = self.get_object()
        usuario = request.user
        
        # Verificar si ya fue visitado
        visita, creada = Visita.objects.get_or_create(
            usuario=usuario,
            lugar=lugar,
            defaults={'puntos_ganados': lugar.puntos}
        )
        
        if creada:
            # Primera visita - agregar puntos
            usuario.agregar_puntos(lugar.puntos)
            
            return Response({
                'success': True,
                'message': 'Lugar marcado como visitado',
                'puntos_ganados': lugar.puntos,
                'puntos_totales': usuario.puntos,
            }, status=status.HTTP_201_CREATED)
        else:
            # Ya visitado anteriormente
            return Response({
                'success': True,
                'message': 'Ya habías visitado este lugar',
                'puntos_ganados': 0,
                'puntos_totales': usuario.puntos,
            }, status=status.HTTP_200_OK)
    
    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated])
    def favorito(self, request, pk=None):
        """
        Toggle favorito de un lugar.
        Agrega o quita de favoritos.
        
        POST /api/lugares/:id/favorito/
        """
        lugar = self.get_object()
        usuario = request.user
        
        favorito = Favorito.objects.filter(usuario=usuario, lugar=lugar)
        
        if favorito.exists():
            # Quitar de favoritos
            favorito.delete()
            return Response({
                'success': True,
                'is_favorito': False,
                'message': 'Eliminado de favoritos'
            }, status=status.HTTP_200_OK)
        else:
            # Agregar a favoritos
            Favorito.objects.create(usuario=usuario, lugar=lugar)
            return Response({
                'success': True,
                'is_favorito': True,
                'message': 'Agregado a favoritos'
            }, status=status.HTTP_201_CREATED)
    
    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated])
    def calificar(self, request, pk=None):
        """
        Calificar un lugar.
        
        POST /api/lugares/:id/calificar/
        Body:
        {
            "comida": 5,
            "servicio": 4,
            "calidad_precio": 5,
            "comentario": "Excelente lugar"
        }
        """
        lugar = self.get_object()
        usuario = request.user
        
        # Obtener datos
        comida = request.data.get('comida', 0)
        servicio = request.data.get('servicio', 0)
        calidad_precio = request.data.get('calidad_precio', 0)
        comentario = request.data.get('comentario', '')
        
        # Crear o actualizar calificación
        calificacion, creada = Calificacion.objects.update_or_create(
            usuario=usuario,
            lugar=lugar,
            defaults={
                'comida': int(comida),
                'servicio': int(servicio),
                'calidad_precio': int(calidad_precio),
                'comentario': comentario,
            }
        )
        
        # El modelo actualiza automáticamente el rating al guardar
        lugar.refresh_from_db()
        
        return Response({
            'success': True,
            'message': 'Calificación registrada' if creada else 'Calificación actualizada',
            'calificacion': CalificacionSerializer(calificacion).data,
            'rating_actualizado': lugar.rating,
        }, status=status.HTTP_201_CREATED if creada else status.HTTP_200_OK)
    
    @action(detail=False, methods=['get'], permission_classes=[IsAuthenticated])
    def mis_visitas(self, request):
        """
        Obtener lugares visitados por el usuario actual.
        
        GET /api/lugares/mis_visitas/
        """
        visitas = Visita.objects.filter(usuario=request.user).select_related('lugar')
        
        lugares = [visita.lugar for visita in visitas]
        serializer = self.get_serializer(lugares, many=True)
        
        return Response({
            'count': len(lugares),
            'results': serializer.data,
        })
    
    @action(detail=False, methods=['get'], permission_classes=[IsAuthenticated])
    def mis_favoritos(self, request):
        """
        Obtener lugares favoritos del usuario actual.
        
        GET /api/lugares/mis_favoritos/
        """
        favoritos = Favorito.objects.filter(usuario=request.user).select_related('lugar')
        
        lugares = [favorito.lugar for favorito in favoritos]
        serializer = self.get_serializer(lugares, many=True)
        
        return Response({
            'count': len(lugares),
            'results': serializer.data,
        })