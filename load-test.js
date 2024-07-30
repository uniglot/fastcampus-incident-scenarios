import http from 'k6/http';
import { sleep, check } from 'k6';

export let options = {
    vus: 500,
    duration: "10m",
};

export default function () {
    let res = http.get('http://k8s-default-fastcamp-527ad3a8da-1607718795.ap-northeast-2.elb.amazonaws.com/lectures/');
    check(res, {
        'status is 200': (r) => r.status === 200,
    });
    sleep(0.1);
}

