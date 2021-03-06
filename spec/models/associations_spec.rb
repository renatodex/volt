require 'spec_helper'

class ::Person < Volt::Model
  has_many :addresses
end

class ::Address < Volt::Model
  belongs_to :person
end

describe Volt::Associations do
  if RUBY_PLATFORM != 'opal'
    before do
      store._people! << { name: 'Jimmy' }
      @person = store._people[0]
      @person._addresses! << { city: 'Bozeman' }
      @person._addresses << { city: 'Portland' }
    end

    it 'should associate via belongs_to' do
      address = store._addresses!.fetch_first.sync

      expect(address.person.sync._id).to eq(@person._id)
    end

    it 'should associate via has_many' do
      person = store._people!.fetch_first.sync

      addresses = person.addresses.fetch.sync
      expect(addresses.size).to eq(2)
      expect(addresses[0]._city).to eq('Bozeman')
    end

    it 'warns users if persistor is not a ModelStore' do
      store = Volt::Model.new({}, persistor: Volt::Persistors::Flash)
      expect do
        store.send(:association_with_root_model, :blah)
      end.to raise_error("blah currently only works on the store collection "\
                         "(support for other collections coming soon)")
    end
  end
end
