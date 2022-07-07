FROM ruby:3.1

EXPOSE 4567

WORKDIR /workspace

# Install Stripe CLI for webhooks
RUN curl https://packages.stripe.dev/api/security/keypair/stripe-cli-gpg/public | apt-key add - &&\
  echo "deb https://packages.stripe.dev/stripe-cli-debian-local stable main" | tee -a /etc/apt/sources.list &&\
  apt update && apt install stripe

COPY Gemfile* /workspace/
RUN ["bundle", "install"]

COPY . /workspace/

CMD ["foreman", "start"]