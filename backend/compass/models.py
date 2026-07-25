from django.db import models

class Node(models.Model):
    name = models.CharField(max_length=100)
    lat = models.DecimalField(max_digits=17, decimal_places=10, default=0.0)
    lng = models.DecimalField(max_digits=17, decimal_places=10, default=0.0)
    floor = models.IntegerField(default=0)

    def __str__ (self):
        return self.name
    
class Destination(models.Model):
    name = models.CharField(max_length=100)
    lat = models.DecimalField(max_digits=17, decimal_places=10, default=0.0)
    lng = models.DecimalField(max_digits=17, decimal_places=10, default=0.0)
    floor = models.IntegerField(default=0)
    nodes = models.ManyToManyField(Node, blank=True)

    def __str__ (self):
        return self.name

class Edge(models.Model):
    type = models.CharField(max_length=100)
    start = models.ForeignKey(Node, on_delete=models.CASCADE, related_name='edges_start')
    end = models.ForeignKey(Node, on_delete=models.CASCADE, related_name='edges_end')
    sheltered = models.BooleanField(default=False)
    stairs = models.BooleanField(default=False)
    weight = models.FloatField(default=1.0)
    unit = models.CharField(max_length=20, default='metres', choices=[('metres', 'metres'), ('steps', 'steps'), ('seconds', 'seconds')])
    duration = models.FloatField(default=0.0)
    bus = models.CharField(max_length=10, blank=True, null=True)

    def __str__ (self):
        return f"From {self.start} to {self.end} by {self.type}"
    
    def calculate_duration(self):
        if self.unit == 'metres':
            distance = self.weight
            return distance * 0.75
        elif self.unit == 'steps':
            steps = self.weight
            return steps * 0.75
        elif self.unit == 'seconds':
            return self.weight
        else:
            return 0.0
    
    def save(self, *args, **kwargs):
        self.duration = self.calculate_duration()
        if self.type == 'bus':
            bus = self.start.name.split('_')[-1]
            self.bus = bus[1:-1]
        if self.type == 'waitForBus' and self.duration != 0.0:
            bus = self.end.name.split('_')[-1]
            self.bus = bus[1:-1]
        super().save(*args, **kwargs)

class AdjacencyList(models.Model):
    node = models.ForeignKey(Node, on_delete=models.CASCADE, related_name='adjacency_node')
    adjacent_node = models.ForeignKey(Node, on_delete=models.CASCADE, related_name='adjacent_node')
    edge = models.ForeignKey(Edge, on_delete=models.CASCADE)

    def __str__ (self):
        return f"{self.node} is adjacent to {self.adjacent_node} by {self.edge}"
    
class BusSchedule(models.Model):
    bus = models.CharField(max_length=10)
    day = models.CharField(max_length=10, choices=[('Weekday', 'Weekday'), ('Saturday', 'Saturday'), ('Sunday', 'Sunday')])
    from_time = models.TimeField()
    to_time = models.TimeField()
    waitAve = models.FloatField(default=0.0)

    def __str__ (self):
        return f"Bus {self.bus} on {self.day} from {self.from_time} to {self.to_time}"

class Classroom(models.Model):
    name = models.CharField(max_length=100)
    lat = models.DecimalField(max_digits=17, decimal_places=10, default=0.0)
    lng = models.DecimalField(max_digits=17, decimal_places=10, default=0.0)
    floor = models.IntegerField(default=0)

    def __str__ (self):
        return self.name
    
class RoomOccupancy(models.Model):
    name = models.CharField(max_length=100)
    day = models.CharField(max_length=10, choices=[('Monday', 'Monday'), ('Tuesday', 'Tuesday'), ('Wednesday', 'Wednesday'), ('Thursday', 'Thursday'), ('Friday', 'Friday'), ('Saturday', 'Saturday'), ('Sunday', 'Sunday')])
    from_time = models.TimeField()
    to_time = models.TimeField()

    def __str__ (self):
        return f"{self.name} on {self.day} from {self.from_time} to {self.to_time}"

class EdgeAggregate(models.Model):
    edge = models.OneToOneField(Edge, on_delete=models.CASCADE, related_name='aggregate')
    count = models.IntegerField(default=0)
    mean = models.FloatField(default=0.0)
    M2 = models.FloatField(default=0.0)
    values = models.JSONField(default=list)