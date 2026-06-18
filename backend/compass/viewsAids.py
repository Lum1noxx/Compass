import math
import heapq
from .models import *


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
                if sheltered == True and neighbor.edge.sheltered == False:
                    continue
                if stairs == False and neighbor.edge.stairs == True:
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