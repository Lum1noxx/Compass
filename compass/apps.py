from django.apps import AppConfig


#this is to implement signals into the db
class CompassConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'compass'

    def ready(self):
        import compass.signals