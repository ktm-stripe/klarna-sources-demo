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


  post '/create_source' do
    data = JSON.parse(request.body.read)

    source = Stripe::Source.create({
      type: 'klarna',
      amount: 1599,
      currency: 'usd',
      klarna: {
        product: 'payment',
        purchase_country: 'US',
        first_name: data['first_name'],
        last_name: data['last_name'],
      },
      owner: {
        email: data['email'],
        address: {
          line1: data['line1'],
          line2: data['line2'],
          city: data['city'],
          state: data['state'],
          postal_code: data['postal_code'],
          country: data['country'],
        }
      },
      flow: 'redirect',
      redirect: {
        return_url: 'http://localhost:4567/complete',
      },
      source_order: {
        items: [{
          type: 'sku',
          description: 'Grey cotton T-shirt',
          quantity: 2,
          currency: 'usd',
          amount: 1499,
        }, {
          type: 'tax',
          description: 'Taxes',
          currency: 'usd',
          amount: 100,
        }, {
          type: 'shipping',
          description: 'Free Shipping',
          currency: 'usd',
          amount: 0,
        }],
      },
    }).to_json

  rescue Stripe::InvalidRequestError => e
    status e.http_status
    body e.json_body.to_json
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