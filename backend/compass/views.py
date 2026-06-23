from .serializers import *
from rest_framework.decorators import api_view
from rest_framework import status
from rest_framework.response import Response
from .models import *
from .viewsAids import *

# Show all nodes and edges in db for testing
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

# Get corrdinates of a list of destinations/nodes for frontend to display on map
@api_view(['GET'])
def get_dest_coordinates(request):
    names = request.GET.getlist('names')
    dests = []
    for name in names:
        dest = Destination.objects.get(name=name)
        dests.append(dest)
    destSerializer = DestSerializer(dests, many=True)
    return Response({'destinations': destSerializer.data})

@api_view(['GET'])
def get_node_coordinates(request):
    names = request.GET.getlist('names')
    nodes = []
    for name in names:
        node = Node.objects.get(name=name)
        nodes.append(node)
    nodeSerializer = NodeSerializer(nodes, many=True)
    return Response({'nodes': nodeSerializer.data})


# Calculate shortest path between 2 destinations, return list of edges in the path
@api_view(['GET'])
def calculate_shortest_path(request):
    start = request.GET.get('start') 
    end = request.GET.get('end')

    #find destinations in db
    try:
        start_dest = Destination.objects.get(name=start)
    except Destination.DoesNotExist:
        return Response({'error': f'Destination {start} not found'}, status=status.HTTP_404_NOT_FOUND)
    try:
        end_dest = Destination.objects.get(name=end)
    except Destination.DoesNotExist:
        return Response({'error': f'Destination {end} not found'}, status=status.HTTP_404_NOT_FOUND)
    
    # get all nodes connected to start and end dests
    start_nodes = start_dest.nodes.all()
    end_nodes = end_dest.nodes.all()
    sheltered = request.GET.get('sheltered') == 'true'
    stairs = request.GET.get('stairs') == 'true'

    path = a_star_search(list(start_nodes), list(end_nodes), sheltered, stairs)
    if path is None:
        return Response({'error': 'No path found'}, status=status.HTTP_404_NOT_FOUND)
    if len(path) == 0:
        return Response({'error': 'You are in the building'}, status=status.HTTP_404_NOT_FOUND)

    edgeSerializer = EdgeSerializer(path, many=True)
    return Response({'edges': edgeSerializer.data})


@api_view(['GET'])
# Get nearby destinations given current location and floor, return list of destinations sorted by distance
def get_near_destinations(request):
    lat = float(request.GET.get('lat'))
    lng = float(request.GET.get('lng'))
    floor = None
    if request.GET.get('floor'):
        floor = int(request.GET.get('floor'))
    count = int(request.GET.get('count'))
    current_dest = Destination(name='current_location', lat=lat, lng=lng, floor= floor if floor is not None else 0)
    current_dest.save()
    
    nearby_dests = []
    for dest in Destination.objects.all():
        if floor is not None and dest.floor != floor:
            continue
        if dest.name == 'current_location':
            continue
        current_dest_db = Destination.objects.get(name='current_location')
        distance = haversine(current_dest_db, dest)
        nearby_dests.append((dest, distance))
    nearby_dests.sort(key=lambda x: x[1])
    nearby_dests = [dest[0] for dest in nearby_dests[:count]]
    destSerializer = DestSerializer(nearby_dests, many=True)
    current_dest.delete()
    return Response({'destinations': destSerializer.data})


# use current gps location to find shortest path
@api_view(['GET'])
def use_current_location(request):
    lat = float(request.GET.get('lat'))
    lng = float(request.GET.get('lng'))
    floor = None
    if request.GET.get('floor'):
        floor = int(request.GET.get('floor'))

    # create temp node for current location and check if end destination exists  
    current_node = Node(name='current_location', lat=lat, lng=lng, floor= floor if floor is not None else 1)
    current_node.save()
    end = request.GET.get('end')
    try:
        end_dest = Destination.objects.get(name=end)
    except Destination.DoesNotExist:
        return Response({'error': f'Destination {end} not found'}, status=status.HTTP_404_NOT_FOUND)
    
    #create edge from current location to top 3 nearest nodes on the same floor
    nearest_nodes = nearby_nodes(current_node, 3)
    temp_edges = []
    for node in nearest_nodes:
        edge = Edge(type='temp_edge', start=current_node, end=node, sheltered=True, stairs=False, weight=round(distance), unit='metres', duration=0.0)
        edge.save()
        temp_edges.append(edge)
        AdjacencyList.objects.create(node=current_node, adjacent_node=node, edge=edge)

    end_nodes = end_dest.nodes.all()
    sheltered = request.GET.get('sheltered') == 'true'
    stairs = request.GET.get('stairs') == 'true'

    # run a star algorithm
    path = a_star_search([current_node], list(end_nodes), sheltered, stairs)
    if path is None:
        return Response({'error': 'No path found'}, status=status.HTTP_404_NOT_FOUND)
    if len(path) == 0:
        return Response({'error': 'You are in the building'}, status=status.HTTP_404_NOT_FOUND)

    #delete current location node and temp edges
    current_node.delete()
    for edge in temp_edges:
        edge.delete()
    
    edgeSerializer = EdgeSerializer(path, many=True)
    return Response({'edges': edgeSerializer.data})



    