"""
URL configuration for compass project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/6.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from compass import views

# adding url paths for api calls

urlpatterns = [
    path('admin/', admin.site.urls),
    path('datawizard/', include('data_wizard.urls')),
    path('nodes/', views.get_nodes),
    path('dest_coordinates/', views.get_dest_coordinates),
    path('node_coordinates/', views.get_node_coordinates),
    path('edges/', views.get_edges),
    path('shortest_path/', views.calculate_shortest_path),
]
