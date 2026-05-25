from rest_framework import serializers
from .models import *

# Serializer to output to json format for the frontend to use
class NodeSerializer(serializers.ModelSerializer):
    class Meta:
        model = Node
        fields = ['name', 'lat', 'lng', 'floor']

class EdgeSerializer(serializers.ModelSerializer):
    start = serializers.CharField(source='start.name')
    end = serializers.CharField(source='end.name')
    class Meta:
        model = Edge
        fields = ['type', 'start', 'end', 'sheltered', 'stairs', 'duration']

class DestSerializer(serializers.ModelSerializer):
    class Meta:
        model = Destination
        fields = ['name', 'lat', 'lng', 'floor']