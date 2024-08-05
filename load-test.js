import http from 'k6/http';
import { sleep, check } from 'k6';

export let options = {
    vus: 100,
    duration: "10m",
};

export default function () {
    let res = http.get('http://localhost:8000/lectures/');
    check(res, {
        'status is 200': (r) => r.status === 200,
    });
    sleep(0.1);
}

