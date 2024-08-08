# Auto Scaling Groups – Scaling Policies
- Dynamic Scaling
  - Target Tracking Scaling
    - Simple to set-up\
      Example: I want the average ASG CPU to stay at around 40%

- Simple / Step Scaling
  - When a CloudWatch alarm is triggered (example CPU > 70%), then add 2 units
  - When a CloudWatch alarm is triggered (example CPU < 30%), then remove 1

- Scheduled Scaling
  - Anticipate a scaling based on known usage patterns\
    Example: increase the min capacity to 10 at 5 pm on Fridays
---
# Amazon S3 – Moving between Storage Classes
![image](https://github.com/user-attachments/assets/09ec3621-92b3-4c29-8e62-b26c896d2bae)
