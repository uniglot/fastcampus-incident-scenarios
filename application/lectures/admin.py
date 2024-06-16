from django.contrib import admin

from lectures.models import Department, Lecture, Person, Professor


@admin.register(Department)
class DepartmentAdmin(admin.ModelAdmin):
    list_display = ["name", "code", "category"]


@admin.register(Lecture)
class LectureAdmin(admin.ModelAdmin):
    list_display = ["name", "code", "professor", "credit", "register_limit"]


@admin.register(Person)
class Person(admin.ModelAdmin):
    list_display = ["name", "department", "total_credit"]


@admin.register(Professor)
class Professor(admin.ModelAdmin):
    list_display = ["name", "email", "department"]