from django.db import models

class Node(models.Model):
    name = models.CharField(max_length=40)
    lat = models.DecimalField(max_digits=9, decimal_places=6, default=0.0)
    lng = models.DecimalField(max_digits=9, decimal_places=6, default=0.0)
    floor = models.IntegerField(default=0)

    def __str__ (self):
        return self.name
    
class Destination(models.Model):
    name = models.CharField(max_length=40)
    lat = models.DecimalField(max_digits=9, decimal_places=6, default=0.0)
    lng = models.DecimalField(max_digits=9, decimal_places=6, default=0.0)
    floor = models.IntegerField(default=0)
    nodes = models.ManyToManyField(Node, blank=True)

    def __str__ (self):
        return self.name

class Edge(models.Model):
    type = models.CharField(max_length=40)
    start = models.ForeignKey(Node, on_delete=models.CASCADE, related_name='edges_start')
    end = models.ForeignKey(Node, on_delete=models.CASCADE, related_name='edges_end')
    sheltered = models.BooleanField(default=False)
    stairs = models.BooleanField(default=False)
    weight = models.FloatField(default=1.0)
    unit = models.CharField(max_length=20, default='metres', choices=[('metres', 'metres'), ('steps', 'steps'), ('seconds', 'seconds')])
    duration = models.FloatField()

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
        super().save(*args, **kwargs)

