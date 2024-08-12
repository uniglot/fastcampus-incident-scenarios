import http from 'k6/http';
import { sleep, check } from 'k6';
import { randomIntBetween } from 'https://jslib.k6.io/k6-utils/1.1.0/index.js';

export let options = {
    vus: 50,
    duration: "10m",
};

export default function () {
    let lectureId = randomIntBetween(1, 100);
    let res = http.get(`http://k8s-default-fastcamp-527ad3a8da-1621931149.ap-northeast-2.elb.amazonaws.com/lectures/${lectureId}/`);
    check(res, {
        'status is 200': (r) => r.status === 200,
    });
    sleep(0.1);
}

