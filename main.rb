# frozen_string_literal: true

require 'json'
require 'pp'
require 'sinatra/reloader'
Dotenv.load

Stripe.api_key = ENV['STRIPE_API_KEY']

class KlarnaSourcesDemo < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    erb :index
  end

  get '/complete' do
    @source = Stripe::Source.retrieve(params[:source])
    erb :complete
  end

  post '/auth' do
    data = JSON.parse(request.body.read)

    Stripe::Charge.create(
      source: data['source_id'],
      amount: data['auth_amount'],
      capture: false,
      currency: 'usd',
    ).to_json

  rescue Stripe::InvalidRequestError => e
    status e.http_status
    body e.json_body.to_json
  end

  get '/charge/:charge_id' do
    @charge = Stripe::Charge.retrieve(params[:charge_id])
    erb :charge
  end

  post '/charge/:charge_id/capture' do
    data = JSON.parse(request.body.read)

    Stripe::Charge.capture(
      params[:charge_id],
      amount: data["capture_amount"]
    ).to_json
  rescue Stripe::InvalidRequestError => e
    status e.http_status
    body e.json_body.to_json
  end

  post '/webhook' do
    data = JSON.parse(request.body.read)

    puts "🕸🪝 Webhook: #{data['type']}"
    p data

    status 200
    body ''
  end

  protected

  def h(html)
    CGI.escapeHTML html
  end

  def as_pretty_json(obj)
    [
      "<pre>",
      JSON.pretty_generate(obj.instance_variable_get("@original_values")),
      "</pre>"
  ].join("\n")
  end

end