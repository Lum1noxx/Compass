from os import name

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
    shelterPref = int(request.GET.get('shelterPref')) 
    stairsPref = int(request.GET.get('stairsPref')) 

    path = a_star_search(list(start_nodes), list(end_nodes), shelterPref, stairsPref)

    # if path is none, check if the preferences are too strict and try again with less strict preferences
    if path is None and (shelterPref == 2 or stairsPref == 2):
        if shelterPref == 2:
            shelterPref = 1
        if stairsPref == 2:
            stairsPref = 1
        path = a_star_search(list(start_nodes), list(end_nodes), shelterPref, stairsPref)
    if path is None:
        return Response({'error': 'No path found'}, status=status.HTTP_404_NOT_FOUND)
    if len(path) == 0:
        return Response({'error': 'You are in the building'}, status=status.HTTP_404_NOT_FOUND)

    edgeSerializer = EdgeSerializer(path, many=True)
    return Response({'edges': edgeSerializer.data,
                     'shelterPref': shelterPref,
                     'stairsPref': stairsPref})


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
    
    try:
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
        return Response({'destinations': destSerializer.data})
    
    finally:
        current_dest.delete()


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
        current_node.delete()
        return Response({'error': f'Destination {end} not found'}, status=status.HTTP_404_NOT_FOUND)
    
    try:
        #create edge from current location to top 3 nearest nodes on the same floor
        nearest_nodes = nearby_nodes(current_node, 3)
        temp_edges = []
        for node in nearest_nodes:
            distance = haversine(current_node, node)
            edge = Edge(type='temp_edge', start=current_node, end=node, sheltered=True, stairs=False, weight=round(distance), unit='metres', duration=0.0)
            edge.save()
            temp_edges.append(edge)
            AdjacencyList.objects.create(node=current_node, adjacent_node=node, edge=edge)

        end_nodes = end_dest.nodes.all()
        shelterPref = int(request.GET.get('shelterPref')) 
        stairsPref = int(request.GET.get('stairsPref')) 

        # run a star algorithm
        path = a_star_search([current_node], list(end_nodes), shelterPref, stairsPref)
        if path is None and (shelterPref == 2 or stairsPref == 2):
            if shelterPref == 2:
                shelterPref = 1
            if stairsPref == 2:
                stairsPref = 1
            path = a_star_search([current_node], list(end_nodes), shelterPref, stairsPref)
        if path is None:
            return Response({'error': 'No path found'}, status=status.HTTP_404_NOT_FOUND)
        if len(path) == 0:
            return Response({'error': 'You are in the building'}, status=status.HTTP_404_NOT_FOUND)
        
        edgeSerializer = EdgeSerializer(path, many=True)
        return Response({'edges': edgeSerializer.data,
                        'shelterPref': shelterPref,
                        'stairsPref': stairsPref})
    
    finally:
        #delete current location node and temp edges
        current_node.delete()
        for edge in temp_edges:
            edge.delete()


@api_view(['GET'])  
def heartbeat(request):
    Destination.objects.count()
    return Response({'status': 'ok'})

@api_view(['GET'])
def get_near_rooms(request):
    lat = float(request.GET.get('lat'))
    lng = float(request.GET.get('lng'))
    count = int(request.GET.get('count'))
    day = request.GET.get('day')
    start_time = request.GET.get('start')
    end_time = request.GET.get('end')

    current_location = Classroom(name='current_location', lat=lat, lng=lng, floor=1)
    current_location.save()
    
    try:
        # find nearby classrooms using Classroom model
        nearby_classrooms = [] 
        for classroom in Classroom.objects.all():
            current_location_db = Classroom.objects.get(name=classroom.name)
            distance = haversine(classroom, current_location_db)
            nearby_classrooms.append((classroom, distance))
        nearby_classrooms.sort(key=lambda x: x[1])
        nearby_classrooms = [classroom[0] for classroom in nearby_classrooms]

        # get occupancy info using RoomOccupancy model
        available_classrooms = get_occupancy_info(nearby_classrooms, count, day, start_time, end_time)
        return Response({'rooms': available_classrooms})
    finally:
        current_location.delete()

@api_view(['POST'])
def update_edge_aggregate(request):
    data = request.data
    # Body: [
    #   {
    # 	name: String (name of node/ start)
    # 	timestamp: double (seconds from 1 jan 1970)
    #   }
    # ]
    for i in range(len(data) - 1):
        start_node = Node.objects.get(name=data[i]['name'])
        end_node = Node.objects.get(name=data[i + 1]['name'])
        edge = Edge.objects.get(start=start_node, end=end_node)
        agg = EdgeAggregate.objects.get(edge=edge)
        
        if agg.count >=200:
            continue # don't update if we have enough data

        agg.count += 1
        duration = data[i + 1]['timestamp'] - data[i]['timestamp']
        agg.values.append(duration)
        delta = duration - agg.mean 
        agg.mean += delta / agg.count
        delta2 = duration - agg.mean
        agg.M2 += delta * delta2
        agg.save()
        
        if agg.count >= 30: #checking for outliers only after we minimum number of data points have been collected
            dataset = agg.values
            variance = agg.M2 / (agg.count - 1)
            stddev = variance ** 0.5
            clean_data = []
            outliers = []
            for value in dataset:
                if abs(value - agg.mean) <= 3 * stddev:
                    clean_data.append(value)
                else:
                    outliers.append(value)
            if outliers: #recalculate mean and M2 without outliers
                agg.mean = sum(clean_data) / len(clean_data)
                agg.M2 = sum((x - agg.mean) ** 2 for x in clean_data)
            agg.values = clean_data
            agg.count = len(clean_data)
            agg.save()
            #update the duration of the edge in the Edge model
            edge.duration = agg.mean
            edge.save()
