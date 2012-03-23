[Spreedly Core](http://addons.heroku.com/spreedlycore) is an [add-on](http://addons.heroku.com) for connecting to a Software-as-a-Service billing solution that serves two major functions for companies and developers.

* First, it removes your [PCI Compliance](https://www.pcisecuritystandards.org/) requirement by pushing the card data handling and storage outside of your application. This is possible by having your customers POST their credit card info to the Spreedly Core service while embedding a transparent redirect URL back to your application (see "Submit payment form" on [the quick start guide](https://spreedlycore.com/manual/quickstart)). 
* Second, it removes any possibility of your gateway locking you in by owning your customer billing data (yes, this happens). By allowing you to charge any card against whatever gateways you as a company have signed up for, you retain all of your customer data and can switch between gateways as you please. Also, expanding internationally won't require an additional technical integration with yet another gateway.

Spreedly Core is accessible via an API and has supported client libraries for Ruby.

## Installing the add-on

Spreedly Core can be installed to a Heroku application via the CLI:

    :::term
    $ heroku addons:add spreedlycore:tester
    -----> Adding spreedlycore to glowing-bull-311... done, v18 (free)

Once Spreedly Core has been added your API login and secret will be available in the app configuration. These items will be used when making requests against the Spreedly Core API. Check to make sure the addon was successfully installed by running `heroku config`.

    :::term
    $ heroku config | grep SPREEDLYCORE
    SPREEDLYCORE_API_LOGIN    => 82ZwP1y9A1DCJJj2lkXxQZHM9Sy
    SPREEDLYCORE_API_SECRET   => fIOChbqqsHvBHEa3KPNIFtx2gBs8iyne14D4EP8sg4Y49Eedtuo9QJ5xgAg1ngIa

After installing Spreedly Core the application should be configured to fully integrate with the add-on.

## Using with Rails 3.x

### Add spreedly-core-ruby to Gemfile

Ruby on Rails applications will need to add the following entry into their `Gemfile` specifying the Spreedly Core client library.

    :::ruby
    gem 'spreedly-core-ruby'

Update application dependencies with bundler.

    :::term
    $ bundle install

### Add an initializer to configure

Create an initializer at `config/initializers/spreedly.rb`

    :::ruby
    # config/initializers/spreedly.rb
    SpreedlyCore.configure

### Deploy changes

Deploy the updated Gemfile to Heroku:

    :::term
    $ git add .
    $ git commit -m "Added initializer and spreedly-core-ruby to bundle"
    $ git push heroku master
    …
    -----> Heroku receiving push
    -----> Launching... done, v3
           http://glowing-bull-311.herokuapp.com deployed to Heroku

    To git@heroku.com:glowing-bull-311.git
     * [new branch]      master -> master

## Quickstart

### Create a test gateway

Drop into console and create a test gateway to run test transactions against

    :::term
    $ heroku run console
    Running console attached to terminal... up, run.1

    tg = SpreedlyCore::TestGateway.get_or_create
    tg.use!
    puts "Test gateway token is #{tg.token}"

### Modify payment form to point to spreedlycore.com

After a test gateway is created, payment forms must be created or modified to post the credit card data directly to Spreedly Core. Spreedly Core will receive your customer's credit card data, and immediately transfer them back to the location you define inside the web payments form. The user won't know that they're being taken offsite to record to the card data, and you as the developer will be left with a token identifier. The token identifier is used to make your charges against, and to access the customer's non-sensitive billing information.

    :::html
    <form action="https://spreedlycore.com/v1/payment_methods" method="POST">
        <fieldset>
            <input name="redirect_url" type="hidden" value="http://example.com/transparent_redirect_complete" />
            <input name="api_login" type="hidden" value="<%= ENV['SPREEDLYCORE_API_LOGIN'] %>" />
            <label for="credit_card_first_name">First name</label>
            <input id="credit_card_first_name" name="credit_card[first_name]" type="text" />
    
            <label for="credit_card_last_name">Last name</label>
            <input id="credit_card_last_name" name="credit_card[last_name]" type="text" />
    
            <label for="credit_card_number">Card Number</label>
            <input id="credit_card_number" name="credit_card[number]" type="text" />
    
            <label for="credit_card_verification_value">Security Code</label>
            <input id="credit_card_verification_value" name="credit_card[verification_value]" type="text" />
    
            <label for="credit_card_month">Expires on</label>
            <input id="credit_card_month" name="credit_card[month]" type="text" />
            <input id="credit_card_year" name="credit_card[year]" type="text" />
    
            <button type='submit'>Submit Payment</button>
        </fieldset>
    </form>

Take special note of the **api_login** and **redirect_url** params hidden in the form, as Spreedly Core will use both of these fields to authenticate the developer's account and to send the customer back to the right location in your app.

#### A note about test card data

Users of the `free` tier of the addon will only be permitted to deal with test credit card data. Furthermore, Spreedly Core as a service will outright reject any card data that doesn't correspond to the 8 numbers listed below.

DO NOT USE REAL CREDIT CARD DATA UNTIL YOUR APPLICATION IS LIVE.

* **Visa**
    * Good Card - 4111111111111111
    * Failed Card - 4012888888881881
* **MasterCard**
    * Good Card - 5555555555554444
    * Failed Card - 5105105105105100
* **American Express**
    * Good Card - 378282246310005
    * Failed Card - 371449635398431
* **Discover**
    * Failed Card - 6011111111111117
    * Failed Card - 6011000990139424

### Submit a test card as a payment method

Load your payment form and use one of the test credit cards above to submit a payment method to Spreedly Core. The payment details will be recorded, and you will be transferred back to your application with an additional URL param corresponding to the newly-created payment method's token.

### Run a test purchase against the test payment method

    :::ruby
    payment_token = 'abc123' # extracted from the URL params
    payment_method = SpreedlyCore::PaymentMethod.find(payment_token)
    if payment_method.valid?
      purchase_transaction = payment_method.purchase(550)
      purchase_transaction.succeeded? # true
    else
      flash[:notice] = "Woops!\n" + payment_method.errors.join("\n")
    end

One final point to take note of is that Spreedly Core does no validation of the information passed in by the customer. We simply return them back to your application, and it's up to you to check for any errors in the payment method before charging against it.

## Usage overview

Make a purchase against a payment method

    :::ruby
    purchase_transaction = payment_method.purchase(1245)
    
Retain a payment method for future use

    :::ruby
    redact_transaction = payment_method.retain
    
Redact a previously retained payment method:

    :::ruby
    redact_transaction = payment_method.redact

Make an authorize request against a payment method, then capture the payment

    :::ruby
    authorize = payment_method.authorize(100)
    authorize.succeeded? # true
    capture = authorize.capture(50) # Capture only half of the authorized amount
    capture.succeeded? # true

    authorize = payment_method.authorize(100)
    authorize.succeeded? # true
    authorized.capture # Capture the full amount
    capture.succeeded? # true
    
Void a previous purchase:

    :::ruby
    purchase_transaction.void # void the purchase

Credit (refund) a previous purchase:

    :::ruby
    purchase_transaction = payment_method.purchase(100) # make a purchase
    purchase_transaction.credit
    purchase_transaction.succeeded? # true 

Credit part of a previous purchase:

    :::ruby
    purchase_transaction = payment_method.purchase(100) # make a purchase
    purchase_transaction.credit(50) # provide a partial credit
    purchase_transaction.succeeded? # true 

## Creating and using a real gateway

When you're ready for primetime, you'll need to complete a couple more steps to start processing real transactions.

1. First, you'll need to get your business (or personal) payment details on file with Spreedly Core so that we can collect transaction and card retention fees.
2. Second, you'll need to acquire a gateway that you can plug into the back of Spreedly Core. Any of the major players will work, and you're not at risk of lock-in because Spreedly Core happily plays middle man. Please consult our [list of supported gateways](https://www.spreedlycore.com/manual/gateways) to see exactly what information you'll need to pass to Spreedly Core when creating your gateway profile.

For this example, an Authorize.net account that only has a login and password credential will be used. First, changed the Spreedly Core addon to the paid tier.

    :::term
    $ heroku addons:upgrade spreedlycore:paid

Then, drop into a heroku console to create your production gateway
    
    :::ruby
    gateway = SpreedlyCore::Gateway.create(:login => 'my_authorize_login', :password => 'my_authorize_password', :gateway_type => 'authorize_net')    
    puts "Authorize.net gateway token is #{gateway.token}"
    
For most users, you will start off using only one gateway token, and as such can configure it as an environment variable to hold your gateway token. In addition to the previous environment variables, the `SpreedlyCore.configure` method will also look for a SPREEDLYCORE_GATEWAY_TOKEN environment value.

    :::term
    $ heroku config:add SPREEDLYCORE_GATEWAY_TOKEN=gateway_token_from_previous_step
    
The Spreely Core API provides validation of the credit card number, security code, and first and last name. In most cases this is enough; however, sometimes you or your gateway may require the full billing information as well. You can modify your initializer to require additional fields.

    :::ruby
    # config/initializers/spreedly.rb
    SpreedlyCore.configure
    SpreedlyCore::PaymentMethod.additional_required_cc_fields :address1, :city, :state, :zip

## Using multiple gateways

For those using multiple gateway tokens, there is a class variable that holds the active gateway token. Before running any sort of transaction against a payment method, you'll need to set the gateway token that you wish to charge against.

    :::ruby
    SpreedlyCore.configure

    :::ruby    
    SpreedlyCore.gateway_token(paypal_gateway_token)
    SpreedlyCore::PaymentMethod.find(pm_token).purchase(550)
    
    :::ruby
    SpreedlyCore.gateway_token(authorize_gateway_token)
    SpreedlyCore::PaymentMethod.find(pm_token).purchase(2885)
    
    :::ruby
    SpreedlyCore.gateway_token(braintree_gateway_token)
    SpreedlyCore::PaymentMethod.find(pm_token).credit(150)

## Support

All Spreedly Core support and runtime issues should be logged with Heroku Support at https://support.heroku.com. Any non-support related issues or product feedback is welcome at [support@spreedlycore.com](mailto:support@spreedly.com).

## Full documentation

Full documentation is available via the Spreedly Core website:

* [Site docs](https://spreedlycore.com/manual)