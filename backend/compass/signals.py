from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import *

# Signals is to auto trigger changes in db when certain actions are done

# When new edge is created, create new Adjacencylist entry
@receiver(post_save, sender=Edge)
def create_log_on_edge_creation(sender, instance, created, **kwargs):
    if created:
        AdjacencyList.objects.create(
            node=instance.start,
            adjacent_node=instance.end,
            edge=instance
        )