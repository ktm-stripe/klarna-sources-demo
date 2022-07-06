var stripe = Stripe('pk_test_51Jjri3AM0pItg6BcHgEbakaBIa0b1sY5rkT0YEchu6gN93KBD935AgGuZmnsEIGvDMgyWurM9neFdoecmfzsg5I100pMGneOU7');

function checkout() {
  var params = serializeForm('checkout_form');

  clearErrors();

  post('/create_source', params, function (result) {
    var result = JSON.parse(this.response)

    if (this.status != 200) {
      renderError(result.error)
    } else {
      window.location.href = result.redirect.url
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
