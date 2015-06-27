### FOR ALL THESE OPERATIONS, YOU NEED TO USE YOUR TOKEN
* Pass it in the HTTP_AUTHORIZATION header as 'Bearer [token]'
  * Replace "[token]" with your token obtained from the [Client App](https://o-captain-my-captain.herokuapp.com/)

### Right now, you can do the following:
* Validate credit card numbers with:
  * GET /api/v1/credit_card/validate?number=[your card number]
* View all your saved credit cards with:
  * GET /api/v1/credit_card/user_id=RQST/
* Save a credit card with:
  * POST /api/v1/credit_card/ with these parameters in a JSON Object:
    1. number
    1. expiration_date
    1. credit_network
    1. owner
