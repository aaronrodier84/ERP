require 'test_helper'

class ZoneWorkflowTest < ActiveSupport::TestCase

  before do
    Zone.destroy_all
    @make_zone, @pack_zone, @ship_zone = [1,2,3].map { |production_order| create :zone, production_order: production_order }
  end

  let(:subject) { described_class.new }

  describe '#next_zone' do
    it 'gets next zone' do
      assert_equal @ship_zone, subject.next_zone(@pack_zone)
      assert_equal @pack_zone, subject.next_zone(@make_zone)
    end

    describe 'when passed only limited subset of zones' do
      let(:subject) { described_class.new([@make_zone, @pack_zone]) }

      it "operates within it's borders" do
        assert_nil subject.next_zone(@pack_zone) 
      end
    end

    it 'is nil if zone is already last one in workflow' do
      assert_nil subject.next_zone(@ship_zone)
    end
  end

  describe '#previous_zone' do
    it 'gets previous zone' do
      assert_equal @make_zone, subject.previous_zone(@pack_zone)
      assert_equal @pack_zone, subject.previous_zone(@ship_zone)
    end

    it 'is nil of zone is already first on in workflow' do
      assert_nil subject.previous_zone(@make_zone)
    end

    describe 'when passed only limited subset of zones' do
      let(:subject) { described_class.new([@pack_zone, @ship_zone]) }

      it "operates within it's borders" do
        assert_nil subject.previous_zone(@pack_zone) 
      end
    end
  end
end
