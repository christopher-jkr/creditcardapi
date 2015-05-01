require_relative '../model/credit_card'
require_relative '../lib/substitution_cipher'
require_relative '../lib/double_trans_cipher'
require_relative '../lib/aes_cipher'
require 'minitest/autorun'

describe 'Test card info encryption' do
  before do
    @cc = CreditCard.new('4916603231464963', 'Mar-30-2020', 'Soumya Ray',
                         'Visa')
    @key = 3
  end

  describe 'Using Caesar cipher' do
    it 'should encrypt card information' do
      enc = SubstitutionCipher::Caesar.encrypt(@cc, @key)
      enc.wont_equal @cc.to_s
    end

    it 'should decrypt text' do
      enc = SubstitutionCipher::Caesar.encrypt(@cc, @key)
      dec = SubstitutionCipher::Caesar.decrypt(enc, @key)
      dec.must_equal @cc.to_s
    end
  end

  describe 'Using Permutation cipher' do
    it 'should encrypt card information' do
      enc = SubstitutionCipher::Permutation.encrypt(@cc, @key)
      enc.wont_equal @cc.to_s
    end

    it 'should decrypt text' do
      enc = SubstitutionCipher::Permutation.encrypt(@cc, @key)
      dec = SubstitutionCipher::Permutation.decrypt(enc, @key)
      dec.must_equal @cc.to_s
    end
  end

  methods = [
    ['Double Transposition Cipher', DoubleTranspositionCipher],
    ['AES Cipher', AesCipher]
  ]
  methods.each do |name, meth|
    describe "Using #{name} cipher" do
      it 'should encrypt card information' do
        enc = meth.encrypt(@cc, @key)
        enc.wont_equal @cc.to_s
      end

      it 'should decrypt card information' do
        enc = meth.encrypt(@cc, @key)
        dec = meth.decrypt(enc, @key)
        dec.must_equal @cc.to_s
      end
    end
  end
end
