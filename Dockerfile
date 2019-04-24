FROM drecom/ubuntu-ruby:2.3.3

ENV LANG C.UTF-8
# 指定時區，否則會用 GMT
ENV TZ Asia/Taipei
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update -qq && apt-get install -y build-essential imagemagick libmagickwand-dev qt5-default libqt5webkit5-dev nodejs redis-server xvfb mysql-client

ENV APP_HOME /home/app/rails-app
RUN mkdir APP_HOME
COPY . APP_HOME
WORKDIR APP_HOME
RUN bundle install

# 設定 Server Port
EXPOSE 80

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0", "-p", "80"]