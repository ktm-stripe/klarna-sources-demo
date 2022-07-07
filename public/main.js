var stripe = Stripe('ADD_YOUR_STRIPE_PUBLISHABLE_KEY');

function checkout() {
  var params = serializeForm('checkout_form');

  clearErrors();

  var sourceParams = {
    type: 'klarna',
    amount: 105_00,
    currency: 'usd',
    klarna: {
      product: 'payment',
      purchase_country: 'US',
      first_name: params.first_name,
      last_name: params.last_name,
    },
    owner: {
      email: params.email,
      address: {
        line1: params.line1,
        line2: params.line2,
        city: params.city,
        state: params.state,
        postal_code: params.postal_code,
        country: params.country,
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
        amount: 100_00,
      }, {
        type: 'tax',
        description: 'Taxes',
        currency: 'usd',
        amount: 5_00,
      }, {
        type: 'shipping',
        description: 'Free Shipping',
        currency: 'usd',
        amount: 0,
      }]
    }
  };

  stripe.createSource(sourceParams).then(function (result) {
    if (result.error) {
      renderError(result.error)
    } else {
      window.location.href = result.source.redirect.url
    }
  });
}

function auth() {
  var params = serializeForm('auth_form');

  clearErrors();

  post('/auth', params, function (result) {
    var result = JSON.parse(this.response)

    if (this.status != 200) {
      renderError(result.error)
    } else {
      window.location.href = '/charge/' + result.id
    }
  });
}

// Capture a Charge
function capture() {
  var params = serializeForm('capture_form');

  clearErrors();

  post('/charge/' + params.charge_id + '/capture', params, function (result) {
    var result = JSON.parse(this.response)

    if (this.status != 200) {
      renderError(result.error)
    } else {
      window.location.href = '/charge/' + result.id
    }
  });
}

function post(url, data, callback) {
  var xhr = new XMLHttpRequest();
  xhr.open("POST", url, true);
  xhr.setRequestHeader('Content-Type', 'application/json');
  xhr.onload = callback
  return xhr.send(JSON.stringify(data));
}

function serializeForm(formName) {
  const formData = new FormData(document.getElementById(formName))
  var params = {}
  for (var pair of formData.entries()) {
    params[pair[0]] = pair[1]
  }

  return params
}

function clearErrors() {
  var error_divs = document.getElementsByClassName('error')

  for (let i = 0; i < error_divs.length; i++) {
    error_divs[i].innerText = '';
  }
}

function renderError(error) {
  if (error.param) {
    var elem_name = error.param.match(/(\w+)\]?$/)[1];
    var elem = document.getElementById(elem_name + '_error');
    if (elem) {
      elem.innerText = error.message;
    } else {
      alert(error.message)
    }
  } else {
    alert(error.message)
  }
}
