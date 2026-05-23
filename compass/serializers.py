from rest_framework import serializers
from .models import *

# Serializer to output to json format for the frontend to use
class NodeSerializer(serializers.ModelSerializer):
    class Meta:
        model = Node
        fields = ['name',]

class EdgeSerializer(serializers.ModelSerializer):
    start = NodeSerializer()
    end = NodeSerializer()
    class Meta:
        model = Edge
        fields = ['type', 'start', 'end', 'sheltered', 'stairs', 'duration']