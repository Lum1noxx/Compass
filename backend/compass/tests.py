from django.test import TestCase, Client
from .models import *
from .serializers import *
from datetime import datetime, time

# class BaseTestCase(TestCase):
#     def setUp(self):
#         # Set up any necessary test data or configurations here
#         pass

#     def tearDown(self):
#         # Clean up after tests if necessary
#         pass

#     def test1(self):
#         self.assertTrue(1==1)

#     def test2(self):
#         try:
#             print("Hello, World!")
#             raise Exception("This is a test exception")
#         except Exception as e:
#             self.fail(f"Test failed with exception: {e}")

# Testing validity of models and their attributes
class TestModels(TestCase):
    # Set up test data for models
    def setUp(self):
        self.node = Node.objects.create(name="Test Node", lat=1.0, lng=1.0, floor=1)
        self.dest = Destination.objects.create(name="Test Destination", lat=1.0, lng=1.0, floor=1)
        self.dest.nodes.add(self.node)
        self.node2 = Node.objects.create(name="Test Node 2", lat=2.0, lng=2.0, floor=1)
        self.edge = Edge.objects.create(type="Test Edge", start=self.node, end=self.node2, sheltered=True, stairs=False, weight=10.0, unit='metres', duration=0.0)
    
    # Test the creation of a Node instance
    def test_node_creation(self):
        # check if created and retrieved correctly
        self.assertTrue(Node.objects.filter(name="Test Node").exists())
        self.assertTrue(isinstance(self.node, Node))
        self.assertEqual(self.node, Node.objects.get(name="Test Node"))
        # check correct attributes
        self.assertEqual(self.node.name, "Test Node")
        self.assertEqual(self.node.lat, 1.0)
        self.assertEqual(self.node.lng, 1.0)
        self.assertEqual(self.node.floor, 1)
        # check string representation
        self.assertEqual(str(self.node), "Test Node")
        print(f"Test for Node creation and correct attributes passed")

    def test_destination_creation(self):
        self.assertTrue(Destination.objects.filter(name="Test Destination").exists())
        self.assertTrue(isinstance(self.dest, Destination))
        self.assertEqual(self.dest, Destination.objects.get(name="Test Destination"))

        self.assertEqual(self.dest.name, "Test Destination")
        self.assertEqual(self.dest.lat, 1.0)
        self.assertEqual(self.dest.lng, 1.0)
        self.assertEqual(self.dest.floor, 1)
        self.assertEqual(self.dest.nodes.first(), self.node)

        self.assertEqual(str(self.dest), "Test Destination")
        print(f"Test for Destination creation and correct attributes passed")

    def test_edge_creation(self):
        
        self.assertTrue(Edge.objects.filter(type="Test Edge").exists())
        self.assertTrue(isinstance(self.edge, Edge))
        self.assertEqual(self.edge, Edge.objects.get(type="Test Edge"))

        self.assertEqual(self.edge.type, "Test Edge")
        self.assertEqual(self.edge.start, self.node)
        self.assertEqual(self.edge.end, self.node2)
        self.assertEqual(self.edge.sheltered, True)
        self.assertEqual(self.edge.stairs, False)
        self.assertEqual(self.edge.weight, 10.0)
        self.assertEqual(self.edge.unit, 'metres')
        self.assertEqual(str(self.edge), f"From {self.node} to {self.node2} by Test Edge")
        print(f"Test for Edge creation and correct attributes passed")
        # check if duration is calculated correctly upon creation of edge
        self.assertEqual(self.edge.duration, 7.5)
        print(f"Test for Edge duration conversion calculation passed")
    
    def test_adjacency_list_creation(self):
        adjacency = AdjacencyList.objects.get(node=self.node, adjacent_node=self.node2)
        self.assertTrue(AdjacencyList.objects.filter(node=self.node, adjacent_node=self.node2).exists())
        self.assertTrue(isinstance(adjacency, AdjacencyList))
        self.assertEqual(adjacency, AdjacencyList.objects.get(node=self.node, adjacent_node=self.node2))

        self.assertEqual(adjacency.node, self.node)
        self.assertEqual(adjacency.adjacent_node, self.node2)
        self.assertEqual(adjacency.edge, self.edge)

        self.assertEqual(str(adjacency), f"{self.node} is adjacent to {self.node2} by {self.edge}")
        print(f"Test for automatic AdjacencyList creation and correct attributes passed")

    def test_serializer_node(self):
        serializer = NodeSerializer(self.node)
        data = serializer.data
        self.assertEqual(data['name'], "Test Node")
        self.assertEqual(float(data['lat']), 1.0)
        self.assertEqual(float(data['lng']), 1.0)
        self.assertEqual(data['floor'], 1)
        print(f"Test for NodeSerializer passed")
    
    def test_serializer_destination(self):
        serializer = DestSerializer(self.dest)
        data = serializer.data
        self.assertEqual(data['name'], "Test Destination")
        self.assertEqual(float(data['lat']), 1.0)
        self.assertEqual(float(data['lng']), 1.0)
        self.assertEqual(data['floor'], 1)
        print(f"Test for DestinationSerializer passed")
    
    def test_serializer_edge(self):
        serializer = EdgeSerializer(self.edge)
        data = serializer.data
        self.assertEqual(data['type'], "Test Edge")
        self.assertEqual(data['start'], 'Test Node')
        self.assertEqual(data['end'], 'Test Node 2')
        self.assertEqual(data['sheltered'], True)
        self.assertEqual(data['stairs'], False)
        self.assertEqual(float(data['duration']), 7.5)
        print(f"Test for EdgeSerializer passed")

# Testing BusSchedule model and its attributes       
class TestBusScheduleModel(TestCase):
    def setUp(self):
        self.bus_schedule = BusSchedule.objects.create(
            bus="Bus 1",
            day="Weekday",
            from_time="08:00:00",
            to_time="10:00:00",
            waitAve=5.0
        )

    def test_bus_schedule_creation(self):
        self.assertTrue(BusSchedule.objects.filter(bus="Bus 1").exists())
        self.assertTrue(isinstance(self.bus_schedule, BusSchedule))

        self.assertEqual(self.bus_schedule.bus, "Bus 1")
        self.assertEqual(self.bus_schedule.day, "Weekday")
        self.assertEqual(str(self.bus_schedule.from_time), "08:00:00")
        self.assertEqual(str(self.bus_schedule.to_time), "10:00:00")
        self.assertEqual(self.bus_schedule.waitAve, 5.0)

        self.assertEqual(str(self.bus_schedule), f"Bus {self.bus_schedule.bus} on {self.bus_schedule.day} from {self.bus_schedule.from_time} to {self.bus_schedule.to_time}")
        print(f"Test for BusSchedule creation and correct attributes passed")

    def test_bus_retrieval(self):
        bus_schedule = BusSchedule.objects.get(bus="Bus 1")
        self.assertEqual(bus_schedule, self.bus_schedule)
        inrangetime = time(9, 0, 0)
        self.assertTrue(bus_schedule.from_time <= inrangetime <= bus_schedule.to_time)
        outrangetime = time(11, 0, 0)
        self.assertFalse(bus_schedule.from_time <= outrangetime <= bus_schedule.to_time)
        print(f"Test for BusSchedule retrieval and time range checking passed")

# Tests for views and API endpoints
class TestViews(TestCase):
    def setUp(self):
        self.client = Client()
        self.node1 = Node.objects.create(name="Node 1", lat=1.0, lng=1.0, floor=1)
        self.node2 = Node.objects.create(name="Node 2", lat=2.0, lng=2.0, floor=1)
        self.dest1 = Destination.objects.create(name="Destination 1", lat=1.0, lng=1.0, floor=1)
        self.dest1.nodes.add(self.node1)
        self.dest2 = Destination.objects.create(name="Destination 2", lat=2.0, lng=2.0, floor=1)
        self.dest2.nodes.add(self.node2)
        self.edge = Edge.objects.create(type="Edge Type", start=self.node1, end=self.node2, sheltered=True, stairs=False, weight=10.0, unit='metres', duration=7.5)
        self.bad_edge = Edge.objects.create(type="Edge Type", start=self.node1, end=self.node2, sheltered=False, stairs=True, weight=10.0, unit='metres', duration=7.5)
        self.bad_edge2 = Edge.objects.create(type="Edge Type", start=self.node1, end=self.node2, sheltered=True, stairs=False, weight=15.0, unit='metres', duration=7.5)


    def test_get_dest_coordinates(self):
        response = self.client.get('/dest_coordinates/', {'names': ["Destination 1"]})
        self.assertEqual(response.status_code, 200)
        self.assertIn('lat', response.json()['destinations'][0])
        self.assertIn('lng', response.json()['destinations'][0])
        self.assertAlmostEqual(float(response.json()['destinations'][0]['lat']), 1.0)
        self.assertAlmostEqual(float(response.json()['destinations'][0]['lng']), 1.0)
        print(f"Test for retrieving destination coordinates passed")
    
    def test_get_node_coordinates(self):
        response = self.client.get('/node_coordinates/', {'names': ["Node 1"]})
        self.assertEqual(response.status_code, 200)
        self.assertIn('lat', response.json()['nodes'][0])
        self.assertIn('lng', response.json()['nodes'][0])
        self.assertAlmostEqual(float(response.json()['nodes'][0]['lat']), 1.0)
        self.assertAlmostEqual(float(response.json()['nodes'][0]['lng']), 1.0)
        print(f"Test for retrieving node coordinates passed")
    
    
    def test_get_near_destinations(self):
        response = self.client.get('/near_destinations/', {'lat': 1.5, 'lng': 1.5, 'floor': 1, 'count': 1})
        self.assertEqual(response.status_code, 200)
        self.assertIn('destinations', response.json())
        self.assertTrue(len(response.json()['destinations']) == 1)
        self.assertTrue(response.json()['destinations'][0]['name'] == 'Destination 2')
        
        print(f"Test for retrieving near destinations passed")

    def test_shortest_path(self):
        response = self.client.get('/shortest_path/', {'start': 'Destination 1', 'end': 'Destination 2', 'sheltered': True, 'stairs': False})
        self.assertEqual(response.status_code, 200)
        self.assertIn('edges', response.json())
        self.assertTrue(len(response.json()['edges']) == 1)
        self.assertTrue(response.json()['edges'][0]['start'] == 'Node 1')
        self.assertTrue(response.json()['edges'][0]['end'] == 'Node 2')
        self.assertTrue(response.json()['edges'][0]['sheltered'] == True)
        self.assertTrue(response.json()['edges'][0]['stairs'] == False)
        self.assertTrue(float(response.json()['edges'][0]['duration']) == 7.5)
        print(f"Test for calculating shortest path passed")

    def test_shortest_path_no_path(self):
        # create a destination with no path to the other destination
        dest3 = Destination.objects.create(name="Destination 3", lat=3.0, lng=3.0, floor=1)
        node3 = Node.objects.create(name="Node 3", lat=3.0, lng=3.0, floor=1)
        dest3.nodes.add(node3)
        response = self.client.get('/shortest_path/', {'start': 'Destination 1', 'end': 'Destination 3', 'sheltered': True, 'stairs': False})
        self.assertEqual(response.status_code, 404)
        print(f"Test for calculating shortest path with no available path passed")

    def test_use_current_location(self):
        response = self.client.get('/use_location/', {'lat': 1.0, 'lng': 1.0, 'floor': 1, 'end': 'Destination 2'})
        self.assertEqual(response.status_code, 200)
        self.assertIn('edges', response.json())
        self.assertTrue(len(response.json()['edges']) == 1)
        self.assertTrue(response.json()['edges'][0]['start'] == 'current location')
        self.assertTrue(response.json()['edges'][0]['end'] == 'Node 2')
        print(f"Test for using current location to find shortest path passed")