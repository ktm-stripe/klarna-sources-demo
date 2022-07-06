FROM ruby:3.1

EXPOSE 4567

WORKDIR /workspace

COPY Gemfile* /workspace/
RUN ["bundle", "install"]

COPY . /workspace/

CMD ["foreman", "start"]