#----------------------------------#
# Ancor Cruz <hello@ancorcruz.com> #
#----------------------------------#

#require 'rubygems'
#require 'debugger'

class Product
  attr_accessor :code, :name, :price

  def initialize(code, name, price)
    @code, @name, @price = code, name, price
  end
end

class Offer
  attr_accessor :product
end

class BuyAndGetFreeOffer < Offer
  def initialize(product, buy = 1, get_free = 1)
    @product, @buy, @get_free = product, buy, get_free
  end

  def price_for(quantity)
    pack = @buy + @get_free
    (quantity / pack + quantity % pack) * @product.price
  end
end

class BulkSpecialPriceOffer < Offer
  def initialize(product, buy_or_more, at)
    @product, @buy_or_more, @at = product, buy_or_more, at
  end

  def price_for(quantity)
    unit_price = quantity >= @buy_or_more ? @at : @product.price
    quantity * unit_price
  end
end

class Checkout
  def initialize(pricing_rules)
    @pricing_rules = pricing_rules
    @basket = Hash.new(0)
  end

  def scan(product)
    @basket[product] += 1
  end

  def total_price
    @basket.inject(0) do |total, (product, quantity)|
      total + find_best_deal(product, quantity)
    end
  end

  private

  def find_best_deal(product, quantity = 1)
    prices = @pricing_rules.map { |r| r.price_for(quantity) if r.product == product }
    prices << product.price * quantity
    prices.compact.min
  end
end

if __FILE__ == $0
  require 'test/unit'

  class CheckoutTest < Test::Unit::TestCase
    def setup
      @fr = Product.new('FR1', 'Fruit tea', 3.11)
      @sr = Product.new('SR1', 'Strawberries', 5.00)
      @cf = Product.new('CF1', 'Coffee', 11.23)
    end

    def total_price(goods = [])
      co = Checkout.new(@pricing_rules)
      goods.each { |item| co.scan(item) }
      co.total_price
    end

    def test_prices_without_offers
      @pricing_rules = []
      assert_equal  0.00, total_price([])
      assert_equal 22.45, total_price([@fr, @sr, @fr, @cf])
      assert_equal  6.22, total_price([@fr, @fr])
      assert_equal 18.11, total_price([@sr, @sr, @fr, @sr])
    end

    def test_total_price_with_offers
      @pricing_rules = [BuyAndGetFreeOffer.new(@fr), BulkSpecialPriceOffer.new(@sr, 3, 4.50)]
      assert_equal  0.00, total_price([])
      assert_equal 19.34, total_price([@fr, @sr, @fr, @cf])
      assert_equal  3.11, total_price([@fr, @fr])
      assert_equal 16.61, total_price([@sr, @sr, @fr, @sr])
    end
  end
end
