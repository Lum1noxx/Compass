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
        widget=ForeignKeyWidget(Node, field = 'name')
    )
    end = fields.Field(
        column_name='end',
        attribute='end',
        widget=ForeignKeyWidget(Node, field = 'name')
    )
    class Meta:
        model = Edge
        import_id_fields = ('type', 'start', 'end')
        fields = ('type', 'start', 'end', 'sheltered', 'stairs', 'weight', 'unit')


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

class AdjacencyListResource(resources.ModelResource):
    node = fields.Field(
        column_name='node',
        attribute='node',
        widget=ForeignKeyWidget(Node, 'name')
    )
    adjacent_node = fields.Field(
        column_name='adjacent_node',
        attribute='adjacent_node',
        widget=ForeignKeyWidget(Node, 'name')
    )
    edge = fields.Field(
        column_name='edge',
        attribute='edge',
        widget=ForeignKeyWidget(Edge, 'type')
    )
    class Meta:
        model = AdjacencyList
        import_id_fields = ('node', 'adjacent_node', 'edge')
        fields = ('node', 'adjacent_node', 'edge')

class BusScheduleResource(resources.ModelResource):
    class Meta:
        model = BusSchedule
        import_id_fields = ('bus', 'day', 'from_time')
        fields = ('bus', 'day', 'from_time', 'to_time', 'waitAve')