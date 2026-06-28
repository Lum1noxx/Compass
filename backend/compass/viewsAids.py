from datetime import datetime
import math
import heapq
from .models import *
from .serializers import *


def haversine(node1, node2):
    R = 6371.0 # Earth radius in kilometers
    
    phi1 = math.radians(float(node1.lat))
    phi2 = math.radians(float(node2.lat))
    d_phi = math.radians(float(node2.lat) - float(node1.lat))
    d_lambda = math.radians(float(node2.lng) - float(node1.lng))

    a = math.sin(d_phi / 2)**2 + math.cos(phi1) * math.cos(phi2) * math.sin(d_lambda / 2)**2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    
    return R * c * 1000

def a_star_search(start_nodes, end_nodes, sheltered, stairs):
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

    try:
        # create temporary edges and adjacency rows from the super start to all start nodes
        for node in start_nodes:
            edge = Edge(type='super_edge', start=super_start, end=node, sheltered=True, stairs=False, weight=0.0, unit='metres', duration=0.0)
            edge.save()
            AdjacencyList.objects.create(node=super_start, adjacent_node=node, edge=edge)

        # a star initialization
        open_set = [(0, super_start.pk, super_start)]
        came_from = {}
        g_score = {super_start: 0}
        f_score = {super_start: haversine(super_start, super_end)}
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
                # check stair and sheltered requirements
                if sheltered == True and neighbor.edge.sheltered == False:
                    continue
                if stairs == False and neighbor.edge.stairs == True:
                    continue

                # check if the edge is to wait for bus and if so, get the wait time
                if neighbor.edge.type == "waitForBus": 
                    wait_time = bus_wait_time(neighbor.edge)
                    if wait_time is not None:
                        neighbor.edge.duration = wait_time
                    else:
                        continue

                tentative_g_score = g_score[current] + neighbor.edge.duration
                if neighbor.adjacent_node not in g_score or tentative_g_score < g_score[neighbor.adjacent_node]:
                    came_from[neighbor.adjacent_node] = (current, neighbor.edge)
                    g_score[neighbor.adjacent_node] = tentative_g_score
                    f_score[neighbor.adjacent_node] = tentative_g_score + haversine(neighbor.adjacent_node, super_end)
                    if neighbor.adjacent_node not in open_set_hash:
                        heapq.heappush(open_set, (f_score[neighbor.adjacent_node], neighbor.adjacent_node.pk, neighbor.adjacent_node))
                        open_set_hash.add(neighbor.adjacent_node)

        return None
    finally:
        super_start.delete()

# bus wait time generator, replacing an API call to ISB bus service, using the static bus schedule
def bus_wait_time(edge):
    if edge.duration == 0.0:
        return 0.0
    dest = edge.end.name.split('_')
    bus = dest[-1]
    bus_name = bus[1:-1]
    schedule = BusSchedule.objects.filter(bus=bus_name)
    
    #check current day of the week and filter schedule accordingly
    now = datetime.now()
    dotw = now.strftime('%A')
    if dotw in ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']:
        schedule = schedule.filter(day='Weekday')
    else:
        schedule = schedule.filter(day=dotw)
    
    #each entry in schedule has a start and end time, check if current time is within any of the entries
    current_time = now.time()
    for entry in schedule:
        if entry.from_time <= current_time <= entry.to_time:
            return entry.waitAve * 60 # convert to seconds
    return 10000 # placeholder for when bus is not running, should be a large number to discourage bus edges

# # check if edge is bus edge and if so, check if it is valid, ie no bus hopping
# def isValidBus (edge):
#     start = edge.start.name.split('_')
#     end = edge.end.name.split('_')
#     return start[-1] == end[-1]


# return k=count nearest nodes to current location
def nearby_nodes(current, count):
    nearby_nodes = []
    for node in Node.objects.filter(floor=current.floor):
        if node.name == 'current_location':
            continue
        current_node_db = Node.objects.get(name='current_location')
        distance = haversine(current_node_db, node)
        nearby_nodes.append((node, distance))
    nearby_nodes.sort(key=lambda x: x[1])
    nearby_nodes = [node[0] for node in nearby_nodes[:count]]
    return nearby_nodes