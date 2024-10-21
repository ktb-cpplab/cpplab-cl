# 베이스 이미지로 공식 nginx 이미지를 사용합니다.
FROM nginx:latest

# 컨테이너에서 사용할 포트를 노출합니다.
EXPOSE 80

# nginx를 실행합니다.
CMD ["nginx", "-g", "daemon off;"]