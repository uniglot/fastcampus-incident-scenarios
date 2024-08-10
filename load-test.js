import http from 'k6/http';
import { sleep, check } from 'k6';

export let options = {
    vus: 10,
    duration: "10m",
};

export default function () {
    let res = http.post('http://localhost:5000/register');
    check(res, {
        'status is 200': (r) => r.status === 200,
    });
    sleep(0.1);
}

