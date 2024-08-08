import random

from django.core.cache import cache
from django.db import transaction
from rest_framework.pagination import PageNumberPagination
from rest_framework.response import Response
from rest_framework.views import APIView

from lectures.models import Lecture, Person
from lectures.serializers import LectureSerializer


class LectureView(APIView):
    def get(self, request, *args, **kwargs):
        paginator = PageNumberPagination()
        lectures = paginator.paginate_queryset(self._filter(), request)
        serializer = LectureSerializer(lectures, many=True)
        return paginator.get_paginated_response(serializer.data)

    def _filter(self):
        queryset = Lecture.objects.all()
        if department_code := self.request.query_params.get("department"):
            queryset = queryset.filter(professor__department__code=department_code)
        
        return queryset


class LectureDetailView(APIView):
    def get(self, request, *args, **kwargs):
        cache_key = f"lecture:{kwargs['lecture_id']}"
        lecture_data = cache.get(cache_key)

        if not lecture_data:
            lecture_data = self.get_lecture_data(kwargs["lecture_id"])
            if lecture_data:
                cache.set(cache_key, lecture_data, timeout=2)
            else:
                return Response({"message": "존재하지 않는 강의입니다."}, status=400)

        return Response(lecture_data, status=200)

    def get_lecture_data(self, lecture_id):
        try:
            lecture = (
                Lecture.objects
                .select_related('professor', 'professor__department')
                .prefetch_related('students')
                .get(id=lecture_id)
            )
            serializer = LectureSerializer(lecture, many=False)
            return serializer.data
        except Lecture.DoesNotExist:
            return None


class LectureRegisterView(APIView):
    @transaction.atomic
    def post(self, *args, **kwargs):
        student_id = self.request.data.get("student_id")
        lecture_id = self.request.data.get("lecture_id")

        student = Person.objects.get(id=student_id)
        lecture = Lecture.objects.get(id=lecture_id)

        if lecture.register_limit < lecture.students.count():
            return Response({"message": "수강 신청이 마감된 강의입니다."}, status=400)

        if student.total_credit + lecture.credit > 24:
            return Response({"message": "24학점 이상 수강할 수 없습니다."}, status=400)

        count = student.lecture_set.exclude(professor__department__code=student.department.code).count()
        if count == 2:
            return Response({"message": "다른 학과의 강의는 두 개까지 수강할 수 있습니다."}, status=400)

        if lecture.students.filter(id=student_id).exists():
            return Response({"message": "이미 수강 신청을 한 과목입니다."}, status=400)

        lecture.students.add(student)
        lecture.save()

        student.total_credit += lecture.credit
        student.save()

        return Response({"message": "수강 신청에 성공했습니다."}, status=204)


class RandomLectureRegisterView(APIView):
    def post(self, *args, **kwargs):
        students = list(Person.objects.all())
        lectures = list(Lecture.objects.all())

        random.shuffle(lectures)

        lecture_capacity = {lecture.id: lecture.register_limit for lecture in lectures}

        with transaction.atomic():
            for student in students:
                num_lectures = random.randint(4, 8)

                available_lectures = [lecture for lecture in lectures if lecture_capacity[lecture.id] > 0]

                if not available_lectures:
                    continue

                selected_lectures = random.sample(available_lectures, min(num_lectures, len(available_lectures)))

                for lecture in selected_lectures:
                    lecture.students.add(student)
                    lecture_capacity[lecture.id] -= 1
                    student.total_credit += 3

                student.save()

                for lecture in selected_lectures:
                    lecture.save()

        return Response({"message": "수강 신청에 성공했습니다."}, status=204)