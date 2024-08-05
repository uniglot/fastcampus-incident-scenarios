DELETE FROM lectures_lecture_students
WHERE person_id IN (1, 2, 3, 4, 5)
OR lecture_id IN (
    SELECT id FROM lectures_lecture 
    WHERE professor_id IN (
        SELECT id FROM lectures_professor 
        WHERE department_id IN (
            SELECT id FROM lectures_department 
            WHERE name = '컴퓨터공학과'
        )
    )
);