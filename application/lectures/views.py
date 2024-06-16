from django.db import transaction
from rest_framework.response import Response
from rest_framework.views import APIView

from lectures.models import Lecture, Person
from lectures.serializers import LectureSerializer


class LectureView(APIView):
    def get(self, *args, **kwargs):
        lectures = self._filter()
        serializer = LectureSerializer(lectures, many=True)
        return Response(serializer.data)

    def _filter(self):
        queryset = Lecture.objects.all()
        if department_code := self.request.query_params.get("department"):
            queryset = queryset.filter(professor__department__code=department_code)
        return queryset


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
