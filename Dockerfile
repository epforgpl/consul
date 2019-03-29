# Use Ruby 2.4.4 as base image
FROM ruby:2.4.4
# TODO do we want alpine as well?

ENV DEBIAN_FRONTEND noninteractive

# Install essential Linux packages
RUN apt-get update -qq
RUN apt-get install -y build-essential libpq-dev postgresql-client nodejs imagemagick sudo libxss1 libappindicator1 libindicator7 unzip memcached
RUN rm -rf /var/lib/apt/lists/*
RUN apt-get clean -y

RUN echo 'Defaults secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/bundle/bin"' > /etc/sudoers.d/secure_path
RUN chmod 0440 /etc/sudoers.d/secure_path

# Define where our application will live inside the image
ENV RAILS_ROOT /var/www/consul

# Set our working directory inside the image
WORKDIR $RAILS_ROOT

# Create application home. App server will need the pids dir so just create everything in one shot
# TODO keep it? RUN mkdir -p $RAILS_ROOT/tmp/pids

# Use the Gemfiles as Docker cache markers. Always bundle before copying app src.
# (the src likely changed and we don't want to invalidate Docker's cache too early)
# http://ilikestuffblog.com/2014/01/06/how-to-skip-bundle-install-when-deploying-a-rails-app-to-docker/
COPY Gemfile* ./

# Prevent bundler warnings; ensure that the bundler version executed is >= that which created Gemfile.lock
RUN gem install bundler -v '~>1.17'

# Finish establishing our Ruby environment
RUN bash -c 'if [[ "$RAILS_ENV" == "production" ]]; then bundle install --without development test; else bundle install; fi'

# TODO this should be installed only for testing and should not land in the final image, make multiple stages docker like in monitorizarevot
# Install Chromium and ChromeDriver for E2E integration tests
# RUN apt-get update -qq && apt-get install -y chromium
# RUN wget -N http://chromedriver.storage.googleapis.com/2.38/chromedriver_linux64.zip
# RUN unzip chromedriver_linux64.zip
# RUN chmod +x chromedriver
# RUN mv -f chromedriver /usr/local/share/chromedriver
# RUN ln -s /usr/local/share/chromedriver /usr/local/bin/chromedriver
# RUN ln -s /usr/local/share/chromedriver /usr/bin/chromedriver

# Copy the Rails application into place
COPY . .

COPY scripts/* /usr/local/bin/

# Define the script we want run once the container boots
# Use the "exec" form of CMD so our script shuts down gracefully on SIGTERM (i.e. `docker stop`)
ENTRYPOINT []
CMD ["/usr/local/bin/start.sh"]
EXPOSE 3000

