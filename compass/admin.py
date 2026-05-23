from django.contrib import admin
from .models import *
from .resources import *
from import_export.admin import ImportExportModelAdmin

# Show models in admin page
@admin.register(Node)
class NodeAdmin(ImportExportModelAdmin):
    resource_class = NodeResource

@admin.register(Edge)
class EdgeAdmin(ImportExportModelAdmin):
    resource_class = EdgeResource

@admin.register(Destination)
class DestinationAdmin(ImportExportModelAdmin):
    resource_class = DestinationResource


