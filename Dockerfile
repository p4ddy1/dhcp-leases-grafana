FROM ruby:3.0

WORKDIR /app
COPY . .

RUN bundle install

EXPOSE 8000

CMD ["ruby", "/app/main.rb"]
