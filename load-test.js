import http from 'k6/http';
import { sleep, check } from 'k6';
import { randomIntBetween } from 'https://jslib.k6.io/k6-utils/1.1.0/index.js';

export let options = {
    vus: 100,
    duration: "10m",
};

export default function () {
    let lectureId = randomIntBetween(1, 100);
    let res = http.get(`http://localhost:8000/lectures/${lectureId}/`);
    check(res, {
        'status is 200': (r) => r.status === 200,
    });
    sleep(0.1);
}

