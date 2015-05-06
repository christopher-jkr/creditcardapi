require_relative './spec_helper'
cards = YAML.load_file 'spec/test_numbers.yml'

describe 'Credit Card API tests' do
  describe 'Getting service root' do
    it 'should return right' do
      get '/'
      last_response.body.must_include 'is running at'
      last_response.status.must_equal 200
    end
  end

  cards.each do |name, numbers|
    describe "Test luhn validator on #{name} cards" do
      numbers['valid'].each do |number|
        it 'should return true' do
          get "api/v1/credit_card/validate?card_number=#{number}"
          last_response.status.must_equal 200
          results = JSON.parse(last_response.body)
          results['validated'].must_equal true
        end
      end
    end

    describe "Test luhn validator on #{name} cards" do
      numbers['invalid'].each do |number|
        it 'should return false' do
          get "api/v1/credit_card/validate?card_number=#{number}"
          last_response.status.must_equal 200
          results = JSON.parse(last_response.body)
          results['validated'].must_equal false
        end
      end
    end
  end

  describe 'Insert records' do
    cards.each do |name, numbers|
      before do
        CreditCard.delete_all
      end

      describe "Inserting valid #{name} records" do
        numbers['valid'].each do |number|
          it 'should get in' do
            req_header = { 'CONTENT_TYPE' => 'application/json' }
            req_body = { expiration_date: '2017-04-19', owner: 'Cheng-Yu Hsu',
                         number: "#{number}", credit_network: "#{name}" }
            post '/api/v1/credit_card', req_body.to_json, req_header
            last_response.status.must_equal 201
          end
        end
      end

      describe "Rejecting invalid #{name} records" do
        numbers['invalid'].each do |number|
          it 'should get in' do
            req_header = { 'CONTENT_TYPE' => 'application/json' }
            req_body = { expiration_date: '2017-04-19', owner: 'Cheng-Yu Hsu',
                         number: "#{number}", credit_network: "#{name}" }
            post '/api/v1/credit_card', req_body.to_json, req_header
            last_response.status.must_equal 400
          end
        end
      end
    end
  end

  describe 'Retrieving all records' do
    before do
      CreditCard.delete_all
    end

    list = []
    it 'should get in' do
      cards.each do |name, numbers|
        numbers['valid'].each do |number|
          list.push(number)
          req_header = { 'CONTENT_TYPE' => 'application/json' }
          req_body = { expiration_date: '2017-04-19', owner: 'Cheng-Yu Hsu',
                       number: "#{number}", credit_network: "#{name}" }
          post '/api/v1/credit_card', req_body.to_json, req_header
        end
      end
      get '/api/v1/credit_card/all'
      last_response.status.must_equal 200
      result = last_response.body.gsub('}', '}  ').split('  ')
      result.length.must_equal 20
      result.each do |res|
        list.must_include JSON.parse(res)['number']
      end
    end
  end
end
