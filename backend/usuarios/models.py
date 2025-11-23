"""
📝 RESUMEN: Modelo de Usuario personalizado extendiendo AbstractUser de Django
✅ APLICADO: Sistema de autenticación con puntos de gamificación
🎯 CONVERSIÓN: Del modelo Usuario del React, adaptado para Django ORM
"""

from django.contrib.auth.models import AbstractUser
from django.db import models


class Usuario(AbstractUser):
    """
    Modelo personalizado de usuario que extiende AbstractUser.
    Incluye campos adicionales para gamificación y perfil.
    """
    
    # Campos adicionales
    telefono = models.CharField(
        max_length=20,
        blank=True,
        null=True,
        help_text="Número de teléfono del usuario"
    )
    
    avatar = models.ImageField(
        upload_to='avatars/',
        blank=True,
        null=True,
        help_text="Foto de perfil del usuario"
    )
    
    puntos = models.IntegerField(
        default=0,
        help_text="Puntos acumulados por visitas y actividades"
    )
    
    fecha_registro = models.DateTimeField(
        auto_now_add=True,
        help_text="Fecha en que se registró el usuario"
    )
    
    # Metadata
    class Meta:
        db_table = 'usuarios'
        verbose_name = 'Usuario'
        verbose_name_plural = 'Usuarios'
        ordering = ['-fecha_registro']
    
    def __str__(self):
        return f"{self.username} ({self.get_full_name()})"
    
    def agregar_puntos(self, cantidad):
        """
        Método para agregar puntos al usuario
        """
        self.puntos += cantidad
        self.save()
        return self.puntos
    
    def obtener_perfil_json(self):
        """
        Retorna el perfil del usuario en formato JSON
        """
        return {
            'id': self.id,
            'nombre': self.get_full_name() or self.username,
            'email': self.email,
            'telefono': self.telefono,
            'puntos': self.puntos,
            'fechaRegistro': self.fecha_registro.isoformat(),
        }