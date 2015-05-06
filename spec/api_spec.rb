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

  describe 'Inserting records' do
  end

  describe 'Retrieving all records' do
  end
end
