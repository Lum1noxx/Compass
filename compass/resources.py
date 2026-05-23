from import_export import resources, widgets, fields
from .models import *
from import_export.widgets import ForeignKeyWidget, ManyToManyWidget

#for import/export of data in admin page, using django-import-export
class NodeResource(resources.ModelResource):
    class Meta:
        model = Node
        import_id_fields = ('name',)
        fields = ('name', 'lat', 'lng', 'floor')

class EdgeResource(resources.ModelResource):
    start = fields.Field(
        column_name='start',
        attribute='start',
        widget=ForeignKeyWidget(Node, 'name')
    )
    end = fields.Field(
        column_name='end',
        attribute='end',
        widget=ForeignKeyWidget(Node, 'name')
    )
    class Meta:
        model = Edge
        import_id_fields = ('type', 'start', 'end')
        fields = ('type', 'start', 'end', 'sheltered', 'stairs', 'duration')


class DestinationResource(resources.ModelResource):
    nodes = fields.Field(
        column_name='nodes',
        attribute='nodes',
        widget=ManyToManyWidget(Node, field='name', separator=',')
    )
    class Meta:
        model = Destination
        import_id_fields = ('name',)
        fields = ('name', 'lat', 'lng', 'floor', 'nodes')
