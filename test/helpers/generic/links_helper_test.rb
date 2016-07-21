require 'test_helper'

class LinksHelperTest < ActionView::TestCase
  include Generic::LinksHelper

  describe 'link_or_text' do
    let(:product) { create :product, id: 111 }

    describe "when no block is given" do
      it 'returns text if not admin' do
        assert_equal "Super Oil", link_or_text(product, false, "Super Oil")
      end

      it 'returns a link if admin' do
        assert_equal '<a href="/products/111">Super Oil</a>', link_or_text(product, true, "Super Oil")
      end
    end

    describe "when block is given" do
      it 'yields block if not admin' do
        assert_equal "Block content", link_or_text(product, false){"Block content"}
      end

      it 'returns a link with a block if admin' do
        assert_equal '<a href="/products/111">Block content</a>', link_or_text(product, true){"Block content"}
      end
    end
  end

end
