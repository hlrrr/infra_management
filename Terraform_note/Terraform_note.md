- terraform init

- terraform plan -out= 파일명
- terraform plan -detailed-exitcode \
이 옵션은 변경 사항이 있을 때만 종료 코드를 2로 반환하여 자동화된 스크립트에서 활용

- terraform apply 파일명
- terraform apply -auto-approve\
변경사항 자동 수락, 적용

- terraform destroy -auto-approve
