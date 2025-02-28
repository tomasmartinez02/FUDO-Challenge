FROM ruby:3.0

WORKDIR /app

ENV RACK_ENV=development

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-p", "3000"]

