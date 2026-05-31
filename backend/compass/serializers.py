from rest_framework import serializers
from .models import *

# Serializer to output to json format for the frontend to use
class NodeSerializer(serializers.ModelSerializer):
    
    def to_representation(self, instance):
        representation = super().to_representation(instance)
        representation['name'] = representation['name'].replace('_', ' ')
        return representation
    
    class Meta:
        model = Node
        fields = ['name', 'lat', 'lng', 'floor']

class EdgeSerializer(serializers.ModelSerializer):
    
    start = serializers.CharField(source='start.name')
    end = serializers.CharField(source='end.name')
    def to_representation(self, instance):
        representation = super().to_representation(instance)
        if representation['start']:
            representation['start'] = representation['start'].replace('_', ' ')
        if representation['end']:
            representation['end'] = representation['end'].replace('_', ' ')
        return representation
    
    class Meta:
        model = Edge
        fields = ['type', 'start', 'end', 'sheltered', 'stairs', 'duration']

class DestSerializer(serializers.ModelSerializer):

    def to_representation(self, instance):
        representation = super().to_representation(instance)
        representation['name'] = representation['name'].replace('_', ' ')
        return representation
    
    class Meta:
        model = Destination
        fields = ['name', 'lat', 'lng', 'floor']