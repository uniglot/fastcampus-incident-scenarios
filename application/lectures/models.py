from django.db import models


class Department(models.Model):
    name = models.CharField(max_length=32)
    code = models.CharField(max_length=2)
    category = models.CharField(max_length=10)

    def __str__(self):
        return self.name


class Person(models.Model):
    name = models.CharField(max_length=32)
    department = models.ForeignKey(Department, on_delete=models.CASCADE)
    total_credit = models.IntegerField(default=0)

    def __str__(self):
        return self.name


class Professor(models.Model):
    name = models.CharField(max_length=32)
    email = models.EmailField()
    department = models.ForeignKey(Department, on_delete=models.CASCADE)

    def __str__(self):
        return f"{self.name}/{self.email}"

class Lecture(models.Model):
    name = models.CharField(max_length=32)
    code = models.CharField(max_length=5)
    professor = models.ForeignKey(Professor, on_delete=models.CASCADE)
    credit = models.IntegerField(default=3)
    register_limit = models.IntegerField()
    students = models.ManyToManyField(Person)

    def __str__(self):
        return f"[{self.code}] {self.name} - {self.professor}"