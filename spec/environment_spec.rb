require_relative "../my_strategy/environment"

describe Environment do
  let(:instance) { described_class.new }

  describe '#nearest_my_hockeyists_to_unit' do
    subject { instance.nearest_my_hockeyists_to_unit(unit) }
    let(:unit) { double(:unit) }
    let(:h1) { double(:h1) }
    let(:h2) { double(:h2) }
    let(:h3) { double(:h3) }
    let(:my_player) { double(:my_player) }
    before :each do
      allow(instance).to receive(:my_player).and_return(my_player)
      allow(my_player).to receive(:id).and_return("id")
      allow(instance).to receive(:player_hockeyists).with("id").and_return([h1, h2, h3])
      allow(h1).to receive(:get_distance_to_unit).with(unit).and_return(3)
      allow(h2).to receive(:get_distance_to_unit).with(unit).and_return(2)
      allow(h3).to receive(:get_distance_to_unit).with(unit).and_return(1)
    end
    it 'returns an array of hockeyists sorted by distance to unit' do
      expect(subject).to eq [h3, h2, h1]
    end
  end

end
