FROM ruby:2.3.1
# Set the base directory used in any further RUN, COPY, and ENTRYPOINT
# commands.
RUN mkdir -p /app
WORKDIR /app

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

# Copy dependencies into the container
COPY Gemfile /app
COPY Gemfile.lock /app
RUN bundle install

# Set the Rails environment to staging
ENV RAILS_ENV staging

# Copy the main application into the container
COPY . /app

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
