FROM ruby:3.0

WORKDIR /app

ENV RACK_ENV=development

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

RUN mkdir -p db

EXPOSE 3000

CMD ["sh", "-c", "bundle exec ruby config/database.rb && bundle exec puma -p 3000"]

