from django.apps import AppConfig


class VasasUserprofileConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "vasas_userprofile"
# from django.apps import AppConfig

# class VasasAuthConfig(AppConfig):
#     name = 'vasas_auth'

#     def ready(self):
#         import vasas_auth.signals
