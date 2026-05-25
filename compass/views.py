from .serializers import *
from rest_framework.decorators import api_view
from rest_framework import status
from rest_framework.response import Response
from .models import *

@api_view(['GET'])
def get_nodes(request):
    nodes = Node.objects.all()
    nodeSerializer = NodeSerializer(nodes, many=True)
    return Response(nodeSerializer.data)

@api_view(['GET'])
def get_edges(request):
    edges = Edge.objects.all()
    edgeSerializer = EdgeSerializer(edges, many=True)
    return Response(edgeSerializer.data)

@api_view(['GET'])
def get_dest_coordinates(request):
    names = request.GET.getlist('names')
    dests = []
    for name in names:
        name = name.replace('_', ' ')
        dest = Destination.objects.get(name=names[0])
        dests.append(dest)
    destSerializer = DestSerializer(dests, many=True)
    return Response({'destinations': destSerializer.data})

@api_view(['GET'])
def get_node_coordinates(request):
    names = request.GET.getlist('names')
    nodes = []
    for name in names:
        name = name.replace('_', ' ')
        node = Node.objects.get(name=name)
        nodes.append(node)
    nodeSerializer = NodeSerializer(nodes, many=True)
    return Response({'nodes': nodeSerializer.data})

@api_view(['GET'])
def calculate_shortest_path(request):
    start = request.GET.get('start') 
    end = request.GET.get('end')

    start = start.replace('_', ' ')
    end = end.replace('_', ' ')

    #find destinations in database
    try:
        start_dest = Destination.objects.get(name=start)
    except Destination.DoesNotExist:
        return Response({'error': f'Destination {start} not found'}, status=status.HTTP_404_NOT_FOUND)
    try:
        end_dest = Destination.objects.get(name=end)
    except Destination.DoesNotExist:
        return Response({'error': f'Destination {end} not found'}, status=status.HTTP_404_NOT_FOUND)
    
    # find the nearest nodes to the start and end destinations
    start_nodes = start_dest.nodes.all()
    end_nodes = end_dest.nodes.all()

    test_start = list(NodeSerializer(start_nodes, many=True).data)
    test_end = list(NodeSerializer(end_nodes, many=True).data)  
    return Response({'message': f'Start: {test_start}, End: {test_end}'})
    # use Dijkstra's algorithm
        # if end is multiple nodes, stop when we reach any of the end nodes
    # return the path in json format
        # serialize all edges, include start, end, type, sheltered, stairs, duration
    pass

