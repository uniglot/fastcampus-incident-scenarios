# Fast Campus - 실전 장애 케이스 8가지 실습과 보고서 작성

> [!CAUTION]
> 본 프로젝트의 시스템 구성에는 교육 목적을 위한 의도적인 결함이 존재합니다.
> This project presents a system with deliberate flaws for educational purposes.

## 준비 사항

1. AWS 액세스 키와 시크릿 키를 발급받아 안전하게 보관하세요.
2. `secrets.tfvars` 라는 이름의 파일을 `infrastructure` 디렉토리 안에 생성하세요.
3. 해당 파일에 아래와 같이 채워 주세요.
    ```
    aws_access_key = "YOURAWSACCESSKEY"
    aws_secret_key = "YOURAWSSECRETACCESSKEY"
    ```
4. 터미널에서 `infrastructure` 디렉토리로 이동한 뒤 `terraform init`을 입력하세요.

## 테라폼 플래닝 및 인프라 적용

- 테라폼 코드를 플래닝하여 인프라가 어떻게 생성될지 보려면, `terraform plan -var-file=secrets.tfvars` 커맨드를 `infrastructure` 디렉토리에서 실행하세요.
- 실제로 테라폼 코드를 적용하여 인프라를 생성 또는 수정하고자 한다면, `terraform apply -var-file=secrets.tfvars` 커맨드를 `infrastructure` 디렉토리에서 실행하세요.
  - 약 20분 내외 소요됩니다.

## EKS 클러스터 접속

1. AWS CLI, `kubectl`, `helm`, `k9s`를 설치하세요.
2. `aws configure --profile fastcampus` 커맨드를 실행하여 AWS 액세스 키와 시크릿 키를 AWS CLI에서 사용하도록 설정하세요.
3. 터미널에서 `aws eks --region ap-northeast-2 update-kubeconfig --name fastcampus-infra-cluster --profile fastcampus`를 실행하여 `kubectl`을 통해 생성한 클러스터에 접근할 수 있도록 합니다.
4. 터미널에서 `kubectl config use-context arn:aws:eks:ap-northeast-2:1234567890:cluster/fastcampus-infra-cluster`을 실행해서 현재 쿠버네티스 컨텍스트를 생성한 클러스터를 바라보게 합니다. (`1234567890`을 본인의 계정 ID로 바꿔주세요.)
5. `kubectl get pods -n kube-system` 커맨드를 실행해 파드들이 정상적으로 출력되는지 확인해 주세요.

## 인프라 제거

1. 쿠버네티스 클러스터에 설치된 모든 자원을 제거하기 위해서, `helm uninstall fastcampus-prod` 커맨드를 입력해 주세요.
2. 프로비저닝된 모든 인프라를 제거하기 위해서, 터미널에서 `terraform destroy -var-file=secrets.tfvars` 커맨드를 입력해 주세요.
  - 약 10분 내외 소요됩니다.
3. RDS 콘솔에서 스냅샷과 PITR로 생성된 데이터베이스 인스턴스를 수동으로 삭제해 주세요.
4. RDS 콘솔 > Snapshots > Manual 에서 RDS 스냅샷을 삭제해 주세요.
5. 로컬 `kubectl` 설정 파일을 정리하기 위해서, 아래의 커맨드를 입력해 주세요.
  - `kubectl config delete-context arn:aws:eks:ap-northeast-2:1234567890:cluster/fastcampus-infra-cluster` (`1234567890`을 본인의 계정 ID로 바꿔주세요.)
  - `kubectl config delete-cluster arn:aws:eks:ap-northeast-2:1234567890:cluster/fastcampus-infra-cluster`
  - `kubectl config delete-user arn:aws:eks:ap-northeast-2:1234567890:cluster/fastcampus-infra-cluster`

## 문제 해결

### VPC가 마지막에 다음과 같이 정확하게 삭제되지 않는 경우가 있습니다.

실습 도중 테라폼으로 보안그룹이 추적되지 않은 경우가 발생했을 때 이런 현상이 발생할 수 있습니다.

![problem-vpc-terraform](https://assets.uniglot.dev/images/problem-vpc-terraform.png)

이럴 때는 콘솔에서 VPC를 아래와 같이 수동으로 삭제해 주시면 됩니다.

![problem-vpc-console](https://assets.uniglot.dev/images/problem-vpc-console.png)

### 테라폼 제거 과정에서 Helm 관련하여 에러가 뜨면서 제거가 되지 않습니다.

아래와 같이 쿠버네티스 서비스 어카운트나 헬름 관련으로 테라폼 에러가 발생하는 경우가 있습니다.

![problem-eks-terraform](https://assets.uniglot.dev/images/problem-eks-terraform.png)

이 경우 테라폼 관리 대상에서 쿠버네티스와 헬름을 제거하면 됩니다. 테라폼으로 쿠버네티스나 헬름 자원을 제거하지 않더라도 쿠버네티스 클러스터가 제거되면서 자연스럽게 함께 제거됩니다.

- `infrastructure/eks.tf`에서 `resource "kubernetes_service_account"`와 `resource "helm_release"`로 되어 있는 블럭을 모두 주석으로 처리해 주세요.
- 주석으로 처리한 리소스 타입과 이름을 참조해서 아래와 같이 모든 자원의 상태를 제거해 주세요.
  ```bash
  terraform state rm kubernetes_service_account.lb_controller_sa
  terraform state rm helm_release.aws_load_balancer_controller
  ```
- 그 다음 다시 `terraform destroy -var-file=secrets.tfvars`를 입력해 주세요.