from rest_framework import serializers

from lectures.models import Department, Lecture, Professor


class DepartmentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Department
        fields = ["name", "code", "category"]


class ProfessorSerializer(serializers.ModelSerializer):
    department = DepartmentSerializer()

    class Meta:
        model = Professor
        fields = ["name", "email", "department"]


class LectureSerializer(serializers.ModelSerializer):
    professor = ProfessorSerializer()
    register_count = serializers.SerializerMethodField()

    class Meta:
        model = Lecture
        fields = ["name", "code", "professor", "credit", "register_limit", "register_count"]

    def get_register_count(self, obj):
        return obj.students.count()