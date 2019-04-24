FROM staticfloat/nginx-certbot

ENV LANG C.UTF-8
# 指定時區，否則會用 GMT
ENV TZ Asia/Taipei
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone


ENV APP_HOME /home/app/rails-app

WORKDIR APP_HOME

# create log directory
RUN mkdir log

# copy over static assets
COPY public public/

COPY nginx/sso.local.conf /etc/nginx/conf.d/nginx.conf