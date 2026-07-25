from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import *

# Signals is to auto trigger changes in db when certain actions are done

# When new edge is created, create new Adjacencylist and EdgeAggregate entries
@receiver(post_save, sender=Edge)
def create_log_on_edge_creation(sender, instance, created, **kwargs):
    if created:
        AdjacencyList.objects.create(
            node=instance.start,
            adjacent_node=instance.end,
            edge=instance
        )
        EdgeAggregate.objects.create(
            edge=instance,
            count=0,
            mean=0.0,
            M2=0.0,
            values=[]
        )
