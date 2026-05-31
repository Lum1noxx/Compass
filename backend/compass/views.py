from .serializers import *
from rest_framework.decorators import api_view
from rest_framework import status
from rest_framework.response import Response
from .models import *
import heapq
import math

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

    path = a_star_search(list(start_nodes), list(end_nodes))
    if path is None:
        return Response({'error': 'No path found'}, status=status.HTTP_404_NOT_FOUND)
    if len(path) == 0:
        return Response({'error': 'You are in the building'}, status=status.HTTP_404_NOT_FOUND)

    edgeSerializer = EdgeSerializer(path, many=True)
    return Response({'edges': edgeSerializer.data})


# a star algorithm helpers
def euclidean_distance(node1, node2):
    return math.hypot(node1.lat - node2.lat, node1.lng - node2.lng)

# use a star algorithm
# for start and end nodes, create a super node that is connected to all start nodes and end nodes with 0 weight edges
def a_star_search(start_nodes, end_nodes):
    if not start_nodes or not end_nodes:
        return None

    # create super nodes for start and end
    start_lat = sum(node.lat for node in start_nodes) / len(start_nodes)
    start_lng = sum(node.lng for node in start_nodes) / len(start_nodes)
    end_lat = sum(node.lat for node in end_nodes) / len(end_nodes)
    end_lng = sum(node.lng for node in end_nodes) / len(end_nodes)

    super_start = Node(name='super_start', lat=start_lat, lng=start_lng, floor=0)
    super_end = Node(name='super_end', lat=end_lat, lng=end_lng , floor=0)
    super_start.save()

    temp_edges = []
    try:
        # create temporary edges and adjacency rows from the super start to all start nodes
        for node in start_nodes:
            edge = Edge(type='super_edge', start=super_start, end=node, sheltered=True, stairs=False, weight=0.0, unit='metres', duration=0.0)
            edge.save()
            temp_edges.append(edge)
            AdjacencyList.objects.create(node=super_start, adjacent_node=node, edge=edge)

        # a star initialization
        open_set = [(0, super_start.pk, super_start)]
        came_from = {}
        g_score = {super_start: 0}
        f_score = {super_start: euclidean_distance(super_start, super_end)}
        open_set_hash = {super_start}

        # run a star algorithm from super start to super end
        while open_set:
            current = heapq.heappop(open_set)[2]
            open_set_hash.remove(current)

            # end condition: if current node is one of the end nodes, reconstruct path and return
            if current in end_nodes:
                path = []
                while current in came_from:
                    prev, edge = came_from[current]
                    if edge.type != 'super_edge':
                        path.append(edge)
                    current = prev
                path.reverse()
                return path

            # get neighbors of current node
            neighbors = AdjacencyList.objects.filter(node=current)
            for neighbor in neighbors:
                tentative_g_score = g_score[current] + neighbor.edge.duration
                if neighbor.adjacent_node not in g_score or tentative_g_score < g_score[neighbor.adjacent_node]:
                    came_from[neighbor.adjacent_node] = (current, neighbor.edge)
                    g_score[neighbor.adjacent_node] = tentative_g_score
                    f_score[neighbor.adjacent_node] = tentative_g_score + euclidean_distance(neighbor.adjacent_node, super_end)
                    if neighbor.adjacent_node not in open_set_hash:
                        heapq.heappush(open_set, (f_score[neighbor.adjacent_node], neighbor.adjacent_node.pk, neighbor.adjacent_node))
                        open_set_hash.add(neighbor.adjacent_node)

        return None
    finally:
        super_start.delete()